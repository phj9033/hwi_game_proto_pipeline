---
title: Prototype Build Loop — Design Spec
date: 2026-05-06
status: draft
revision: 2 (post-review)
related:
  - pipeline.yaml (concept-pipeline ≥ v0.2.1, 본 spec 채택 시 v0.3 으로 bump)
  - workspace/<slug>/06-integrated-spec.md (SSOT)
  - workspace/<slug>/06-tech-spec.md
  - workspace/<slug>/06-art-bible.md
  - workspace/<slug>/06-changelog.md
---

# Prototype Build Loop — Design Spec

## 1. 목적

`concept-pipeline` 의 단계 7(준비 완료 게이트)을 통과한 산출물 패밀리(SSOT + art-bible + tech-spec + changelog)를 입력으로 받아, **실제 프로토타입 빌드와 라운드 단위 반복 수정**을 지원하는 별도 워크플로우를 정의한다.

본 워크플로우는 `concept-pipeline` 과 같은 레포·같은 워크스페이스를 공유하면서, **새 스킬 1 개**(`prototype-build-loop`)로 동작한다.

본 spec 의 채택은 `pipeline.yaml` 을 **v0.2.1 → v0.3** 으로 bump 한다 (§6.4 참조). v0.2.1 미만에서는 동작 보장 ✕ — 단계 7 의 cross_reference_check (v0.2.1 신규) 에 의존.

## 2. 비목표 (Non-goals)

- 사용자 직접 수정의 자동 추적 — 누락 허용. *코드 = 빌드의 진실, SSOT = 컨셉 룰의 진실* 이라는 이중 진실 모델.
- 자동 빌드 / 헤드리스 테스트 / 메트릭 자동 회수 — 본 v0.1 범위 ✕
- 라운드별 폴더 스냅샷 — `build/{engine}/` 단일 트리에 in-place
- 엔진 결정을 `concept-pipeline` 단계 6 안으로 끌어들이기 — tech-spec 은 엔진 무관 유지
- drift 탐지 / "라운드는 반드시 스킬 통해서만 진입" 강제 규약

## 3. 핵심 원칙

1. **컨셉 파이프라인 정신 계승** — 데이터 주도 + 자동 흐름 + 결정 지점 멈춤 + 영속 상태.
2. **AI 수정만 추적** — Round 0 (초기 환경) + Round N (AI 수정 라운드). 사용자 직접 수정은 추적 ✕.
3. **단일 작업 트리** — `build/{engine}/` 한 디렉토리, in-place 수정. 라운드별 폴더 ✕.
4. **명시적 마일스톤만 분기** — 스냅샷은 사용자 요청에만 (git tag).
5. **엔진 추상화는 데이터** — `engines/{engine}.md` 어댑터 파일 추가만으로 새 엔진 지원.
6. **이중 진실** — 빌드 동작은 코드가 SoT, 컨셉 룰은 SSOT 가 SoT. 둘이 충돌하면 라운드 N 에서 명시적으로 동기화.
7. **자동 감지는 *결정 지점을 추가* 하는 것이지 우회가 아님** — Round N 자동 진입도 패치 적용 직전 사용자 확인을 반드시 거침.

## 4. 아키텍처

### 4.1 파일·디렉토리 구조

```
~/concept-pipeline/                                ← 같은 레포
├── pipeline.yaml                                   ← v0.3 으로 bump (§6.4)
├── .claude/skills/
│   ├── concept-pipeline/SKILL.md                  ← 기존
│   └── prototype-build-loop/                      ← 신규
│       ├── SKILL.md                               ← 코어 흐름 (엔진 무관)
│       ├── adapter-template.md                    ← 어댑터 작성 표준 (§4.3)
│       └── engines/
│           ├── godot.md                           ← Godot 4.x 어댑터
│           └── unity.md                           ← Unity 6.x 어댑터
├── .claude/commands/
│   ├── prototype-start.md                         ← 신규 슬래시
│   ├── prototype-round.md                         ← 신규 슬래시 (escape hatch)
│   └── prototype-snapshot.md                      ← 신규 슬래시
├── .claude/hooks/
│   └── session-start.sh                           ← 기존 + build/ 인지 보강
├── tests/
│   └── build_loop_smoke.sh                        ← 신규 (§9)
└── workspace/<slug>/
    ├── 06-integrated-spec.md   (SSOT)
    ├── 06-art-bible.md
    ├── 06-tech-spec.md
    ├── 06-changelog.md          ← SSOT 부속 (append-only)
    ├── ITERATION_LOG.md         ← 라운드 누적 로그
    ├── state.yaml               ← 기존 + build_state 신규 섹션
    └── build/
        ├── engine.yaml          ← 정적 엔진 메타 (선택 결과·init 정보)
        └── godot/  또는  unity/  ← 단일 작업 트리, 자체 git init
            ├── .git/             ← 부모 레포의 .gitignore 로 분리 (§4.4)
            └── ... (엔진 표준 프로젝트)
```

### 4.2 엔진 어댑터 — β 패턴

`SKILL.md` 는 엔진 무관 코어. 엔진별 차이는 `engines/{engine}.md` 데이터 파일에 격리.

### 4.3 어댑터 파일 형식 (필수 schema)

각 어댑터 파일은 markdown + YAML frontmatter. 코어 SKILL 이 읽어서 사용하므로 **헤더 컨벤션이 고정**.

```markdown
---
engine: godot
version: "4.3"
required_tools:
  - godot          # CLI 또는 Hub 명령
init_command: "godot --headless --quit-after 1 --path ."  # 또는 수동 가이드 키
---

## 모듈 매핑
- tech-spec §F 모듈 1개 → 파일 1개: `scripts/<module_snake_case>.gd`
- 기본 부모 노드 타입: `Node` / `Node2D` / `CharacterBody2D` (모듈 분류에 따라)
- 모듈 간 의존: 시그널 통한 약결합

## 시그널 매핑
- tech-spec §G 시그널 → autoload 싱글톤 `signals.gd` 의 `signal X(args)`
- 시그널명은 §G 의 식별자 그대로 (snake_case)

## Resource 매핑
- tech-spec §G Resource → `Resource` 상속 클래스 + `resources/<name>.tres`
- 인스펙터 노출 필드: `@export`

## 테스트 매트릭스 형식
- 프레임워크: GUT
- 위치: `tests/test_<module>.gd`
- §I 의 AC 1개 → test 함수 1개 (`test_ac_<id>`)

## 프로젝트 init 절차
1. `project.godot` 생성 (engine version 4.3 기본)
2. autoload 등록: `signals.gd`
3. main_scene 지정: `scenes/main.tscn`
4. `.gitignore` 적용 (아래)

## .gitignore 템플릿
\`\`\`
.godot/
.import/
*.translation
\`\`\`

## .editorconfig
\`\`\`
[*.gd]
indent_style = tab
\`\`\`
```

코어 SKILL 이 검증하는 필수 H2 헤더 7개:
`모듈 매핑`, `시그널 매핑`, `Resource 매핑`, `테스트 매트릭스 형식`, `프로젝트 init 절차`, `.gitignore 템플릿`, `.editorconfig`.

`adapter-template.md` 는 위 schema 의 빈 템플릿. 새 엔진 추가 시 복제 후 채움.

### 4.4 중첩 git 정책

부모 레포 (`~/concept-pipeline/`) 와 `build/{engine}/` 는 **분리된 git 트리**.

- 부모 레포 `.gitignore` 에 `workspace/*/build/*/` 추가 (build 트리 자체를 부모가 추적 ✕)
- `build/{engine}/.git` 은 자체 트리. 스냅샷·라운드 commit 은 여기서.
- 부모는 `workspace/<slug>/state.yaml`, `ITERATION_LOG.md`, `engine.yaml` 만 추적 (메타만).
- 서브모듈 ✕ — 사용자 부담 큼. 단순 분리.

## 5. 라이프사이클

### 5.1 전체 흐름

```
[concept-pipeline 단계 7 통과 → 산출물 패밀리 완성]
        │
        ▼
명시적 트리거 ("프로토타입 시작" / /prototype-start)
        │
        ▼
┌─ Round 0 ──────────────────────────────────────┐
│ 0.1 전제 검증           단계 7 게이트 통과 + 산출물 4종     │
│                        (SSOT, art-bible, tech-spec, changelog) │
│ 0.2 엔진 선택           "Godot 4 / Unity 6 중?"  │
│ 0.3 어댑터 로드         engines/{선택}.md 검증·로드        │
│ 0.4 스캐폴드 생성 확인   "build/<engine>/ 에 생성. OK?"    │
│ 0.5 L4 스캐폴드 생성    tech-spec §F·§G·§I 기반            │
│                        + 코어 루프 1 사이클 동작           │
│                        + build/<engine>/ git init          │
│ 0.6 ITERATION_LOG 첫 항목 (round 0, 3 필드)               │
│ 0.7 state.yaml 갱신    artifacts.engine, build_state 등    │
│ 0.8 부모 레포에 메타 commit (선택, 사용자 확인)             │
└────────────────────────────────────────────────┘
        │
        ▼
┌─ Round N (반복) — 자동 감지 진입 (§5.3) ───────┐
│ N.1 사용자 발화에서 수정 의도 감지               │
│ N.2 SSOT 분석           영향 §섹션 식별           │
│ N.3 패치 제안           diff 형태로 사용자에게 표시│
│ N.4 사용자 검토·승인     "적용할까요? 부분 적용 가능"│
│ N.5 적용 + build 트리 commit (메시지 §5.5)        │
│ N.6 ITERATION_LOG append (5 필드)                │
│ N.7 SSOT 룰 영향 시 06-changelog.md 도 append     │
│ N.8 state.yaml.build_state 갱신                   │
└────────────────────────────────────────────────┘
        │
        ▼ (선택적·명시적)
"스냅샷 v1.0 찍어줘" / /prototype-snapshot v1.0
        │
        ▼
git status 확인 → uncommitted 있으면 경고 → git tag
```

### 5.2 Round 0 — L4 (최소 플레이) 깊이

산출 트리는 **코어 루프 1 사이클이 placeholder 에셋으로 돌아가는** 상태.

생성 항목:

1. 엔진 표준 프로젝트 골격 (`.gitignore`, `.editorconfig`, 진입 씬)
2. tech-spec §F 의 모듈 폴더·빈 파일 (시그니처·주석)
3. tech-spec §G 의 시그널 정의·Resource 클래스
4. tech-spec §I 의 테스트 매트릭스 골격 (1번 AC 만 통과 가능 수준)
5. 코어 루프 1 사이클의 placeholder 구현 (실제 에셋·튜닝 ✕, 동작만 ◯)
6. README.md (어떻게 실행하는지)

### 5.3 Round N — 자동 감지 규칙

#### 키워드 추출 소스 (구체화)

수정 의도 감지에 쓰는 *시스템·메카닉 키워드* 는 다음 두 출처에서 자동 추출:

1. **SSOT §C (시스템 인벤토리)** 의 항목명 — 첫 진입 시 1회 파싱하여 `state.yaml.build_state.system_keywords` 에 캐시
2. **SSOT §B (코어 메카닉)** 의 명사 토큰

#### 판정 규칙

```
입력: 사용자 발화 텍스트 U

전제: workspace/<slug>/build/ 존재 (Round 0 통과)

규칙 1 — 질문 우선:
  U 가 의문사 ("어떻게/왜/뭐가/언제/어디/뭔가요/인가요") 로 시작 또는 끝나면
  → 라운드 ✕, 답변만 (조건 2 무시)

규칙 2 — 액션 동사 + 대상:
  U 에 액션 동사 (추가/수정/변경/제거/바꿔/줄여/늘려/고쳐/빼/넣어/강화/약화) 1개 이상
  AND
  U 에 system_keywords 또는 §B 메카닉 토큰 1개 이상
  → 라운드 ◯ 진입 (감지 신뢰도 = 높음)

규칙 3 — 평가어 + 대상:
  U 에 평가어 ("어색해/안 어울려/이상해/약해/세/지루해/혼란스러워") 1개 이상
  AND
  대상 토큰 1개 이상
  → 라운드 ◯ 진입 (감지 신뢰도 = 중간 → "수정 라운드로 처리할까요?" 1회 확인)

규칙 4 — 그 외:
  → 라운드 ✕, 일반 응답

우선순위: 규칙 1 > 규칙 2 > 규칙 3 > 규칙 4
```

명시적 escape hatch (`/prototype-round` 슬래시) 는 자동 감지가 놓친 경우의 fallback. SSOT 자체 수정 요청 ("art-bible 에 어종 추가해줘" 같은 *문서 수정*) 은 규칙 2 에서 잡힐 수 있으므로, **AI 가 패치 제안 단계에서 *이건 SSOT 수정이라 concept-pipeline /cp-redo 6 으로 가야 합니다* 라고 안내** 하고 라운드 자체는 취소.

### 5.4 스냅샷

- 트리거: 사용자 명시 호출만 (T1)
- 메커니즘: `build/{engine}/` 의 git tag (S1)
- 사전 검사: uncommitted changes 있으면 3 옵션 ("auto-commit 후 tag" / "stash 후 tag" / "취소")
- 태그 형식: `v{semver}-{이름}` 예: `v1.0-vertical-slice`

### 5.5 commit 메시지 규약

Round N 의 build 트리 commit 메시지는 AI 가 ITERATION_LOG 의 *진단·변경* 발췌로 자동 생성:

```
Round {N}: {라운드명}

{진단 1줄 발췌}

변경:
- {변경 bullet 1}
- {변경 bullet 2}
- ...
```

부분 적용 시 commit 메시지 끝에 `(partial: <파일 목록>)` 명시.

## 6. 데이터 형식

### 6.1 ITERATION_LOG.md

#### 라운드 헤더 통일

`pipeline.yaml.iteration_log.schema.round_header` 는 v0.2 까지 `## v{N} — {라운드명} ({YYYY-MM-DD})` 였음. 본 spec 의 v0.3 bump 에서 다음으로 확장:

```
## v{N} — {라운드명} ({YYYY-MM-DD})
```

`{N}` 은 0 부터 시작하는 정수. v0 = Round 0 (초기 환경). v1+ = Round N (AI 수정 라운드).

#### v0 (Round 0) — 3 필드

```markdown
## v0 — 초기 환경 (2026-05-06)
**엔진**: Godot 4.3
**세팅**: tech-spec §F 의 4 모듈 스텁, §G 의 시그널 6·Resource 3, §I 의 AC 1번 가설 검증 가능
**시드 컨텐츠**: 코어 루프 1 사이클 placeholder 동작 (어종 1·플레이어·UI 최소)
```

#### v1+ (Round N) — 5 필드 (기존)

```markdown
## v3 — 파동 피드백 강화 (2026-05-12)
**구성**: 어종 위치 변동 + 파동 effect 강도 조정
**사용자 피드백**: "어종 흐름이 약해서 손맛이 안 나"
**진단**: §G.1 어종 서사 → 시각 신호 결선 부족. wave fx 강도가 §E 룰에 못 미침.
**변경**: scripts/fish.gd (+12 -3), scenes/fx/wave.tscn (+5 -0), art-bible §E 보강
**결과**: 파동 진폭 1.5배. 다음 라운드 리듬·사운드 결선 평가 예정.
```

### 6.2 build/engine.yaml — 정적 메타만

```yaml
engine: godot
version: "4.3"
project_path: ./godot         # workspace/<slug>/build/ 기준 상대
initialized_at: 2026-05-06T14:00:00
adapter_file: engines/godot.md
adapter_checksum: <sha256>     # 어댑터 변경 감지용
```

런타임 상태(현재 라운드·마지막 스냅샷)는 `state.yaml` 에 단일 SoT 로 둠.

### 6.3 state.yaml 확장 (v0.3)

```yaml
# 신규 필드
artifacts:
  ...
  engine: godot                       # 신규 (선택된 엔진)
  build_initialized: true             # 신규 (Round 0 완료 플래그)

build_state:                          # 신규 섹션 (resume_fields 분류)
  current_round: 3                    # 마지막 완료 라운드 (정수)
  last_snapshot: v1.0-vertical-slice  # 마지막 git tag (또는 null)
  last_round_at: 2026-05-12T16:30:00  # ISO 8601
  system_keywords:                    # SSOT §C 항목명 캐시 (Round N 감지에 사용)
    - 어종_시스템
    - 파동_피드백
    - 인벤토리
```

### 6.4 pipeline.yaml v0.3 변경 사항

본 spec 채택 시 다음 변경이 함께 들어가야 함:

1. **`pipeline.version`**: `"0.2.1"` → `"0.3"`
2. **`changelog`** 항목 추가 (v0.3, 2026-05-XX 자) — 본 spec 참조.
3. **`state_schema.required_fields`** 에 추가:
   - `artifacts.engine: string | null`
   - `artifacts.build_initialized: boolean` (기본 `false`)
4. **`state_schema.resume_fields`** 에 새 그룹 `build_state` 추가:
   ```yaml
   build_state:
     current_round: integer | null
     last_snapshot: string | null
     last_round_at: ISO 8601 | null
     system_keywords: array | null
   ```
5. **`state_schema.deprecated_fields`** — 변경 ✕ (본 spec 은 *제거* 가 아닌 *추가* 마이그레이션).
6. **`steps[5].iteration_log.schema`** 확장:
   ```yaml
   round_header: "## v{N} — {라운드명} ({YYYY-MM-DD})"
   round_variants:                       # 신규
     v0:                                 # Round 0 — 초기 환경
       fields:
         - "**엔진**: ..."
         - "**세팅**: ..."
         - "**시드 컨텐츠**: ..."
     vN:                                 # Round N ≥ 1 — AI 수정
       fields:                           # 기존 5 필드 그대로
         - "**구성**: ..."
         - "**사용자 피드백**: ..."
         - "**진단**: ..."
         - "**변경**: ..."
         - "**결과**: ..."
   ```

#### 마이그레이션 메커니즘

- 본 변경은 **추가만** (필드 삭제 ✕). 따라서 `deprecated_fields` 가 아닌 **`required_fields/resume_fields 기본값 추가` 경로** (pipeline.yaml L91 의 마이그레이션 규약 3 항목 b) 사용.
- 스킬 부팅 시 `state.yaml.pipeline_version != "0.3"` 이면:
  1. `.archive/state-pre-migration-<timestamp>.yaml` 백업
  2. 신규 필드 기본값 추가 (`engine: null`, `build_initialized: false`, `build_state: null`)
  3. `pipeline_version: "0.3"` 으로 갱신
  4. `notes` 에 `"schema migration 0.2.1 → 0.3 (build-loop fields added)"` 1줄 기록
- 마이그레이션 실패 시 백업 보존 + 사용자 보고.

## 7. 트리거·UX

### 7.1 트리거 매핑

| 동작 | 트리거 | 즉시 실행 |
|------|--------|----------|
| 프로토타입 시작 (Round 0) | "프로토타입 시작" / `/prototype-start` | ✕ — 전제 검증 + 엔진 선택 + 스캐폴드 확인 후 |
| 수정 라운드 (Round N) | 자동 감지 (§5.3) 또는 `/prototype-round` | ✕ — 패치 제안 후 사용자 승인 |
| 스냅샷 | "스냅샷 v… 찍어줘" / `/prototype-snapshot <tag>` | ◯ (가벼움) — git status 확인 후 tag |

### 7.2 SessionStart 훅 보강

기존 훅이 활성 프로젝트만 표시. 다음 추가:

- `workspace/<slug>/build/` 존재 시 `📌 build mode active (v{current_round}, last snapshot {last_snapshot})` 1줄 추가
- 자동 감지 모드가 켜진 상태임을 사용자에게 인지시킴
- 이모지 톤은 기존 훅 (`📌`) 과 일치

### 7.3 결정 지점·확인 가드

- **Round 0 스캐폴드 생성 직전**: 경로·생성 항목 표시 + 1 회 확인
- **Round N 패치 적용 직전**: diff 표시 + 1 회 확인. *부분 적용* 가능 ("이 파일은 적용, 이 파일은 보류")
- **스냅샷 생성 직전**: uncommitted 있으면 3 옵션 (auto-commit / stash / 취소)
- 어느 단계에서든 "취소" / "다시" 로 빠질 수 있음
- 자동 감지 진입 시 **신뢰도 = 중간** 이면 "수정 라운드로 처리할까요?" 1회 확인 후 진입

## 8. 에러·엣지 케이스

| 케이스 | 처리 |
|--------|------|
| 단계 7 게이트 미통과 상태에서 "프로토타입 시작" | 거부 + 누락 산출물 안내 |
| 엔진 선택 후 어댑터 파일 부재 | 에러 + `adapter-template.md` 복제 가이드 |
| 어댑터 파일이 §4.3 schema 위반 (필수 H2 누락) | 에러 + 누락 헤더 명시 |
| Round 0 도중 스캐폴드 일부 실패 | 트랜잭션 ✕. 실패 지점까지 보존 + 사용자 보고 + 재시도 옵션 |
| Round N 패치가 컴파일 실패 가능 | AI 자체 검증 ✕ (v0.1). 사용자가 빌드 후 발견 → 다음 라운드로 보강 |
| 자동 감지 오인식 (질문을 수정으로) | 규칙 1 우선순위로 1차 가드 + 신뢰도 중간 시 사용자 확인. 잘못 들어가도 "취소" 가능 |
| 사용자 발화가 SSOT 자체 수정 요청 (art-bible/SSOT 파일 직접) | AI 가 안내: "이건 concept-pipeline `/cp-redo 6` 으로" + 라운드 취소 |
| 스냅샷 시 uncommitted 충돌 | "auto-commit 후 tag" / "stash" / "취소" 3 옵션 제시 |
| state.yaml 마이그레이션 (v0.2.1 → v0.3) | §6.4 마이그레이션 메커니즘 (필드 *추가* 경로) |
| 어댑터 파일 변경 감지 (`adapter_checksum` 불일치) | 사용자 경고 + 다음 Round 0 재실행 권고 (또는 무시 옵션) |

## 9. 테스트 전략

스킬 자체는 LLM 주도 흐름이라 단위 테스트는 *구조 검증*에 집중. 신규 `tests/build_loop_smoke.sh` (concept-pipeline 의 `pipeline_smoke.sh` 와 동일 포맷):

1. 어댑터 파일 (`engines/godot.md`, `engines/unity.md`) 존재 + §4.3 의 필수 H2 헤더 7 개 모두 포함
2. `adapter-template.md` 존재
3. SKILL.md 트리거 키워드 (자동 감지 액션 동사·평가어·의문사) 정의 존재
4. 슬래시 커맨드 3 종 (`prototype-start/round/snapshot`) 파일 존재
5. session-start.sh 가 build/ 인지 분기 가짐 (`grep` 패턴 `build/`)
6. ITERATION_LOG 스키마 — `## v{N} —` 헤더 패턴, v0 의 3 필드 / vN 의 5 필드 구분
7. pipeline.yaml v0.3 검증 — `pipeline.version: "0.3"`, `state_schema.required_fields.artifacts.engine`, `iteration_log.schema.round_variants` 키 존재
8. 부모 레포 `.gitignore` 에 `workspace/*/build/*/` 포함

라이브 검증은 *최소 1 슬러그* 에 대해 Round 0 → Round 1 → Snapshot 의 최소 시나리오를 수동 실행 (Godot 1회·Unity 1회).

## 10. 향후 (v0.2+ of build-loop)

- 드리프트 탐지 — 코드의 SSOT 인용 누락 또는 SSOT 룰과 코드 동작 불일치의 주기적 감사 (선택적)
- 헤드리스 빌드·자동 테스트 — Godot/Unity CI 연동
- 라운드 시작 시 *드라이런* 모드 — "이 발화는 라운드 잡히려나?" 미리 묻기
- AI 자체 검증 — 패치 제안 전 모듈 재컴파일 시뮬레이션 (Godot LSP / Unity Roslyn)
- 마일스톤 자동 스냅샷 — vertical slice / MVP 식별 시 자동 tag 제안
- 어댑터 자동 갱신 — 엔진 버전 출시 시 어댑터 파일 마이그레이션

## 11. 결정 요약 (브레인스토밍 트레이스)

| 결정 | 채택 | 이유 |
|------|-----|------|
| 워크플로우 분리 방식 | 새 스킬 + 같은 워크스페이스 | drift 차단(같은 디렉토리) + 도구 분리(다른 mode) |
| Round 0 깊이 | L4 (최소 플레이) | Round 1 부터 의미 있는 피드백 가능 |
| 엔진 어댑터 구조 | β (코어 + 데이터 파일) | 데이터 주도 정신 일치, 새 엔진 추가 1장으로 |
| 추적 범위 | Round 0 + AI 수정 라운드만 | 풀 트래킹은 비용 대비 가치 ✕, 코드가 진실 |
| 폴더 분기 | in-place + 명시 git tag | 폴더 폭증 ✕, git 표준 활용 |
| 스냅샷 트리거 | 사용자 명시만 | 자동 마일스톤은 식별 비용 큼, v0.2+ 로 |
| ITERATION_LOG 스키마 | 라운드 종류별 다른 스키마 (v0=3 / vN=5) | Round 0 vs Round N 본질 차이 인정 |
| 수정 라운드 트리거 | 자동 감지 + 슬래시 fallback | 대화 흐름 자연스러움 + escape hatch 보존 |
| 자동 감지 키워드 출처 | SSOT §C·§B 자동 추출 캐시 | 프로젝트별 정확도 + 데이터 주도 |
| 중첩 git 정책 | 부모 .gitignore 분리, 서브모듈 ✕ | 사용자 부담 최소 |
| pipeline.yaml bump | v0.2.1 → v0.3 (state_schema + iteration_log 확장) | minor bump 규약 준수 |

---

*본 문서는 brainstorming 세션의 합의를 기록한 spec. 구현 plan 은 `writing-plans` 단계에서 별도 작성.*
