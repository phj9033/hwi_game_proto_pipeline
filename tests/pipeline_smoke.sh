#!/usr/bin/env bash
# concept-pipeline 본체 스모크 테스트
#
# 실행:
#   bash tests/pipeline_smoke.sh
#
# 검증 항목:
#   1. pipeline.yaml / config.yaml YAML 파싱
#   2. prompts/*.md 모두 존재 (pipeline.yaml 의 prompt 참조 기준)
#   3. .claude/hooks/session-start.sh 실행 가능
#   4. .claude/skills/concept-pipeline/SKILL.md 존재
#   5. .claude/commands/cp-{status,redo}.md 존재
#   6. pipeline.yaml.version 이 "0.x" 형식 string
#   7. pipeline.yaml CHANGELOG 의 version 들이 단조 감소 (최신이 최상단)
#   8. 단계 7 게이트의 cross_reference_check 패턴이 sail-and-cast 산출물(있으면) 에서 통과
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

echo "=== concept-pipeline smoke test ==="
echo "ROOT: $PIPELINE_ROOT"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 1. YAML 파싱
# ─────────────────────────────────────────────────────────────────────────────
echo "[1] YAML 파싱"
if python3 -c "import yaml; yaml.safe_load(open('pipeline.yaml'))" 2>/dev/null; then
  ok "pipeline.yaml 파싱 OK"
else
  fail "pipeline.yaml 파싱 실패"
fi
if python3 -c "import yaml; yaml.safe_load(open('config.yaml'))" 2>/dev/null; then
  ok "config.yaml 파싱 OK"
else
  fail "config.yaml 파싱 실패"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2. prompts/*.md 모두 존재
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[2] prompts 파일 존재"
for f in prompts/01-concept.md prompts/02-draft.md prompts/04-eval.md \
         prompts/05-expand.md prompts/06-spec.md prompts/06b-art-bible.md \
         prompts/06c-tech-spec.md; do
  if [[ -f "$f" ]]; then ok "$f"; else fail "$f 없음"; fi
done

# ─────────────────────────────────────────────────────────────────────────────
# 3. hooks·skills·commands
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[3] 인프라 파일"
HOOK=".claude/hooks/session-start.sh"
if [[ -f "$HOOK" ]]; then
  ok "$HOOK 존재"
  if [[ -x "$HOOK" ]] || head -1 "$HOOK" | grep -q "^#!"; then
    ok "$HOOK 실행 가능 (shebang 또는 +x)"
  else
    warn "$HOOK 실행 비트 ✕ (bash 명시 호출은 OK)"
  fi
else
  fail "$HOOK 없음"
fi
[[ -f ".claude/skills/concept-pipeline/SKILL.md" ]] && ok "SKILL.md 존재" || fail "SKILL.md 없음"
[[ -f ".claude/commands/cp-status.md" ]] && ok "cp-status.md 존재" || fail "cp-status.md 없음"
[[ -f ".claude/commands/cp-redo.md" ]] && ok "cp-redo.md 존재" || fail "cp-redo.md 없음"
[[ -f ".claude/settings.json" ]] && ok "settings.json 존재" || fail "settings.json 없음"

# ─────────────────────────────────────────────────────────────────────────────
# 4. version 형식 + CHANGELOG 단조 감소
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[4] version 메타"
VERSION=$(python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); print(d['pipeline']['version'])")
if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  ok "pipeline.version=$VERSION (semver-like)"
else
  fail "pipeline.version=$VERSION 형식 위반"
fi

CHANGELOG_OK=$(python3 <<'PY'
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
log = d.get('changelog', [])
if not log:
    print("EMPTY"); raise SystemExit
versions = [tuple(map(int, e['version'].split('.'))) for e in log]
print("OK" if versions == sorted(versions, reverse=True) else "DESC_VIOLATION")
PY
)
case "$CHANGELOG_OK" in
  OK)               ok "CHANGELOG 단조 감소 (최신이 최상단)" ;;
  EMPTY)            warn "CHANGELOG 비어있음" ;;
  DESC_VIOLATION)   fail "CHANGELOG 정렬 위반" ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# 5. 단계 7 게이트 패턴 — sail-and-cast 가 있으면 검증
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[5] 단계 7 게이트 패턴 (sail-and-cast 산출물 기준)"
SLUG_DIR="workspace/sail-and-cast"
if [[ -d "$SLUG_DIR" ]]; then
  for f in 06-integrated-spec.md 06-art-bible.md 06-tech-spec.md; do
    [[ -f "$SLUG_DIR/$f" ]] && ok "$f 존재" || warn "$f 없음 (sail-and-cast 산출물 부분 미작성)"
  done
  if [[ -f "$SLUG_DIR/06-art-bible.md" && -f "$SLUG_DIR/06-tech-spec.md" ]]; then
    # grep -c 는 0 매치 시 exit 1 → "|| echo 0" 패턴은 stdout 에 "0" 두 번 박는다.
    # grep | wc -l 로 단순화 (출력은 항상 정수, exit 코드 무시)
    AB_REF=$(grep -E "06-integrated-spec\.md" "$SLUG_DIR/06-art-bible.md" 2>/dev/null | wc -l | tr -d ' ')
    TS_REF=$(grep -E "06-integrated-spec\.md" "$SLUG_DIR/06-tech-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $AB_REF -ge 3 ]] && ok "art-bible SSOT 인용 ${AB_REF}회 (>=3)" || fail "art-bible SSOT 인용 ${AB_REF}회 (<3)"
    [[ $TS_REF -ge 3 ]] && ok "tech-spec SSOT 인용 ${TS_REF}회 (>=3)" || fail "tech-spec SSOT 인용 ${TS_REF}회 (<3)"

    AB_COPY=$(grep -E "^## 부록 X|^## 변경 이력|^### 변경 이력" "$SLUG_DIR/06-art-bible.md" 2>/dev/null | wc -l | tr -d ' ')
    TS_COPY=$(grep -E "^## 부록 X|^## 변경 이력|^### 변경 이력" "$SLUG_DIR/06-tech-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $AB_COPY -eq 0 ]] && ok "art-bible 변경이력 복제 없음" || fail "art-bible 변경이력 복제 ${AB_COPY}건"
    [[ $TS_COPY -eq 0 ]] && ok "tech-spec 변경이력 복제 없음" || fail "tech-spec 변경이력 복제 ${TS_COPY}건"
  fi
  if [[ -f "$SLUG_DIR/06-integrated-spec.md" ]]; then
    SSOT_LOG=$(grep -E "^- 20[0-9]{2}-[0-9]{2}-[0-9]{2} v[0-9]" "$SLUG_DIR/06-integrated-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $SSOT_LOG -eq 0 ]] && ok "SSOT 본문 변경이력 항목 없음 (분리됨)" || fail "SSOT 본문 변경이력 ${SSOT_LOG}건 - 06-changelog.md 로 분리 필요"
  fi

  # 단계 3 content 게이트 (v0.2.1~) — 분기 축 "왜 이 변주" 필드 검증
  for d in A B C; do
    if [[ -f "$SLUG_DIR/02-draft-${d}.md" ]]; then
      WHY=$(grep -E "왜 이 변주" "$SLUG_DIR/02-draft-${d}.md" 2>/dev/null | wc -l | tr -d ' ')
      [[ $WHY -ge 1 ]] && ok "02-draft-${d}.md '왜 이 변주' 필드 있음" || fail "02-draft-${d}.md '왜 이 변주' 필드 누락"
    fi
  done

  # 단계 7 깊이 게이트 (v0.2.1~) — 시점 문서가 SSOT 의 *적절한 섹션* 인용
  if [[ -f "$SLUG_DIR/06-art-bible.md" ]]; then
    AB_E=$(grep -E "§E" "$SLUG_DIR/06-art-bible.md" 2>/dev/null | wc -l | tr -d ' ')
    AB_G1=$(grep -E "§G\\.1|§G[ .]" "$SLUG_DIR/06-art-bible.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $AB_E -ge 1 ]] && ok "art-bible §E 인용 ${AB_E}회 (>=1)" || fail "art-bible §E 인용 없음"
    [[ $AB_G1 -ge 1 ]] && ok "art-bible §G.1 인용 ${AB_G1}회 (>=1)" || fail "art-bible §G.1 인용 없음"
  fi
  if [[ -f "$SLUG_DIR/06-tech-spec.md" ]]; then
    TS_F=$(grep -E "§F" "$SLUG_DIR/06-tech-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    TS_G=$(grep -E "§G" "$SLUG_DIR/06-tech-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    TS_I=$(grep -E "§I" "$SLUG_DIR/06-tech-spec.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $TS_F -ge 1 ]] && ok "tech-spec §F 인용 ${TS_F}회 (>=1)" || fail "tech-spec §F 인용 없음"
    [[ $TS_G -ge 1 ]] && ok "tech-spec §G 인용 ${TS_G}회 (>=1)" || fail "tech-spec §G 인용 없음"
    [[ $TS_I -ge 1 ]] && ok "tech-spec §I 인용 ${TS_I}회 (>=1)" || fail "tech-spec §I 인용 없음"
  fi
else
  warn "workspace/sail-and-cast 없음 — 게이트 검증 스킵"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "PASS: $PASS / FAIL: $FAIL / WARN: $WARN"
echo "================================"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
