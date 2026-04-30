#!/usr/bin/env bash
# concept-pipeline SessionStart hook
# 디렉토리 진입 시 활성 프로젝트 상태를 한 화면에 표시한다.

set -e

PIPELINE_ROOT="$HOME/concept-pipeline"
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

# 간단 파싱 (yq 없이 grep 으로)
CURRENT_STEP=$(grep "^current_step:" "$STATE_FILE" | sed 's/current_step: *//' | tr -d '"')
LAST_PAUSE=$(grep "^last_pause_reason:" "$STATE_FILE" | sed 's/last_pause_reason: *//' | tr -d '"')
LAST_PAUSE_AT=$(grep "^last_pause_at:" "$STATE_FILE" | sed 's/last_pause_at: *//' | tr -d '"')
COMPLETED_COUNT=$(grep -c "^  - { id:" "$STATE_FILE" 2>/dev/null || echo 0)

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

echo ""
echo "이어가기:  \"이어서 하자\"  또는  /concept-pipeline"
echo "상태 확인: /cp-status"
echo "재실행:    /cp-redo <단계번호>"
echo "================================"
