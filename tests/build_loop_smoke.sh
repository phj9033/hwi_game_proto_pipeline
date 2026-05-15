#!/usr/bin/env bash
# prototype-build-loop 스모크 테스트
#
# 실행:  bash tests/build_loop_smoke.sh
#
# 검증 항목:
#   1. pipeline.yaml v0.3 schema 확장 (version, state_schema, iteration_log.round_variants)
#   2. .gitignore 에 workspace/*/build/*/ 패턴
#   3. 신규 스킬·슬래시·훅 파일 존재
#   4. engines/{godot,unity}.md 의 §4.3 필수 H2 헤더 7개 존재
#   5. SKILL.md 의 자동 감지 트리거 키워드 정의 존재
#   6. session-start.sh 의 build/ 분기 grep 패턴
#
# 종료 코드: 0 = 모두 통과, 1 = 1개 이상 실패

set -u

PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PIPELINE_ROOT"

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }

echo "=== prototype-build-loop smoke test ==="
echo "ROOT: $PIPELINE_ROOT"
echo ""

# ─── 1. pipeline.yaml v0.3+ ───
echo "[1] pipeline.yaml v0.3+ schema"
VERSION=$(python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); print(d['pipeline']['version'])")
# 본 테스트는 v0.3 에서 도입된 schema 가 살아있는지 검증. 후속 버전 (0.4+) 도 통과해야 함.
VERSION_OK=$(python3 -c "
v = '$VERSION'.split('.')
ok = (int(v[0]), int(v[1])) >= (0, 3)
print('OK' if ok else 'FAIL')
")
[[ "$VERSION_OK" == "OK" ]] && ok "pipeline.version=$VERSION (>=0.3)" || fail "pipeline.version=$VERSION (expected >=0.3)"

ENGINE_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'engine:' in ex else 'MISS')
")
[[ "$ENGINE_FIELD" == "OK" ]] && ok "state_schema example 에 engine 필드" || fail "state_schema example 에 engine 누락"

BUILD_STATE=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
rf = d['state_schema'].get('resume_fields', {})
print('OK' if 'build_state' in rf else 'MISS')
")
[[ "$BUILD_STATE" == "OK" ]] && ok "resume_fields.build_state 그룹 존재" || fail "resume_fields.build_state 누락"

ROUND_VARIANTS=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
step6 = next(s for s in d['steps'] if s['id'] == 6)
sch = step6.get('iteration_log', {}).get('schema', {})
rv = sch.get('round_variants', {})
print('OK' if 'v0' in rv and 'vN' in rv else 'MISS')
")
[[ "$ROUND_VARIANTS" == "OK" ]] && ok "iteration_log.round_variants v0+vN" || fail "round_variants v0/vN 누락"

ROUND_SUBSTEPS=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
step6 = next(s for s in d['steps'] if s['id'] == 6)
rv = step6.get('iteration_log', {}).get('schema', {}).get('round_variants', {})
expected = ['v0.1', 'v0.2', 'v0.3', 'v0.4', 'v0.5']
missing = [k for k in expected if k not in rv]
print('OK' if not missing else 'MISS:' + ','.join(missing))
")
[[ "$ROUND_SUBSTEPS" == "OK" ]] && ok "round_variants v0.1~v0.5 모두 존재 (v0.6+)" || fail "round_variants substep: $ROUND_SUBSTEPS"

# ─── 2. .gitignore ───
echo ""
echo "[2] .gitignore 빌드 트리 격리"
grep -qF "workspace/*/build/*/" .gitignore && ok "build/* 제외 패턴 있음" || fail "build/* 제외 패턴 없음"
grep -qF "!workspace/*/build/engine.yaml" .gitignore && ok "engine.yaml 예외 패턴" || fail "engine.yaml 예외 누락"

# ─── 3. 신규 파일 존재 ───
echo ""
echo "[3] 신규 인프라 파일"
for f in \
  ".claude/skills/prototype-build-loop/SKILL.md" \
  ".claude/skills/prototype-build-loop/adapter-template.md" \
  ".claude/skills/prototype-build-loop/engines/godot.md" \
  ".claude/skills/prototype-build-loop/engines/unity.md" \
  ".claude/commands/prototype-start.md" \
  ".claude/commands/prototype-round.md" \
  ".claude/commands/prototype-snapshot.md" \
  "prompts/prototype-build-loop/round0-scaffold.md" \
  "prompts/prototype-build-loop/roundN-patch.md" \
  "prompts/prototype-build-loop/auto-build-orchestrator.md" \
  "prompts/prototype-build-loop/round0.1-scaffold.md" \
  "prompts/prototype-build-loop/round0.2-core-loop.md" \
  "prompts/prototype-build-loop/round0.3-systems.md" \
  "prompts/prototype-build-loop/round0.4-content.md" \
  "prompts/prototype-build-loop/round0.5-art-placeholders.md" \
  ".claude/skills/prototype-build-loop/tools/gen_placeholders.py" \
  ".claude/skills/prototype-build-loop/tools/test_gen_placeholders.py"; do
  [[ -f "$f" ]] && ok "$f" || fail "$f 없음"
done

# ─── 4. 어댑터 §4.3 필수 H2 헤더 7개 ───
echo ""
echo "[4] 어댑터 필수 H2 헤더 (§4.3)"
REQUIRED_H2=(
  "## 모듈 매핑"
  "## 시그널 매핑"
  "## Resource 매핑"
  "## 테스트 매트릭스 형식"
  "## 프로젝트 init 절차"
  "## .gitignore 템플릿"
  "## .editorconfig"
)
for engine in godot unity; do
  af=".claude/skills/prototype-build-loop/engines/${engine}.md"
  if [[ -f "$af" ]]; then
    for h2 in "${REQUIRED_H2[@]}"; do
      grep -qF "$h2" "$af" && ok "${engine}.md: $h2" || fail "${engine}.md: $h2 누락"
    done
  fi
done

# ─── 5. SKILL.md 자동 감지 트리거 키워드 ───
echo ""
echo "[5] SKILL.md 자동 감지 정의"
SK=".claude/skills/prototype-build-loop/SKILL.md"
if [[ -f "$SK" ]]; then
  grep -qE "추가|수정|변경|제거|바꿔|줄여|늘려|고쳐" "$SK" && ok "액션 동사 정의" || fail "액션 동사 누락"
  grep -qE "어색|안 어울려|이상해|약해|세|지루" "$SK" && ok "평가어 정의" || fail "평가어 누락"
  grep -qE "어떻게|왜|뭐가|언제|어디" "$SK" && ok "의문사 정의 (질문 가드)" || fail "의문사 정의 누락"
fi

# ─── 6. session-start.sh build/ 분기 ───
echo ""
echo "[6] session-start.sh build/ 분기"
HOOK=".claude/hooks/session-start.sh"
if [[ -f "$HOOK" ]]; then
  grep -qF 'build mode active' "$HOOK" && ok "build mode 표시 라인" || fail "build mode 표시 라인 없음"
  grep -qF 'BUILD_DIR=' "$HOOK" && ok "BUILD_DIR 변수 정의" || fail "BUILD_DIR 변수 정의 없음"
  grep -qF '/prototype-start' "$HOOK" && ok "프로토타입 안내 줄" || fail "프로토타입 안내 줄 없음"
fi

# ─── 7. 06b-art-bible.md 슬롯 맵 컬럼 확장 (v0.5) ───
echo ""
echo "[7] 06b-art-bible.md 슬롯 맵 확장 (v0.5)"
AB="prompts/06b-art-bible.md"
if [[ -f "$AB" ]]; then
  grep -q "category" "$AB" && ok "category 컬럼 명시" || fail "category 컬럼 미명시"
  grep -q "palette_ref" "$AB" && ok "palette_ref 컬럼 명시" || fail "palette_ref 컬럼 미명시"
fi

# ─── 8. gen_placeholders.py 단위 테스트 (v0.5) ───
echo ""
echo "[8] gen_placeholders.py 단위 테스트"
if python3 -c "import PIL" 2>/dev/null; then
  if python3 -m pytest .claude/skills/prototype-build-loop/tools/test_gen_placeholders.py -q 2>&1 | tail -3 | grep -qE "passed"; then
    ok "gen_placeholders.py pytest 통과"
  else
    fail "gen_placeholders.py pytest 실패"
  fi
else
  warn "Pillow 미설치 — gen_placeholders.py 테스트 스킵"
fi

# ─── 결과 요약 ───
echo ""
echo "================================"
echo "PASS: $PASS / FAIL: $FAIL / WARN: $WARN"
echo "================================"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
