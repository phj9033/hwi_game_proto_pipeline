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
