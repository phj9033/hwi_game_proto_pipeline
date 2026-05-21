# spec-pipeline 골든 검증 기준

LLM 내용 검증 ✕. 구조·존재·길이만.

각 골든 입력에 대해 다음을 단언:

## 산출물 존재
- `workspace/<golden-slug>/gdd.md` 존재 + 0바이트 아님
- `workspace/<golden-slug>/tech-spec.md` 존재 + 0바이트 아님
- `workspace/<golden-slug>/art-spec.md` 존재 + 0바이트 아님

## 헤딩 수
- `gdd.md` H1 count ≥ 12
- `tech-spec.md` H1 count ≥ 10
- `art-spec.md` H1 count ≥ 11

## art-spec 일관성
- `art-spec.md` §10 의 모든 `prompt:` 행은 §2 의 hex 1개 이상 또는 §1 의 키워드 1개 이상 본문에 포함

## 슬러그 영향
- 각 골든 입력은 고유 슬러그 (`golden-short`, `golden-medium`, `golden-long`)
- 골든 실행은 기존 workspace 슬러그를 건드리지 않음
