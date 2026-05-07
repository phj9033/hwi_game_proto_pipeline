#!/usr/bin/env bash
# concept-pipeline SessionStart hook
# 디렉토리 진입 시 활성 프로젝트 상태를 한 화면에 표시한다.
#
# 클론 위치 오버라이드:
#   다른 경로에 클론한 경우 환경변수로 지정.
#   예) export CONCEPT_PIPELINE_ROOT="$HOME/work/concept-pipeline"

set -e

PIPELINE_ROOT="${CONCEPT_PIPELINE_ROOT:-$HOME/concept-pipeline}"
ACTIVE_FILE="$PIPELINE_ROOT/workspace/.active"

echo "=== concept-pipeline ==="

if [[ ! -f "$ACTIVE_FILE" ]]; then
  echo "활성 프로젝트 없음."
  echo ""
  echo "시작하려면:"
  echo "  /concept-pipeline                  (슬래시)"
  echo "  \"컨셉 파이프라인 시작\"           (자연어)"
  echo "  \"게임 컨셉 만들자\"                (자연어)"
  echo "================================"
  exit 0
fi

SLUG=$(cat "$ACTIVE_FILE" | tr -d '[:space:]')
STATE_FILE="$PIPELINE_ROOT/workspace/$SLUG/state.yaml"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "활성 프로젝트: $SLUG (state.yaml 없음 — 손상 가능성)"
  echo "================================"
  exit 0
fi

# YAML 파싱 — yq 있으면 사용, 없으면 grep/sed 폴백
# yq 는 멀티라인·따옴표·중첩 키에 안전. grep 폴백은 단순 단일 라인 키만 지원.
if command -v yq >/dev/null 2>&1; then
  CURRENT_STEP=$(yq -r '.current_step // ""' "$STATE_FILE")
  LAST_PAUSE=$(yq -r '.last_pause_reason // ""' "$STATE_FILE")
  LAST_PAUSE_AT=$(yq -r '.last_pause_at // ""' "$STATE_FILE")
  COMPLETED_COUNT=$(yq -r '.completed_steps | length' "$STATE_FILE" 2>/dev/null || echo 0)
else
  CURRENT_STEP=$(grep "^current_step:" "$STATE_FILE" | sed 's/current_step: *//' | tr -d '"')
  LAST_PAUSE=$(grep "^last_pause_reason:" "$STATE_FILE" | sed 's/last_pause_reason: *//' | tr -d '"')
  LAST_PAUSE_AT=$(grep "^last_pause_at:" "$STATE_FILE" | sed 's/last_pause_at: *//' | tr -d '"')
  COMPLETED_COUNT=$(grep -c "^  - { id:" "$STATE_FILE" 2>/dev/null || echo 0)
fi

# 단계 이름 매핑
case "$CURRENT_STEP" in
  1) STEP_NAME="컨셉 정립" ;;
  2) STEP_NAME="3개 분기 초안" ;;
  3) STEP_NAME="저장 게이트" ;;
  4) STEP_NAME="5-Axis 평가" ;;
  5) STEP_NAME="상세 확장" ;;
  6) STEP_NAME="통합 명세서" ;;
  7) STEP_NAME="완료 게이트" ;;
  8) STEP_NAME="✅ 완료" ;;
  *) STEP_NAME="알 수 없음" ;;
esac

echo "📌 활성 프로젝트: $SLUG"
echo "   현재 단계: $CURRENT_STEP/7 — $STEP_NAME"

if [[ -n "$LAST_PAUSE" && "$LAST_PAUSE" != "null" && "$LAST_PAUSE" != "~" ]]; then
  echo "   마지막 멈춤: $LAST_PAUSE"
  [[ -n "$LAST_PAUSE_AT" && "$LAST_PAUSE_AT" != "null" ]] && echo "   ($LAST_PAUSE_AT)"
fi

# build/ 디렉토리 인지 (v0.3 prototype-build-loop)
BUILD_DIR="$PIPELINE_ROOT/workspace/$SLUG/build"
if [[ -d "$BUILD_DIR" ]]; then
  if command -v yq >/dev/null 2>&1; then
    CURRENT_ROUND=$(yq -r '.build_state.current_round // ""' "$STATE_FILE" 2>/dev/null)
    LAST_SNAPSHOT=$(yq -r '.build_state.last_snapshot // ""' "$STATE_FILE" 2>/dev/null)
    BUILD_ENGINE=$(yq -r '.artifacts.engine // ""' "$STATE_FILE" 2>/dev/null)
  else
    CURRENT_ROUND=$(awk '/^build_state:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag && /current_round:/{print; exit}' "$STATE_FILE" | sed 's/.*current_round: *//' | tr -d '"')
    LAST_SNAPSHOT=$(awk '/^build_state:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag && /last_snapshot:/{print; exit}' "$STATE_FILE" | sed 's/.*last_snapshot: *//' | tr -d '"')
    BUILD_ENGINE=$(awk '/^artifacts:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag && /^[[:space:]]+engine:/{print; exit}' "$STATE_FILE" | sed 's/.*engine: *//' | tr -d '"')
  fi
  echo ""
  echo "🛠 build mode active:"
  [[ -n "$BUILD_ENGINE" && "$BUILD_ENGINE" != "null" ]] && echo "   엔진: $BUILD_ENGINE"
  [[ -n "$CURRENT_ROUND" && "$CURRENT_ROUND" != "null" ]] && echo "   현재 라운드: v$CURRENT_ROUND"
  [[ -n "$LAST_SNAPSHOT" && "$LAST_SNAPSHOT" != "null" ]] && echo "   마지막 스냅샷: $LAST_SNAPSHOT"
fi

echo ""
echo "이어가기:  \"이어서 하자\"  또는  /concept-pipeline"
echo "상태 확인: /cp-status"
echo "재실행:    /cp-redo <단계번호>"
echo "프로토타입: \"프로토타입 시작\"  또는  /prototype-start"
echo "스냅샷:    /prototype-snapshot <tag>"
echo "================================"
