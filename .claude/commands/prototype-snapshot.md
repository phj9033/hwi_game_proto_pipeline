---
description: 빌드 트리에 git tag 스냅샷 생성 (사용자 명시 마일스톤)
argument-hint: <tag-name>
model: haiku
---

build/{engine}/ 트리에 git tag 를 만든다.

인자: 태그 이름 (예: `v1.0-vertical-slice`, `v2.0-mvp`)

흐름:
1. `build/{engine}/` 의 git status 확인
2. uncommitted 있으면 3 옵션 제시: auto-commit / stash / 취소
3. `git tag <인자>` 실행 (정상 흐름 또는 사용자 선택 후)
4. `state.yaml.build_state.last_snapshot` 갱신
