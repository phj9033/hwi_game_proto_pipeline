# 단계 6c — 개발 사양서 (시점 문서, 자동)

## 목적
SSOT(`06-integrated-spec.md`) 의 §F 아키텍처·§G 데이터 스키마·§H 가설·§I AC 를
**개발자가 즉시 사용 가능한 모듈·코드·테스트 단위**로 전개한다.

## 입력
- `workspace/<slug>/06-integrated-spec.md` (SSOT, 필수)
- `workspace/<slug>/prototype/` 디렉토리 (있으면) — 실제 코드와 SSOT 매핑 추출
- `workspace/<slug>/ITERATION_LOG.md` (있으면) — 빌드 변경 이력. 작성 규약은
  `pipeline.yaml` 단계 6 의 `iteration_log` 섹션 참조 (append-only, 라운드별 5 필드).
  본 문서 갱신 시 *최근 N 라운드의 변경* 항목을 반영해 *모듈 매핑·시그널 카탈로그* 가
  실제 코드와 어긋나지 않게 한다.

## 산출물
`workspace/<slug>/06-tech-spec.md`

## 작성 원칙
- **인용만, 복제 ✕**: ADR·시스템 표·룰 번호는 SSOT 를 *링크* (예: "→ 06-integrated-spec.md §F.ADR-1"). 본문에 다시 적지 않음.
- **시점 문서 = 매핑 단위**: 각 시스템·룰·AC 1건 = 1행. 행마다 *코드 위치·테스트 ID·검증 명령* 박힘.
- **드리프트 차단**: SSOT 룰 번호 변경 시 본 문서가 깨지도록 *번호 강참조* (룰 1 → SSOT §B.1).
- **prototype 존재 시 자동 채움**: 실제 파일·라인 grep 으로 매핑 갱신 — placeholder 응답 ✕.

## 필수 섹션 (5개)

### 1. 모듈 매핑
SSOT §C 시스템 표를 **실제 코드 위치** 와 1:1 매핑.

| 시스템 ID | SSOT 인용 | 책임 (1줄) | 코드 위치 | 의존 모듈 (코드) | 인터페이스 (이벤트) |
|---|---|---|---|---|---|
| S1 | §C.S1 | 입질·텐션 시뮬 | `systems/s1_tension/tension_simulator.gd` | `EventBus`, `InputContext` | tension_changed, fish_landed, ... |
| ... | ... | ... | ... | ... | ... |

### 2. 데이터 플로우
SSOT §F 데이터 흐름 mermaid 를 *인용*하고, 시점 문서에서는 **시그널 카탈로그** 만 박는다.

| 시그널명 | emit 위치 | 구독 위치 | 페이로드 |
|---|---|---|---|
| `tension_changed(value: float)` | `s1_tension/tension_simulator.gd:tap_reel` | `fishing_only.gd:_on_tension_changed`, `s7_visibility:apply_delay` | tension 0~100 |
| ... | ... | ... | ... |

### 3. 테스트 매트릭스
SSOT §I AC-N 모두를 **테스트 ID** 와 1:1 매핑.

| AC ID | SSOT 인용 | 테스트 위치 | 실행 명령 | 통과 기준 |
|---|---|---|---|---|
| AC-1 | §I.AC-1 | `tests/flow_test.tscn` | `godot --headless tests/flow_test.tscn` | 5 씬 전이 무에러 |
| AC-3 | §I.AC-3 | `tests/ac_test.tscn` (lifetime 11 케이스) | `godot --headless tests/ac_test.tscn` | ALL PASSED |
| ... | ... | ... | ... | ... |

EC (엣지 케이스) 도 동일 형식으로 별도 표.

### 4. ADR 코드 매핑
SSOT §F ADR-N 각각이 **어느 코드에서 강제** 되는지.

| ADR ID | SSOT 인용 | 강제 위치 | 위반 시 증상 |
|---|---|---|---|
| ADR-1 | §F.ADR-1 (Signal Bus) | `globals/event_bus.gd` | 직접 의존 → grep 으로 발견 |
| ADR-4 | §F.ADR-4 (회차 트랜잭션) | `s5_journal/journal_manager.gd:commit` | 부분 적용 → tests/ac_test (AC-6) 실패 |
| ... | ... | ... | ... |

### 5. 빌드·검증 절차
- 헤드리스 테스트 명령 (CI 직접 사용 가능)
- 프로토타입 빌드 검증 절차 (Godot 버전·export presets)
- 모바일 빌드 절차 (iOS·Android, ADR-6/7 정합 검증)
- 회귀 테스트 1줄 명령 (모든 ac_test + flow_test)

## 작성 절차 (자동, 사용자 응답 ✕)
1. SSOT 읽기 — §C·§F·§G·§H·§I 추출
2. `prototype/` 디렉토리 grep:
   - 시스템 매핑: `find prototype/systems -name "*.gd"`
   - 시그널 카탈로그: `grep -rn "EventBus\." prototype/`
   - 테스트: `ls prototype/tests/*.tscn`
3. 5 섹션 작성, 각 섹션 *인용 1줄 + 매핑 표* 만
4. 자기 점검:
   - 모든 SSOT §C 시스템이 모듈 매핑 표에 있는가?
   - 모든 SSOT §I AC 가 테스트 매트릭스에 있는가? (미구현 = "TODO" 명시)
   - 모든 §F ADR 이 강제 위치를 가지는가?
   - 빌드·검증 명령이 *복붙해서 실행 가능* 한가?

## 톤
- 한국어 본문 + 영어 코드·명령·시그널명
- 표·코드블록 우선, 산문 최소
- "이 문서만 보고 빌드·테스트·디버깅 진입 가능한가?" 가 통과 기준
