---
description: concept-pipeline 진행 상황 표시 (간단 스냅샷)
argument-hint: [--project <slug>]
model: haiku
---

# /cp-status — 파이프라인 진행 상황

`~/concept-pipeline/workspace/` 의 모든 프로젝트와 활성 프로젝트의 진행 상태를 한 화면에 표시한다.

## 동작

1. `~/concept-pipeline/workspace/.active` 읽어서 활성 프로젝트 식별 (있으면)
2. `~/concept-pipeline/workspace/*/state.yaml` 모두 스캔
3. 각 프로젝트마다 다음 한 줄로 정리:
   - `[★]` 활성 프로젝트 마커 (있으면)
   - 프로젝트 slug
   - 현재 단계 번호 + 이름
   - 진행률 (completed/7)
   - 마지막 갱신 시각

4. 활성 프로젝트가 있으면 추가로:
   - 산출물 파일 목록 (workspace/<slug>/ 의 *.md)
   - 다음 권장 명령 (`/cp-next`)

5. `--project <slug>` 인자 있으면 그 프로젝트만 상세 표시

## 출력 형식 예시

```
파이프라인 프로젝트 (3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
★ dragon-cafe        4/7  4단계: 5-Axis 평가 (대기)    2026-04-28 14:30
  reel-odyssey-v2    2/7  2단계: 분기 초안            2026-04-25 09:12
  space-fishing      7/7  완료                         2026-04-20 18:00

활성: dragon-cafe
산출물: 01-concept.md, 02-draft-A.md, 02-draft-B.md, 02-draft-C.md
다음: /cp-next  (4단계 평가 시작)
```

## 출력 톤
- 명령어이므로 짧고 빠른 표시
- 사용자 질문 없이 즉시 반환
- 한국어 + 영문 slug 혼용 OK
- 5점 척도, 3.5 컷오프 등 부가정보는 활성 프로젝트가 4단계 직후일 때만 표시
