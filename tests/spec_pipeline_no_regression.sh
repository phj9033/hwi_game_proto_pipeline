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
