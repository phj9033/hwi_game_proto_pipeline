# auto-pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 컨셉 텍스트 + 엔진 선택 2회 입력만으로 게임 컨셉 정립 → 통합 명세서 → 프로토타입 빌드 → 완성도 충족 라운드까지 풀자동 수행하는 Claude Code 스킬 `auto-pipeline` 을 신설한다.

**Architecture:** 디렉터 (`.claude/skills/auto-pipeline/SKILL.md`) 가 상태 머신 + 정책 (자동 결정 / 종료 / 에스컬레이션) 을 들고, 무거운 substep (RAG, 빌드, critic, verify) 은 Agent 서브태스크 워커로 격리. 기존 `concept-pipeline` / `prototype-build-loop` 스킬은 무수정, prompts/yaml 만 재사용.

**Tech Stack:** Markdown SKILL.md, YAML state/work-order/worker-report 스키마, bash + python3 인라인 스모크 테스트, `pkm search` CLI 호출, Claude Agent 도구.

**Spec:** `docs/superpowers/specs/2026-05-19-auto-pipeline-design.md`

---

## File Structure

### 신규 생성
- `.claude/skills/auto-pipeline/SKILL.md` — 디렉터 (상태 머신 + 정책)
- `.claude/commands/auto-pipeline.md` — `/auto-pipeline` 슬래시
- `prompts/auto/critic.md` — critic 워커 prompt
- `prompts/auto/verify.md` — verify 워커 prompt
- `prompts/auto/pkm-fetch.md` — pkm-fetch 워커 prompt
- `prompts/auto/concept-stage-wrapper.md` — concept-stage 워커 wrapper (기존 01~06c 인용)
- `prompts/auto/build-substep-wrapper.md` — build-substep 워커 wrapper (기존 round0.* 인용)
- `prompts/auto/work-order-schema.md` — work-order YAML 스키마 + 예제
- `prompts/auto/worker-report-schema.md` — worker-report YAML 스키마 + 예제
- `tests/auto_pipeline_smoke.sh` — 구조·스키마 스모크 테스트

### 수정
- `pipeline.yaml` — version `0.6` → `0.7`, `state_schema` 에 auto-pipeline 필드 추가, changelog 항목 추가
- `.gitignore` — `workspace/*/work-orders/`, `worker-reports/`, `pkm-cache/`, `decisions.log`, `completion-report.md` 추가
- `.claude/hooks/session-start.sh` — auto-mode 슬러그 표시 분기 추가
- `README.md` — auto-pipeline 섹션 1개 추가

### 무수정 (회귀 가드)
- `.claude/skills/concept-pipeline/SKILL.md`
- `.claude/skills/prototype-build-loop/SKILL.md`
- `prompts/01~06c-*.md`
- `prompts/prototype-build-loop/round0.*.md`

---

## Phase 0 — 사전 작업

### Task 0: baseline 태그 + 워크스페이스 점검

**Files:** (없음 — git 작업만)

- [ ] **Step 1: 작업 시작 직전 commit 에 baseline 태그 부여**

Run: `git tag auto-pipeline-baseline`
Expected: 무출력 (이후 Task 17 회귀 가드가 이 태그 기준 diff 사용)

- [ ] **Step 2: 작업 트리 청결 확인**

Run: `git status`
Expected: "working tree clean" (또는 본 plan 외 변경 없음)

- [ ] **Step 3: 기존 두 스킬 SKILL.md 해시 기록 (작업 종료 시 비교용)**

```bash
shasum .claude/skills/concept-pipeline/SKILL.md .claude/skills/prototype-build-loop/SKILL.md > /tmp/auto-pipeline-baseline-hashes.txt
cat /tmp/auto-pipeline-baseline-hashes.txt
```

Expected: 2 라인 SHA-1 해시 출력 (Task 17 에서 동일성 점검)

---

## Phase 1 — 스모크 테스트 발판 (TDD anchor)

### Task 1: 빈 스모크 테스트 스켈레톤 작성

**Files:**
- Create: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 스켈레톤 스크립트 작성**

```bash
#!/usr/bin/env bash
# auto-pipeline 스모크 테스트
#
# 실행:  bash tests/auto_pipeline_smoke.sh
#
# 검증 항목:
#   1. pipeline.yaml v0.7 schema (mode/engine_choice/art_default/failed_orders 필드)
#   2. 신규 스킬·슬래시 파일 존재
#   3. prompts/auto/ 6개 파일 존재 + 필수 H2 헤더
#   4. .gitignore 패턴
#   5. session-start.sh 의 auto-mode 분기
#
# 종료 코드: 0 = 모두 통과, 1 = 1개 이상 실패

set -u

PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PIPELINE_ROOT"

PASS=0
FAIL=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo "=== auto-pipeline smoke test ==="
echo "ROOT: $PIPELINE_ROOT"
echo ""

# (어서션은 Task 2 이후 순차 추가)

echo ""
echo "─── 결과 ───"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

- [ ] **Step 2: 실행 가능 권한 부여 + 스켈레톤 실행 (PASS=0, FAIL=0 확인)**

Run: `chmod +x tests/auto_pipeline_smoke.sh && bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 0, "PASS: 0" "FAIL: 0"

- [ ] **Step 3: Commit**

```bash
git add tests/auto_pipeline_smoke.sh
git commit -m "test(auto-pipeline): smoke test skeleton"
```

---

## Phase 2 — pipeline.yaml v0.7 스키마 확장

### Task 2: state_schema 확장 어서션 추가

**Files:**
- Modify: `tests/auto_pipeline_smoke.sh` (어서션 추가)

- [ ] **Step 1: 어서션 블록 추가** (스켈레톤의 `# (어서션은 ... 순차 추가)` 자리에)

```bash
# ─── 1. pipeline.yaml v0.7+ schema ───
echo "[1] pipeline.yaml v0.7+ schema"
VERSION_OK=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
v = d['pipeline']['version'].split('.')
print('OK' if (int(v[0]), int(v[1])) >= (0, 7) else 'FAIL')
")
[[ "$VERSION_OK" == "OK" ]] && ok "pipeline.version >= 0.7" || fail "pipeline.version >= 0.7"

MODE_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'mode:' in ex else 'MISS')
")
[[ "$MODE_FIELD" == "OK" ]] && ok "state_schema example 에 mode 필드" || fail "state_schema example 에 mode 필드"

ENGINE_CHOICE_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'engine_choice:' in ex else 'MISS')
")
[[ "$ENGINE_CHOICE_FIELD" == "OK" ]] && ok "state_schema example 에 engine_choice 필드" || fail "state_schema example 에 engine_choice 필드"

ART_DEFAULT_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'art_default:' in ex else 'MISS')
")
[[ "$ART_DEFAULT_FIELD" == "OK" ]] && ok "state_schema example 에 art_default 필드" || fail "state_schema example 에 art_default 필드"

FAILED_ORDERS_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'failed_orders:' in ex else 'MISS')
")
[[ "$FAILED_ORDERS_FIELD" == "OK" ]] && ok "state_schema example 에 failed_orders 필드" || fail "state_schema example 에 failed_orders 필드"
```

- [ ] **Step 2: 스모크 실행 → 5개 FAIL 확인**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 1, "FAIL: 5"

- [ ] **Step 3: Commit**

```bash
git add tests/auto_pipeline_smoke.sh
git commit -m "test(auto-pipeline): state_schema v0.7 assertions (failing)"
```

### Task 3: pipeline.yaml 을 v0.7 로 bump + state_schema 확장

**Files:**
- Modify: `pipeline.yaml` (version, changelog, state_schema.example, state_schema.resume_fields)

- [ ] **Step 1: pipeline.yaml 의 `pipeline.version` 을 `"0.6"` → `"0.7"` 변경**

- [ ] **Step 2: `changelog` 리스트 맨 앞에 v0.7 항목 prepend**

```yaml
  - version: "0.7"
    date: "2026-05-19"
    summary: "auto-pipeline 스킬 도입: 풀자동 컨셉→프로토타입 흐름"
    breaking_changes: []
    additions:
      - "state_schema.example 에 mode, engine_choice, art_default, failed_orders 필드 추가 (auto-pipeline 전용)"
      - "state_schema.resume_fields 에 auto_state 그룹 신규 (mode, engine_choice, art_default, last_worker_report, failed_orders[])"
      - "기존 두 스킬 (concept-pipeline, prototype-build-loop) 은 이 필드들을 무시 (backward-compatible)"
    rationale:
      - "사용자 입력 2회 (컨셉, 엔진) 로 끝까지 자동 진행하는 별도 진입점 필요 — 기존 두 스킬은 대화형 결정 지점 보존"
```

- [ ] **Step 3: `state_schema.example` 블록에 새 필드 5개 추가** (yaml `example: |` 문자열 내부)

기존 예시 yaml 안에:
```yaml
    mode: auto                       # v0.7~: auto | manual. 기본 manual (기존 호환)
    engine_choice: null              # v0.7~: godot | unity | null. auto 모드 시작 시 사용자가 즉시 입력
    art_default: pixel_art           # v0.7~: pixel_art (디폴트) | <override>. 컨셉에 "3D"/"사실풍" 명시 시만 우회
    failed_orders: []                # v0.7~: 5회 한도 도달 후 우회된 work-order ID 리스트 (auto 모드 추적성)
    last_worker_report: null         # v0.7~: 가장 최근 완료 worker-report 파일명 (재개 시 다음 번호 산출)
```

- [ ] **Step 4: `state_schema.resume_fields` 에 `auto_state` 그룹 추가**

```yaml
    auto_state:                       # v0.7~: auto-pipeline 전용. mode=manual 이면 전부 무시
      mode: enum                     # auto | manual
      engine_choice: enum | null     # godot | unity | null
      art_default: string            # 디폴트 "pixel_art"
      last_worker_report: string | null
      failed_orders: list[string]    # ID 목록
```

- [ ] **Step 5: 스모크 실행 → 5개 PASS 확인**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 0, "PASS: 5" "FAIL: 0"

- [ ] **Step 6: Commit**

```bash
git add pipeline.yaml tests/auto_pipeline_smoke.sh
git commit -m "feat(pipeline.yaml): v0.7 — auto-pipeline state_schema 필드 추가"
```

---

## Phase 3 — work-order / worker-report 스키마 문서

### Task 4: work-order-schema.md 작성 + 스모크 어서션

**Files:**
- Create: `prompts/auto/work-order-schema.md`
- Modify: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 스모크에 어서션 추가**

```bash
# ─── 2. prompts/auto/ 파일 존재 ───
echo ""
echo "[2] prompts/auto/ 파일 존재"
for f in work-order-schema.md worker-report-schema.md critic.md verify.md pkm-fetch.md concept-stage-wrapper.md build-substep-wrapper.md; do
  [[ -f "prompts/auto/$f" ]] && ok "prompts/auto/$f 존재" || fail "prompts/auto/$f 없음"
done
```

- [ ] **Step 2: 스모크 실행 → 7개 FAIL 확인**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 7"

- [ ] **Step 3: `prompts/auto/work-order-schema.md` 작성**

```markdown
# work-order YAML 스키마

디렉터(`auto-pipeline` SKILL.md)가 워커(Agent 서브태스크)에게 작업을 지시하는 단일 입력 형식. **append-only**, 한 워커 호출당 1 파일.

## 파일 경로

`workspace/<slug>/work-orders/{NNN}-{stage}.yaml`

- `NNN` — 0부터 시작하는 3자리 시퀀스 (예: `001`, `002`, …)
- `stage` — `stage-01-concept`, `stage-04-eval`, `build-r0-substep-0.1`, `verify-r3`, `critic-r2-c`, `pkm-fetch-s01` 등

## 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `order_id` | string | ✓ | 파일명과 동일 |
| `worker_type` | enum | ✓ | concept-stage | build-substep | critic | verify | pkm-fetch |
| `stage` | int \| string | ✓ | 1~7 또는 "r0.1" 등 |
| `goal` | string | ✓ | 한 문장 작업 목표 |
| `inputs` | list[path] | ✓ | 워커가 읽을 파일 경로 |
| `prompt_file` | path | (concept-stage / build-substep 만) | 기존 prompts/ 경로 |
| `policy` | object | ✓ | art_default, engine, self_critique 등 |
| `constraints` | object | ✓ | output_path, decision_required 등 |
| `tier` | int | | 1~3 (재시도 tier), 첫 시도 시 1 |
| `parent_order_id` | string \| null | | Tier 3 분할 시 원 work-order |

## 예제 1 — concept-stage 워커 (단계 4 평가)

\`\`\`yaml
order_id: "003-stage-04-eval"
worker_type: concept-stage
stage: 4
goal: "A/B/C 5-Axis 평가 + 1위 선정"
inputs:
  - workspace/dragon-cafe/02-draft-A.md
  - workspace/dragon-cafe/02-draft-B.md
  - workspace/dragon-cafe/02-draft-C.md
  - workspace/dragon-cafe/pkm-cache/stage-04-rag.md
prompt_file: prompts/04-eval.md
policy:
  art_default: pixel_art
  engine: godot
  self_critique: true
constraints:
  output_path: workspace/dragon-cafe/04-eval-report.md
  decision_required: true
tier: 1
parent_order_id: null
\`\`\`

## 예제 2 — verify 워커 (Round 2 종료 점검)

\`\`\`yaml
order_id: "047-verify-r2"
worker_type: verify
stage: "r2"
goal: "Round 2 종료 후 3축 체크리스트 점검"
inputs:
  - workspace/dragon-cafe/06-integrated-spec.md
  - workspace/dragon-cafe/06-art-bible.md
  - workspace/dragon-cafe/06-tech-spec.md
  - workspace/dragon-cafe/build/godot/
policy:
  engine: godot
constraints:
  output_path: workspace/dragon-cafe/worker-reports/047-verify-r2.md
  thresholds:
    ac_pass_rate: 1.0
    ssot_coverage: 0.9
    art_slot_fill: 1.0
tier: 1
parent_order_id: null
\`\`\`

## 예제 3 — pkm-fetch 워커 (단계 5 시작)

\`\`\`yaml
order_id: "008-pkm-fetch-s05"
worker_type: pkm-fetch
stage: 5
goal: "단계 5 RAG 쿼리 결과 캐시 생성"
inputs:
  - pipeline.yaml
policy:
  pkm_scope: project   # pkm search 의 --scope. 미링크 시 wiki 폴백
constraints:
  output_path: workspace/dragon-cafe/pkm-cache/stage-05-rag.md
  query_source: pipeline.yaml.steps[4].rag_queries
tier: 1
parent_order_id: null
\`\`\`

## 검증 규칙

- `worker_type=concept-stage` 또는 `build-substep` → `prompt_file` 필수
- `worker_type=pkm-fetch` → `policy.pkm_scope` 필수
- `worker_type=verify` → `constraints.thresholds` 필수
- `tier=3` → `parent_order_id` 필수

## 변경 이력

| 버전 | 날짜 | 내용 |
|------|------|------|
| 0.1 | 2026-05-19 | 초안 (auto-pipeline 도입) |
```

- [ ] **Step 4: 스모크 실행 → work-order-schema.md PASS, 나머지 6 FAIL**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 6", "FAIL: 6"

- [ ] **Step 5: Commit**

```bash
git add prompts/auto/work-order-schema.md tests/auto_pipeline_smoke.sh
git commit -m "feat(auto-pipeline): work-order YAML 스키마 정의"
```

### Task 5: worker-report-schema.md 작성

**Files:**
- Create: `prompts/auto/worker-report-schema.md`

- [ ] **Step 1: `prompts/auto/worker-report-schema.md` 작성**

```markdown
# worker-report YAML 스키마

워커(Agent 서브태스크)가 작업 완료 후 디렉터에게 결과를 회수하는 단일 출력 형식. **append-only**, work-order 1개당 1 보고서.

## 파일 경로

`workspace/<slug>/worker-reports/{NNN}-{stage}.md`

- `NNN`·`stage` 는 대응 work-order 와 동일 ID

## 파일 구조

`.md` 파일 상단에 YAML frontmatter, 본문에 사람이 읽을 요약·이슈·에러 로그.

\`\`\`markdown
---
order_id: "003-stage-04-eval"
worker_type: concept-stage
status: completed              # completed | failed | partial
started_at: "2026-05-19T10:23:11Z"
completed_at: "2026-05-19T10:25:48Z"
outputs:
  - path: workspace/dragon-cafe/04-eval-report.md
    summary: "5-Axis 평균 A=3.8 B=4.2 C=3.5. B 가 1위."
decision_proposal:              # decision_required=true 시 필수
  choice: "B"
  rationale: "B 의 Depth 4.5, Novelty 4.0 이 결정적..."
issues: []                      # 빈 리스트면 정상
tier_used: 1                    # 이 보고가 몇 번째 tier 시도였나
---

## 요약
(사람이 읽을 본문)

## 이슈 / 미달 항목
(있으면 bullet)

## 에러 로그
(failed/partial 일 때만)
\`\`\`

## 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `order_id` | string | ✓ | 대응 work-order |
| `worker_type` | enum | ✓ | work-order 와 동일 |
| `status` | enum | ✓ | completed | failed | partial |
| `started_at` | ISO 8601 | ✓ | 워커 시작 UTC |
| `completed_at` | ISO 8601 | ✓ | 워커 종료 UTC |
| `outputs` | list[object] | ✓ | path, summary 쌍 |
| `decision_proposal` | object | decision_required=true 시 | choice, rationale |
| `issues` | list[string] | ✓ | 빈 리스트라도 명시 |
| `tier_used` | int | ✓ | 1 \| 2 \| 3 |

## status 별 디렉터 동작

| status | 디렉터 동작 |
|--------|-----------|
| completed | decisions.log append, state.yaml 갱신, 다음 work-order 디스패치 |
| partial | tier+1 로 같은 work-order 재시도 (보강 수행) |
| failed | tier+1 로 재시도. tier=3 실패 후 누적 5회 도달 시 우회 |

## verify 워커 전용 추가 필드

verify 워커의 frontmatter 에 `verify_axes` 추가:

\`\`\`yaml
verify_axes:
  ac_pass_rate: 0.85          # AC 테스트 PASS 비율 (0~1)
  ssot_coverage: 0.92         # SSOT 9섹션 covered 율 (0~1)
  art_slot_fill: 1.00         # art-bible 슬롯 채움률 (0~1)
verdict: FAIL                  # PASS | FAIL
failing_items:
  - "AC §I-3 (인벤토리 슬롯 한계) 미통과"
  - "SSOT §F.2 (저장 구조) 빈 슬롯"
\`\`\`

## 변경 이력

| 버전 | 날짜 | 내용 |
|------|------|------|
| 0.1 | 2026-05-19 | 초안 (auto-pipeline 도입) |
```

- [ ] **Step 2: 스모크 실행 → PASS: 7, FAIL: 5**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 7", "FAIL: 5"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/worker-report-schema.md
git commit -m "feat(auto-pipeline): worker-report YAML 스키마 정의"
```

---

## Phase 4 — 워커 prompt 파일

### Task 6: pkm-fetch.md 워커 prompt

**Files:**
- Create: `prompts/auto/pkm-fetch.md`

- [ ] **Step 1: `prompts/auto/pkm-fetch.md` 작성**

```markdown
# pkm-fetch 워커 prompt

당신은 auto-pipeline 의 pkm-fetch 워커다. 디렉터가 전달한 work-order 의 단계별 RAG 쿼리를 실행하고 결과를 캐시 파일로 저장한다.

## 입력
- work-order YAML (단일 인자)
- `pipeline.yaml.steps[<stage-1>].rag_queries` — 쿼리 리스트
- `pkm` CLI (`pkm search <query>`)

## 처리

1. work-order.constraints.query_source 에서 쿼리 리스트 추출
2. 각 쿼리마다 `pkm search "<query>" --top-n 5 --scope <policy.pkm_scope> --json` 호출
3. 결과를 한 markdown 파일로 묶어 work-order.constraints.output_path 에 저장:

\`\`\`markdown
# stage <N> RAG 결과 캐시

생성: <ISO 8601>
쿼리: <count> 개

## Query 1: "<쿼리>"

### Hit 1: <title>
<excerpt>

### Hit 2: ...

## Query 2: ...
\`\`\`

4. 빈 결과는 "(결과 없음)" 으로 명시 (워커가 흐름 깨지 않게)
5. `pkm` CLI 가 PATH 에 없거나 exit code != 0 면:
   - status: partial 보고
   - 본문에 "PKM 미연결 — LLM 자체 지식으로 진행" 1줄 캐시 작성
   - 디렉터는 partial 도 다음 단계 진행 (P5 우회 가능 정책)

## 출력
- 캐시 파일 (work-order.constraints.output_path)
- worker-report (`worker-reports/{order_id}.md`)

## worker-report 작성 규칙

\`\`\`yaml
---
order_id: "{order_id}"
worker_type: pkm-fetch
status: completed | partial
outputs:
  - path: <캐시 경로>
    summary: "단계 <N> 쿼리 <count>개 중 <hit_total> 결과"
issues: []
tier_used: 1
---
\`\`\`

## 절대 금지
- 컨셉 정립·평가·결정 활동 (다른 워커의 영역)
- 사용자에게 질문
- work-order 외 임의 쿼리 추가
```

- [ ] **Step 2: 스모크 실행 → PASS: 8, FAIL: 4**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 8", "FAIL: 4"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/pkm-fetch.md
git commit -m "feat(auto-pipeline): pkm-fetch 워커 prompt"
```

### Task 7: critic.md 워커 prompt

**Files:**
- Create: `prompts/auto/critic.md`

- [ ] **Step 1: `prompts/auto/critic.md` 작성**

```markdown
# critic 워커 prompt

당신은 auto-pipeline 의 critic 워커다. 다른 워커가 만든 1차 산출물을 검토하고 비평·수정안을 돌려준다 (P2 2-pass 자체 비평).

## 입력
- work-order YAML
- 비평 대상 산출물 (`inputs[0]`)
- 동 단계의 prompt 파일 (`inputs[1]`)
- (옵션) 같은 단계 PKM 캐시 (`inputs[2]`)

## 처리

1. 산출물을 prompt 파일의 출력 스키마·체크리스트와 정합 검사
2. 다음 4축으로 1줄 비평:
   - **누락**: prompt 가 요구한 섹션·필드 빠짐
   - **모순**: 산출물 내부 / SSOT 와 충돌
   - **모호**: 후속 워커가 둘 이상으로 해석 가능한 표현
   - **YAGNI**: prompt 가 요구하지 않은 과잉 내용
3. 비평이 1건 이상이면 **수정안 문단** 작성 — 산출물에 패치해 넣을 구체 텍스트 (어디에 무엇을 추가/수정)
4. 비평 0건이면 status: completed + decision_proposal.choice="accept_as_is"

## 비평 작성 형식 (worker-report 본문)

\`\`\`markdown
## 비평

- [누락] <섹션명>: <한 문장>
- [모순] <대상>: <한 문장>
- [모호] <표현>: <한 문장>
- [YAGNI] <대상>: <한 문장>

## 수정안

(누락 보강 · 모순 해결 · 모호 명확화 · YAGNI 제거 의 패치 문단)
\`\`\`

## worker-report frontmatter

\`\`\`yaml
---
order_id: "{order_id}"
worker_type: critic
status: completed
outputs:
  - path: worker-reports/{order_id}.md
    summary: "<비평 N건> | accept_as_is"
decision_proposal:
  choice: revise | accept_as_is
  rationale: "..."
issues: []
tier_used: 1
---
\`\`\`

## 디렉터의 후속

- choice=revise → 디렉터가 같은 stage 의 concept-stage 워커에게 **수정안 패치를 적용해 최종본을 출력** 하는 work-order 재발행
- choice=accept_as_is → 디렉터가 1차 산출물을 최종으로 채택

## 절대 금지
- 산출물 자체를 직접 덮어쓰기 (재호출은 디렉터가 결정)
- 새 RAG 쿼리 (이미 PKM 캐시가 있다면 그것만 인용)
- 비평을 5건 초과 작성 (가장 중대한 4건 이내)
```

- [ ] **Step 2: 스모크 실행 → PASS: 9, FAIL: 3**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 9", "FAIL: 3"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/critic.md
git commit -m "feat(auto-pipeline): critic 워커 prompt"
```

### Task 8: verify.md 워커 prompt

**Files:**
- Create: `prompts/auto/verify.md`

- [ ] **Step 1: `prompts/auto/verify.md` 작성**

```markdown
# verify 워커 prompt

당신은 auto-pipeline 의 verify 워커다. 빌드 라운드 종료 시 P3 3축 체크리스트로 종료 조건 충족 여부를 판정한다.

## 입력
- work-order YAML (`constraints.thresholds` 필수)
- `06-integrated-spec.md` (SSOT)
- `06-art-bible.md`
- `06-tech-spec.md` (§H 에 AC 정의)
- `build/<engine>/` 디렉토리

## 3축 점검 절차

### 축 1 — AC 테스트 PASS율
1. `06-tech-spec.md` §H 의 AC 리스트 추출 (`AC §<섹션>-<번호>: <조건>` 형식)
2. 각 AC 에 대해 `build/<engine>/` 의 테스트 산출물(있으면) 또는 코드 정합성 확인
3. PASS 수 / 전체 수 = `ac_pass_rate`

### 축 2 — SSOT 9섹션 covered 율
1. SSOT §A ~ §I 각 섹션에서 "최소 충족 항목" 추출 (각 섹션의 H3 헤더)
2. 빌드 산출물(코드·씬·콘텐츠) 에서 각 항목 구현 여부 확인
3. covered 수 / 전체 수 = `ssot_coverage`

### 축 3 — art-bible 슬롯 채움률
1. `06-art-bible.md` 의 슬롯 테이블 추출 (스프라이트 슬롯, UI 슬롯 등)
2. `build/<engine>/` 에서 각 슬롯 경로에 placeholder 라도 존재하는지 확인
3. 채워진 슬롯 수 / 전체 슬롯 수 = `art_slot_fill`

## 판정

\`\`\`
verdict = PASS  if all three axes >= constraints.thresholds
        | FAIL  otherwise
\`\`\`

## 출력 — worker-report (verdict + failing_items)

\`\`\`yaml
---
order_id: "{order_id}"
worker_type: verify
status: completed
outputs:
  - path: worker-reports/{order_id}.md
    summary: "verdict=<P/F>, ac=<x.xx>, ssot=<x.xx>, art=<x.xx>"
verify_axes:
  ac_pass_rate: 0.85
  ssot_coverage: 0.92
  art_slot_fill: 1.00
verdict: FAIL
failing_items:
  - "AC §I-3 (인벤토리 슬롯 한계) 미통과"
  - "SSOT §F.2 (저장 구조) 빈 슬롯"
issues: []
tier_used: 1
---
\`\`\`

## 디렉터의 후속

- verdict=PASS → completion-report.md 생성, 흐름 종료
- verdict=FAIL → `failing_items` 를 입력으로 다음 라운드 build-substep 워커 디스패치
- 라운드 카운트 ≥ 10 (P3 D) → 강제 종료, completion-report 에 미달 리스트

## 절대 금지
- 자체적으로 빌드 수정 (verify 는 측정만)
- 임의 기준 추가 (constraints.thresholds 만)
- 사용자에게 질문
```

- [ ] **Step 2: 스모크 실행 → PASS: 10, FAIL: 2**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 10", "FAIL: 2"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/verify.md
git commit -m "feat(auto-pipeline): verify 워커 prompt"
```

### Task 9: concept-stage-wrapper.md 워커 prompt

**Files:**
- Create: `prompts/auto/concept-stage-wrapper.md`

- [ ] **Step 1: `prompts/auto/concept-stage-wrapper.md` 작성**

```markdown
# concept-stage-wrapper 워커 prompt

당신은 auto-pipeline 의 concept-stage 워커다. 기존 `concept-pipeline` 의 단계별 prompt (prompts/01~06c-*.md) 를 자동 모드로 실행한다.

## 입력
- work-order YAML
- `prompt_file` 에 명시된 기존 prompt 파일 (예: `prompts/04-eval.md`)
- 이전 단계 산출물 (`inputs`)
- PKM 캐시 (`inputs` 마지막)
- (재호출 시) 동 단계 critic 보고서

## 처리

### 모드 1 — 1차 호출
1. `prompt_file` 의 본문을 그대로 읽음
2. work-order.constraints.output_path 의 산출물 생성 — `prompt_file` 의 출력 스키마 그대로 따름
3. 사용자 대화 부분은 다음 자동 정책으로 대체:
   - **단계 1 (6 섹션 Q&A)**: work-order.inputs[0] (컨셉 텍스트) 에서 직접 추출, 빠진 섹션은 LLM 추론으로 채움 (P1)
   - **단계 2 (분기 축 지정)**: prompt 의 "자동 추천 축" 그대로 채택
   - **단계 4 (A/B/C 선택)**: 5-Axis 점수 1위 선택, 동률 시 critic 워커 회부 (이 워커는 1차에선 점수만 산출)
   - **단계 5 (약점 보강 방향)**: prompt 의 "추천 보강 방향" 그대로 채택
   - **단계 6 (SSOT 9섹션 합의)**: 9 섹션 모두 1차안으로 생성
   - **단계 6b/6c (art-bible/tech-spec)**: SSOT 그대로 인용, work-order.policy.art_default / engine 반영
4. work-order.policy.engine, art_default 를 산출물에 박음 (적용 가능 단계만)

### 모드 2 — 재호출 (critic 비평 반영)
1. 1차 산출물 + critic 워커의 수정안 문단을 읽음
2. 1차 산출물에 수정안 패치를 적용 — 동일 output_path 덮어쓰기 (`.bak` 백업 후)

## worker-report frontmatter

\`\`\`yaml
---
order_id: "{order_id}"
worker_type: concept-stage
status: completed | partial | failed
outputs:
  - path: <output_path>
    summary: "<산출물 핵심 한 문장>"
decision_proposal:                    # work-order.constraints.decision_required=true 시 필수
  choice: "<선택값>"
  rationale: "<근거>"
issues: []
tier_used: <1|2|3>
---
\`\`\`

## 단계별 decision_proposal.choice 값
- 단계 4: "A" | "B" | "C"
- 단계 5: "accept_recommended" | "<커스텀 방향 짧은 키>" (자동 모드는 항상 accept_recommended)
- 그 외: null (디렉터가 단순히 산출물만 받음)

## 절대 금지
- 사용자에게 질문
- 기존 prompt 파일 내용 무시 (반드시 출력 스키마 준수)
- work-order.policy 무시 (engine·art_default 누락 시 critic 워커가 적발)
```

- [ ] **Step 2: 스모크 실행 → PASS: 11, FAIL: 1**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "PASS: 11", "FAIL: 1"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/concept-stage-wrapper.md
git commit -m "feat(auto-pipeline): concept-stage-wrapper 워커 prompt"
```

### Task 10: build-substep-wrapper.md 워커 prompt

**Files:**
- Create: `prompts/auto/build-substep-wrapper.md`

- [ ] **Step 1: `prompts/auto/build-substep-wrapper.md` 작성**

```markdown
# build-substep-wrapper 워커 prompt

당신은 auto-pipeline 의 build-substep 워커다. 기존 `prototype-build-loop` 의 substep prompt (prompts/prototype-build-loop/round0.*.md, roundN-patch.md) 를 자동 모드로 실행한다.

## 입력
- work-order YAML
- `prompt_file` (예: `prompts/prototype-build-loop/round0.3-systems.md`)
- 06-* 3 산출물 (`inputs`)
- 현재 `build/<engine>/` 상태
- (Round N 시) verify 의 failing_items 리스트

## 처리

### Round 0 substep (0.1~0.5)
1. `prompt_file` 본문 그대로 실행
2. work-order.policy.engine 으로 어댑터 분기 (engines/godot.md or engines/unity.md)
3. work-order.policy.art_default 가 `pixel_art` 면 substep 0.5 에서 픽셀아트 placeholder 생성 경로. 헬퍼 위치: `.claude/skills/prototype-build-loop/tools/gen_placeholders.py` (기존 `prompts/prototype-build-loop/round0.5-art-placeholders.md` 가 이미 정확한 경로로 호출하므로, 워커는 해당 substep prompt 를 그대로 실행하면 됨)
4. 사용자 승인 부분은 자동 채택 (자동 모드)
5. build/<engine>/ 에 substep 시작 시 자동 git commit: `auto-r0-s{N}-pre`
6. substep 완료 시 git commit: `auto-r0-s{N}: <substep 명>`

### Round N (수정 라운드)
1. `prompts/prototype-build-loop/roundN-patch.md` 본문 그대로 실행
2. verify.failing_items 의 각 항목을 패치 대상으로 매핑
3. 사용자 승인 부분 자동 채택
4. SSOT 변경이 필요한 항목이 발견되면:
   - status: partial 보고 + 본문에 "SSOT 변경 필요: §<섹션>"
   - 디렉터가 이를 받아 단계 6 (concept-stage) 재호출로 분기

## worker-report frontmatter

\`\`\`yaml
---
order_id: "{order_id}"
worker_type: build-substep
status: completed | partial | failed
outputs:
  - path: build/<engine>/
    summary: "<변경 파일 수>개 변경, commit=<sha 8자리>"
issues: []
tier_used: <1|2|3>
substep_metadata:                     # build-substep 전용
  engine: godot | unity
  substep_id: "r0.3" | "rN-patch-<i>"
  commit_sha: "<8자리>"
  ssot_change_required: false         # true 면 디렉터가 단계 6 재호출
---
\`\`\`

## 절대 금지
- 사용자에게 질문
- SSOT 자체 수정 (룰 변경은 디렉터가 단계 6 재호출로만 가능)
- work-order.policy.engine 외 엔진 호출
- art_default 무시 (Round 0.5 에서 pixel_art 슬롯 채움 필수, 단 컨셉에 "3D" 명시 시 SSOT 가 우선)
```

- [ ] **Step 2: 스모크 실행 → PASS: 12, FAIL: 0**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 0, "PASS: 12", "FAIL: 0"

- [ ] **Step 3: Commit**

```bash
git add prompts/auto/build-substep-wrapper.md
git commit -m "feat(auto-pipeline): build-substep-wrapper 워커 prompt"
```

---

## Phase 5 — 디렉터 SKILL.md

### Task 11: SKILL.md 스켈레톤 + 스모크 어서션

**Files:**
- Create: `.claude/skills/auto-pipeline/SKILL.md`
- Modify: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 스모크에 어서션 추가**

```bash
# ─── 3. 신규 스킬 파일 존재 ───
echo ""
echo "[3] 신규 스킬·슬래시 파일"
[[ -f ".claude/skills/auto-pipeline/SKILL.md" ]] && ok "SKILL.md 존재" || fail "SKILL.md 없음"
[[ -f ".claude/commands/auto-pipeline.md" ]] && ok "auto-pipeline.md 슬래시 존재" || fail "auto-pipeline.md 슬래시 없음"

# ─── 4. SKILL.md 필수 H2 헤더 ───
echo ""
echo "[4] SKILL.md 필수 H2 헤더"
SKILL_FILE=".claude/skills/auto-pipeline/SKILL.md"
if [[ -f "$SKILL_FILE" ]]; then
  for h in "역할" "부팅" "디스패치 루프" "자동 결정 정책" "종료 조건" "에스컬레이션" "재개"; do
    grep -q "^## .*$h" "$SKILL_FILE" && ok "## …$h" || fail "## …$h 누락"
  done
else
  fail "SKILL.md 없음, H2 검사 skip"
fi
```

- [ ] **Step 2: 스모크 실행 → "SKILL.md 없음" 1건 + "슬래시 없음" 1건 + "H2 검사 skip" 1건 = FAIL: 3**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 3"

- [ ] **Step 3: Commit (테스트만 먼저)**

```bash
git add tests/auto_pipeline_smoke.sh
git commit -m "test(auto-pipeline): SKILL.md/슬래시 어서션 (failing)"
```

### Task 12: SKILL.md 본문 작성

**Files:**
- Create: `.claude/skills/auto-pipeline/SKILL.md`

- [ ] **Step 1: 디렉토리 생성 + SKILL.md 작성**

```bash
mkdir -p .claude/skills/auto-pipeline
```

```markdown
---
name: auto-pipeline
description: 컨셉 텍스트와 엔진 선택만 받으면 게임 컨셉 정립부터 프로토타입 빌드까지 풀자동 진행한다. 기존 concept-pipeline 의 7 단계와 prototype-build-loop 의 Round 0~N 을 데이터 재사용 방식으로 묶어, 무거운 substep 은 Agent 서브태스크로 격리한다. 결정 지점은 LLM 추천 + 자체 비평 2-pass 로 자동 채택, 종료는 3축 체크리스트(AC PASS / SSOT covered / art 슬롯 채움) + 라운드 상한 M=10 으로 판정. 트리거 - "/auto-pipeline", "오토 파이프라인 시작", "풀자동 게임 만들자", "자동으로 다 돌려", "이어서" (재개). 산출물은 메뉴부터 1주기 플레이 가능한 프로토타입.
---

# auto-pipeline — 풀자동 컨셉→프로토타입 디렉터

## 역할

당신은 auto-pipeline 의 디렉터다. 사용자 입력은 **시작 시점 1회 (컨셉 텍스트 + 엔진)** 와 **세션 끊김 후 "이어서" 한마디** 외엔 받지 않는다. 모든 결정·실행·검증은 워커(Agent 서브태스크) 에게 위임하고, 당신은 상태 머신·정책·디스패치만 관리한다.

## 부팅 — 신규 vs 재개

1. `workspace/.active` 확인
2. **존재 + state.yaml.mode == auto** → 재개 모드 (§재개)
3. **존재 + state.yaml.mode == manual** → 거부: "활성 슬러그가 manual 모드입니다. concept-pipeline 으로 이어가시거나 새 슬러그로 auto-pipeline 을 시작하세요."
4. **부재 (신규)** — 1 메시지로 다음 2 입력 동시 요청:
   ```
   auto-pipeline 시작. 다음을 한 메시지로 알려주세요:
   1) 컨셉 텍스트 (자유 형식, 길이 무관)
   2) 엔진 (godot / unity 중 하나)
   ```
   - 응답이 부족하면 (예: 엔진 누락) 1회 재질문 — 한도 2회. 한도 초과 시 거부.

신규 입력 받으면:
1. 슬러그 생성 — 컨셉의 핵심 명사 → kebab-case (예: "dragon-cafe")
2. `workspace/<slug>/` + 서브 디렉토리 생성: `work-orders/`, `worker-reports/`, `pkm-cache/`
3. `workspace/.active` 에 슬러그 1줄 기록
4. `state.yaml` 초기화 — `mode: auto`, `engine_choice: <choice>`, `art_default: pixel_art` (컨셉에 "3D"/"사실풍" 명시 시 우회), `failed_orders: []`
5. `decisions.log` 초기 1줄 — "auto-pipeline 시작: 컨셉='<요약 1줄>', 엔진=<choice>"
6. 단계 1 디스패치 (§디스패치 루프)

## 디스패치 루프

핵심 동작. 모든 워커 호출은 다음 7단계.

```
[1] 다음 work-order 생성 (시퀀스 NNN 증가)
[2] work-orders/{NNN}-{stage}.yaml 디스크에 기록
[3] Agent 도구로 워커 디스패치
    - subagent_type: general-purpose
    - description: "{worker_type}: {stage}"
    - prompt:
        "당신은 auto-pipeline 의 {worker_type} 워커.
         work-order 를 읽고 작업 수행:
         work-order: <YAML 내용 인용>
         워커 매뉴얼: prompts/auto/{worker}.md
         (필요시 기존 prompt_file 인용)
         완료 후 worker-reports/{NNN}-{stage}.md 작성."
[4] 워커 결과 회수 (마지막 메시지 == worker-report 경로)
[5] worker-reports/{NNN}-{stage}.md 읽음 (frontmatter 파싱)
[6] status 별 분기 (§에스컬레이션)
[7] state.yaml.last_worker_report 갱신 (atomic write)
```

`decisions.log` append (모든 결정·우회·tier 전이):

```
2026-05-19T10:25:48Z | order=003-stage-04-eval | choice=B | tier=1 | critic=accept
```

## 단계 흐름

### 단계 1~7 (concept-stage)

| 단계 | worker_type | prompt_file | 비고 |
|------|-------------|-------------|------|
| 1 | concept-stage | prompts/01-concept.md | 컨셉 텍스트 → 6 섹션 추출 (P1 B) |
| 2 | concept-stage | prompts/02-draft.md | 분기 축 자동 채택 |
| 3 | (gate-only) | — | 산출물 3종 존재 점검만, 워커 없음 |
| 4 | concept-stage | prompts/04-eval.md | A/B/C 5-Axis 평가, 1위 자동 선택 |
| 5 | concept-stage | prompts/05-expand.md | 약점 보강 추천 채택 |
| 6 | concept-stage | prompts/06-spec.md | SSOT 9섹션 |
| 6b | concept-stage | prompts/06b-art-bible.md | 픽셀아트 디폴트 박힘 |
| 6c | concept-stage | prompts/06c-tech-spec.md | engine 박힘 |
| 7 | (gate-only) | — | 산출물 4종 점검 (SSOT + art-bible + tech-spec + changelog) |

각 prompt-driven 단계 진입 시:
1. pkm-fetch 워커 디스패치 → `pkm-cache/stage-{NN}-rag.md`
2. concept-stage 워커 디스패치 (1차)
3. critic 워커 디스패치
4. critic 의 decision_proposal.choice == "revise" 면 concept-stage 워커 재호출 (모드 2)
5. 최종 산출물 → `decisions.log` append → 다음 단계로

### 단계 8 (Round 0 자동 빌드)

단계 7 게이트 통과 시 사용자 질문 ✕. 즉시 진행:
1. `build/{engine}/` 디렉토리 생성 (기존이 비어있어야 함, 있으면 거부)
2. substep 0.1~0.5 순차 디스패치 (build-substep 워커)
3. 각 substep 시작 시 git commit `auto-r0-s{N}-pre`
4. substep 완료 시 git commit `auto-r0-s{N}: <명>` + `ITERATION_LOG.md` v0.{N} append

### 단계 9~N (Round N — 종료 조건 충족까지)

1. verify 워커 디스패치 → `verify_axes` + `verdict`
2. verdict=PASS → §종료
3. verdict=FAIL → `failing_items` 를 입력으로 build-substep 워커 디스패치 (Round N)
4. critic 워커 디스패치 (수정안 비평)
5. 다음 라운드로 (1번 반복)
6. 라운드 카운트 ≥ 10 도달 시 강제 §종료

## 자동 결정 정책 (P2)

모든 결정 지점에서 다음 절차:

1. **1차 추천**: concept-stage 워커가 prompt 의 "권고/추천" 옵션 그대로 채택
2. **자체 비평**: critic 워커 디스패치
3. **수정 채택**: critic.choice == "revise" 면 concept-stage 재호출, "accept_as_is" 면 1차 채택
4. **단계 4 만 점수 우선**: 5-Axis 점수 1위가 명백하면 critic 생략 가능 (점수차 ≥ 0.5)

모든 결정은 `decisions.log` append-only.

## 종료 조건 (P3)

**3축 체크리스트 + 라운드 상한 안전망**:

1. verify 워커의 `verify_axes` 가 work-order.constraints.thresholds 를 모두 충족
2. 또는 라운드 카운트 ≥ 10 도달 (강제 종료)

기본 thresholds:
- `ac_pass_rate: 1.0`
- `ssot_coverage: 0.9`
- `art_slot_fill: 1.0`

종료 시 `completion-report.md` 생성:
```markdown
# auto-pipeline 완성 보고서

생성: <ISO 8601>
프로젝트: <slug>
엔진: <engine>
라운드 수: <N>
verdict: <PASS|FORCED_TERMINATION>

## 산출물
- (경로 리스트)

## verify 최종 점수
- ac_pass_rate: x.xx
- ssot_coverage: x.xx
- art_slot_fill: x.xx

## 미달 항목 (verdict=FORCED_TERMINATION 일 때만)
- (failing_items 리스트)

## 우회된 work-orders
- (state.yaml.failed_orders)
```

사용자 알림:
```
▶ 프로토타입 완성 (verdict: PASS).
  메뉴부터 1주기 플레이 가능. 빌드: build/<engine>/
  보고서: workspace/<slug>/completion-report.md
```

## 에스컬레이션 (P4)

worker-report.status 별 디렉터 동작:

| status | tier | 동작 |
|--------|------|------|
| completed | * | decisions.log append, 다음 단계 |
| partial | 1 | 같은 work-order 의 tier=2 재발행 (보강: 에러 로그 + 추가 인용 + 엄격 스키마) |
| failed | 1 | tier=2 재발행 |
| partial / failed | 2 | tier=3 재발행 (critic 워커가 work-order 자체를 N개로 분할) |
| 3 | 누적 5회 도달 | 우회: `state.yaml.failed_orders` append, 다음 단계 진행. concept-stage / verify 는 예외 (§예외 정지) |

tier 별 보강 항목:
- **Tier 2**: work-order.inputs 에 직전 worker-report 추가, `policy.strict_schema: true` 추가
- **Tier 3**: critic 워커가 work-order 를 분할 → 각각 tier=1 로 재시작

### 예외 정지 — 사용자 호출

concept-stage / verify 워커가 누적 5회 도달 시:
1. 사용자에게 알림:
   ```
   ▶ auto-pipeline 정지: <단계명> 5회 시도 실패.
     마지막 보고: worker-reports/<NNN>-<stage>.md
     수동 개입 필요. concept-pipeline 또는 prototype-build-loop 로 이어가세요.
   ```
2. state.yaml.last_pause_reason = "auto_max_retries_exceeded"
3. 흐름 종료. 재시작은 manual 모드 권장.

## 재개

`SessionStart` 훅이 활성 슬러그 + `mode == auto` + 현재 단계/라운드 + `last_worker_report` 표시. 사용자가 "이어서" 한마디 입력 시:

1. state.yaml 읽음
2. `last_worker_report` 다음 시퀀스부터 디스패치 루프 진입
3. 진행 중이던 단계가 있으면 (last_worker_report 의 status == in-progress 라면 워커 디스패치 중 중단된 것) tier+1 로 재발행

## 픽셀아트 디폴트 규칙

- `state.yaml.art_default = "pixel_art"` (기본)
- 컨셉 텍스트에 `"3D"` / `"사실풍"` / `"realistic"` 1회 이상 등장 시 → 단계 1 워커가 6 섹션 추출하면서 `art_default` 를 컨셉의 표현으로 갱신
- 단계 6b art-bible 워커는 `art_default` 를 work-order.policy 로 받아 슬롯 정의에 박음
- substep 0.5 (build) 는 `art_default == "pixel_art"` 면 픽셀아트 placeholder 생성 경로

## 외부 도구

- `pkm search` — 단계별 RAG (pkm-fetch 워커가 호출)
- `pkm-recall` 스킬 — 파이프라인 시작 시 1회 사전 컨텍스트 로딩 (디렉터가 시작 시 한 번 Skill 호출)
- Agent 도구 — 모든 워커 디스패치

## 외부 자산 (재사용)

- `pipeline.yaml` — 단계 정의, RAG 쿼리
- `config.yaml` — 5-Axis 가중치
- `prompts/01~06c-*.md` — concept-stage 워커가 인용
- `prompts/prototype-build-loop/round0.*.md` / `roundN-patch.md` — build-substep 워커가 인용
- `engines/godot.md`, `engines/unity.md` — 어댑터
- `pipeline.yaml.steps[5].iteration_log` — ITERATION_LOG 스키마

## spec 참조

설계 근거: `docs/superpowers/specs/2026-05-19-auto-pipeline-design.md`
```

- [ ] **Step 2: 스모크 실행 → SKILL.md PASS, 슬래시만 FAIL: 1**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 1" ("auto-pipeline.md 슬래시 없음")

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/auto-pipeline/SKILL.md tests/auto_pipeline_smoke.sh
git commit -m "feat(auto-pipeline): SKILL.md 디렉터 본문"
```

---

## Phase 6 — 슬래시 + 훅 + .gitignore

### Task 13: /auto-pipeline 슬래시

**Files:**
- Create: `.claude/commands/auto-pipeline.md`

- [ ] **Step 1: 슬래시 파일 작성**

기존 `.claude/commands/` 의 다른 슬래시(예: `cp-status.md`) 포맷을 참고. 짧게:

```markdown
---
description: auto-pipeline 풀자동 컨셉→프로토타입 흐름 진입
allowed-tools: Skill
---

`auto-pipeline` 스킬을 invoke 하여 풀자동 흐름을 시작/재개한다.
```

- [ ] **Step 2: 스모크 실행 → 모두 PASS**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 0, "FAIL: 0"

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/auto-pipeline.md
git commit -m "feat(auto-pipeline): /auto-pipeline 슬래시"
```

### Task 14: .gitignore 갱신 + 스모크 어서션

**Files:**
- Modify: `.gitignore`
- Modify: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 스모크에 어서션 추가**

```bash
# ─── 5. .gitignore 패턴 ───
echo ""
echo "[5] .gitignore auto-pipeline 패턴"
for pat in "workspace/\*/work-orders/" "workspace/\*/worker-reports/" "workspace/\*/pkm-cache/" "workspace/\*/decisions.log" "workspace/\*/completion-report.md"; do
  unescaped=$(echo "$pat" | sed 's/\\\*/*/g')
  grep -qF "$unescaped" .gitignore && ok ".gitignore 에 $unescaped" || fail ".gitignore 에 $unescaped 누락"
done
```

- [ ] **Step 2: 스모크 → FAIL: 5**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 5"

- [ ] **Step 3: `.gitignore` 끝에 블록 추가**

```
# auto-pipeline (v0.7~)
workspace/*/work-orders/
workspace/*/worker-reports/
workspace/*/pkm-cache/
workspace/*/decisions.log
workspace/*/completion-report.md
```

- [ ] **Step 4: 스모크 → PASS**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 0"

- [ ] **Step 5: Commit**

```bash
git add .gitignore tests/auto_pipeline_smoke.sh
git commit -m "chore(auto-pipeline): .gitignore 패턴 추가"
```

### Task 15: session-start.sh 의 auto-mode 분기 + 스모크 어서션

**Files:**
- Modify: `.claude/hooks/session-start.sh`
- Modify: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 스모크에 어서션 추가**

```bash
# ─── 6. session-start.sh 의 auto-mode 분기 ───
echo ""
echo "[6] session-start.sh auto-mode 분기"
HOOK=".claude/hooks/session-start.sh"
if [[ -f "$HOOK" ]]; then
  grep -q "mode.*auto" "$HOOK" && ok "session-start.sh 에 auto 분기" || fail "session-start.sh 에 auto 분기 누락"
else
  fail "session-start.sh 없음"
fi
```

- [ ] **Step 2: 스모크 → FAIL: 1**

- [ ] **Step 3: `.claude/hooks/session-start.sh` 의 활성 슬러그 상태 출력 블록에 auto 분기 추가**

기존 슬러그 보고 블록 안에 (`state.yaml` 파싱 직후):

```bash
# auto-pipeline 모드면 별도 안내
MODE=$(python3 -c "import yaml; d=yaml.safe_load(open('$STATE_FILE')); print(d.get('mode','manual'))")
if [[ "$MODE" == "auto" ]]; then
  echo "  📌 활성 프로젝트 (auto-pipeline): $SLUG"
  echo "     이어가려면 \"이어서\" 또는 /auto-pipeline"
fi
```

(기존 manual 출력 블록 위에 if/else 분기로 묶음 — 구체 위치는 기존 파일 구조에 맞춰 조정)

- [ ] **Step 4: 스모크 → PASS**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: "FAIL: 0"

- [ ] **Step 5: Commit**

```bash
git add .claude/hooks/session-start.sh tests/auto_pipeline_smoke.sh
git commit -m "feat(auto-pipeline): session-start.sh auto-mode 분기"
```

---

## Phase 7 — README + 회귀 가드

### Task 16: README.md 에 auto-pipeline 섹션 추가

**Files:**
- Modify: `README.md`

- [ ] **Step 1: README 의 "다음 단계" 섹션 직후에 `### auto-pipeline (v0.7~)` 추가**

아래 텍스트를 그대로 추가 (내부 코드 블록은 들여쓰기로 표현하여 fence 충돌 방지):

    ### auto-pipeline (v0.7~)

    기존 두 스킬을 묶어 **컨셉 + 엔진 2회 입력만으로 끝까지 자동** 진행하는 별도 진입점. 결정 지점은 LLM 추천 + critic 자체 비평으로 자동 채택, 종료는 3축 체크리스트 + 라운드 상한으로 판정. 픽셀아트 디폴트 (외부 디자인 툴 부재 환경 가정).

        "/auto-pipeline" 또는 "오토 파이프라인 시작"
        → 컨셉 텍스트 + 엔진 (godot/unity) 1회 입력
        → 끝까지 자동 (세션 끊기면 "이어서" 한마디로 재개)

    자세한 내용: [auto-pipeline spec](docs/superpowers/specs/2026-05-19-auto-pipeline-design.md)

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(auto-pipeline): README 섹션 추가"
```

### Task 17: 회귀 가드 — 기존 두 스킬 무수정 확인 + 스모크 어서션

**Files:**
- Modify: `tests/auto_pipeline_smoke.sh`

- [ ] **Step 1: 회귀 어서션 추가** (Task 0 에서 만든 `auto-pipeline-baseline` 태그 기준)

```bash
# ─── 7. 회귀 가드: 기존 두 스킬 무수정 ───
echo ""
echo "[7] 회귀 가드"
if git rev-parse auto-pipeline-baseline >/dev/null 2>&1; then
  DIFF_CONCEPT=$(git diff --name-only auto-pipeline-baseline HEAD -- .claude/skills/concept-pipeline/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  DIFF_BUILD=$(git diff --name-only auto-pipeline-baseline HEAD -- .claude/skills/prototype-build-loop/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  [[ "$DIFF_CONCEPT" == "0" ]] && ok "concept-pipeline SKILL.md 무수정" || fail "concept-pipeline SKILL.md 수정됨"
  [[ "$DIFF_BUILD" == "0" ]] && ok "prototype-build-loop SKILL.md 무수정" || fail "prototype-build-loop SKILL.md 수정됨"
else
  warn() { echo "  ⚠️  $1"; }
  warn "auto-pipeline-baseline 태그 없음 — 회귀 가드 skip (Task 0 미수행)"
fi
```

> 주: 본 어서션은 Task 0 의 `git tag auto-pipeline-baseline` 이 선행되어야 동작한다. baseline 태그가 없으면 경고 후 skip (실패 처리 ✕) — plan 적용 환경에 따라 baseline 시점이 다를 수 있어 강제 실패는 피한다.

- [ ] **Step 2: 스모크 → 모두 PASS**

Run: `bash tests/auto_pipeline_smoke.sh`
Expected: 종료 코드 0

- [ ] **Step 3: Commit**

```bash
git add tests/auto_pipeline_smoke.sh
git commit -m "test(auto-pipeline): 기존 스킬 무수정 회귀 가드"
```

### Task 18: 최종 전체 스모크 + 기존 스모크 회귀 점검

**Files:** (없음 — 실행만)

- [ ] **Step 1: 모든 스모크 실행**

Run: `bash tests/pipeline_smoke.sh && bash tests/build_loop_smoke.sh && bash tests/auto_pipeline_smoke.sh`
Expected: 3개 모두 종료 코드 0

- [ ] **Step 2: 기존 스킬 동작 수동 확인 (옵션)**

`/concept-pipeline` 슬래시가 여전히 호출되는지, `/prototype-start` 가 여전히 호출되는지 — `.claude/commands/` 트리만 점검 (실 실행은 불필요)

- [ ] **Step 3: 변경 요약 commit (옵션, 빈 commit 또는 CHANGELOG 갱신)**

전체 PR 의 changelog 가 필요하면 별도 commit. plan 마지막 마무리.

---

## 검증 체크리스트 (모든 Task 완료 후)

- [ ] `pipeline.yaml.version >= 0.7`
- [ ] `.claude/skills/auto-pipeline/SKILL.md` 존재 + 7개 H2 (역할, 부팅, 디스패치 루프, 자동 결정 정책, 종료 조건, 에스컬레이션, 재개)
- [ ] `.claude/commands/auto-pipeline.md` 존재
- [ ] `prompts/auto/` 에 7 파일 (스키마 2 + 워커 5)
- [ ] `.gitignore` 에 5 패턴
- [ ] `session-start.sh` auto-mode 분기
- [ ] `README.md` auto-pipeline 섹션
- [ ] 3개 스모크 (pipeline, build_loop, auto_pipeline) 모두 PASS
- [ ] 기존 두 스킬 SKILL.md 무수정
- [ ] 기존 `prompts/01~06c-*.md`, `prompts/prototype-build-loop/round0.*.md`, `roundN-patch.md` 무수정

---

## 알려진 외부 의존 (구현자 주의)

1. **`pkm` CLI 가 PATH 에 있어야 pkm-fetch 워커가 정상 동작** — 없으면 `partial` 보고 + 빈 캐시. spec §11 알려진 한계 참조.
2. **Agent 도구 (general-purpose subagent)** 가 무겁게 호출됨 — Round 0 만 해도 5 substep × (1 워커 + 1 critic) = 10 회. 컨셉 7단계 × 평균 3 워커 = 21 회. 한 번 시동 시 총 30~50회 Agent 호출 예상.
3. **워커가 부모 컨텍스트 못 봄** — work-order 의 inputs 파일 경로로만 정보 전달. 디스패치 prompt 작성 시 work-order YAML 내용을 prompt 본문에 인용해야 함 (디렉터 §디스패치 루프 [3] 참조).
4. **세션 끊기면 Claude Code 안에서 다음 세션 자동 기동 ✕** — "이어서" 한마디 입력 필요. spec §11 한계 참조.
5. **`build/` git commit** 은 부모 레포의 commit (별도 sub-repo 아님). spec 리뷰 권고 5번 반영.

---

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-05-19 | 초안 작성 (spec 2026-05-19-auto-pipeline-design.md 기반). 18 Task, 7 Phase |
