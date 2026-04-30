---
title: 테스트 증거 매트릭스 (Story Type 별)
collection: architecture-patterns
axis: E
theory_id: test-evidence-matrix
keywords: [test, evidence, story-type, logic, integration, visual, ui, config, blocking, advisory, automation]
applies_to: [implementation, evaluation]
related: [adr-template, tr-id-system]
last_updated: 2026-04-28
---

# 테스트 증거 매트릭스

> 모든 스토리(작업 단위)는 *완료 = 동작 증명*. 그러나 증거 형식은 스토리 타입에 따라 다르다.
> 자동화하지 말아야 할 것을 자동화하려 하면 시간 낭비, 자동화해야 할 것을 수동으로 하면 회귀 발생.

## 5 가지 스토리 타입

| 타입 | 정의 | 예시 |
|------|------|------|
| **Logic** | 결정론적 계산·상태 머신·AI 의사결정 | 점수 공식, 상태 전이, AI 행동 트리 |
| **Integration** | 여러 시스템 간 통합 | 미니게임 ↔ 스코어링, 입력 ↔ 캐릭터 |
| **Visual / Feel** | 애니메이션·VFX·게임 느낌 | 히트 이펙트, 화면 흔들림, 무게감 |
| **UI** | 메뉴·HUD·화면 흐름 | 메인 메뉴 네비, 인벤토리 화면 |
| **Config / Data** | 밸런싱·튜닝·데이터 변경 | 난이도 곡선 조정, 가격 테이블 |

---

## 매트릭스

| 타입 | 필요 증거 | 위치 | 게이트 등급 |
|------|----------|------|-------------|
| **Logic** | 자동화된 단위 테스트 — 반드시 통과 | `tests/unit/[system]/` | 🔴 BLOCKING |
| **Integration** | 통합 테스트 OR 문서화된 플레이테스트 | `tests/integration/[system]/` 또는 `production/qa/playtests/` | 🔴 BLOCKING |
| **Visual / Feel** | 스크린샷 + 디자인 리드 sign-off | `production/qa/evidence/` | 🟡 ADVISORY |
| **UI** | 수동 워크스루 문서 OR 인터랙션 테스트 | `production/qa/evidence/` | 🟡 ADVISORY |
| **Config / Data** | 스모크 체크 통과 | `production/qa/smoke-[date].md` | 🟡 ADVISORY |

### 게이트 등급 의미

- 🔴 **BLOCKING**: 증거 미충족 시 스토리 *완료 불가*. CI 에서 차단.
- 🟡 **ADVISORY**: 증거 미충족 시 경고. 디자인 리드 sign-off 로 무시 가능.

---

## 1. Logic — 자동 단위 테스트

### 무엇을 테스트하는가
- 점수·데미지·진화 등 *공식*
- 상태 머신 전이 로직
- AI 의사결정 (고정 입력 → 고정 출력)
- 데이터 변환·검증 함수

### 작성 규약

```python
# tests/unit/scoring/test_score_calculation.py

def test_basic_score_calculation():
    """TR-SCORE-001: 일반 캐치 = BaseValue × Combo × Bonus"""
    result = calculate_score(base=100, combo=3, bonus=1.0)
    assert result == 300

def test_legendary_max_score():
    """TR-SCORE-002: LEGENDARY × 콤보10 × 하드 = 50000"""
    result = calculate_score(base=1000, combo=10, bonus=2.0)
    assert result == 20000  # 1000 * 10 * 2.0

def test_combo_capped_at_99():
    """TR-SCORE-003: Combo 100 이상은 99 로 캡"""
    result = calculate_score(base=100, combo=150, bonus=1.0)
    expected = 100 * 99 * 1.0
    assert result == expected
```

### 작성 규칙

- **명명**: `test_<scenario>_<expected>` 또는 `test_<TR-ID>_<scenario>`
- **결정론**: 같은 입력 = 같은 출력. random·시간·환경 의존 금지
- **격리**: 각 테스트는 자기 셋업·티어다운. 순서 의존 금지
- **외부 차단**: DB·네트워크·파일 I/O 차단 (Mock 또는 in-memory)
- **하드코딩 금지**: 픽스처 파일 또는 팩토리 함수 사용 (단, 경계값 테스트는 수치가 핵심이라 예외)

---

## 2. Integration — 통합 테스트 또는 플레이테스트

### 무엇을 테스트하는가
- 두 개 이상 시스템의 협력
- 시그널·이벤트 전파
- 데이터 흐름 (시스템 A 출력 → 시스템 B 입력)

### 두 가지 방식

#### A) 자동 통합 테스트 (가능하면 우선)
```python
# tests/integration/minigame_scoring/test_catch_to_score.py

def test_catch_event_increments_score():
    """TR-INT-001: 미니게임 캐치 시 스코어링이 점수 가산"""
    game = setup_test_game()
    initial_score = game.scoring.get_score()
    
    game.minigame.simulate_catch(object_id=42, value=100)
    
    assert game.scoring.get_score() == initial_score + 100
```

#### B) 문서화된 플레이테스트 (자동화 어려운 경우)
```markdown
# production/qa/playtests/2026-04-28-minigame-flow.md

## TR-INT-002 검증: 미니게임 → 결과 화면 전이

테스터: hwijung
환경: M1 Mac, 1080p, 60fps
빌드: dev-2026-04-28-a1b2c3

### 시나리오 1: 정상 종료
1. 게임 시작 (메인 메뉴 → 시작 클릭) → ✅
2. 60초 플레이 → ✅
3. 60초 만료 시 결과 화면 전이 → ✅
4. 결과 화면에 최종 점수 표시 → ✅
5. 메인 메뉴 복귀 클릭 → ✅

### 시나리오 2: 일시정지 후 재개
1. 30초 시점 ESC 일시정지 → ✅
2. 재개 → 정확히 30초 시점부터 → ✅
3. 모든 활성 오브젝트 잔여 수명 보존 (육안 확인) → ✅

검증 결과: PASS
```

---

## 3. Visual / Feel — 스크린샷 + Sign-off

### 자동화 못하는 이유
- 셰이더 출력의 미적 평가 불가능
- 애니메이션 곡선의 "자연스러움" 측정 불가능
- 입력 반응성의 *체감* 평가 불가능 (수치 < 100ms 가 자동 검증, 그러나 *느낌*은 별개)

### 증거 형식

```markdown
# production/qa/evidence/TR-MINI-007-hit-effect-2026-04-28.md

## TR-MINI-007: 일반 캐치 히트 이펙트

### 스크린샷
![normal-catch](../screenshots/normal-catch-2026-04-28.png)
![legendary-catch](../screenshots/legendary-catch-2026-04-28.png)

### 영상 (5초)
production/qa/videos/hit-effect-comparison.mp4

### 자동 측정 (참고)
- Hit Pause: 50ms ✓ (TR-MINI-007 명세)
- Particle 수: 5 ✓
- 사운드 트리거 지연: 12ms ✓

### 디자인 리드 평가
- 일반 캐치: 충분히 만족스러운 강도
- 전설 캐치: 충분히 강조되어 일반과 차별 분명
- 사운드 vs 시각의 동기: 양호

### Sign-off
- 디자인 리드: hwijung @ 2026-04-28 ✓
- 비고: 다음 단계에서 카메라 흔들림 강도 +10% 검토
```

### 게이트 등급이 ADVISORY 인 이유
미적 평가는 주관적. 디자인 리드 sign-off 가 *최종 결정*. 자동 거부 대신 경고만.

---

## 4. UI — 워크스루 문서 또는 인터랙션 테스트

### 두 가지 방식

#### A) 수동 워크스루 문서
```markdown
# production/qa/evidence/TR-MENU-001-main-menu-flow-2026-04-28.md

## TR-MENU-001: 메인 메뉴 네비게이션

### 클릭 가능 영역
| 버튼 | 위치 | 동작 | 검증 |
|------|------|------|------|
| 시작 | 화면 중앙 | 게임 시작 | ✓ 클릭 시 게임 화면 전이 |
| 옵션 | 시작 아래 | 옵션 화면 | ✓ 클릭 시 옵션 모달 |
| 종료 | 좌하단 | 게임 종료 | ✓ 클릭 시 종료 다이얼로그 |

### 키보드 네비
- Tab: 버튼 순환 → ✓
- Enter: 활성 버튼 클릭 → ✓
- ESC: 취소 / 뒤로 → ✓

### 시각 상태
- Hover: 색 변화 ✓
- Pressed: 0.5px down ✓
- Disabled: 회색 + 클릭 무반응 ✓

검증자: hwijung @ 2026-04-28
```

#### B) 인터랙션 테스트 (자동화 가능 시)
```python
# tests/ui/test_main_menu_navigation.py

def test_start_button_triggers_game_start():
    menu = MainMenu()
    menu.show()
    menu.click_button("start")
    assert menu.next_screen == "game"
```

---

## 5. Config / Data — 스모크 체크

### 무엇을 테스트하는가
- 데이터 파일 로드 성공
- 변경 후 게임이 충돌 없이 시작되는지
- 핵심 메카닉이 정상 동작하는지 (수치는 검증하지 않음)

### 증거 형식

```markdown
# production/qa/smoke-2026-04-28.md

## 변경 사항
- difficulty-curve.yaml: 30초 시점 가속 +20%
- spawn-weights.yaml: LEGENDARY 가중치 0.05 → 0.07

## 스모크 체크
- [x] 게임 시작 정상
- [x] 60초 플레이 충돌 없음
- [x] 메뉴 전환 정상
- [x] 일시정지/재개 정상

검증자: hwijung @ 2026-04-28 14:30
```

### 왜 ADVISORY 인가
밸런싱은 본질적으로 반복 조정. 매 변경마다 풀 테스트는 비효율. 스모크 + 플레이테스트가 충분.

---

## 자동화 vs 수동 결정 가이드

| 테스트 대상 | 자동화? |
|-------------|---------|
| 결정론적 함수 | ✅ 자동 |
| 상태 머신 | ✅ 자동 |
| 시스템 간 데이터 흐름 | ✅ 자동 (가능하면) |
| 셰이더 출력의 미적 | ❌ 수동 (스크린샷) |
| 애니메이션 자연스러움 | ❌ 수동 |
| 입력 반응 *체감* | ❌ 수동 (자동은 *수치*만) |
| 플랫폼별 렌더링 | ❌ 수동 (실제 하드웨어) |
| 풀 게임플레이 세션 | ❌ 수동 (플레이테스트) |
| 밸런스의 "재미" | ❌ 수동 |

---

## CI 통합

### 자동 테스트는 main 브랜치 + PR 마다 실행

엔진별:
- **Godot**: `godot --headless --script tests/gdunit4_runner.gd`
- **Unity**: `game-ci/unity-test-runner@v4`
- **Unreal**: 헤드리스 러너 + `-nullrhi`

### 실패 시
- BLOCKING 게이트 (Logic, Integration): 머지 차단
- ADVISORY 게이트 (Visual, UI, Config): 경고만

### 절대 안 함
- 실패 테스트 비활성화로 CI 통과 — 근본 원인 수정
- Hooks 우회 (--no-verify) — 정당한 사유 없으면 절대 안 함

---

## 안티패턴

### 1. Visual 을 Logic 으로 자동화 시도
"이 셰이더 출력 픽셀 단위로 비교" → 환경에 따라 깨짐.

해결: 자동은 측정 가능한 *수치*만 (FPS, 메모리 등). 미적은 스크린샷 + 사람.

---

### 2. 자동 가능한 걸 수동으로
"점수 공식은 매번 손으로 계산" → 회귀 발생.

해결: 결정론적 = 무조건 자동. 한 번 작성 후 영구히 검증.

---

### 3. 환경 명시 없는 증거
스크린샷만 첨부, 어떤 빌드인지·하드웨어인지 명시 없음.

해결: 모든 증거에 환경 (빌드 ID, 하드웨어, 해상도, FPS).

---

### 4. Sign-off 부재
스크린샷 첨부했지만 디자인 리드 동의 없음. 통과 기준 모호.

해결: ADVISORY 게이트는 모두 sign-off 명시 (이름 + 날짜).

---

## 검증 체크리스트

- [ ] 스토리에 타입 명시 (Logic/Integration/Visual/UI/Config)
- [ ] 타입에 맞는 증거 형식
- [ ] BLOCKING 증거는 자동 + CI 통과
- [ ] ADVISORY 증거는 sign-off + 환경 명시
- [ ] TR-ID 인용 (검증 대상이 어느 요구사항인지)
- [ ] 스모크 체크는 매 데이터 변경마다
