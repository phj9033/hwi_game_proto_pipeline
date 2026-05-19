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

# ─── 2. prompts/auto/ 파일 존재 ───
echo ""
echo "[2] prompts/auto/ 파일 존재"
for f in work-order-schema.md worker-report-schema.md critic.md verify.md pkm-fetch.md concept-stage-wrapper.md build-substep-wrapper.md; do
  [[ -f "prompts/auto/$f" ]] && ok "prompts/auto/$f 존재" || fail "prompts/auto/$f 없음"
done

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

# ─── 5. .gitignore 패턴 ───
echo ""
echo "[5] .gitignore auto-pipeline 패턴"
for pat in "workspace/\*/work-orders/" "workspace/\*/worker-reports/" "workspace/\*/pkm-cache/" "workspace/\*/decisions.log" "workspace/\*/completion-report.md"; do
  unescaped=$(echo "$pat" | sed 's/\\\*/*/g')
  grep -qF "$unescaped" .gitignore && ok ".gitignore 에 $unescaped" || fail ".gitignore 에 $unescaped 누락"
done

# ─── 6. session-start.sh 의 auto-mode 분기 ───
echo ""
echo "[6] session-start.sh auto-mode 분기"
HOOK=".claude/hooks/session-start.sh"
if [[ -f "$HOOK" ]]; then
  grep -q "mode.*auto" "$HOOK" && ok "session-start.sh 에 auto 분기" || fail "session-start.sh 에 auto 분기 누락"
else
  fail "session-start.sh 없음"
fi

# ─── 7. 회귀 가드: 기존 두 스킬 무수정 ───
echo ""
echo "[7] 회귀 가드 (auto-pipeline-baseline 기준)"
if git rev-parse auto-pipeline-baseline >/dev/null 2>&1; then
  DIFF_CONCEPT=$(git diff --name-only auto-pipeline-baseline HEAD -- .claude/skills/concept-pipeline/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  DIFF_BUILD=$(git diff --name-only auto-pipeline-baseline HEAD -- .claude/skills/prototype-build-loop/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  [[ "$DIFF_CONCEPT" == "0" ]] && ok "concept-pipeline SKILL.md 무수정" || fail "concept-pipeline SKILL.md 수정됨"
  [[ "$DIFF_BUILD" == "0" ]] && ok "prototype-build-loop SKILL.md 무수정" || fail "prototype-build-loop SKILL.md 수정됨"
else
  echo "  ⚠️  auto-pipeline-baseline 태그 없음 — 회귀 가드 skip (Task 0 미수행)"
fi

echo ""
echo "─── 결과 ───"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
