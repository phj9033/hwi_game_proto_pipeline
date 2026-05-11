---
title: Auto-Build Substeps — Design Spec
date: 2026-05-11
status: draft
revision: 1
supersedes_partial: 2026-05-06-prototype-build-loop-design.md (§6 Round 0 절차)
related:
  - pipeline.yaml (≥ v0.3, 본 spec 채택 시 v0.4 으로 bump)
  - .claude/skills/prototype-build-loop/SKILL.md
  - prompts/prototype-build-loop/round0-scaffold.md (deprecated by this spec)
  - prompts/06b-art-bible.md
  - workspace/<slug>/06-art-bible.md
  - workspace/<slug>/06-tech-spec.md
  - workspace/<slug>/06-integrated-spec.md
---

# Auto-Build Substeps — Design Spec

## 1. 목적

기존 `prototype-build-loop` 의 Round 0 는 *L4 스캐폴드 (코어 루프 placeholder)* 까지만 생성하고 사용자 입력을 대기한다. 본 spec 은 Round 0 를 **분수 substep 4개 (0.1~0.4) 의 자동 연쇄** 로 확장하여, 엔진 선택 후 단계 7 산출물 4종을 바탕으로 **AC §I 가설 1번 검증 가능 + 픽셀아트 placeholder 까지** 자동으로 진행한 뒤 사용자 첫 피드백 라운드 (Round 1) 로 진입하도록 한다.

사용자는 "프로토타입 시작" 한 번 → 엔진 선택 → 자동 1차 빌드 완성 보고 → Round 1+ (기존 roundN-patch 그대로) 의 흐름을 경험한다.

## 2. 비목표 (Non-goals)

- **AC1 실제 통과 보장** — 테스트가 실행되어 결과가 출력되는 수준까지만 (pass/fail 무관). 통과 디버그는 사용자 라운드 책임.
- **§C 시스템 전수 구현** — AC1 측정에 필수인 §C 1~2개만. 나머지는 Round 1+ 사용자 피드백 라운드에서.
- **이미지 자동 생성 (DALL-E/SD 호출)** — 비용·실패율로 제외. 단색 도형 + 라벨 PNG 만.
- **기존 진행 중 프로젝트 마이그레이션** — 이미 Round 1+ 진행 중인 프로젝트는 그대로 (whatever-bites 등). 신규 프로젝트만 자동 빌드 적용.
- **LLM 자가 디버그 무한 루프** — substep 실패 시 자동 재시도는 최대 1회. 두 번째 실패는 강제 사용자 개입.

## 3. 핵심 원칙

1. **외부 인터페이스 1 트리거 → 내부 4 substep** — 사용자는 "프로토타입 시작" 한 번. 내부 0.1~0.4 는 자동 연쇄, substep 마다 commit + ITERATION_LOG 항목.
2. **AC1 = stop 라인** — AC §I 가설 1번이 *측정 가능한 인프라까지* 가 자동 빌드 완료 기준. "통과" 가 아니라 "실행 가능".
3. **substep 트랜잭션** — 각 substep 은 단일 commit 단위. 실패 시 마지막 성공 commit 유지, uncommitted 변경만 롤백, 사용자에게 3 옵션 (재개·수동 전환·롤백) 제시.
4. **Placeholder + prompt 파일 = 영구 자산** — 픽셀 placeholder 는 교체 대상, `*.prompt.md` 는 교체 후에도 유지 (history 역할 + 재생성 시 일관성 가이드).
5. **Round 1+ 변경 ✕** — 기존 roundN-patch / 자동 감지 / SSOT 분기 / 스냅샷 모두 그대로.

## 4. 전체 아키텍처

### 4.1 흐름 비교

**현재 (v0.3)**:
```
사용자 "프로토타입 시작" + 엔진 선택
  → Round 0 (scaffold placeholder)
  → 끝, 사용자 입력 대기
  → Round 1, 2, ... (사용자 피드백)
```

**변경 (v0.4)**:
```
사용자 "프로토타입 시작" + 엔진 선택  ─┐
  → Round 0.1 (scaffold)              │
  → Round 0.2 (코어 루프 §B)           │  자동 연쇄
  → Round 0.3 (§C 시스템 + AC1)        │  사용자 개입 ✕
  → Round 0.4 (art placeholder)       │  각 substep 별 commit
  → 자동 빌드 완료 보고                ─┘
  → Round 1, 2, ... (사용자 피드백, 기존 그대로)
```

### 4.2 state.yaml.build_state 스키마 (v0.4)

```yaml
build_state:
  current_round: 0              # 기존, 마지막 완료 라운드 (정수)
  current_substep: "0.4"        # 신규, 자동 빌드 진행 중일 때만 (완료 시 null)
  auto_build_status: "completed"  # 신규: in_progress | completed | failed_at_<substep>
  system_keywords: [...]        # 기존
  last_round_at: "..."          # 기존
  last_snapshot: null           # 기존
```

### 4.3 진입 조건

자동 빌드 substep (0.1~0.4) 은 다음 조건 모두 만족 시에만 트리거:
- 단계 7 통과 (`completed_steps` 에 id=7)
- 4종 산출물 존재 (`06-integrated-spec.md` / `06-art-bible.md` / `06-tech-spec.md` / `06-changelog.md`)
- `state.yaml.build_state.current_round` 가 null 또는 부재 (즉, 첫 진입)
- `build/` 디렉토리가 비어있음

기존 진행 프로젝트 (whatever-bites 등) 는 위 조건 불충족 → 기존 roundN-patch 직접 진입.

## 5. Substep 상세

### 5.1 Round 0.1 — Scaffold

**입력**: tech-spec §F (모듈), §G (시그널·Resource), engine 어댑터

**작업**:
1. 어댑터 로드·검증 (7 필수 H2 헤더)
2. 어댑터 *프로젝트 init 절차* 1~6 순차 실행
3. tech-spec §F 모듈 → 어댑터 *모듈 매핑* 규칙으로 빈 파일·시그니처
4. tech-spec §G 시그널 → 어댑터 *시그널 매핑* 으로 정의 파일
5. tech-spec §G Resource → 어댑터 *Resource 매핑* 으로 클래스
6. 디렉토리 트리 생성 (`scenes/`, `scripts/`, `resources/`, `data/`, `tests/`, `art/`)

**성공 기준**: `{engine init_command}` 통과 (빌드 자체 OK)

**commit**: `Round 0.1: scaffold (engine={engine})`

**ITERATION_LOG**:
```
## v0.1 — Scaffold (YYYY-MM-DD)
**엔진**: {engine} {version}
**모듈**: tech-spec §F 의 N 항목 스텁
**시그널·Resource**: §G 의 N 시그널, N Resource
```

### 5.2 Round 0.2 — 코어 루프 (§B)

**입력**: SSOT §B 코어 메카닉, tech-spec §F 코어 모듈

**작업**:
1. §B 의 *입력 → 동작 → 결과 → 다음 사이클* 1 cycle 을 최소 구현
2. placeholder 데이터·hardcoded 값 OK (수치는 SSOT §B 값 우선)
3. 어댑터 *코어 루프 매핑* 패턴 따름 (Godot: `_process` / `_input` / signal 흐름)

**성공 기준**: 코어 루프 한 사이클이 실행 가능 (수동 트리거든 자동이든) — 입력 → 동작 → 결과 흐름이 끊김 없이 통과

**commit**: `Round 0.2: core loop (§B {메카닉명})`

**ITERATION_LOG**:
```
## v0.2 — 코어 루프 (YYYY-MM-DD)
**구현 §B**: {핵심 메카닉명}
**1 cycle 흐름**: 입력({...}) → 동작({...}) → 결과({...})
**하드코딩**: {추후 §C 시스템으로 빠질 값 목록}
```

### 5.3 Round 0.3 — §C 시스템 + AC1 인프라 (stop 라인)

**입력**: SSOT §I AC 1번, §I AC1 매핑된 §C 시스템 1~2개, tech-spec §I AC

**작업**:
1. AC1 가설 측정에 필수인 §C 시스템만 구현
2. 어댑터의 *테스트 매트릭스 형식* 으로 AC1 테스트 함수 작성
3. 테스트 실행 인프라 (예: Godot 의 `--headless --test`, Unity 의 `runEditModeTest`)
4. AC1 입출력 명세에 따라 측정 지점 (계측) 추가

**성공 기준**: AC1 테스트 명령 실행 시 결과 출력 (pass/fail 무관). 결과 원문이 stdout 또는 로그 파일에 기록.

**commit**: `Round 0.3: §C systems for AC1 + test scaffold`

**ITERATION_LOG**:
```
## v0.3 — §C 시스템 + AC1 (YYYY-MM-DD)
**구현 §C**: {AC1 필수 시스템 N개}
**AC1 테스트**: {테스트 함수명}
**실행 결과**: {원문 1~3줄, pass/fail 명시}
**다음 라운드 권고**: {fail 인 경우 가설 진단 1줄}
```

### 5.4 Round 0.4 — Art placeholder + 프롬프트 파일

**입력**: SSOT §D, `06-art-bible.md` 슬롯 목록 (§Z 슬롯 테이블)

**작업**:
1. art-bible §Z 슬롯 테이블 파싱 (slot_id / category / size / palette_ref / 설명)
2. `tools/gen_placeholders.py` 호출 (입력: art-bible 경로, 출력: `build/{engine}/art/`)
3. 슬롯마다:
   - 카테고리별 도형·색 규칙 (§6.2) 으로 PNG 생성
   - `{slot_id}.prompt.md` sibling 파일 생성 (frontmatter + 프롬프트 + art-bible 인용 + 교체 가이드)
4. 코드에서 placeholder 경로 참조 연결 (어댑터의 *에셋 로드 컨벤션* 따름)

**성공 기준**: art-bible 슬롯 N개 → PNG N개 + prompt.md N개. 코드에서 한 슬롯 이상 로드 성공 (smoke test).

**commit**: `Round 0.4: art placeholders + prompt files (N slots)`

**ITERATION_LOG**:
```
## v0.4 — Art placeholder (YYYY-MM-DD)
**슬롯 수**: N
**카테고리 분포**: creature N, character N, object N, ui N, effect N
**placeholder 규칙**: §6.2 표 따름
**프롬프트 파일 경로**: build/{engine}/art/{slot_id}.prompt.md
```

## 6. Art placeholder 시스템

### 6.1 슬롯 추출 (art-bible 의존)

`06-art-bible.md` 에 다음 형식의 슬롯 테이블을 강제:

```markdown
## §Z 슬롯 목록

| slot_id | category | size | palette_ref | 설명 |
|---------|----------|------|-------------|------|
| fish_01 | creature | 32x32 | §X.2 (ocean) | 작은 청록 물고기 |
| player  | character | 48x48 | §X.1 (warm) | 주인공 |
| hud_bg  | ui | 320x64 | §X.3 (neutral) | 상단 HUD 배경 |
```

→ `prompts/06b-art-bible.md` 의 출력 템플릿에 §Z 섹션을 항상 포함하도록 prompt 수정 (구현 계획 단계 별도 항목).

기존 프로젝트의 art-bible 에 §Z 가 없으면: Round 0.4 가 LLM 으로 art-bible 본문에서 슬롯 추론, 결과를 §Z 섹션으로 art-bible 에 append (`06-changelog.md` 에 v0.4 기록).

### 6.2 카테고리별 placeholder 규칙

| category | 도형 | 색상 |
|----------|------|------|
| creature | 원 | art-bible 팔레트 *primary* |
| character | 사각형 (세로) | art-bible 팔레트 *accent* |
| object | 사각형 | art-bible 팔레트 *secondary* |
| ui | 사각형 (모서리 둥근) | 회색조 |
| effect | 다이아몬드 | art-bible 팔레트 *highlight* |

- 배경: 투명 PNG
- 라벨: 슬롯 id 텍스트 (검은색, PIL 기본 폰트, 슬롯이 작으면 라벨 생략)
- 크기: art-bible 슬롯 테이블의 size 따름

팔레트 ref 가 art-bible 에서 해석되지 않으면 fallback 색상 (해시 기반 일관 색).

### 6.3 프롬프트 파일 스키마

`build/{engine}/art/{slot_id}.prompt.md`:

```markdown
---
slot_id: fish_01
category: creature
size: 32x32
palette_ref: art-bible §X.2 (ocean)
placeholder_generated_at: 2026-05-11
---

# 이미지 생성 프롬프트
{art-bible 슬롯 설명을 픽셀아트 프롬프트로 1~2문장 변환}

# 컨텍스트 (art-bible 인용)
- §Z 슬롯 row: {원문 인용}
- §X.{palette_ref}: {팔레트 발췌 2~3줄}

# 교체 가이드
- 파일명: `{slot_id}.png` 동일하게 유지
- 사이즈: {size} (변경 시 코드에서 sprite size 조정 필요)
- 배경: 투명 PNG
- 동일 경로에 덮어쓰기. 이 prompt.md 파일은 그대로 유지 (history 역할)
```

### 6.4 디렉토리 구조

```
build/godot/art/
  fish_01.png            ← placeholder (교체 대상)
  fish_01.prompt.md      ← 영구 (교체 후 유지)
  player.png
  player.prompt.md
  hud_bg.png
  hud_bg.prompt.md
  ...
```

### 6.5 코드 연결

- 엔진 어댑터의 *에셋 로드 컨벤션* 항목에 `art/{slot_id}.png` 경로 패턴 명시
- 교체 시 동일 파일명·동일 경로면 코드 수정 ✕, PNG 만 덮어쓰면 끝

## 7. 실패 처리

### 7.1 substep 단위 트랜잭션

```
Round 0.1 ✓ → commit
Round 0.2 ✓ → commit
Round 0.3 시도 → 도중 실패
  → 0.3 작업 파일 git restore (uncommitted 변경만)
  → state.yaml.build_state:
     auto_build_status: "failed_at_0.3"
     current_substep: "0.3"
  → 사용자 보고
```

### 7.2 실패 시 사용자 옵션

| 옵션 | 동작 |
|------|------|
| 1. **재개** | 마지막 성공 substep 다음부터 자동 재시도. AI 가 실패 원인 진단 1회 반영 후 재진행. **재시도 최대 1회**. |
| 2. **수동 전환** | 자동 모드 abort, Round 1+ 사용자 피드백 라운드로 전환. 미완료 substep (예: 0.4 art) 은 사용자가 별도 슬래시 (`/cp-art-rebuild`) 로 회고 적용 가능. |
| 3. **롤백** | Round 0.1 (또는 지정 substep) 까지 `git reset --hard` 후 처음부터 재시도. 기존 commit 폐기. **사용자 명시 확인 필수**. |

### 7.3 LLM 자가 디버그 가드

- 옵션 1 (재개) 에서 AI 자체 재시도는 substep 당 1회만
- 두 번째 실패 시 강제로 옵션 2 (수동 전환) 권고, 옵션 1 비활성화
- 옵션 3 (롤백) 은 사용자 명시 확인 필수 (commit 폐기 destructive)

### 7.4 부분 실패 (substep 안)

substep 내부에 여러 파일 변경 중 일부만 성공:
- uncommitted 변경 그대로 보존
- 사용자에게: "0.3 시도 중 N 개 파일 변경 후 실패 — 변경 파일 목록: [...]. 재개·수동 전환·롤백 중 선택"

## 8. 기존 프로젝트 영향

### 8.1 마이그레이션 안 함

자동 빌드 substep 은 §4.3 진입 조건 충족 시에만 트리거. 기존 진행 중 프로젝트 (whatever-bites: build/godot/ 존재 + Round 10) 는 조건 불충족 → 기존 roundN-patch 직접 진입, 변경 ✕.

### 8.2 state.yaml 마이그레이션

신규 필드 (`current_substep`, `auto_build_status`) 는 옵션 필드. 기존 프로젝트:
- 자동 빌드 안 거쳐서 둘 다 null/부재 OK
- `pipeline.yaml` 의 `version` 만 0.3 → 0.4 bump 시 state.yaml 의 `pipeline_version` 도 일관성 위해 동기화 (선택)

신규 프로젝트는 Round 0.1 진입 시 자동으로 채워짐.

### 8.3 회고 적용 — art prompt 시스템

별도 슬래시 `/cp-art-rebuild` (구현 계획 단계 별도 항목):
- 기존 프로젝트에서 art prompt 파일 시스템을 회고적으로 적용
- art-bible 의 §Z 슬롯 추출 → 누락된 prompt.md 생성, 기존 PNG 는 보존
- 이미 PNG 있으면 placeholder 재생성 ✕ (덮어쓰기 위험), prompt.md 만 생성

## 9. 변경 파일 목록

### 9.1 신규

| 파일 | 역할 |
|------|------|
| `prompts/prototype-build-loop/auto-build-orchestrator.md` | 0.1→0.4 자동 연쇄 제어, 실패 시 옵션 제시 |
| `prompts/prototype-build-loop/round0.1-scaffold.md` | scaffold (기존 round0-scaffold.md 핵심 이전) |
| `prompts/prototype-build-loop/round0.2-core-loop.md` | §B 코어 루프 1 cycle |
| `prompts/prototype-build-loop/round0.3-systems-ac1.md` | AC1 필수 §C + 테스트 인프라 |
| `prompts/prototype-build-loop/round0.4-art-placeholders.md` | art-bible 슬롯 → placeholder + prompt.md |
| `.claude/skills/prototype-build-loop/tools/gen_placeholders.py` | PIL 헬퍼 (§6.2 규칙) |

### 9.2 수정

| 파일 | 변경 |
|------|------|
| `.claude/skills/prototype-build-loop/SKILL.md` | §2 모드 / §3 트리거 / §6 Round 0 절차 → orchestrator 위임 / 실패 처리 §추가 / §10 0.3→0.4 마이그레이션 |
| `prompts/prototype-build-loop/round0-scaffold.md` | deprecated (top 에 1줄 표기 + auto-build-orchestrator 참조 링크) |
| `pipeline.yaml` | `version: "0.3" → "0.4"`, `steps[5].iteration_log.schema` 에 substep round_variants 추가 |
| `.claude/skills/prototype-build-loop/engines/godot.md` | 에셋 로드 컨벤션 (`art/{slot_id}.png`) 1줄 |
| `.claude/skills/prototype-build-loop/engines/unity.md` | 동일 |
| `prompts/06b-art-bible.md` | 출력에 §Z 슬롯 테이블 강제 |
| `.claude/commands/prototype-start.md` (있으면) | orchestrator 진입점 호출 |

### 9.3 영향 ✕

- `prompts/prototype-build-loop/roundN-patch.md` (Round 1+ 그대로)
- `prompts/01-concept.md` ~ `06-spec.md` (단계 1~6)
- `workspace/whatever-bites/*`, `workspace/sail-and-cast/*` (기존 프로젝트)

## 10. 테스트 전략

### 10.1 단위 테스트

- `tools/gen_placeholders.py`: 카테고리별 PNG 생성 정확도 (도형·색·라벨), 슬롯 테이블 파싱 (정상·결손 케이스)
- art-bible §Z 파서: 정규 테이블·결손·중복 slot_id 처리

### 10.2 통합 테스트 (smoke)

- 신규 프로젝트 mock 으로 단계 7 통과 상태 → "프로토타입 시작" → 0.1~0.4 자동 진행 → commit 4개 + ITERATION_LOG 4 항목 검증
- substep 중간 실패 주입 (예: 어댑터 매핑 누락) → 옵션 3 가지 제시 검증
- 기존 프로젝트 (whatever-bites 상태) → 자동 빌드 ✕, roundN-patch 진입 검증

### 10.3 E2E (수동, 사용자)

- 신규 게임 컨셉 → 단계 1~7 → "프로토타입 시작" → 자동 빌드 → AC1 테스트 결과 확인 → Round 1 사용자 피드백

## 11. 마이그레이션 (pipeline.yaml v0.3 → v0.4)

1. `pipeline.yaml.version: "0.3" → "0.4"`
2. `state.yaml`: `pipeline_version` 동기화 (선택), `build_state.current_substep` / `auto_build_status` 필드 추가 (기본값 null)
3. `.archive/state-pre-migration-{timestamp}.yaml` 백업
4. `state.yaml.notes` 에 `"schema migration 0.3 → 0.4 (auto-build substeps added)"` 1줄

SKILL.md §10 에 케이스 추가.

## 12. 미해결 / 추후

- §C 시스템 자동 선택의 정확도 — AC1 가설을 어떻게 §C 항목과 매핑할지 LLM 추론에 의존. tech-spec §I 에 AC↔§C 매핑이 명시되어 있으면 정확, 아니면 휴리스틱. **구현 계획 단계에서 tech-spec 의 AC 매핑 필드 강제 여부 결정**.
- art-bible §Z 슬롯 테이블 신규 강제 — 기존 06b-art-bible.md prompt 의 출력 형식 변경 필요. 기존 프로젝트의 art-bible 에는 §Z 가 없으므로 LLM 후추출 분기 (§6.1 후반부).
- Round 0.3 의 AC1 테스트가 의외로 무겁게 나오는 경우 (예: 통합 시나리오) — 어댑터별 *AC1 최소 인프라* 기준선이 어디까지인지 어댑터에 명시 필요.
- `/cp-art-rebuild` 슬래시 (회고 적용) 의 구체 절차 — 본 spec 범위 ✕, 별도 spec.

## 13. 결정 기록

| 결정 | 선택 | 이유 |
|------|------|------|
| 자동 빌드 범위 | AC §I 가설 1번 검증 가능 | 코어만 (A) 은 재미 평가 불가, 전체 (C) 는 Round 0 비대화 |
| Placeholder 방식 | 단색 도형 + 라벨 (PIL) | 자동 픽셀아트 (B) 는 placeholder 다듬기 노력 낭비, CC0 팩 (C) 은 라이선스·매핑 부담 |
| 프롬프트 파일 위치 | PNG 옆 sibling | manifest (C) 는 외부 도구 워크플로 추가 단계 필요, 별도 prompts/ (B) 는 동기화 부담 |
| 라운드 번호 규약 | 분수 (0.1~0.4) | 큰 Round 0 (A) 는 복구 불투명, 별도 단계 (C) 는 별도 로그 일관성 ↓ |
| AC1 stop 판정 | 테스트 실행 가능 (pass 무관) | 테스트 파일 존재만 (A) 은 안 굴러감, 통과 보장 (C) 은 LLM 자동 디버그 무한 루프 위험 |
