---
engine: <engine-id>          # 예: godot, unity, bevy
version: "<x.y>"             # 엔진 버전
required_tools:
  - <tool-name>              # 예: godot, dotnet
init_command: ""             # 비대화식 init 명령 또는 "(manual)" + 가이드
---

<!--
어댑터 작성 규약 (v0.3):
- 7 개 H2 헤더는 *고정* — 추가는 OK, 누락은 ✕ (smoke test 검증)
- 코어 SKILL 이 이 데이터를 grep + 섹션 추출 방식으로 읽음
- 가능한 한 *명령형 단문* 으로 (구체적 경로·명령 포함)
-->

## 모듈 매핑

- tech-spec §F 모듈 1 개 → 파일 1 개: `<엔진별 경로 패턴>`
- 기본 부모 클래스/노드 타입: `<예시>`
- 모듈 간 의존: <시그널/이벤트/직접 참조 중 무엇>

## 시그널 매핑

- tech-spec §G 시그널 → <엔진별 매커니즘>
- 시그널명 컨벤션: <snake_case / camelCase 등>

## Resource 매핑

- tech-spec §G Resource → <엔진별 클래스 + 파일 형식>
- 인스펙터 노출 방식: <어노테이션·패턴>

## 테스트 매트릭스 형식

- 프레임워크: <테스트 라이브러리>
- 테스트 파일 위치: `<경로 패턴>`
- §I AC 1 개 → 테스트 함수 1 개 매핑 규칙

## 프로젝트 init 절차

1. <스텝 1>
2. <스텝 2>
3. ...
(자동화 가능하면 init_command 에도 명시)

## .gitignore 템플릿

```
<엔진 표준 .gitignore 내용>
```

## .editorconfig

```
<엔진 권장 들여쓰기·인코딩 규칙>
```
