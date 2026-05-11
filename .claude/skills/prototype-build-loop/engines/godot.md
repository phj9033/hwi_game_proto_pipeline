---
engine: godot
version: "4.3"
required_tools:
  - godot                    # CLI: godot --version 으로 확인
init_command: "godot --headless --quit-after 1 --path ."
---

## 모듈 매핑

- tech-spec §F 모듈 1 개 → 파일 1 개: `scripts/<module_snake_case>.gd`
- 기본 부모 노드 타입: 모듈 분류에 따라 `Node` / `Node2D` / `CharacterBody2D` / `Control` (UI) / `Resource` (데이터)
- 모듈 간 의존: autoload 싱글톤 `signals.gd` 통한 시그널 약결합 (직접 참조 ✕)

## 시그널 매핑

- tech-spec §G 시그널 → autoload `signals.gd` 의 `signal X(args...)`
- 시그널명: §G 의 식별자 그대로 (snake_case 권장)
- emit: `Signals.emit_signal("x", arg1, arg2)`
- connect: `Signals.x.connect(_on_x)`

## Resource 매핑

- tech-spec §G Resource → `class_name <Name> extends Resource`
- 파일 형식: `.tres` (텍스트), `resources/<name>.tres` 디렉토리
- 인스펙터 노출: `@export var field: Type`
- 직렬화 키: `@export_storage` 사용 가능

## 테스트 매트릭스 형식

- 프레임워크: GUT (Godot Unit Test) 또는 GoDotTest
- 테스트 파일 위치: `tests/test_<module>.gd`
- §I AC 1 개 → 테스트 함수 1 개: `func test_ac_<id>():`
- 실행: `godot --headless -s addons/gut/gut_cmdln.gd`

## 에셋 로드 컨벤션

- Placeholder PNG 경로: `art/{slot_id}.png` (`build/{engine}/` 기준 상대 경로)
- 로드 패턴: `preload("res://art/{slot_id}.png")` 또는 `load("res://art/{slot_id}.png")`
- 교체 시: 동일 파일명·동일 경로면 코드 수정 ✕. sprite size 변경 시만 scene 의 sprite 크기 조정.
- art-bible §Z 슬롯 맵의 `통합 위치` 컬럼 = 호출처 (예: `species_icon.gd:make_for_species`)

## 프로젝트 init 절차

1. `project.godot` 생성 (engine version 4.3 명시)
2. autoload 등록: AutoLoad → `signals.gd`
3. main_scene 지정: `scenes/main.tscn`
4. `.gitignore` / `.editorconfig` 적용
5. `godot --headless --quit-after 1 --path .` 으로 import 트리거 (.godot/ 생성)
6. tests/ 디렉토리 골격 생성

## .gitignore 템플릿

```
.godot/
.import/
*.translation
.DS_Store
```

## .editorconfig

```
root = true

[*.gd]
indent_style = tab
indent_size = 4
charset = utf-8
end_of_line = lf
trim_trailing_whitespace = true
insert_final_newline = true

[*.tscn]
indent_style = tab

[*.tres]
indent_style = tab
```
