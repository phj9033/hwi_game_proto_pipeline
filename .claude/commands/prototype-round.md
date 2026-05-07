---
description: AI 수정 라운드 명시 트리거 (자동 감지 escape hatch)
model: sonnet
---

prototype-build-loop 의 Round N (AI 수정 라운드) 를 명시 호출.

평소엔 자동 감지로 진입하지만, 감지가 놓친 경우 / 의심스러운 경우 사용:

1. 사용자에게 수정 요청·피드백 입력 받기
2. SSOT 영향 §섹션 식별
3. 엔진 어댑터 기반 코드 패치 제안 (diff 표시)
4. 사용자 검토·승인 (부분 적용 OK)
5. build/{engine}/ commit + ITERATION_LOG vN 항목 (5 필드)
6. SSOT 룰 영향 시 06-changelog.md 도 append
