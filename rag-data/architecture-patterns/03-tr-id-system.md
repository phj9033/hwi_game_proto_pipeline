---
title: TR-ID 시스템 (Stable Requirement ID)
collection: architecture-patterns
axis: E
theory_id: tr-id-system
keywords: [TR-ID, requirement-id, traceability, stable-identifier, registry, gdd-to-story, gdd-to-adr]
applies_to: [creation, evaluation, implementation]
related: [adr-template, control-manifest]
last_updated: 2026-04-28
---

# TR-ID 시스템 (Stable Requirement ID)

> GDD 본문은 변하지만 ID 는 변하지 않는다.
> ADR·스토리·테스트가 GDD 텍스트가 아닌 *ID 로* 참조하면 GDD 변경에 강건해진다.

## 왜 필요한가

GDD 의 한 요구사항을 ADR 또는 스토리에서 인용해야 할 때:

**ID 없이 (취약)**:
```
ADR-005:
  GDD Requirements Addressed:
    - "캐릭터는 정지에서 최고속도까지 100ms 안에 도달한다" (movement-system.md, 3.1 절)
```

→ GDD 가 수정되어 텍스트가 바뀌면 인용이 stale. 절 번호도 바뀜.

**ID 로 (강건)**:
```
ADR-005:
  GDD Requirements Addressed:
    - TR-MOV-001: 캐릭터 이동 가속 명세
```

→ GDD 텍스트가 어떻게 바뀌든 TR-MOV-001 은 동일 요구사항을 가리킴.

---

## TR-ID 형식

```
TR-<SYSTEM>-<NUMBER>
```

- `TR` : Technical Requirement (고정 prefix)
- `<SYSTEM>` : 시스템 약어 (3~5자, UPPER_CASE)
- `<NUMBER>` : 3자리 숫자, 0-padded

### 시스템 약어 표 (예시)

| 시스템 | 약어 |
|--------|------|
| 이동 (Movement) | MOV |
| 입력 (Input) | INPUT |
| 카메라 (Camera) | CAM |
| 미니게임 (Minigame) | MINI |
| 스코어링 (Scoring) | SCORE |
| 난이도 (Difficulty) | DIFF |
| 스폰 (Spawner) | SPAWN |
| 인벤토리 (Inventory) | INV |
| 세이브 (Save) | SAVE |
| HUD | HUD |
| 메뉴 (Menu) | MENU |

### 예시

```
TR-MOV-001  → 이동 시스템의 1번 요구사항
TR-MINI-007 → 미니게임 시스템의 7번 요구사항
TR-INPUT-003 → 입력 시스템의 3번 요구사항
```

---

## TR Registry (등록부)

모든 TR-ID 는 중앙 registry 에 정의된다.

### 위치
```
docs/architecture/tr-registry.yaml
```

### 형식

```yaml
# tr-registry.yaml
# 모든 TR-ID 의 단일 진실 소스. 추가만 가능, 재번호·삭제 금지.

version: "1.0"
last_updated: 2026-04-28

requirements:
  - id: TR-MOV-001
    title: 캐릭터 이동 가속 명세
    description: 정지에서 최고속도 도달 시간 100ms (6 frames @ 60fps)
    source_gdd: design/gdd/movement-system.md
    section: 4 Formulas
    status: active
    created: 2026-03-15

  - id: TR-MOV-002
    title: 카메라 따라가기 lag
    description: 캐릭터 이동 시 카메라 lag 200ms (smooth follow)
    source_gdd: design/gdd/movement-system.md
    section: Game Feel 명세
    status: active
    created: 2026-03-15

  - id: TR-MINI-001
    title: 미니게임 동시 활성 오브젝트 수
    description: max_active_objects 기본 6, 안전 범위 [3, 10]
    source_gdd: design/gdd/whack-a-mole-minigame.md
    section: 7 Tuning Knobs
    status: active
    created: 2026-04-22

  - id: TR-MINI-007
    title: 클릭 → 시각 피드백 지연
    description: < 100ms (3 frames @ 60fps)
    source_gdd: design/gdd/whack-a-mole-minigame.md
    section: 8 Acceptance Criteria
    status: active
    created: 2026-04-22

  - id: TR-MINI-005
    title: (DEPRECATED) 가용 오브젝트 풀 30종
    description: 도감 시스템 통합 시 deprecated. 대체 TR-INV-001
    source_gdd: design/gdd/whack-a-mole-minigame.md
    section: 3 Detailed Rules
    status: deprecated
    deprecated_at: 2026-04-25
    replaced_by: TR-INV-001
    created: 2026-04-22
```

---

## 운영 규칙

### 추가만 가능

새 요구사항이 생기면 다음 번호 부여 (`TR-MINI-008`):
- 등록부에 추가
- GDD 의 해당 섹션에 ID 표기 (선택)
- ADR / 스토리에서 ID 로 인용

### 재번호 금지

`TR-MINI-007` 이 한 번 부여되면 다른 요구사항으로 재사용 절대 금지. 6개월 후 옛 ADR 이 stale.

### 삭제 금지

요구사항이 사라지면 → `status: deprecated`. 기록은 유지.

이유:
- 옛 ADR·테스트·문서가 그 ID 를 참조 가능
- 삭제하면 참조가 dangling
- deprecated 표기로 새 인용 차단 + 기존 인용은 동작

### 변경 시

요구사항의 *내용* 변경:
- `description` 수정
- `last_updated` 갱신
- ID 는 그대로

요구사항이 *완전히 다른 의미* 로 바뀜:
- 옛 ID 는 deprecated
- 새 ID 부여 (다음 번호)
- `replaced_by` 로 연결

---

## ADR / Story / Test 와의 연동

### ADR 의 인용

```markdown
# ADR-005: 캐릭터 이동 모델 결정

## GDD Requirements Addressed
- TR-MOV-001: 캐릭터 이동 가속 명세
- TR-MOV-002: 카메라 lag
- TR-INPUT-003: 키 입력 → 이동 시작 < 16ms
```

### Story 의 인용

```yaml
# story-implement-character-movement.yaml
title: 캐릭터 이동 시스템 구현

addresses:
  - TR-MOV-001
  - TR-MOV-002

acceptance_criteria:
  - 정지에서 최고속도 도달 100ms (TR-MOV-001 검증)
  - 카메라 lag 200ms (TR-MOV-002 검증)
```

### Test 의 인용

```python
# test_movement_acceleration.py

def test_acceleration_time_meets_TR_MOV_001():
    """TR-MOV-001: 정지 → 최고속도 100ms 이내 도달"""
    character = Character()
    character.start_moving()
    time = character.time_to_max_velocity()
    assert time <= 0.100, f"TR-MOV-001 violated: {time*1000}ms"
```

→ TR-ID 가 GDD 와 ADR·스토리·테스트를 잇는 *불변 키*.

---

## 양방향 추적

`/architecture-review` 또는 동등한 도구가 다음을 검증:

- 모든 TR-ID 가 registry 에 존재 (orphan ID 없음)
- 모든 active TR-ID 가 최소 1개 ADR·스토리에서 참조됨 (untraced 없음)
- deprecated TR-ID 를 새 코드가 참조하지 않음 (stale 없음)

검증 결과:
```
TR Coverage Report:
  Total TR-IDs: 47
  Active: 42
  Deprecated: 5
  Untraced: 0   ← 모든 active 요구사항이 어디선가 인용됨
  Stale References: 0
```

---

## 안티패턴

### 1. ID 없이 GDD 텍스트 인용
"위 GDD 의 3.1 절" 식 인용. 절 번호는 변경됨.

해결: TR-ID 사용. 불가피한 경우 *적어도 시스템명*이라도 명시.

---

### 2. 재번호
TR-MINI-007 의미가 바뀌어서 옛 의미를 다른 ID 로 재할당.

해결: 절대 재번호 안 함. 옛 ID 는 deprecated, 새 ID 부여.

---

### 3. ID 형식 흔들림
`TR-MOV-1` (zero padding 없음), `TR-mov-001` (lowercase) 등 혼재.

해결: `TR-<UPPERCASE>-<3자리 0-padded>` 일관 사용.

---

### 4. Registry 미사용
ID 만 GDD·ADR 에 적고 중앙 registry 없음. 진실 소스 흩어짐.

해결: tr-registry.yaml 단일 소스. 새 ID 추가 시 registry 우선.

---

### 5. Untraced 무시
GDD 에 "TR-MINI-099 가능" 이라 적었지만 ADR·스토리에 인용 없음. 의도된 요구사항이 구현 안 됨.

해결: cross-review 시 untraced 검증. 0 이어야.

---

## 검증 체크리스트

- [ ] tr-registry.yaml 단일 소스 존재
- [ ] 모든 TR-ID 가 정확한 형식 (TR-XXX-001)
- [ ] 추가만, 재번호·삭제 없음
- [ ] deprecated 의 replaced_by 명시
- [ ] 모든 active TR-ID 가 최소 1개 ADR·스토리에서 참조
- [ ] 모든 ADR 의 "GDD Requirements Addressed" 가 registry 에 존재
- [ ] cross-review 시 untraced·stale 0
