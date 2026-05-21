# spec-pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 신규 `spec-pipeline` 스킬 구축 — 컨셉 텍스트 1회 입력 → GDD/기술명세서/아트명세서 3개 자동 산출. 기존 스킬 무수정.

**Architecture:** 데이터 주도 (`spec-pipeline.yaml` + `prompts/spec/`) + 자동 흐름 스킬 (`SKILL.md`) + 4 게이트 (G1~G4) + 끝단 2 문서 병렬 subagent. PKM-recall 1회 응축 호출.

**Tech Stack:** Markdown + YAML + Bash 스모크 테스트 + Python (yaml 파싱) — 기존 레포 패턴 동일.

**Spec:** `docs/superpowers/specs/2026-05-21-spec-pipeline-design.md`

---

## File Structure

**Create:**

```
spec-pipeline.yaml                              # 단계 + 게이트 + 스키마 정의
.claude/skills/spec-pipeline/SKILL.md           # 자동 흐름 스킬
prompts/spec/01-inference.md                    # G1 추론 프롬프트
prompts/spec/02-pkm-query.md                    # PKM 쿼리 + 점수화
prompts/spec/03-gdd.md                          # GDD master 작성
prompts/spec/03-gdd-partial.md                  # G3 partial-edit 모드
prompts/spec/04-style-options.md                # 아트 스타일 후보 생성
prompts/spec/05a-tech.md                        # tech-spec-writer subagent
prompts/spec/05b-art.md                         # art-spec-writer subagent
tests/spec_pipeline_smoke.sh                    # 단위 스모크 테스트
tests/spec_pipeline_no_regression.sh            # 기존 스킬 무수정 가드
tests/spec_pipeline_resume.sh                   # 재개 회귀 테스트
tests/spec_pipeline/golden/short-pitch.txt      # 골든 입력 1
tests/spec_pipeline/golden/medium-paragraph.txt # 골든 입력 2
tests/spec_pipeline/golden/long-memo.txt        # 골든 입력 3
tests/spec_pipeline/golden/EXPECTED.md          # 골든 검증 기준 (구조만, 내용 ✕)
```

**Do not modify (회귀 가드 대상):**
- `pipeline.yaml`, `config.yaml`
- 기존 `prompts/*.md` (sibling 디렉토리 추가만 허용)
- `.claude/skills/concept-pipeline/`, `.claude/skills/auto-pipeline/`, `.claude/skills/prototype-build-loop/`
- 기존 hooks, commands

**Allowed to modify (선택, 마지막 작업):**
- `README.md` (신규 파이프라인 1섹션 추가)
- `.claude/hooks/session-start.sh` (만약 spec_pipeline 활성 슬러그 표시 필요 시. 보수적으로 미수정 선호 — 별도 task 로 결정)

---

## Phase A — 스켈레톤 + 회귀 가드

### Task 1: 기존 스킬 무수정 회귀 가드 작성

**Files:**
- Create: `tests/spec_pipeline_no_regression.sh`

먼저 회귀 가드를 만들어 이후 모든 작업이 이 가드를 통과하도록 한다.

- [ ] **Step 1: baseline 태그 결정**

현재 main 의 HEAD 가 baseline. 추가 태그는 만들지 않고 작업 시작 전 SHA 를 기록한다.

Run:
```bash
git rev-parse HEAD > /tmp/spec-pipeline-baseline-sha
cat /tmp/spec-pipeline-baseline-sha
```
Expected: 40자 SHA 출력. (테스트 스크립트 안에 하드코딩하지 않고 환경변수/파라미터로 전달)

- [ ] **Step 2: no_regression.sh 작성**

```bash
#!/usr/bin/env bash
# spec-pipeline 작업 중 기존 스킬·yaml·prompts 가 수정되지 않았음을 단언.
# baseline SHA 와 비교해 다음 경로의 modified == 0, added 만 허용.
#
# 사용: BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh

set -u
BASELINE="${BASELINE:?BASELINE env var required (e.g. git rev-parse main)}"

PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PIPELINE_ROOT"

PASS=0
FAIL=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo "=== spec-pipeline no-regression guard ==="
echo "BASELINE: $BASELINE"
echo ""

# 가드 대상 경로
GUARDED_PATHS=(
  "pipeline.yaml"
  "config.yaml"
  ".claude/skills/concept-pipeline/"
  ".claude/skills/auto-pipeline/"
  ".claude/skills/prototype-build-loop/"
  ".claude/hooks/"
  ".claude/commands/"
)

# 기존 prompts/*.md 는 sibling 추가만 허용. 기존 파일은 무수정.
EXISTING_PROMPTS=$(git ls-tree -r --name-only "$BASELINE" -- prompts/ | grep -E '\.md$' || true)

for path in "${GUARDED_PATHS[@]}"; do
  changed=$(git diff --name-status "$BASELINE" -- "$path" | awk '$1 ~ /^[MD]/ {print $2}')
  if [ -z "$changed" ]; then
    ok "$path 변경 없음"
  else
    fail "$path 변경됨: $changed"
  fi
done

# 기존 prompts 무수정 (추가만 허용)
for p in $EXISTING_PROMPTS; do
  changed=$(git diff --name-status "$BASELINE" -- "$p" | awk '$1 ~ /^[MD]/ {print $2}')
  if [ -z "$changed" ]; then
    : # OK
  else
    fail "기존 prompt 변경됨: $p"
  fi
done
echo "  (기존 prompts $(echo $EXISTING_PROMPTS | wc -w)개 무수정 확인)"
ok "기존 prompts 무수정"

echo ""
echo "Result: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 3: 가드 실행 — 베이스라인 대비 변경 없음을 확인**

Run:
```bash
chmod +x tests/spec_pipeline_no_regression.sh
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh
```
Expected: 모든 항목 ✅, exit 0

- [ ] **Step 4: Commit**

```bash
git add tests/spec_pipeline_no_regression.sh
git commit -m "test(spec-pipeline): 기존 스킬 무수정 회귀 가드 (baseline 비교)"
```

---

### Task 2: 스모크 테스트 — 스켈레톤 파일 부재 단언 (Red)

**Files:**
- Create: `tests/spec_pipeline_smoke.sh`

스켈레톤 파일들이 아직 없음을 단언하는 테스트를 먼저 만들어 TDD red 상태로 시작한다. 단, 우리는 곧 만들 것이므로 테스트는 "있을 때 통과" 로 작성하고, 1차 실행은 fail 상태가 정상.

- [ ] **Step 1: smoke.sh 작성**

```bash
#!/usr/bin/env bash
# spec-pipeline 스모크 테스트
#
# 검증 항목:
#   1. spec-pipeline.yaml 파싱
#   2. .claude/skills/spec-pipeline/SKILL.md 존재 + frontmatter 유효
#   3. prompts/spec/ 6개 + 1개 (partial) 파일 존재 (01, 02, 03, 03-partial, 04, 05a, 05b)
#   4. spec-pipeline.yaml 의 prompts 참조가 실제 파일 가리킴
#   5. spec-pipeline.yaml.version 이 "0.x" string
#   6. state.yaml 네임스페이스 키 (spec_pipeline) 가 schema 에 등장
#
# 종료 코드: 0 = 모두 통과, 1 = 1개 이상 실패

set -u
PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PIPELINE_ROOT"

PASS=0
FAIL=0
ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo "=== spec-pipeline smoke test ==="
echo "ROOT: $PIPELINE_ROOT"
echo ""

# [1] YAML 파싱
echo "[1] spec-pipeline.yaml 파싱"
if [ -f spec-pipeline.yaml ] && python3 -c "import yaml; yaml.safe_load(open('spec-pipeline.yaml'))" 2>/dev/null; then
  ok "spec-pipeline.yaml 파싱 OK"
else
  fail "spec-pipeline.yaml 파싱 실패 또는 부재"
fi

# [2] SKILL.md 존재 + frontmatter
echo "[2] SKILL.md"
SKILL=".claude/skills/spec-pipeline/SKILL.md"
if [ -f "$SKILL" ]; then
  ok "$SKILL 존재"
  if head -1 "$SKILL" | grep -q '^---$' && grep -q '^name: spec-pipeline$' "$SKILL" && grep -q '^description:' "$SKILL"; then
    ok "frontmatter (name, description) 유효"
  else
    fail "frontmatter 누락 또는 형식 오류"
  fi
else
  fail "$SKILL 부재"
fi

# [3] prompts/spec/ 파일들
echo "[3] prompts/spec/"
for p in 01-inference.md 02-pkm-query.md 03-gdd.md 03-gdd-partial.md 04-style-options.md 05a-tech.md 05b-art.md; do
  if [ -f "prompts/spec/$p" ]; then ok "prompts/spec/$p 존재"; else fail "prompts/spec/$p 부재"; fi
done

# [4] yaml 의 prompt 참조 일관성
echo "[4] yaml prompt 참조"
if [ -f spec-pipeline.yaml ]; then
  refs=$(python3 -c "
import yaml, sys
d = yaml.safe_load(open('spec-pipeline.yaml'))
for s in d.get('pipeline',{}).get('steps',[]):
    p = s.get('prompt')
    if p:
        print(p)
" 2>/dev/null || true)
  for r in $refs; do
    if [ -f "$r" ]; then ok "참조 $r 존재"; else fail "참조 $r 부재"; fi
  done
fi

# [5] version 형식
echo "[5] version 형식"
if [ -f spec-pipeline.yaml ]; then
  v=$(python3 -c "import yaml; print(yaml.safe_load(open('spec-pipeline.yaml'))['pipeline']['version'])" 2>/dev/null || true)
  if echo "$v" | grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$'; then
    ok "version=$v"
  else
    fail "version 형식 비정상: '$v'"
  fi
fi

# [6] state_schema 의 spec_pipeline 네임스페이스
echo "[6] state_schema"
if grep -q 'spec_pipeline:' spec-pipeline.yaml 2>/dev/null; then
  ok "spec_pipeline 네임스페이스 등장"
else
  fail "spec_pipeline 네임스페이스 부재"
fi

echo ""
echo "Result: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: 실행 — 모든 항목 FAIL 확인 (red)**

Run:
```bash
chmod +x tests/spec_pipeline_smoke.sh
bash tests/spec_pipeline_smoke.sh; echo "exit=$?"
```
Expected: PASS=0 또는 매우 적음, FAIL 대부분 (아직 파일 없음), exit=1.

- [ ] **Step 3: Commit (red 상태로 시작)**

```bash
git add tests/spec_pipeline_smoke.sh
git commit -m "test(spec-pipeline): 스켈레톤 스모크 테스트 (현재 red)"
```

---

### Task 3: spec-pipeline.yaml 스켈레톤 (Green for §6)

**Files:**
- Create: `spec-pipeline.yaml`

- [ ] **Step 1: 최소 yaml 작성**

```yaml
# spec-pipeline — 컨셉 텍스트 → GDD/기술명세서/아트명세서 3개 산출
# 기존 concept-pipeline 과 독립. 같은 workspace/<slug>/ 에 공존 가능.

pipeline:
  name: concept-to-specs
  version: "0.1"
  workspace_root: ./workspace
  language: ko
  backup_dir: .archive
  backup_naming:
    rerun: "{step_id}-{slug}-{timestamp}/"

  steps:
    - id: step_0
      name: 입력 수신
      mode: conversation
      output: concept.md
    - id: step_1
      name: 장르·메카닉 추론
      mode: ai_generation
      prompt: prompts/spec/01-inference.md
      output: inference.yaml
      gate: G1
    - id: step_2
      name: PKM 회상
      mode: pkm_recall
      prompt: prompts/spec/02-pkm-query.md
      output: pkm-recall.md
      gate: G2
    - id: step_3
      name: GDD master 생성
      mode: ai_generation
      prompt: prompts/spec/03-gdd.md
      partial_prompt: prompts/spec/03-gdd-partial.md
      output: gdd.md
      gate: G3
    - id: step_4
      name: 아트 스타일 옵션
      mode: ai_generation
      prompt: prompts/spec/04-style-options.md
      output: style-options.md
      gate: G4
    - id: step_5
      name: 병렬 작성 (tech + art)
      mode: subagent_parallel
      subagents:
        - id: tech-spec-writer
          prompt: prompts/spec/05a-tech.md
          output: tech-spec.md
        - id: art-spec-writer
          prompt: prompts/spec/05b-art.md
          output: art-spec.md
    - id: step_6
      name: 완료 리포트
      mode: gate

  gates:
    G1:
      after: step_1
      user_actions: [accept, edit, redo]
    G2:
      after: step_2
      user_actions: [adopt_items, adopt_all, skip]
      max_items_displayed: 8
      min_score: 3
    G3:
      after: step_3
      user_actions: [accept, partial-edit, redo]
      max_redo_loops: 3
    G4:
      after: step_4
      user_actions: [select_a, select_b, select_c]

# ─────────────────────────────────────────────────────────────────────
# state.yaml 스키마 — spec_pipeline 키 네임스페이스
# ─────────────────────────────────────────────────────────────────────
state_schema:
  namespace: spec_pipeline
  coexists_with:
    - concept-pipeline   # 기존 키 (project, current_step 등) 미터치
  example: |
    spec_pipeline:
      version: 1
      slug: dragon-cafe
      created_at: 2026-05-21T10:00:00Z
      updated_at: 2026-05-21T10:42:00Z
      current_step: 3
      last_gate: G2
      status: in_progress
      step_0:
        concept_path: concept.md
        input_chars: 412
      step_1:
        inference_path: inference.yaml
        gate_g1: { passed_at: null, user_action: pending, edits: null }
      step_2:
        recall_path: pkm-recall.md
        raw_items: 0
        skipped_reason: null
        gate_g2: { passed_at: null, adopted_item_ids: [] }
      step_3:
        gdd_path: gdd.md
        gate_g3: { passed_at: null, user_action: pending, partial_edits: [] }
      step_4:
        style_options_path: style-options.md
        gate_g4: { passed_at: null, selected: null }
      step_5:
        tech_spec_path: tech-spec.md
        art_spec_path: art-spec.md
        subagent_dispatched_at: null
        subagent_completed_at: null
        tech_failed: false
        art_failed: false

changelog:
  - version: "0.1"
    date: "2026-05-21"
    summary: "초기 스켈레톤 — 7단계 정의 + 4 게이트 + state_schema"
```

- [ ] **Step 2: yaml 파싱 검증**

Run:
```bash
python3 -c "import yaml; d = yaml.safe_load(open('spec-pipeline.yaml')); assert d['pipeline']['version'] == '0.1'; print('OK')"
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add spec-pipeline.yaml
git commit -m "feat(spec-pipeline): pipeline.yaml 스켈레톤 v0.1 (단계+게이트+state schema)"
```

---

### Task 4: prompts/spec/ 디렉토리 + 7개 스텁 파일

**Files:**
- Create: `prompts/spec/01-inference.md`
- Create: `prompts/spec/02-pkm-query.md`
- Create: `prompts/spec/03-gdd.md`
- Create: `prompts/spec/03-gdd-partial.md`
- Create: `prompts/spec/04-style-options.md`
- Create: `prompts/spec/05a-tech.md`
- Create: `prompts/spec/05b-art.md`

각 파일은 최소 H1 + 1~2개 H2 섹션만 있는 스텁. 본격 내용은 Phase B~F 에서 채운다.

- [ ] **Step 1: 7개 스텁 파일 작성**

각각 다음 형식:

```markdown
# <prompt 이름>

> spec-pipeline step <N>. 신규 파이프라인 전용. 기존 prompts/01-concept.md 등과 무관.

## 역할
(TODO — Phase B~F 에서 채움)

## 입력
(TODO)

## 출력
(TODO)
```

각 파일의 `<prompt 이름>`:
- `01-inference.md` → "장르·메카닉 추론"
- `02-pkm-query.md` → "PKM 쿼리 + 관련성 점수화"
- `03-gdd.md` → "GDD master 작성"
- `03-gdd-partial.md` → "GDD 섹션 부분 재작성"
- `04-style-options.md` → "아트 스타일 옵션 3개 생성"
- `05a-tech.md` → "tech-spec-writer subagent"
- `05b-art.md` → "art-spec-writer subagent"

- [ ] **Step 2: 7개 파일 존재 확인**

Run:
```bash
ls prompts/spec/ | sort
```
Expected: 7개 파일 (`01-inference.md` `02-pkm-query.md` `03-gdd.md` `03-gdd-partial.md` `04-style-options.md` `05a-tech.md` `05b-art.md`)

- [ ] **Step 3: Commit**

```bash
git add prompts/spec/
git commit -m "feat(spec-pipeline): prompts/spec/ 스텁 7개 (단계별 LLM 프롬프트 자리)"
```

---

### Task 5: SKILL.md 스켈레톤

**Files:**
- Create: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: SKILL.md 최소 frontmatter + 1차 본문**

```markdown
---
name: spec-pipeline
description: 컨셉 텍스트 1회 입력 → 게임 상세기획서(GDD) · 기술명세서 · 아트명세서 3개 문서를 자동 생성한다. 4 게이트 최소 개입 + 끝단 2 문서 병렬 subagent. PKM-recall 1회 응축 호출로 사용자 누적 지식 활용. 기존 concept-pipeline 과 독립 — 같은 workspace 슬러그에 공존 가능. 트리거 - "/spec-pipeline", "스펙 파이프라인 시작", "3종 명세서 만들자", "이어서 (재개)".
---

# Spec Pipeline — 자동 흐름 스킬

## 역할
~/concept-pipeline/ 의 데이터 주도 파이프라인 실행기. 트리거되면 끝까지 흐름을 끌어가며, 4 게이트 (G1~G4) 에서만 사용자에게 묻는다.

## 입력 데이터
- `~/concept-pipeline/spec-pipeline.yaml` — 단계+게이트 정의 (불변)
- `~/concept-pipeline/prompts/spec/<NN>-*.md` — 단계별 LLM 프롬프트
- `~/concept-pipeline/workspace/.active` — 활성 슬러그 (1줄)
- `~/concept-pipeline/workspace/<slug>/state.yaml` — 진행 상태 (`spec_pipeline:` 네임스페이스 사용)

## 산출물 (workspace/<slug>/)
- `concept.md` — 입력 원문 (Step 0)
- `inference.yaml` — 추론 결과 (Step 1)
- `pkm-recall.md` — PKM 회상 (Step 2)
- `gdd.md` — 게임 상세기획서 master (Step 3)
- `style-options.md` — 아트 스타일 후보 3개 (Step 4)
- `tech-spec.md` — 기술명세서 (Step 5 worker)
- `art-spec.md` — 아트명세서 (Step 5 worker)

## 부팅 — 신규 vs 재개
1. `workspace/.active` 존재 확인
2. 존재 → `state.yaml.spec_pipeline` 키 읽기
   - 키 없음 → 신규 spec-pipeline 시작 여부 사용자에게 물음
   - 키 있고 `status: in_progress` → 재개 (마지막 통과 게이트 다음부터)
   - 키 있고 `status: done` → "다시 만들기 / 이어보기" 선택
3. 부재 → 슬러그 1회 입력 받음

## 흐름
(전체 7단계 + 4 게이트 로직 — Phase B~F 에서 단계별로 채움)

## 기존 스킬과의 관계
- concept-pipeline / auto-pipeline / prototype-build-loop 와 **독립 진입점**
- 같은 슬러그의 기존 산출물 (예: `06-tech-spec.md`) 과 신규 산출물 (`tech-spec.md`) 은 파일명이 달라 공존
- 본 스킬은 위 3개 스킬의 파일을 1바이트도 수정하지 않는다 (`tests/spec_pipeline_no_regression.sh` 로 단언)
```

- [ ] **Step 2: 스모크 테스트 실행 (이번엔 일부 green)**

Run:
```bash
bash tests/spec_pipeline_smoke.sh
```
Expected: [1] [2] [3] [4] [5] [6] 모두 PASS (스켈레톤 단계). 미완성 본문이 있어도 구조 검증만이라 통과.

- [ ] **Step 3: 회귀 가드 통과 확인**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh
```
Expected: 모두 ✅, exit 0 (기존 파일 무수정 유지)

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): SKILL.md 스켈레톤 (frontmatter+부팅+산출물 매핑)"
```

---

## Phase B — Step 0 + Step 1 (입력 + 추론)

### Task 6: prompts/spec/01-inference.md 본문

**Files:**
- Modify: `prompts/spec/01-inference.md`

- [ ] **Step 1: 본문 작성**

```markdown
# 장르·메카닉 추론

> spec-pipeline Step 1. 컨셉 텍스트(`concept.md`) 를 받아 구조화된 추론 결과를 yaml 로 저장한다.

## 역할
사용자가 준 자유 형식 컨셉 텍스트에서 게임 디자인의 5축을 추출한다. 분량이 1문장이든 몇 페이지든 동일 yaml 키로 정규화한다.

## 입력
- `workspace/<slug>/concept.md` 전문

## 출력
`workspace/<slug>/inference.yaml` — 다음 스키마:

```yaml
genre: <주 장르 1개. 서브장르는 sub_genres 로 분리>
sub_genres: [<0~3개>]
core_mechanics:
  - name: <1단어~2단어>
    why: <컨셉에서 추론한 근거 1줄>
  # 3~5개. 너무 적으면 추론 부족, 너무 많으면 우선순위 흐려짐
player_fantasy: <한 줄. "플레이어는 무엇이 된 기분을 느끼는가">
tone_mood: [<2~5개 키워드>, 예: cozy, ominous, frantic]
comparable_titles:
  - title: <게임명>
    why: <어떤 차원에서 비교 가능한지 1줄>
  # 정확히 3개. 적절한 게 떠오르지 않으면 가장 가까운 사례 + "loose comparison" 표시
ambiguities: [<원문에서 모호하거나 비어있는 차원 0~3개>]
```

## 작성 규칙
- 추측은 explicit 하게. 컨셉에 명시되지 않은 것을 추론했으면 `ambiguities` 에도 기록.
- 비교작이 떠오르지 않아도 빈 배열로 두지 말고 가장 가까운 3개 + `loose comparison` 표시.
- 모든 한국어 출력. 영어 게임명은 영어로 유지.

## 실패 케이스
- 컨셉 텍스트가 10자 미만 또는 키워드 0개 → `error: too_short` 키만 반환. 호출측이 사용자에게 재입력 요청.
```

- [ ] **Step 2: 스모크 테스트 재실행 — 여전히 green**

Run:
```bash
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add prompts/spec/01-inference.md
git commit -m "feat(spec-pipeline): 01-inference 프롬프트 본문 (5축 추출 스키마)"
```

---

### Task 7: SKILL.md 에 Step 0 + Step 1 + G1 로직 추가

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: Step 0/1/G1 섹션 추가**

`## 흐름` 헤더 아래 다음 섹션 추가:

```markdown
### Step 0 — 입력 수신
1. 활성 슬러그 확인 (없으면 사용자에게 새 슬러그 요청 — kebab-case 검증)
2. "컨셉 텍스트를 붙여넣어 주세요 (분량 자유 — 1문장 ~ 몇 페이지)" 멀티라인 1회 입력
3. 10자 미만이면 1회 재요청 (그래도 짧으면 그대로 진행)
4. `workspace/<slug>/concept.md` 에 저장 + `state.yaml` 의 `spec_pipeline.step_0` 채움
5. `current_step: 1` 로 마킹 후 Step 1 진입

### Step 1 — 장르·메카닉 추론
1. `prompts/spec/01-inference.md` 의 지시를 따라 `concept.md` 를 분석
2. 결과를 `workspace/<slug>/inference.yaml` 에 yaml 로 저장
3. `error: too_short` 인 경우 사용자에게 1~2문장 추가 힌트 요청 → 재추론 1회. 또 실패하면 그대로 진행 (게이트 표시는 빈 inference 로)

### G1 — 추론 결과 확인 (사용자 게이트)
표시 포맷:
```
[추론 결과]
장르: <genre>
서브장르: <sub_genres or "—">
코어 메카닉:
  1. <name> — <why>
  2. ...
플레이어 판타지: <player_fantasy>
톤·무드: <tone_mood>
비교작:
  - <title> — <why>
  ...
모호한 차원: <ambiguities or "없음">

[선택]
  a. 이대로 진행 (accept)
  e. 특정 필드 수정 (edit)
  r. 다시 추론 (redo)
```

- accept → `state.yaml` `gate_g1: { passed_at: <now>, user_action: accept }` → Step 2 진입
- edit → 사용자가 필드명+새값 입력 → inference.yaml 갱신 → 다시 G1 표시
- redo → Step 1 재실행 (Phase E8 가드: 동일 게이트 3회 누적 시 "수동 편집 권장" 안내)
```

- [ ] **Step 2: 회귀 가드 + 스모크 통과 재확인**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): Step 0/1 + G1 게이트 로직 (SKILL.md)"
```

---

## Phase C — Step 2 PKM

### Task 8: prompts/spec/02-pkm-query.md 본문

**Files:**
- Modify: `prompts/spec/02-pkm-query.md`

- [ ] **Step 1: 본문 작성 (점수화 루브릭 인라인)**

```markdown
# PKM 쿼리 + 관련성 점수화

> spec-pipeline Step 2. G1 통과한 `inference.yaml` 로부터 PKM 검색 쿼리를 자동 생성하고, 결과를 점수화해 G2 게이트 표시 후보를 만든다.

## 역할
1. inference 의 각 차원에서 5~7개 PKM 쿼리 자동 생성
2. pkm-recall 스킬을 쿼리당 1회씩 순차 호출
3. 결과 통합·중복 제거 후 각 항목을 0~5 점으로 자체 점수화
4. 점수 ≥ 3 인 항목을 최대 8개까지 G2 게이트용 리스트로 반환

## 쿼리 자동 생성

inference 에서 다음 7개를 만든다 (메카닉이 3개 미만이면 그만큼 줄어듦):

```
1. "{genre} 게임 디자인 결정"
2. "{core_mechanics[0].name} 시스템 패턴"
3. "{core_mechanics[1].name} 시스템 패턴"
4. "{core_mechanics[2].name} 시스템 패턴" (3개 이상일 때만)
5. "{tone_mood[0]} {tone_mood[1]} 아트 디렉션"
6. "{comparable_titles[0].title} 분석"
7. "{comparable_titles[1].title} 분석"
```

각 쿼리를 별도로 pkm-recall 호출. 결과는 동일 `id`/`source` 기준으로 중복 제거.

## 점수화 루브릭 (각 항목 0~5)

각 PKM 항목의 본문을 보고 다음 3축의 합으로 점수 (각 0~2, 마지막 +1 보너스):

- **직접성 (0~2)**: 항목이 inference 의 특정 차원을 직접 언급하면 2, 인접 개념이면 1, 무관해 보이면 0
- **재사용 가능성 (0~2)**: 항목이 결정/패턴/스니펫처럼 구체적 가이드 형태면 2, 추상적 통찰이면 1, 메타 정보면 0
- **신선도 보너스 (+1)**: 항목 일자가 1년 이내면 +1

총 0~5점. **3점 이상**만 G2 후보로 표시.

## 출력

`workspace/<slug>/pkm-recall.md` — 다음 구조:

```markdown
# PKM Recall

생성일: <ISO>
쿼리 수: N
원시 항목 수: M

## CANDIDATES (점수 ≥ 3, 최대 8개)

### [1] score=4.5 source=<source> title=<title>
why-match: "<쿼리 X> 와 직접 매치"
excerpt: "<200자 내외>"

### [2] ...

## DISCARDED (점수 < 3, 카운트만)
- N items below threshold

## ADOPTED  (G2 통과 후 호출측이 채움)
(빈 섹션 — 사용자 채택 후 호출측이 본문 복사해 채움)
```

## 폴백
- pkm-recall 미설치/호출 실패 → 빈 파일 + `# SKIPPED: pkm-recall unavailable` 헤더만. 호출측이 G2 건너뜀.
- 모든 쿼리 0결과 또는 모두 점수 < 3 → `## CANDIDATES` 섹션 비움. 호출측이 G2 자동 통과.
```

- [ ] **Step 2: 스모크 + 회귀 통과**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add prompts/spec/02-pkm-query.md
git commit -m "feat(spec-pipeline): 02-pkm-query 프롬프트 (3축 점수 루브릭 인라인)"
```

---

### Task 9: SKILL.md 에 Step 2 + G2 + 폴백 로직 추가

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: Step 2/G2 섹션 추가**

`## 흐름` 아래 G1 다음에 추가:

```markdown
### Step 2 — PKM 회상
1. `prompts/spec/02-pkm-query.md` 의 지시를 따라 pkm-recall 스킬을 5~7회 순차 호출
   - 호출 실패 (스킬 없음/오류) 시 `pkm-recall.md` 에 `# SKIPPED: pkm-recall unavailable` 만 쓰고 `state.yaml.step_2.skipped_reason = "pkm-recall unavailable"` 마킹 → G2 건너뛰고 Step 3 으로 직진
2. 결과를 점수화해 `workspace/<slug>/pkm-recall.md` 의 CANDIDATES 섹션에 ≥ 3점 항목 최대 8개로 저장
3. CANDIDATES 가 0개면 사용자에게 "관련 PKM 없음 — 그대로 진행" 안내 후 G2 자동 통과

### G2 — PKM 관련성 검증 게이트
표시 포맷:
```
[PKM 회상 결과 — {N}개 후보]

[1] (4.5) [PKM/game-design] 자원관리 게임 자원노드 패턴
    why: "<core_mechanic #2> 시스템 패턴" 쿼리 매치
    excerpt: "노드 수보다 노드 가치 다양성이 ..."

[2] (4.1) ...

채택 항목 번호를 쉼표로 (예: 1,3,5)
또는: "전체" / "건너뛰기"
선택:
```

- 채택 항목의 본문을 `pkm-recall.md` 의 `## ADOPTED` 섹션에 복사 (Step 3/5 에서 인용 위해)
- `state.yaml.spec_pipeline.step_2.gate_g2.adopted_item_ids` 에 ID 배열 저장
- `state.yaml.last_gate = G2` 마킹 후 Step 3 진입
```

- [ ] **Step 2: 통과 확인**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): Step 2 + G2 + PKM 폴백 로직"
```

---

## Phase D — Step 3 GDD (master 문서)

### Task 10: prompts/spec/03-gdd.md 본문 + 03-gdd-partial.md

**Files:**
- Modify: `prompts/spec/03-gdd.md`
- Modify: `prompts/spec/03-gdd-partial.md`

- [ ] **Step 1: 03-gdd.md (전체 생성) 본문**

```markdown
# GDD master 작성

> spec-pipeline Step 3. concept + inference + 채택 PKM 으로 게임 상세기획서 마스터 문서를 1회 생성한다.

## 역할
이후 기술명세서·아트명세서가 모두 참조할 마스터 문서를 작성한다. 12 섹션 고정 구조. 분량은 8~12 페이지 (4000~6000 단어).

## 입력 (모두 인라인 컨텍스트로 받음)
- `concept.md` 전문
- `inference.yaml` 전문
- `pkm-recall.md` 의 `## ADOPTED` 섹션 (없을 수 있음)

## 출력 구조 — `workspace/<slug>/gdd.md`

다음 12개 H1 섹션, 순서·번호 고정:

```
# 1. 한 줄 정의 + 엘리베이터 피치
# 2. 플레이어 판타지 / 타겟 / 톤
# 3. 코어 루프
# 4. 시스템
# 5. 진행·페이싱
# 6. 메타 진행
# 7. 컨텐츠 종류 + 1회차 분량 견적
# 8. UX / 정보 흐름
# 9. 승리·실패 조건 + Fail State
# 10. 첫 5분 시나리오
# 11. 비전 차별점
# 12. 변경 이력
```

§4 시스템은 inference.core_mechanics 의 각 메카닉 → §4.1, §4.2, ... 로 1:1+ 매핑. 각 §4.x 는 다음 3 서브섹션:
```
## 4.x.1 목적
## 4.x.2 규칙  (조건/수치는 placeholder OK)
## 4.x.3 상호작용  (다른 시스템 어떻게 엮이는지)
```

§6 메타 진행 — 해당 게임에 없으면 "해당 없음" 한 줄. 섹션 자체는 생략 ✕ (헤딩 수 검증 때문).

§12 변경 이력 — 최초 작성 시 1 row:
```
| 일자 | 변경 | 사유 |
| 2026-05-21 | 초안 작성 | Step 3 자동 생성 |
```

## 작성 규칙
- 채택 PKM 항목이 있으면 본문에 자연스럽게 통합. 인용 마커는 `[PKM:<id>]` 형식으로 본문 끝에 (집중도 보존)
- 한국어. 게임명·기술용어는 영어 그대로
- 모든 H1 12개가 존재하지 않으면 출력 무효 — 다시 시도

## 실패 케이스
- 헤딩 수 < 12 → 호출측이 1회 재시도
- 2회 모두 실패 → 호출측이 사용자에게 "GDD 자동 생성 실패 — 수동 작성 권장" 안내
```

- [ ] **Step 2: 03-gdd-partial.md (섹션 부분 재작성) 본문**

```markdown
# GDD 섹션 부분 재작성

> spec-pipeline G3 partial-edit. 사용자가 특정 섹션 ID 를 지정하면 해당 섹션만 재생성한다.

## 역할
G3 게이트에서 사용자가 `partial-edit` 선택 + 섹션 번호 (예: §4.2, §7) 지정 시 호출된다.

## 입력
- 기존 `gdd.md` 전문 (다른 섹션 보존 위해 필요)
- 재작성 대상 섹션 ID 리스트 (예: ["§4.2", "§7"])
- 사용자 추가 지시 (선택, 1~2 문장)
- `concept.md`, `inference.yaml`, `pkm-recall.md`의 ADOPTED

## 섹션 입도
- §N (예: §7) — H1 1개 전체 재작성
- §N.x (예: §4.2) — H2 1개 그룹 재작성 (이 경우 §4.2.1, §4.2.2, §4.2.3 모두 같이 재작성)
- §N.x.y 단위 (예: §4.2.1) 는 지원 ✕ — 너무 잘면 H2 단위로 묶어 처리

## 출력
- `gdd.md` 의 지정 섹션만 교체. 다른 섹션 한 글자도 변경 ✕
- §12 변경 이력에 1 row 추가 (`partial-edit §4.2, §7`)

## 작성 규칙
- 다른 섹션 참조 (예: §3) 가 깨지지 않도록 cross-ref 유지
- 사용자 추가 지시가 있으면 반드시 반영. 무시할 수 없음.
```

- [ ] **Step 3: 통과 확인**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add prompts/spec/03-gdd.md prompts/spec/03-gdd-partial.md
git commit -m "feat(spec-pipeline): 03-gdd master + partial-edit 프롬프트 (12 섹션 고정)"
```

---

### Task 11: SKILL.md 에 Step 3 + G3 로직

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: Step 3 + G3 섹션 추가**

```markdown
### Step 3 — GDD master 생성
1. `prompts/spec/03-gdd.md` 의 지시를 따라 `workspace/<slug>/gdd.md` 작성
2. 작성 후 H1 개수 검증 — 12개 미만이면 1회 재시도. 그래도 실패하면 사용자에게 보고
3. `state.yaml.spec_pipeline.step_3.gdd_path = "gdd.md"` 마킹

### G3 — GDD 초안 확인
표시 포맷:
```
[GDD 초안 — gdd.md (헤딩 12/12)]

# 1. 한 줄 정의 + 엘리베이터 피치
<본문 일부 첫 200자>
...

# 2. 플레이어 판타지 / 타겟 / 톤
<...>
... (각 섹션 첫 200자만 요약 표시)

[선택]
  a. 이대로 진행 (accept)
  p. 섹션 부분 수정 (partial-edit)  — 섹션 번호 쉼표 입력 (예: §4.2, §7)
  r. 전체 다시 작성 (redo)
```

- accept → `gate_g3: { passed_at: <now>, user_action: accept }` → Step 4 진입
- partial-edit → 섹션 ID 받음 + (선택) 사용자 추가 지시 1~2문장 받음 → `03-gdd-partial.md` 실행 → 다시 G3 표시
- redo → Step 3 재실행
- **3회 누적 (G3 표시 카운트 ≥ 3) 시**: "G3 가 3번째입니다. 수동 편집을 권장합니다 (현재 gdd.md 그대로 두고 Step 4 로 진행 / 일시 abort) — 선택?" 표시
```

- [ ] **Step 2: 통과 확인 + commit**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): Step 3 + G3 게이트 (partial-edit + 3회 누적 가드)"
```

---

## Phase E — Step 4 아트 스타일

### Task 12: prompts/spec/04-style-options.md 본문

**Files:**
- Modify: `prompts/spec/04-style-options.md`

- [ ] **Step 1: 본문 작성**

```markdown
# 아트 스타일 옵션 3개 생성

> spec-pipeline Step 4. GDD §2 톤·무드 → 아트 스타일 후보 3개를 만든다.

## 역할
GDD 의 톤·무드와 비교작에서 어울리는 시각 스타일 3개를 후보로 제시. 사용자는 G4 에서 1개를 선택한다.

## 입력
- `gdd.md` §2 플레이어 판타지/타겟/톤
- `gdd.md` §1 엘리베이터 피치
- `inference.yaml.comparable_titles`

## 출력 — `workspace/<slug>/style-options.md`

```markdown
# Style Options

## Option A — <스타일 이름>
- 레퍼런스 키워드: <5~8개>
- 컬러 팔레트 (대표 5색): #...., #...., #...., #...., #....
- 해상도 가이드: 스프라이트 <NxN>, 배경 <WxH>, UI <WxH>
- 카메라·구도: <2~3 문장>
- 어울리는 이유: GDD 톤·무드 {tone_mood} 와 어떻게 매치되는지 1~2 문장
- 예시 비교작: <1~2개>

## Option B — <스타일 이름>
(동일 구조)

## Option C — <스타일 이름>
(동일 구조)
```

## 작성 규칙
- 3개 옵션은 명확히 다른 결을 가져야 함 (예: 픽셀아트 / 셀룰러 / 로우폴리 — 또는 그래픽노블 / 페이퍼크래프트 / 미니멀 등)
- 각 옵션은 standalone — 사용자가 1개만 보고도 그 의도를 충분히 이해 가능
- 1개 옵션은 항상 픽셀아트 또는 미니멀 (저비용 베이스라인)
- 한국어. 스타일 이름은 일반 호칭 (예: "픽셀아트 (16-bit)", "로우폴리 3D")

## 실패 폴백
- GDD §2 가 비어있거나 톤·무드 추출 불가 → 폴백 3 옵션: 픽셀아트 / 셀룰러 / 미니멀 — 키워드·팔레트는 일반론으로
```

- [ ] **Step 2: 통과 확인 + commit**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add prompts/spec/04-style-options.md
git commit -m "feat(spec-pipeline): 04-style-options 프롬프트 (3 옵션 + 폴백)"
```

---

### Task 13: SKILL.md 에 Step 4 + G4 로직

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: Step 4 + G4 섹션 추가**

```markdown
### Step 4 — 아트 스타일 옵션
1. `prompts/spec/04-style-options.md` 의 지시를 따라 `workspace/<slug>/style-options.md` 작성
2. Option A/B/C 3개 모두 존재하는지 검증 (각 ## H2 헤더 확인)

### G4 — 아트 스타일 선택
표시 포맷:
```
[아트 스타일 후보 3개]

A. <스타일 이름>
   레퍼런스: <키워드>
   팔레트: <5색 hex>
   어울리는 이유: <한 줄>

B. <스타일 이름>
   ...

C. <스타일 이름>
   ...

선택 (a/b/c):
```

- 선택 받으면 `state.yaml.spec_pipeline.step_4.gate_g4.selected = "A"|"B"|"C"`
- Step 5 진입
```

- [ ] **Step 2: 통과 확인 + commit**

```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): Step 4 + G4 게이트 (스타일 선택)"
```

---

## Phase F — Step 5 병렬 워커

### Task 14: prompts/spec/05a-tech.md 본문

**Files:**
- Modify: `prompts/spec/05a-tech.md`

- [ ] **Step 1: 본문 작성**

```markdown
# tech-spec-writer (subagent prompt)

> spec-pipeline Step 5 워커 1. 메인 스킬이 Agent 툴로 디스패치한다. 본 프롬프트가 워커의 시스템 프롬프트.

## 너의 역할
GDD master 를 받아 엔진 비종속 기술명세서를 작성한다.

## 입력 (메인이 인라인 컨텍스트로 전달)
- `gdd.md` 전문
- `inference.yaml` 전문
- `pkm-recall.md` 의 `## ADOPTED` 섹션 (없을 수 있음)
- workspace 경로 (예: `workspace/dragon-cafe/`)

## 출력 파일
Write 툴로 `<workspace>/tech-spec.md` 저장.

## 출력 구조 (10 H1 섹션, 순서 고정)

```
# 1. 모듈 분해
# 2. 데이터 모델
# 3. 상태머신
# 4. 시스템 간 의존성 그래프
# 5. 영속성
# 6. 핵심 알고리즘 노트
# 7. 입력·디바이스 가정
# 8. 성능 예산
# 9. 테스트 전략 — Acceptance Criteria
# 10. 외부 의존 / 라이선스 고려
```

## 작성 규칙
- **엔진 비종속**: Godot/Unity/Unreal/엔진명 직접 언급 ✕. "엔진 컴포넌트", "씬 그래프 노드", "ECS 엔티티" 같은 일반 추상어 사용
- §1 모듈 분해는 GDD §4 의 각 시스템 → 모듈 1:1 이상 매핑. 누락 시 §1 끝에 "[누락] §4.x 시스템 미매핑" 행 추가
- §9 Acceptance Criteria 는 GDD §4 규칙을 검증 가능한 형태로 (예: "노드 3개 배치 시 자원 흐름이 5초 안에 안정화")
- 한국어. 기술 용어는 영어 그대로 (FSM, ECS, Bevy/Component, etc)
- 분량 가이드: §1~9 각 200~600자, §10 100~300자. 전체 3000~5000자

## 출력 후 보고 (메인에게 200단어 이내)
- 저장 경로
- H1 헤딩 수
- 누락 매핑 (있으면 §1 의 "[누락]" 행 수)
- 이슈 (있으면)
```

- [ ] **Step 2: 통과 확인 + commit**

```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add prompts/spec/05a-tech.md
git commit -m "feat(spec-pipeline): 05a-tech subagent 프롬프트 (엔진 비종속 10 섹션)"
```

---

### Task 15: prompts/spec/05b-art.md 본문

**Files:**
- Modify: `prompts/spec/05b-art.md`

- [ ] **Step 1: 본문 작성**

```markdown
# art-spec-writer (subagent prompt)

> spec-pipeline Step 5 워커 2. 메인 스킬이 Agent 툴로 디스패치한다.

## 너의 역할
GDD + 선택된 아트 스타일을 받아 아트명세서 (스타일 + 슬롯표 + 에셋 생성 프롬프트) 를 작성한다.

## 입력
- `gdd.md` 전문
- `style-options.md` 의 선택된 옵션 (메인이 어느 옵션인지 알려줌, 예: "Option B 선택됨")
- `pkm-recall.md` 의 `## ADOPTED` 섹션 (없을 수 있음)
- workspace 경로

## 출력 파일
Write 툴로 `<workspace>/art-spec.md` 저장.

## 출력 구조 (11 H1 섹션, 순서 고정)

```
# 1. 스타일 정의
# 2. 컬러 팔레트
# 3. 해상도·캔버스 규칙
# 4. 카메라·구도 가이드
# 5. 캐릭터·NPC 슬롯표
# 6. 환경·배경 슬롯표
# 7. 오브젝트·아이템 슬롯표
# 8. UI·아이콘 슬롯표
# 9. VFX·이펙트 슬롯표
# 10. 에셋 생성 프롬프트
# 11. 일관성 체크리스트
```

## 슬롯표 포맷 (§5~9 동일)

```
| ID  | 이름   | 카테고리   | 용도 (GDD §X.x 참조) | 해상도 | 우선순위 | 상태 |
| C01 | 주인공 | character | 플레이어 조작 (§3)   | 64x64  | P0       | TBD  |
```

ID prefix: C=character, E=environment, O=object, U=ui, V=vfx
번호는 카테고리 내 1부터 단조 증가.
GDD 의 등장 요소를 모두 슬롯화. 누락 의심 시 §11 일관성 체크리스트에 행 추가.

## 에셋 생성 프롬프트 포맷 (§10)

각 슬롯 1개씩, 다음 형식:
```
[C01 — 주인공]
prompt: "pixel art, 64x64 sprite of a stranded astronaut, ..."
negative: "blurry, low-res, signature"
style anchor: §1 키워드 + §2 팔레트 hex (최소 1개 hex 본문 포함)
ref keywords: <§1 스타일 키워드>
```

## 작성 규칙
- **모든 에셋 프롬프트는 §1 스타일 키워드 1개 이상 + §2 팔레트 hex 1개 이상을 본문에 명시적으로 인용** (일관성 체크 자동 검증 대상)
- 한국어 슬롯 설명 + 영어 prompt 본문 (이미지 생성 모델 입력용)
- 분량 가이드: §1~4 각 100~300자, §5~9 각 슬롯 1행 + 5~15행, §10 슬롯 수만큼, §11 5~10 항목

## 출력 후 보고 (메인에게 200단어 이내)
- 저장 경로
- H1 헤딩 수 + 슬롯 총 개수
- §10 프롬프트 중 §1/§2 인용 누락 건수 (자체 검증)
- 이슈 (있으면)
```

- [ ] **Step 2: 통과 확인 + commit**

```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add prompts/spec/05b-art.md
git commit -m "feat(spec-pipeline): 05b-art subagent 프롬프트 (11 섹션 + 슬롯표 + 일관성 자체검증)"
```

---

### Task 16: SKILL.md 에 Step 5 병렬 디스패치 + Step 6 + 사후 검증

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: Step 5/6 섹션 추가**

```markdown
### Step 5 — 병렬 작성 (subagent 2개 동시 디스패치)

**디스패치 시점**: G4 통과 즉시.
**중요**: 두 Agent 호출을 **동일 응답 메시지 내에서 병렬** 호출 (Agent 툴 2개를 1 응답에 배치).

```
Agent(
  subagent_type=general-purpose,
  description="Tech spec writer",
  prompt=<prompts/spec/05a-tech.md 의 본문 + 입력 데이터 인라인>
)

Agent(
  subagent_type=general-purpose,
  description="Art spec writer",
  prompt=<prompts/spec/05b-art.md 의 본문 + 입력 데이터 (선택된 옵션 명시) 인라인>
)
```

`state.yaml.spec_pipeline.step_5.subagent_dispatched_at = <now>`.

### Step 5.5 — 사후 검증
두 워커 보고를 받은 후:
1. `tech-spec.md` 존재 + 비어있지 않음 + H1 ≥ 10 → 통과. 실패 시 `tech_failed: true` 마킹.
2. `art-spec.md` 존재 + 비어있지 않음 + H1 ≥ 11 → 통과. 실패 시 `art_failed: true` 마킹.
3. art-spec §10 의 에셋 프롬프트가 §1 키워드 + §2 hex 중 1개 이상 인용했는지 grep — 누락 행 수 보고 (실패는 ✕, 경고만)

### Step 5.6 — 워커 재시도 (실패한 경우만)
- 한쪽만 실패 → 동일 프롬프트 1회 재시도 (Agent 1개)
- 양쪽 실패 → 메인이 인라인 폴백 작성 (GDD 재로드, 토큰 비용 감수)
- 재시도 후에도 실패 → 사용자에게 어느 문서가 부실한지 보고 + 수동 작성 안내

`state.yaml.spec_pipeline.step_5.subagent_completed_at = <now>`.

### Step 6 — 완료 리포트
표시 포맷:
```
[spec-pipeline 완료]
산출물:
  📄 workspace/<slug>/gdd.md          (게임 상세기획서, H1 N개)
  ⚙️  workspace/<slug>/tech-spec.md    (기술명세서, H1 N개)
  🎨 workspace/<slug>/art-spec.md     (아트명세서, H1 N개, 슬롯 N개)

주요 결정:
  - 장르: <genre>
  - 스타일: <selected style name>
  - PKM 참조: N개 채택

다음 단계 (선택):
  - 프로토타입 빌드: "프로토타입 시작" 또는 /prototype-start (별도 입력 필요)
  - 산출물 검토 후 부분 재작성: /sp-redo step_3 (추후 추가)
```

`state.yaml.spec_pipeline.status = "done"` 마킹 후 종료.
```

- [ ] **Step 2: 통과 확인 + commit**

```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): Step 5 병렬 디스패치 + Step 6 완료 리포트 + 사후 검증/재시도"
```

---

### Task 17: SKILL.md 에 에러 처리 매트릭스 (E1~E15) + 재개 로직 명시

**Files:**
- Modify: `.claude/skills/spec-pipeline/SKILL.md`

- [ ] **Step 1: 매트릭스 섹션 추가**

`## 흐름` 다음에 별도 H2 섹션으로:

```markdown
## 에러 처리 매트릭스

| # | 시나리오 | 처리 |
|---|---------|------|
| E1 | 활성 슬러그 없음 | 슬러그 1회 요청. 빈/공백/충돌 시 재요청 |
| E2 | 기존 concept-pipeline 진행 중 | spec_pipeline 키 네임스페이스로 공존. "어느 쪽 이어가기?" 1회 확인 |
| E3 | 컨셉 < 10자 | 1회 재요청. 그래도 짧으면 진행 |
| E4 | G1 추론 실패 | "1~2문장 추가 힌트" → 재추론 1회. 또 실패 시 빈 inference 로 G1 표시 |
| E5 | pkm-recall 미설치/오류 | step_2.skipped 마킹 → G2 건너뛰고 Step 3 직진 |
| E6 | PKM 0 결과/모두 < 3점 | G2 자동 통과 |
| E7 | G3 partial-edit | 섹션 ID 받아 03-gdd-partial.md 실행. 다른 섹션 보존 |
| E8 | G3 무한 루프 | 동일 게이트 3회 누적 시 "수동 편집 권장 + abort 옵션" |
| E9 | G4 스타일 옵션 생성 실패 | 폴백: 픽셀아트/셀룰러/미니멀 3 옵션 |
| E10 | Step 5 한쪽 워커 실패 | 1회 재시도 후도 실패 → 마킹 + 안내 |
| E11 | Step 5 양쪽 실패 | 메인 인라인 폴백 |
| E12 | 재개 시 출력 파일 일부만 존재 | state.yaml + 파일 존재 여부 비교. "보존 / 덮어쓰기" 1회 물음 |
| E13 | 같은 슬러그 재트리거 (done) | "다시 만들기 / 이어보기" 선택. 다시 만들기 시 .bak 백업 후 새로 |
| E14 | 슬러그 공백/특수문자 | kebab-case 자동 변환 + 사용자 확인 |
| E15 | workspace/<slug> 디렉토리 부재 | 자동 생성 |

**state.yaml 손상**: 파싱 실패 → `state.yaml.bak.<ts>` 백업 후 사용자에게 보고. 자동 복구 ✕.

## 재개 로직
세션 진입 시:
1. `workspace/.active` 의 슬러그 읽기
2. `workspace/<slug>/state.yaml.spec_pipeline` 키 존재 여부 확인
3. `last_gate` 기준 entry point 결정:
   - null → step_0
   - G1 → step_2
   - G2 → step_3
   - G3 → step_4
   - G4 → step_5
4. 해당 entry 의 출력 파일 존재하면 LLM 재추론 ✕, 디스크에서 로드만
5. `status == done` 이면 "이미 완료됨 — 다시 만들기 (재시작) / 종료 / 다른 슬러그" 옵션 표시
```

- [ ] **Step 2: 통과 확인 + commit**

```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```

```bash
git add .claude/skills/spec-pipeline/SKILL.md
git commit -m "feat(spec-pipeline): 에러 매트릭스 E1~E15 + 재개 로직"
```

---

## Phase G — Golden 테스트 + 재개 회귀 + 마무리

### Task 18: 골든 입력 3종 + EXPECTED 구조 기준

**Files:**
- Create: `tests/spec_pipeline/golden/short-pitch.txt`
- Create: `tests/spec_pipeline/golden/medium-paragraph.txt`
- Create: `tests/spec_pipeline/golden/long-memo.txt`
- Create: `tests/spec_pipeline/golden/EXPECTED.md`

LLM 출력은 비결정적이라 **구조만** 검증한다.

- [ ] **Step 1: 골든 입력 3종 작성**

`short-pitch.txt`:
```
별을 떠돌아다니는 우주택시 기사 게임. 손님 태우고 행성 사이를 날고 팁만으로 개를 잘 먹어야 살아남는다.
```

`medium-paragraph.txt`:
```
배경은 19세기 영국 변두리 작은 항구. 플레이어는 갓 부임한 우체국장이다.
편지·소포를 분류하고 배달인을 고용해 마을 곳곳에 보낸다.
시간은 압박이지만 손님과의 짧은 대화로 관계가 쌓이고, 그 관계가 다음 배달의 우선순위를 바꾼다.
실수는 마을 평판에 누적되어 결국 우체국 폐쇄로 이어진다.
은은하게 우울하지만 다정한 톤. 픽셀아트 또는 그래픽노블 결.
```

`long-memo.txt`: (대략 30~40 줄의 비정형 메모 — 컨셉, 자유 연상, 메카닉 단편들 섞임. 분량 적응 검증용)

```
대충 떠오른 메모들

- 깊은 바다 아래 어딘가, 빛이 거의 없고
- 잠수정 하나 + 손전등 하나
- 자원이 산소·전력·식량 3개. 셋 다 떨어지면 끝
- 길 잃기 쉬움. 지도는 손으로 그려야 함 (메타퍼: 그리는 행위 자체가 게임)
- ...
(20+ 줄 자유 메모)
```

`EXPECTED.md` — 구조 검증 기준:
```markdown
# spec-pipeline 골든 검증 기준

LLM 내용 검증 ✕. 구조·존재·길이만.

각 골든 입력에 대해 다음을 단언:

## 산출물 존재
- `workspace/<golden-slug>/gdd.md` 존재 + 0바이트 아님
- `workspace/<golden-slug>/tech-spec.md` 존재 + 0바이트 아님
- `workspace/<golden-slug>/art-spec.md` 존재 + 0바이트 아님

## 헤딩 수
- `gdd.md` H1 count ≥ 12
- `tech-spec.md` H1 count ≥ 10
- `art-spec.md` H1 count ≥ 11

## art-spec 일관성
- `art-spec.md` §10 의 모든 `prompt:` 행은 §2 의 hex 1개 이상 또는 §1 의 키워드 1개 이상 본문에 포함

## 슬러그 영향
- 각 골든 입력은 고유 슬러그 (`golden-short`, `golden-medium`, `golden-long`)
- 골든 실행은 기존 workspace 슬러그를 건드리지 않음
```

- [ ] **Step 2: Commit**

```bash
git add tests/spec_pipeline/golden/
git commit -m "test(spec-pipeline): 골든 입력 3종 + EXPECTED 구조 기준"
```

---

### Task 19: spec_pipeline_resume.sh — 재개 회귀 테스트

**Files:**
- Create: `tests/spec_pipeline_resume.sh`

실제 LLM 실행은 비용 큼 → 본 스크립트는 **state.yaml 만 조작**하여 재개 entry point 가 정확한지 검증한다.

- [ ] **Step 1: 스크립트 작성**

```bash
#!/usr/bin/env bash
# spec-pipeline 재개 entry point 결정 회귀 테스트
# state.yaml 의 last_gate 값에 따라 SKILL.md 의 재개 로직이 명시한 entry 가 일관되는지 검증.
#
# 실행: bash tests/spec_pipeline_resume.sh

set -u
PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PIPELINE_ROOT"

PASS=0
FAIL=0
ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo "=== spec-pipeline resume regression ==="
SKILL=".claude/skills/spec-pipeline/SKILL.md"

# SKILL.md 의 재개 로직 섹션이 다음 매핑을 모두 명시했는지 grep:
declare -a MAPPINGS=(
  "null → step_0"
  "G1 → step_2"
  "G2 → step_3"
  "G3 → step_4"
  "G4 → step_5"
)
for m in "${MAPPINGS[@]}"; do
  if grep -F "$m" "$SKILL" > /dev/null; then
    ok "재개 매핑 '$m' 존재"
  else
    fail "재개 매핑 '$m' 누락"
  fi
done

# state_schema 의 last_gate 가 G1~G4 모두 cover
for g in G1 G2 G3 G4; do
  if grep -q "last_gate: $g" spec-pipeline.yaml || grep -q "$g" spec-pipeline.yaml; then
    ok "spec-pipeline.yaml 에 $g 등장"
  else
    fail "spec-pipeline.yaml 에 $g 누락"
  fi
done

# done/in_progress 상태 처리 명시
if grep -q 'status == done' "$SKILL" || grep -q '"done"' "$SKILL"; then
  ok "done 상태 분기 존재"
else
  fail "done 상태 분기 누락"
fi

echo ""
echo "Result: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: 실행 + commit**

Run:
```bash
chmod +x tests/spec_pipeline_resume.sh
bash tests/spec_pipeline_resume.sh
```
Expected: 모두 ✅

```bash
git add tests/spec_pipeline_resume.sh
git commit -m "test(spec-pipeline): 재개 entry point 회귀 (state.yaml 매핑 grep)"
```

---

### Task 20: README.md 에 spec-pipeline 1섹션 추가

**Files:**
- Modify: `README.md`

README 수정은 회귀 가드 대상이 아니다 (가드는 .claude/skills/, pipeline.yaml, config.yaml, 기존 prompts/*.md 만).

- [ ] **Step 1: README 끝부분 (auto-pipeline 섹션 뒤) 에 spec-pipeline 섹션 추가**

```markdown
### spec-pipeline (v0.1~)

**컨셉 텍스트 1회 입력으로 3개 명세서 (GDD + 기술명세서 + 아트명세서) 를 자동 생성**하는 별도 진입점. 기존 7단계 컨셉 파이프라인과 독립. pkm-recall 1회 응축 호출로 사용자 개인 PKM 지식을 GDD/tech/art 생성에 반영한다.

```
"/spec-pipeline" 또는 "스펙 파이프라인 시작"
  → 컨셉 텍스트 + 4 게이트 (장르 추론 / PKM 관련성 / GDD 초안 / 아트 스타일 선택)
  → 끝단 2 문서 병렬 subagent 작성
  → workspace/<slug>/{gdd,tech-spec,art-spec}.md
```

자세한 내용: [spec-pipeline spec](docs/superpowers/specs/2026-05-21-spec-pipeline-design.md) · [구현 plan](docs/superpowers/plans/2026-05-21-spec-pipeline.md)
```

- [ ] **Step 2: 회귀 가드 통과 (README 수정은 가드 대상 ✕)**

Run:
```bash
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
bash tests/spec_pipeline_smoke.sh && echo OK
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs(spec-pipeline): README 에 신규 파이프라인 1섹션 추가"
```

---

### Task 21: 최종 통합 검증

- [ ] **Step 1: 모든 테스트 일괄 실행**

Run:
```bash
echo "--- no_regression ---" && \
BASELINE=$(cat /tmp/spec-pipeline-baseline-sha) bash tests/spec_pipeline_no_regression.sh && \
echo "--- smoke ---" && \
bash tests/spec_pipeline_smoke.sh && \
echo "--- resume ---" && \
bash tests/spec_pipeline_resume.sh && \
echo "--- 기존 스킬 스모크 (regression sanity) ---" && \
bash tests/pipeline_smoke.sh && \
bash tests/auto_pipeline_smoke.sh && \
bash tests/build_loop_smoke.sh && \
echo "ALL GREEN"
```
Expected: `ALL GREEN`

- [ ] **Step 2: 디렉토리 상태 확인**

Run:
```bash
ls .claude/skills/spec-pipeline/
ls prompts/spec/
ls tests/spec_pipeline_*.sh
ls tests/spec_pipeline/golden/
```
Expected: 모두 존재 + 파일 수 일치 (skills 1, prompts 7, tests 3, golden 4)

- [ ] **Step 3: git log 정리 확인**

Run:
```bash
git log --oneline $(cat /tmp/spec-pipeline-baseline-sha)..HEAD
```
Expected: 약 20개 커밋, 모두 `(spec-pipeline)` scope, 1줄 1주제.

- [ ] **Step 4: 최종 커밋 (있다면)**

이 시점에 추가 커밋이 필요 없으면 skip.

---

## 주의 사항

- **TDD red→green 패턴**: Task 1~2 는 "guard 먼저 / smoke 먼저" 로 red 상태에서 시작. Task 3~16 은 각 파일 추가가 곧 green 만들기. 진짜 LLM-execution 검증은 골든 (Task 18) 이지만 자동 실행 ✕ (수동 1회 검증).
- **기존 스킬 무수정**: 매 Task 끝에 회귀 가드 실행. 한 번이라도 실패하면 그 task 안에서 수정.
- **세션 끊김 대비**: 매 task 끝에 commit. 다음 세션은 `git log` 만 보고 다음 task 결정 가능.
- **parallel dispatch 확인**: Task 16 의 Step 5 병렬 패턴은 기존 auto-pipeline 도 사용 중. 실제 LLM 실행 단계에서 1회 골든 테스트로 검증.
- **subagent prompts**: Task 14/15 의 05a/05b 는 prompt 본문이 곧 subagent 시스템 프롬프트. 메인이 Agent 툴 호출 시 prompt 인자로 통째로 + 입력 데이터 인라인 추가.

## 향후 (이 plan 범위 밖)

- `/sp-status`, `/sp-redo <step>` 슬래시 (기존 cp-* 패턴 차용)
- `prototype-build-loop` 입력 어댑터 (spec 의 3 문서 → 기존 06-spec 패밀리 변환)
- session-start.sh 에 spec_pipeline 진행 상태 표시 (현재는 기존 훅의 generic 부분만 사용)
