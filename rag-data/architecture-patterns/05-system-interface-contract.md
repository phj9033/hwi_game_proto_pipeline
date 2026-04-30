---
title: 시스템 인터페이스 계약 패턴
collection: architecture-patterns
axis: D
theory_id: system-interface-contract
keywords: [interface, contract, resource, config, data-flow, single-direction, immutable, signal, dependency-injection]
applies_to: [creation, implementation]
related: [bidirectional-dependency, system-layering]
last_updated: 2026-04-28
---

# 시스템 인터페이스 계약 패턴

> 시스템 간 통신은 *우연*이 아니라 *계약*이어야 한다.
> 데이터 흐름은 단방향, 가변 상태는 한 시스템 소유, 의존은 인터페이스로.

## 핵심 원리

시스템이 다른 시스템과 직접 *내부 상태에 접근*하면:

- 내부 변경 시 의존 시스템 모두 수정 필요
- 테스트 시 전체 시스템 셋업 필요 (격리 불가)
- 새 시스템 추가 시 영향 범위 예측 불가

→ 시스템 간에는 **명시적 계약(인터페이스)** 만 노출.

---

## 패턴 1: Resource/Config 객체 (불변 데이터 전달)

### 문제

난이도 디렉터가 스포너의 동작 파라미터를 *직접 변경*:

```gdscript
# ❌ 안티패턴
class_name DifficultyDirector

func update_for_run_progress(progress: float):
    spawner.spawn_interval_ms = base_interval - (progress * 200)
    spawner.max_active = base_active + int(progress * 2)
    spawner.legendary_chance = base_legendary + (progress * 0.05)
```

문제:
- 디렉터가 스포너 *내부 변수* 를 안다 → 강결합
- 스포너가 같은 변수를 직접도 쓰면 race condition
- 디렉터 테스트 시 스포너도 셋업 필요

### 해결: SpawnConfig (Resource)

```gdscript
# ✅ 계약 객체
class_name SpawnConfig
extends Resource

@export var spawn_interval_ms: int = 700
@export var max_active: int = 6
@export var legendary_chance: float = 0.05
@export var pity_threshold: int = 30

# 검증
func is_valid() -> bool:
    return spawn_interval_ms > 0 and max_active > 0 and \
           legendary_chance >= 0.0 and legendary_chance <= 1.0
```

```gdscript
# 디렉터: SpawnConfig 만 만든다
class_name DifficultyDirector

signal config_updated(config: SpawnConfig)

func update_for_run_progress(progress: float):
    var config = SpawnConfig.new()
    config.spawn_interval_ms = base_interval - int(progress * 200)
    config.max_active = base_active + int(progress * 2)
    config.legendary_chance = base_legendary + (progress * 0.05)
    if config.is_valid():
        config_updated.emit(config)
```

```gdscript
# 스포너: SpawnConfig 를 받는다 (소비자)
class_name ObjectSpawner

var current_config: SpawnConfig

func _ready():
    DifficultyDirector.config_updated.connect(_on_config_updated)

func _on_config_updated(config: SpawnConfig):
    current_config = config
    # 내부 동작에만 사용. 외부 변경 안 받음.
```

### 효과
- 디렉터는 SpawnConfig 만 알면 됨. 스포너 내부 모름.
- 스포너는 SpawnConfig 만 받음. 디렉터 모름.
- 데이터 흐름: 디렉터 → SpawnConfig → 스포너 (단방향)
- 테스트 시 SpawnConfig 직접 만들어서 스포너 단독 검증 가능

---

## 패턴 2: 시그널 기반 이벤트 (구독·발행)

### 문제

미니게임이 점수 변경을 직접 호출:

```gdscript
# ❌ 안티패턴
class_name Minigame

func _on_object_caught(obj):
    Scoring.add_score(obj.value)        # 직접 호출
    HUD.update_score(Scoring.score)     # 직접 호출
    Codex.mark_discovered(obj.id)       # 직접 호출
```

문제:
- 미니게임이 스코어링·HUD·도감 모두 의존 (의존 폭주)
- 새 시스템 (예: 업적) 추가 시 미니게임 코드 수정
- 미니게임 테스트 시 모든 시스템 셋업 필요

### 해결: 시그널 발행

```gdscript
# ✅ 미니게임은 이벤트만 발행
class_name Minigame

signal object_caught(id: int, value: int, rarity: String)

func _on_object_caught(obj):
    object_caught.emit(obj.id, obj.value, obj.rarity)
    # 끝. 누가 듣는지 모름.
```

```gdscript
# 다른 시스템들이 *구독*
class_name Scoring
func _ready():
    Minigame.object_caught.connect(_on_caught)
func _on_caught(id, value, rarity):
    self.score += value

class_name HUD
func _ready():
    Minigame.object_caught.connect(_on_caught)
func _on_caught(id, value, rarity):
    update_combo_display()

class_name Codex
func _ready():
    Minigame.object_caught.connect(_on_caught)
func _on_caught(id, value, rarity):
    mark_discovered(id)
```

### 효과
- 미니게임이 누구도 모름. 발행만.
- 새 시스템 (업적) 추가 시 미니게임 변경 0.
- 의존 방향 정상: Feature/Presentation → Core (시그널 구독).

---

## 패턴 3: 의존성 주입 (Dependency Injection)

### 문제

시스템 내부에서 다른 시스템을 *생성*:

```gdscript
# ❌ 안티패턴
class_name RunManager

var minigame: Minigame

func _ready():
    minigame = Minigame.new()        # 직접 생성
    add_child(minigame)
```

문제:
- 테스트 시 Mock Minigame 으로 교체 불가
- Minigame 의 생성 인자가 변하면 RunManager 도 변경

### 해결: 외부에서 주입

```gdscript
# ✅ 외부에서 받음
class_name RunManager

var minigame: Minigame

func setup(provided_minigame: Minigame):
    minigame = provided_minigame
```

```gdscript
# 메인 또는 컨테이너에서 주입
var run_manager = RunManager.new()
var minigame = Minigame.new()
run_manager.setup(minigame)

# 테스트 시
var mock_minigame = MockMinigame.new()
run_manager.setup(mock_minigame)
```

### 효과
- RunManager 가 Minigame 의 *인터페이스*만 알면 됨
- 테스트 시 Mock 으로 격리
- Minigame 생성 변경이 RunManager 에 영향 없음

---

## 패턴 4: 단방향 데이터 흐름

### 원칙

```
Feature → Core → Foundation
   ↓        ↓        ↓
        Foundation
```

데이터는 항상 위에서 아래로. 아래에서 위로 가야 할 때는 시그널.

### 예시

```
[난이도 디렉터 (Feature)]
   ↓ SpawnConfig 객체 (Resource)
[스포너 (Core)]
   ↓ Spawn 명령
[오브젝트 풀 (Core)]
   ↓ 오브젝트 인스턴스
[화면 표시 (Presentation)]
   ↑ object_caught 시그널 (역방향, 시그널)
[Feature/Presentation 시스템들 모두 구독]
```

### 안티패턴

```
[Foundation: 오브젝트 DB]
   ↑ "스코어링이 필요로 하는 데이터 형식 알아내기" — Feature 의 정보가 위로 흐름
[Feature: 스코어링]
```

→ DB 가 스코어링을 *모르는* 채로, 스코어링이 DB 를 *읽는* 패턴이 정상.

---

## 패턴 5: 읽기 전용 vs 변경 가능 분리

### 원칙

데이터 객체는 명확히 표시:
- **읽기 전용** (Resource, Config): 받아서 변경 못 함
- **변경 가능** (Service, Manager): 명시적 메서드로만 변경

### Resource/Config (불변)

```gdscript
class_name PlayerStats
extends Resource

@export var max_hp: int
@export var move_speed: float
# 외부에서 직접 변경 안 함. 새 인스턴스 만들어서 교체.
```

### Service (변경 가능, 인터페이스로만)

```gdscript
class_name CurrencyManager

var _balance: int = 0   # 외부 직접 접근 금지 (private 약속)

func get_balance() -> int:
    return _balance

func add(amount: int) -> bool:
    if amount <= 0:
        return false
    _balance += amount
    balance_changed.emit(_balance)
    return true

func spend(amount: int) -> bool:
    if amount > _balance:
        return false
    _balance -= amount
    balance_changed.emit(_balance)
    return true
```

→ 외부는 `get_balance()`, `add()`, `spend()` 만 호출. 직접 `_balance += 100` 금지.

---

## SaveableComponent 패턴 (예시)

세이브/로드 시스템이 모든 시스템 알면 결합 폭주. 인터페이스로 해결:

```gdscript
# 인터페이스 (책임 명시)
class_name ISaveable

func save_data() -> Dictionary:
    push_error("Override required")
    return {}

func load_data(data: Dictionary):
    push_error("Override required")
```

```gdscript
# 각 시스템이 직접 구현
class_name InventorySystem
extends ISaveable

var items: Array

func save_data() -> Dictionary:
    return { "items": items }

func load_data(data: Dictionary):
    items = data.get("items", [])
```

```gdscript
# 세이브 매니저는 ISaveable 인터페이스만 안다
class_name SaveManager

var saveables: Array[ISaveable] = []

func register(saveable: ISaveable):
    saveables.append(saveable)

func save():
    var snapshot = {}
    for s in saveables:
        snapshot[s.get_class()] = s.save_data()
    write_to_disk(snapshot)
```

→ 새 시스템 추가 시 SaveManager 변경 0. 새 시스템이 ISaveable 구현 + 등록만.

---

## 안티패턴

### 1. 글로벌 변수 통신
```
GlobalState.score += 100   # 어디서든 변경 가능
```
→ race condition, 디버깅 악몽.

해결: 시스템 소유 + 인터페이스 (`Scoring.add(100)`).

---

### 2. 직접 참조 체인
```
RunManager.minigame.scoring.hud.update()
```
→ 4단계 결합. 한 단계 변경 시 다 깨짐.

해결: 시그널 또는 1단계 인터페이스만.

---

### 3. 가변 객체 공유
```
config = MinigameConfig.new()
spawner.use(config)
director.modify(config)        # 같은 인스턴스 수정 → 스포너에 영향
```
→ 누가 수정했는지 추적 불가.

해결: Resource 는 불변. 변경 시 새 인스턴스 만들어 교체.

---

### 4. 인터페이스 없이 직접 의존
```
class A:
    var b: ConcreteB         # 구체 클래스 의존
```
→ B 변경 시 A 도 변경. 테스트 시 B 의 실제 인스턴스 필요.

해결: 인터페이스 또는 base class 의존. DI 로 주입.

---

### 5. 양방향 가변 상태
```
A.state ↔ B.state            # 둘 다 서로 변경
```
→ 일관성 깨짐. 무한 루프 가능.

해결: 한쪽이 owner, 다른 쪽은 reader. 변경은 시그널로.

---

## 검증 체크리스트

각 시스템 GDD 의 인터페이스 섹션에:

- [ ] 입력 인터페이스 명시 (어떤 데이터/시그널을 받는가)
- [ ] 출력 인터페이스 명시 (어떤 데이터/시그널을 내보내는가)
- [ ] 데이터 흐름 단방향 (변경 가능 객체는 한 쪽만 소유)
- [ ] Resource/Config 객체는 불변 (변경 시 새 인스턴스)
- [ ] 다른 시스템과 *시그널* 또는 *인터페이스 객체* 로만 통신
- [ ] 직접 참조 체인 2단계 이내
- [ ] 글로벌 가변 상태 없음
