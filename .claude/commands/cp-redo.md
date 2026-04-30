---
description: concept-pipeline 특정 단계 재실행 (이전 산출물 백업)
argument-hint: <step-id> [--project <slug>]
model: sonnet
---

# /cp-redo — 특정 단계 재실행

활성 프로젝트의 특정 단계를 처음부터 다시 실행한다. 기존 산출물은 백업.

## 입력
`$ARGUMENTS`:
- 첫 인자: step-id (1~7 정수)
- 옵션: `--project <slug>`

## 동작

1. **활성 프로젝트 결정** (`/cp-next` 와 동일 규칙)
2. **step-id 검증** — 1~7 범위, pipeline.yaml 에 존재하는지
3. **사용자 확인 필수**
   - "단계 N (<이름>) 을 재실행합니다."
   - "기존 산출물은 백업됩니다: <목록>"
   - "이후 단계의 산출물도 무효화됩니다 (current_step 이 N 으로 리셋)."
   - "계속 진행할까요? (y/n)"
4. **백업** — 해당 단계 + 이후 단계의 모든 outputs 파일을:
   - `<filename>.backup-<YYYYMMDD-HHMMSS>` 로 rename
   - 단계 N 이상의 모든 산출물에 적용
5. **state.yaml 갱신**
   - `current_step` = N
   - `completed_steps` 에서 N 이상 모두 제거
   - `artifacts` 의 해당 키들 null/빈 리스트로 리셋
   - `notes` 에 "재실행: 단계 N at <timestamp>" 항목 추가
6. **알림**
   - "단계 N 재진입 완료. `/cp-next` 로 실행 시작."

## 안전 장치

- 백업 없이 덮어쓰기 절대 금지
- `--force` 플래그 없으면 항상 사용자 확인 필수
- 단계 1 재실행 = 거의 새 프로젝트와 동일 → 더 강하게 경고

## 참조
- pipeline.yaml
- workspace/<slug>/state.yaml
- workspace/<slug>/*.md (산출물)

## 출력 톤
- 안전이 우선. 사용자 확인 없이 진행 금지.
- 백업된 파일 경로를 명시
- 다음 명령 안내 (`/cp-next`)
