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
