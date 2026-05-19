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
