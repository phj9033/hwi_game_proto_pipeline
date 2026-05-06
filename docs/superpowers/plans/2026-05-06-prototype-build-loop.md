# Prototype Build Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Concept-pipeline 의 단계 7 산출물을 입력으로 받아 Godot/Unity 프로토타입 빌드와 라운드 단위 AI 수정을 지원하는 새 스킬 `prototype-build-loop` 를 구현한다.

**Architecture:** 데이터 주도 패턴 (β) — 코어 SKILL.md 는 엔진 무관, 엔진별 차이는 `engines/{engine}.md` 어댑터 데이터 파일에 격리. ITERATION_LOG.md 가 Round 0 (초기) + Round N (AI 수정) 만 추적, 사용자 직접 수정은 누락 허용. 빌드 트리는 `build/{engine}/` 단일 디렉토리 + git tag 스냅샷.

**Tech Stack:** Markdown skill files, bash hook, YAML config (pipeline.yaml), Python3 + PyYAML (smoke test), git (스냅샷).

**Spec:** `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md`

---

## File Structure

### Create
- `.claude/skills/prototype-build-loop/SKILL.md` — 코어 스킬 (Round 0/N 흐름, 자동 감지 룰)
- `.claude/skills/prototype-build-loop/adapter-template.md` — 어댑터 빈 템플릿
- `.claude/skills/prototype-build-loop/engines/godot.md` — Godot 4.x 어댑터
- `.claude/skills/prototype-build-loop/engines/unity.md` — Unity 6.x 어댑터
- `.claude/commands/prototype-start.md` — `/prototype-start` 슬래시
- `.claude/commands/prototype-round.md` — `/prototype-round` 슬래시 (escape hatch)
- `.claude/commands/prototype-snapshot.md` — `/prototype-snapshot <tag>` 슬래시
- `tests/build_loop_smoke.sh` — 스모크 테스트
- `prompts/prototype-build-loop/round0-scaffold.md` — Round 0 스캐폴드 프롬프트
- `prompts/prototype-build-loop/roundN-patch.md` — Round N 패치 제안 프롬프트

### Modify
- `pipeline.yaml` — v0.2.1 → v0.3 (state_schema + iteration_log.round_variants + changelog)
- `.claude/hooks/session-start.sh` — `build/` 디렉토리 인지 분기 추가
- `.gitignore` — `workspace/*/build/*/` 추가
- `README.md` — 스킬 도입 1줄 안내 (선택)

---

## Task 1: pipeline.yaml v0.3 schema 확장

**Files:**
- Modify: `pipeline.yaml`

- [ ] **Step 1: pipeline.version bump**

`pipeline.yaml` line 7 에서:
```yaml
version: "0.2.1"
```
→
```yaml
version: "0.3"
```

- [ ] **Step 2: changelog 항목 prepend (line 29 의 `changelog:` 직후)**

```yaml
changelog:
  - version: "0.3"
    date: "2026-05-06"
    changes:
      - "신규: prototype-build-loop 스킬 통합 — concept-pipeline 단계 7 이후 프로토타입 빌드·라운드 워크플로우"
      - "state_schema.required_fields 에 artifacts.engine, artifacts.build_initialized 추가"
      - "state_schema.resume_fields 에 build_state 그룹 신규 (current_round, last_snapshot, last_round_at, system_keywords)"
      - "단계 6 iteration_log.schema 에 round_variants 신규 — v0 (3 필드) + vN (5 필드) 구분"
  - version: "0.2.1"
    ...
```

- [ ] **Step 3: state_schema.required_fields.artifacts 확장 (line 69 영역)**

`artifacts: object` 의 주석/예시에 다음 키들이 정의됨을 명시:
- `engine`: string | null — 선택된 엔진 (`godot` / `unity` / null)
- `build_initialized`: boolean — Round 0 완료 여부 (기본 false)

`state_schema.example` (line 101 영역) 의 `artifacts:` 블록에 두 줄 추가:
```yaml
artifacts:
  ...
  engine: null
  build_initialized: false
```

- [ ] **Step 4: state_schema.resume_fields 에 build_state 그룹 추가 (line 72 영역)**

`resume_fields:` 아래에 신규 그룹:
```yaml
  build_state:                       # 프로토타입 빌드 라운드 상태 (v0.3~)
    current_round: integer | null    # 마지막 완료 라운드 (정수)
    last_snapshot: string | null     # 마지막 git tag (또는 null)
    last_round_at: ISO 8601 | null
    system_keywords: array | null    # SSOT §C·§B 추출 캐시
```

- [ ] **Step 5: 단계 6 iteration_log.schema 교체 (정확 anchor)**

기존 마이그레이션 규약(rule 3 의 "누락된 required_fields/resume_fields 기본값 추가") 이 이미 *필드 추가* 시나리오를 처리하므로 별도 보강 ✕. 본 step 은 `iteration_log.schema` 만 교체.

`pipeline.yaml` 에서 정확한 old/new (Edit anchor):

old_string:
```yaml
      schema:
        round_header: "## v{N} — {라운드명} ({YYYY-MM-DD})"
        round_fields:                # 각 라운드 본문 5 필드 (전부 또는 일부)
          - "**구성**: 이번 라운드의 빌드 구성 / 메인 변화"
          - "**사용자 피드백**: 인용 형태로 *원문 그대로*"
          - "**진단**: 피드백 → 원인 추적 (1~3줄)"
          - "**변경**: 코드/명세 변경 항목 (bullet)"
          - "**결과**: 변경 후 측정·관찰 (다음 라운드 트리거)"
```

new_string:
```yaml
      schema:
        round_header: "## v{N} — {라운드명} ({YYYY-MM-DD})"
        # round_fields 는 v0.3 에서 round_variants 로 대체됨 (라운드 종류별 다른 필드 셋).
        round_variants:                # v0.3~ : 라운드 종류별 필드 셋
          v0:                          # Round 0 — 초기 환경 (prototype-build-loop)
            description: "build/{engine}/ 스캐폴드 직후 1회. AI 수정 라운드 ✕."
            fields:
              - "**엔진**: 선택된 엔진 + 버전"
              - "**세팅**: tech-spec §F·§G·§I 어느 만큼 스캐폴드되었나"
              - "**시드 컨텐츠**: 코어 루프 1 사이클 placeholder 동작 범위"
          vN:                          # Round N ≥ 1 — AI 수정 라운드
            description: "사용자 피드백·요청 → AI 패치 → 적용 1 사이클 종료 시"
            fields:
              - "**구성**: 이번 라운드의 빌드 구성 / 메인 변화"
              - "**사용자 피드백**: 인용 형태로 *원문 그대로*"
              - "**진단**: 피드백 → 원인 추적 (1~3줄)"
              - "**변경**: 코드/명세 변경 항목 (bullet)"
              - "**결과**: 변경 후 측정·관찰 (다음 라운드 트리거)"
```

`round_fields:` 키는 *제거*. 호환 호출처가 없으므로 (v0.2.x 산출물이 이 키를 직접 읽는 코드 ✕) 깨끗하게 자름. v0.3 changelog 에 이 사실을 기재.

- [ ] **Step 6: YAML 파싱 검증**

```bash
python3 -c "import yaml; yaml.safe_load(open('pipeline.yaml'))"
```
Expected: 에러 없음, exit 0.

- [ ] **Step 7: changelog 추가 항목 보강 — round_fields 제거 명시**

Step 2 에서 추가한 v0.3 changelog 의 changes 리스트에 다음 줄 추가:
```
      - "BREAKING (낮음): iteration_log.schema.round_fields 키 제거 (round_variants.vN.fields 로 대체). 외부 호출처 영향 ✕."
```

- [ ] **Step 8: Commit**

```bash
git add pipeline.yaml
git commit -m "feat(pipeline): v0.3 schema — build-loop fields + iteration_log.round_variants"
```

---

## Task 2: 부모 레포 .gitignore + 빌드 트리 격리

**Files:**
- Modify: `.gitignore` (없으면 생성)

- [ ] **Step 1: .gitignore 확인**

```bash
test -f .gitignore && cat .gitignore | tail -20 || echo "MISSING"
```
Expected: 기존 내용 또는 MISSING.

- [ ] **Step 2: 빌드 트리 + 스냅샷 패턴 추가**

`.gitignore` 끝에 다음 블록 append (이미 있으면 스킵):
```
# prototype-build-loop — build trees have their own .git, exclude from parent
workspace/*/build/*/
!workspace/*/build/engine.yaml
```

`engine.yaml` 은 메타 파일이라 부모가 추적해야 함 → `!` 로 예외.

- [ ] **Step 3: 검증**

```bash
grep -F "workspace/*/build/*/" .gitignore
grep -F "!workspace/*/build/engine.yaml" .gitignore
```
Expected: 두 줄 모두 매치.

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore(gitignore): exclude prototype build trees, keep engine.yaml meta"
```

---

## Task 3: build_loop_smoke.sh 스모크 테스트 작성

**Files:**
- Create: `tests/build_loop_smoke.sh`

- [ ] **Step 1: 스모크 테스트 파일 생성**

`tests/build_loop_smoke.sh` 작성. `tests/pipeline_smoke.sh` 의 헤더·도우미 함수 패턴 그대로 차용:

```bash
#!/usr/bin/env bash
# prototype-build-loop 스모크 테스트
#
# 실행:  bash tests/build_loop_smoke.sh
#
# 검증 항목:
#   1. pipeline.yaml v0.3 schema 확장 (version, state_schema, iteration_log.round_variants)
#   2. .gitignore 에 workspace/*/build/*/ 패턴
#   3. 신규 스킬·슬래시·훅 파일 존재
#   4. engines/{godot,unity}.md 의 §4.3 필수 H2 헤더 7개 존재
#   5. SKILL.md 의 자동 감지 트리거 키워드 정의 존재
#   6. session-start.sh 의 build/ 분기 grep 패턴
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

echo "=== prototype-build-loop smoke test ==="
echo "ROOT: $PIPELINE_ROOT"
echo ""

# ─── 1. pipeline.yaml v0.3 ───
echo "[1] pipeline.yaml v0.3 schema"
VERSION=$(python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); print(d['pipeline']['version'])")
[[ "$VERSION" == "0.3" ]] && ok "pipeline.version=0.3" || fail "pipeline.version=$VERSION (expected 0.3)"

ENGINE_FIELD=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
ex = d['state_schema'].get('example', '')
print('OK' if 'engine:' in ex else 'MISS')
")
[[ "$ENGINE_FIELD" == "OK" ]] && ok "state_schema example 에 engine 필드" || fail "state_schema example 에 engine 누락"

BUILD_STATE=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
rf = d['state_schema'].get('resume_fields', {})
print('OK' if 'build_state' in rf else 'MISS')
")
[[ "$BUILD_STATE" == "OK" ]] && ok "resume_fields.build_state 그룹 존재" || fail "resume_fields.build_state 누락"

ROUND_VARIANTS=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
step6 = next(s for s in d['steps'] if s['id'] == 6)
sch = step6.get('iteration_log', {}).get('schema', {})
rv = sch.get('round_variants', {})
print('OK' if 'v0' in rv and 'vN' in rv else 'MISS')
")
[[ "$ROUND_VARIANTS" == "OK" ]] && ok "iteration_log.round_variants v0+vN" || fail "round_variants v0/vN 누락"

# ─── 2. .gitignore ───
echo ""
echo "[2] .gitignore 빌드 트리 격리"
grep -qF "workspace/*/build/*/" .gitignore && ok "build/* 제외 패턴 있음" || fail "build/* 제외 패턴 없음"
grep -qF "!workspace/*/build/engine.yaml" .gitignore && ok "engine.yaml 예외 패턴" || fail "engine.yaml 예외 누락"

# ─── 3. 신규 파일 존재 ───
echo ""
echo "[3] 신규 인프라 파일"
for f in \
  ".claude/skills/prototype-build-loop/SKILL.md" \
  ".claude/skills/prototype-build-loop/adapter-template.md" \
  ".claude/skills/prototype-build-loop/engines/godot.md" \
  ".claude/skills/prototype-build-loop/engines/unity.md" \
  ".claude/commands/prototype-start.md" \
  ".claude/commands/prototype-round.md" \
  ".claude/commands/prototype-snapshot.md" \
  "prompts/prototype-build-loop/round0-scaffold.md" \
  "prompts/prototype-build-loop/roundN-patch.md"; do
  [[ -f "$f" ]] && ok "$f" || fail "$f 없음"
done

# ─── 4. 어댑터 §4.3 필수 H2 헤더 7개 ───
echo ""
echo "[4] 어댑터 필수 H2 헤더 (§4.3)"
REQUIRED_H2=(
  "## 모듈 매핑"
  "## 시그널 매핑"
  "## Resource 매핑"
  "## 테스트 매트릭스 형식"
  "## 프로젝트 init 절차"
  "## .gitignore 템플릿"
  "## .editorconfig"
)
for engine in godot unity; do
  af=".claude/skills/prototype-build-loop/engines/${engine}.md"
  if [[ -f "$af" ]]; then
    for h2 in "${REQUIRED_H2[@]}"; do
      grep -qF "$h2" "$af" && ok "${engine}.md: $h2" || fail "${engine}.md: $h2 누락"
    done
  fi
done

# ─── 5. SKILL.md 자동 감지 트리거 키워드 ───
echo ""
echo "[5] SKILL.md 자동 감지 정의"
SK=".claude/skills/prototype-build-loop/SKILL.md"
if [[ -f "$SK" ]]; then
  grep -qE "추가|수정|변경|제거|바꿔|줄여|늘려|고쳐" "$SK" && ok "액션 동사 정의" || fail "액션 동사 누락"
  grep -qE "어색|안 어울려|이상해|약해|세|지루" "$SK" && ok "평가어 정의" || fail "평가어 누락"
  grep -qE "어떻게|왜|뭐가|언제|어디" "$SK" && ok "의문사 정의 (질문 가드)" || fail "의문사 정의 누락"
fi

# ─── 6. session-start.sh build/ 분기 ───
echo ""
echo "[6] session-start.sh build/ 분기"
HOOK=".claude/hooks/session-start.sh"
if [[ -f "$HOOK" ]]; then
  grep -qF 'build mode active' "$HOOK" && ok "build mode 표시 라인" || fail "build mode 표시 라인 없음"
  grep -qF 'BUILD_DIR=' "$HOOK" && ok "BUILD_DIR 변수 정의" || fail "BUILD_DIR 변수 정의 없음"
  grep -qF '/prototype-start' "$HOOK" && ok "프로토타입 안내 줄" || fail "프로토타입 안내 줄 없음"
fi

# ─── 결과 요약 ───
echo ""
echo "================================"
echo "PASS: $PASS / FAIL: $FAIL / WARN: $WARN"
echo "================================"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

- [ ] **Step 2: 실행 권한 부여 + 첫 실행 (모두 fail 예상)**

```bash
chmod +x tests/build_loop_smoke.sh
bash tests/build_loop_smoke.sh
```
Expected: 다수 FAIL (아직 신규 파일들 없음). pipeline.yaml v0.3 와 .gitignore 검증은 PASS (Task 1·2 완료한 경우).

- [ ] **Step 3: Commit**

```bash
git add tests/build_loop_smoke.sh
git commit -m "test(build-loop): add smoke test harness for v0.3 schema + skill files"
```

---

## Task 4: adapter-template.md 작성

**Files:**
- Create: `.claude/skills/prototype-build-loop/adapter-template.md`

- [ ] **Step 1: 디렉토리 생성**

```bash
mkdir -p .claude/skills/prototype-build-loop/engines
```

- [ ] **Step 2: adapter-template.md 작성**

`.claude/skills/prototype-build-loop/adapter-template.md`:

```markdown
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

\`\`\`
<엔진 표준 .gitignore 내용>
\`\`\`

## .editorconfig

\`\`\`
<엔진 권장 들여쓰기·인코딩 규칙>
\`\`\`
```

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/prototype-build-loop/adapter-template.md
git commit -m "feat(build-loop): add engine adapter template (7 required H2 schema)"
```

---

## Task 5: Godot 어댑터 (engines/godot.md)

**Files:**
- Create: `.claude/skills/prototype-build-loop/engines/godot.md`

- [ ] **Step 1: 어댑터 작성**

`.claude/skills/prototype-build-loop/engines/godot.md`:

```markdown
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

## 프로젝트 init 절차

1. `project.godot` 생성 (engine version 4.3 명시)
2. autoload 등록: AutoLoad → `signals.gd`
3. main_scene 지정: `scenes/main.tscn`
4. `.gitignore` / `.editorconfig` 적용
5. `godot --headless --quit-after 1 --path .` 으로 import 트리거 (.godot/ 생성)
6. tests/ 디렉토리 골격 생성

## .gitignore 템플릿

\`\`\`
.godot/
.import/
*.translation
.DS_Store
\`\`\`

## .editorconfig

\`\`\`
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
\`\`\`
```

- [ ] **Step 2: 스모크 테스트 부분 검증**

```bash
bash tests/build_loop_smoke.sh 2>&1 | grep -E "godot.md|FAIL|PASS"
```
Expected: godot.md 의 7 개 H2 항목 모두 PASS.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/prototype-build-loop/engines/godot.md
git commit -m "feat(build-loop): add Godot 4.3 engine adapter"
```

---

## Task 6: Unity 어댑터 (engines/unity.md)

**Files:**
- Create: `.claude/skills/prototype-build-loop/engines/unity.md`

- [ ] **Step 1: 어댑터 작성**

`.claude/skills/prototype-build-loop/engines/unity.md`:

```markdown
---
engine: unity
version: "6.0"               # Unity 6 (LTS 가까움)
required_tools:
  - Unity                    # Unity Hub 또는 직접 설치
init_command: "(manual)"     # Unity Hub UI 또는 unity-hub CLI
---

## 모듈 매핑

- tech-spec §F 모듈 1 개 → 파일 1 개: `Assets/Scripts/<Module>.cs`
- 기본 부모 클래스: 모듈 분류에 따라 `MonoBehaviour` (씬 동작) / `ScriptableObject` (데이터) / 일반 클래스 (서비스)
- 모듈 간 의존: C# `event` 또는 UnityEvent 통한 약결합 + DI 컨테이너 (Zenject/VContainer 선택)

## 시그널 매핑

- tech-spec §G 시그널 → C# `static event Action<T>` 또는 `UnityEvent<T>` (인스펙터 노출 필요 시)
- 시그널명: PascalCase (C# 컨벤션)
- emit: `OnX?.Invoke(arg)`
- connect: `OnX += HandleX;`

## Resource 매핑

- tech-spec §G Resource → `[CreateAssetMenu] public class <Name>SO : ScriptableObject`
- 파일 형식: `.asset` 직렬화. 위치: `Assets/Resources/<Name>.asset`
- 인스펙터 노출: `[SerializeField] private Type field;`

## 테스트 매트릭스 형식

- 프레임워크: Unity Test Framework (NUnit 기반)
- 테스트 파일 위치: `Assets/Tests/EditMode/Test_<Module>.cs` (EditMode) / `Assets/Tests/PlayMode/...` (PlayMode)
- §I AC 1 개 → 테스트 메서드 1 개: `[Test] public void Ac_<id>()`
- 실행: Unity Editor → Test Runner 또는 `unity -batchmode -runTests`

## 프로젝트 init 절차

1. Unity Hub 에서 신규 3D/2D Core 프로젝트 생성 (Unity 6 LTS 선택)
2. `Assets/Scripts/`, `Assets/Resources/`, `Assets/Tests/EditMode/`, `Assets/Tests/PlayMode/` 디렉토리 생성
3. Test Framework 패키지 추가 (Window → Package Manager → Test Framework)
4. `Assembly Definition` 파일 추가 (Tests 격리 위해)
5. `.gitignore` / `.editorconfig` 적용
6. `Packages/manifest.json` 에 필요 패키지 명시

## .gitignore 템플릿

\`\`\`
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Mm]emoryCaptures/
[Uu]ser[Ss]ettings/
*.csproj
*.sln
*.suo
*.user
.vs/
.idea/
.DS_Store
\`\`\`

## .editorconfig

\`\`\`
root = true

[*.cs]
indent_style = space
indent_size = 4
charset = utf-8-bom
end_of_line = crlf
trim_trailing_whitespace = true
insert_final_newline = true

[*.{asset,prefab,unity,mat}]
indent_style = space
indent_size = 2
\`\`\`
```

- [ ] **Step 2: 스모크 테스트 부분 검증**

```bash
bash tests/build_loop_smoke.sh 2>&1 | grep -E "unity.md|FAIL|PASS"
```
Expected: unity.md 의 7 개 H2 항목 모두 PASS.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/prototype-build-loop/engines/unity.md
git commit -m "feat(build-loop): add Unity 6 engine adapter"
```

---

## Task 7: 슬래시 명령 3종

**Files:**
- Create: `.claude/commands/prototype-start.md`
- Create: `.claude/commands/prototype-round.md`
- Create: `.claude/commands/prototype-snapshot.md`

기존 `cp-status.md`, `cp-redo.md` 패턴 참조.

- [ ] **Step 1: prototype-start.md 작성**

`.claude/commands/prototype-start.md`:

```markdown
---
description: 프로토타입 빌드 루프 시작 — 엔진 선택 후 Round 0 (L4 스캐폴드) 생성
model: sonnet
---

prototype-build-loop 스킬을 호출하여 Round 0 진입:

1. 활성 프로젝트의 단계 7 게이트 통과 + 산출물 4종 (SSOT, art-bible, tech-spec, changelog) 존재 검증
2. 엔진 선택: Godot 4 / Unity 6 (사용자 응답 대기)
3. `engines/{선택}.md` 어댑터 로드·검증
4. 스캐폴드 계획 표시 + 사용자 확인
5. `workspace/<slug>/build/{engine}/` 생성 + git init
6. tech-spec §F·§G·§I 기반 L4 스캐폴드 (모듈 스텁·시그널·Resource·테스트 골격·코어 루프 placeholder)
7. ITERATION_LOG.md 에 v0 항목 (3 필드)
8. state.yaml.artifacts.engine, build_state 갱신

전제: 단계 7 미통과 시 거부 + 누락 산출물 안내.
```

- [ ] **Step 2: prototype-round.md 작성**

`.claude/commands/prototype-round.md`:

```markdown
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
```

- [ ] **Step 3: prototype-snapshot.md 작성**

`.claude/commands/prototype-snapshot.md`:

```markdown
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
```

- [ ] **Step 4: 스모크 테스트 검증**

```bash
bash tests/build_loop_smoke.sh 2>&1 | grep -E "prototype-(start|round|snapshot)"
```
Expected: 3 개 모두 PASS.

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/prototype-start.md \
        .claude/commands/prototype-round.md \
        .claude/commands/prototype-snapshot.md
git commit -m "feat(build-loop): add 3 slash commands (start/round/snapshot)"
```

---

## Task 8: session-start.sh build/ 분기

**Files:**
- Modify: `.claude/hooks/session-start.sh`

- [ ] **Step 1: 활성 프로젝트 마지막 멈춤 블록 직후에 build mode 분기 삽입 (정확 anchor)**

old_string:
```bash
if [[ -n "$LAST_PAUSE" && "$LAST_PAUSE" != "null" && "$LAST_PAUSE" != "~" ]]; then
  echo "   마지막 멈춤: $LAST_PAUSE"
  [[ -n "$LAST_PAUSE_AT" && "$LAST_PAUSE_AT" != "null" ]] && echo "   ($LAST_PAUSE_AT)"
fi

echo ""
echo "이어가기:  \"이어서 하자\"  또는  /concept-pipeline"
```

new_string:
```bash
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
```

(awk 폴백은 grep 보다 *섹션 경계* 를 정확히 잡아 다른 컨텍스트의 `engine:` 같은 키를 잘못 캐치하지 않음.)

- [ ] **Step 2: 명령 안내 줄 추가 (정확 anchor)**

old_string:
```bash
echo "이어가기:  \"이어서 하자\"  또는  /concept-pipeline"
echo "상태 확인: /cp-status"
echo "재실행:    /cp-redo <단계번호>"
echo "================================"
```

new_string:
```bash
echo "이어가기:  \"이어서 하자\"  또는  /concept-pipeline"
echo "상태 확인: /cp-status"
echo "재실행:    /cp-redo <단계번호>"
echo "프로토타입: \"프로토타입 시작\"  또는  /prototype-start"
echo "스냅샷:    /prototype-snapshot <tag>"
echo "================================"
```

- [ ] **Step 3: 실행 가능 검증**

```bash
bash .claude/hooks/session-start.sh
```
Expected: 에러 없음, 활성 프로젝트 없음 메시지 (또는 활성 시 build mode 표시).

- [ ] **Step 4: 스모크 테스트**

```bash
bash tests/build_loop_smoke.sh 2>&1 | grep -E "build/ 분기"
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add .claude/hooks/session-start.sh
git commit -m "feat(hook): session-start build/ awareness for prototype-build-loop"
```

---

## Task 9: 프롬프트 파일 — Round 0 / Round N

**Files:**
- Create: `prompts/prototype-build-loop/round0-scaffold.md`
- Create: `prompts/prototype-build-loop/roundN-patch.md`

- [ ] **Step 1: 디렉토리 생성**

```bash
mkdir -p prompts/prototype-build-loop
```

- [ ] **Step 2: round0-scaffold.md 작성**

`prompts/prototype-build-loop/round0-scaffold.md`:

```markdown
# Round 0 — 초기 환경 스캐폴드 프롬프트

## 입력
- `06-tech-spec.md` (§F 모듈, §G 시그널·Resource, §I AC)
- `06-art-bible.md` (placeholder 에셋 슬롯)
- `engines/{선택 엔진}.md` (모듈/시그널/Resource 매핑 규칙)
- 사용자 선택: 엔진 (`godot` / `unity`)

## 출력
- `workspace/<slug>/build/{engine}/` 디렉토리에 L4 스캐폴드 (코어 루프 1 사이클이 placeholder 로 동작)
- `workspace/<slug>/ITERATION_LOG.md` 에 v0 항목 (3 필드: 엔진/세팅/시드 컨텐츠)
- `workspace/<slug>/build/engine.yaml` (정적 메타)
- `workspace/<slug>/state.yaml` 갱신 (artifacts.engine, build_initialized=true, build_state 초기화)

## 절차

1. **전제 검증**
   - 단계 7 게이트 통과 (`completed_steps` 에 id=7) 또는 4종 산출물 모두 존재
   - 누락 시 거부 + 안내

2. **어댑터 로드·검증**
   - `engines/{engine}.md` frontmatter 파싱 (engine, version, required_tools, init_command)
   - 7 개 필수 H2 헤더 존재 검증 (smoke test 와 동일 패턴)
   - `required_tools` 의 명령이 실제 PATH 에 있는지 사용자에게 확인 (자동 ✕)

3. **스캐폴드 계획 표시**
   - 생성될 디렉토리·파일 트리 미리보기 (한 화면 이내)
   - 사용자 OK 받기

4. **스캐폴드 생성**
   - 어댑터의 *프로젝트 init 절차* 1~6 순차 실행
   - tech-spec §F 모듈 → 어댑터 *모듈 매핑* 규칙으로 빈 파일·시그니처
   - tech-spec §G 시그널 → 어댑터 *시그널 매핑* 으로 정의 파일
   - tech-spec §G Resource → 어댑터 *Resource 매핑* 으로 클래스
   - tech-spec §I AC 1번 → 어댑터 *테스트 매트릭스 형식* 으로 테스트 함수 골격
   - 코어 루프 placeholder: tech-spec §B 코어 메카닉 1 사이클이 *입력 → 동작 → 결과* 1회 표현되는 최소 코드

5. **git init**
   - `cd build/{engine}/ && git init && git add . && git commit -m "Round 0: initial scaffold (engine={engine})"`

6. **메타 갱신**
   - `engine.yaml` 작성 (engine, version, project_path, initialized_at, adapter_file, adapter_checksum)
   - `state.yaml.artifacts.engine`, `build_initialized=true`, `build_state.current_round=0`, `build_state.system_keywords` (SSOT §C·§B 추출)
   - `ITERATION_LOG.md` 에 v0 항목 append:
     ```
     ## v0 — 초기 환경 (YYYY-MM-DD)
     **엔진**: {engine} {version}
     **세팅**: tech-spec §F 의 N 모듈 스텁, §G 의 N 시그널·N Resource, §I 의 AC 1 가설
     **시드 컨텐츠**: 코어 루프 1 사이클 placeholder ({핵심 동작})
     ```

7. **결과 보고**
   - 생성 파일 수·경로
   - 다음 액션: 사용자가 빌드해서 동작 확인 → 피드백 자유 발화 → 자동 Round 1 진입
```

- [ ] **Step 3: roundN-patch.md 작성**

`prompts/prototype-build-loop/roundN-patch.md`:

```markdown
# Round N — AI 수정 라운드 패치 프롬프트

## 입력
- 사용자 발화 (수정 요청·피드백)
- `06-integrated-spec.md` (SSOT 룰)
- `06-tech-spec.md` (모듈·시그널·AC)
- `engines/{engine}.md` (코드 패턴 규칙)
- `build/{engine}/` 현재 트리

## 출력
- 패치 제안 (diff 형태)
- 사용자 승인 시 적용 + commit
- `ITERATION_LOG.md` 에 v{N} 항목 (5 필드)
- (조건부) `06-changelog.md` 에 SSOT 변경 1줄

## 절차

1. **자동 감지 진입 검증** (SKILL.md 의 §5.3 규칙 1~4)
   - 의문문이면 라운드 ✕, 답변만
   - 액션동사+대상 OR 평가어+대상 → 진입
   - 신뢰도 중간 → "수정 라운드로 처리할까요?" 1회 확인

2. **SSOT 영향 §섹션 식별**
   - 사용자 발화의 키워드를 SSOT 9 섹션 (A~I) 에 매칭
   - 1 개 이상 §섹션 명시 (예: "§E·§G.1 영향")

3. **SSOT 자체 수정 vs 코드 수정 분기**
   - 사용자 발화가 *룰 변경* 이면 → "이건 concept-pipeline `/cp-redo 6` 로 가야 합니다" 안내 후 라운드 취소
   - *코드/에셋 수정* 이면 다음 단계

4. **패치 제안**
   - 어댑터의 코드 패턴 규칙으로 변경 파일 식별 (시그널 추가 → autoload 수정, Resource 필드 추가 → 클래스 수정 등)
   - diff 형태로 표시 (파일별 +/- 라인 수)
   - 영향 SSOT §섹션·tech-spec §섹션 인용 명시

5. **사용자 승인**
   - "적용할까요?" / "부분 적용 (이 파일만)" / "취소"
   - 부분 적용 시 어떤 파일 적용·보류인지 명시

6. **적용 + commit**
   - `build/{engine}/` 의 파일 수정
   - `git add . && git commit -m "Round {N}: <라운드명> ..."` (commit 메시지 §5.5)
   - 부분 적용은 commit 메시지에 `(partial: <파일목록>)` 명시

7. **ITERATION_LOG append**
   ```
   ## v{N} — {라운드명} (YYYY-MM-DD)
   **구성**: ...
   **사용자 피드백**: "{원문 인용}"
   **진단**: ... (1~3줄)
   **변경**: bullet list
   **결과**: 다음 라운드 트리거 / 측정 예정
   ```

8. **SSOT 룰 영향 시 06-changelog.md append**
   - SSOT 룰 (§B·§C·§I 등) 이 변경되었으면 `06-changelog.md` 에 1줄:
     ```
     - YYYY-MM-DD v{N} — {라운드명}
       - §X: {변경 항목·왜}
     ```

9. **state.yaml 갱신**
   - `build_state.current_round = N`
   - `build_state.last_round_at = ISO`
```

- [ ] **Step 4: Commit**

```bash
git add prompts/prototype-build-loop/
git commit -m "feat(build-loop): add Round 0 scaffold + Round N patch prompts"
```

---

## Task 10: SKILL.md 코어 — frontmatter + 트리거 정의

**Files:**
- Create: `.claude/skills/prototype-build-loop/SKILL.md`

이 작업은 큰 마크다운이라 두 단계로 나눔: Step 1 = 골격·트리거, Step 2 = 절차 본문.

- [ ] **Step 1: SKILL.md 골격 + frontmatter + 트리거 정의 작성**

`.claude/skills/prototype-build-loop/SKILL.md`:

```markdown
---
name: prototype-build-loop
description: 게임 컨셉 파이프라인 단계 7 통과 후 프로토타입 빌드를 시작하고 라운드 단위 AI 수정을 관리한다. Godot/Unity 둘 다 지원, 시작 시 사용자 선택. ITERATION_LOG.md 에 Round 0 (초기 환경) + Round N (AI 수정) 만 기록 — 사용자 직접 수정은 누락 허용. 트리거 - "프로토타입 시작", "프로토타입 빌드", /prototype-start, /prototype-round, /prototype-snapshot. 자동 감지 - build/ 디렉토리 활성 + 사용자 발화에 수정 의도 (액션 동사 추가/수정/변경/제거/바꿔/줄여/늘려/고쳐, 평가어 어색해/안 어울려/이상해/약해/세/지루해, SSOT 시스템·메카닉 키워드) 포함 시 Round N 진입. 의문사 (어떻게/왜/뭐가/언제/어디) 우선 — 질문이면 답변만 하고 라운드 ✕.
---

# prototype-build-loop

## 1. 역할

`concept-pipeline` 단계 7 (준비 완료 게이트) 통과 후, 산출물 패밀리 (SSOT + art-bible + tech-spec + changelog) 를 입력으로 **실제 프로토타입 빌드 + 라운드 단위 AI 수정** 을 진행한다.

## 2. 모드

- **Round 0 (1회)**: 엔진 선택 + L4 스캐폴드 생성 (코어 루프 placeholder 동작)
- **Round N (반복)**: 사용자 수정 요청·피드백 → AI 패치 제안 → 사용자 승인 → 적용·로깅
- **Snapshot (선택)**: 사용자 명시 호출 → `build/{engine}/` 의 git tag

## 3. 트리거

| 동작 | 트리거 |
|------|--------|
| Round 0 | 명시: "프로토타입 시작" / "프로토타입 빌드" / `/prototype-start` |
| Round N | 자동 감지 (§5) 또는 `/prototype-round` |
| Snapshot | 명시: "스냅샷 v… 찍어줘" / `/prototype-snapshot <tag>` |

## 4. 전제

- 활성 프로젝트가 단계 7 통과 (`workspace/<slug>/state.yaml.completed_steps` 에 id=7)
- 산출물 4 종 존재: `06-integrated-spec.md`, `06-art-bible.md`, `06-tech-spec.md`, `06-changelog.md`
- pipeline.yaml.version >= "0.3"

## 5. Round N 자동 감지 규칙

### 5.1 키워드 출처

`state.yaml.build_state.system_keywords` 에 캐시된 SSOT §C 항목명 + §B 메카닉 토큰. 캐시가 비어있으면 1회 SSOT 파싱하여 채움.

### 5.2 판정 (우선순위 순)

```
입력: 사용자 발화 U

전제: workspace/<slug>/build/ 존재

규칙 1 [질문 가드, 최우선]:
  U 가 의문사 (어떻게/왜/뭐가/언제/어디/뭔가요/인가요) 로 시작 또는 끝나면
  → 라운드 ✕, 답변만

규칙 2 [액션 동사 + 대상, 신뢰도 높음]:
  U 에 액션 동사 (추가/수정/변경/제거/바꿔/줄여/늘려/고쳐/빼/넣어/강화/약화) 1개 이상
  AND
  U 에 system_keywords 또는 §B 메카닉 토큰 1개 이상
  → 라운드 ◯ 즉시 진입

규칙 3 [평가어 + 대상, 신뢰도 중간]:
  U 에 평가어 (어색해/안 어울려/이상해/약해/세/지루해/혼란스러워) 1개 이상
  AND
  대상 토큰 1개 이상
  → "수정 라운드로 처리할까요?" 1회 확인 → 사용자 OK 시 진입

규칙 4 [그 외]:
  → 라운드 ✕, 일반 응답
```

### 5.3 SSOT 자체 수정 분기

발화가 *코드·에셋* 이 아닌 *SSOT 룰* 수정이면 (예: "art-bible 에 어종 추가", "AC §I 에 항목 추가") AI 가 안내:

> "이건 SSOT 변경입니다. concept-pipeline 의 `/cp-redo 6` 로 가서 단계 6 을 재실행해야 일관성이 유지됩니다."

라운드 자체는 취소.

(다음 step 에서 §6~§9 절차 본문 추가)
```

- [ ] **Step 2: SKILL.md 절차 본문 추가 (§6~§10)**

위 파일에 다음 섹션 추가 (이어붙임):

```markdown

## 6. Round 0 절차

`prompts/prototype-build-loop/round0-scaffold.md` 참조.

요약:
1. 전제 검증 (단계 7·산출물 4종)
2. 엔진 선택 질문 ("Godot 4 / Unity 6 중?")
3. `engines/{선택}.md` 어댑터 로드·검증 (7 H2 헤더)
4. 스캐폴드 계획 표시 + 사용자 확인
5. 어댑터 *프로젝트 init 절차* 실행
6. tech-spec §F·§G·§I 매핑 → 모듈·시그널·Resource·테스트 골격 + 코어 루프 placeholder
7. `build/{engine}/` git init + 첫 commit
8. `engine.yaml`, `ITERATION_LOG.md` v0 항목, `state.yaml` 갱신

## 7. Round N 절차

`prompts/prototype-build-loop/roundN-patch.md` 참조.

요약:
1. 자동 감지 진입 (§5) 또는 `/prototype-round`
2. SSOT 영향 §섹션 식별
3. 코드 vs SSOT 분기 — SSOT 면 `/cp-redo 6` 안내 후 취소
4. 어댑터 기반 패치 제안 (diff)
5. 사용자 승인 (전체 / 부분 / 취소)
6. 적용 + `build/{engine}/` commit (메시지 §8)
7. `ITERATION_LOG.md` v{N} 항목 (5 필드)
8. SSOT 룰 영향 시 `06-changelog.md` append
9. `state.yaml.build_state` 갱신

## 8. commit 메시지 규약

`build/{engine}/` 트리의 commit 메시지 형식:

```
Round {N}: {라운드명}

{진단 1줄}

변경:
- {변경 bullet 1}
- {변경 bullet 2}
```

부분 적용 시 끝에 `(partial: <파일목록>)`.

## 9. Snapshot 절차

1. `build/{engine}/` 의 `git status` 확인
2. uncommitted 있으면 3 옵션:
   - "auto-commit 후 tag" — `git add . && git commit -m "snapshot pre-tag" && git tag <tag>`
   - "stash 후 tag" — `git stash && git tag <tag>` (사용자가 나중에 stash pop)
   - "취소" — 아무 작업 ✕
3. `state.yaml.build_state.last_snapshot = <tag>` 갱신

## 10. 에러 케이스

| 케이스 | 처리 |
|--------|------|
| 단계 7 미통과 | 거부 + 누락 산출물 안내 |
| 엔진 선택 후 어댑터 부재 | 에러 + `adapter-template.md` 복제 가이드 |
| 어댑터 §4.3 schema 위반 (필수 H2 누락) | 에러 + 누락 헤더 명시 |
| Round 0 스캐폴드 일부 실패 | 트랜잭션 ✕. 실패 지점까지 보존 + 사용자 보고 |
| 자동 감지 오인식 | 규칙 1·신뢰도 중간 확인이 1차 가드. 사용자 "취소" 가능 |
| SSOT 자체 수정 요청 | `/cp-redo 6` 안내 후 라운드 취소 |
| 스냅샷 시 uncommitted 충돌 | 3 옵션 (auto-commit/stash/취소) |
| state.yaml v0.2.1 → v0.3 마이그레이션 | (1) `.archive/state-pre-migration-{timestamp}.yaml` 백업 → (2) 누락 필드 기본값 추가 (`artifacts.engine=null`, `artifacts.build_initialized=false`, `build_state=null`) → (3) `notes` 에 `"schema migration 0.2.1 → 0.3 (build-loop fields added)"` 1줄 → (4) `pipeline_version: "0.3"` 갱신. 실패 시 백업 보존 + 사용자 보고. |
| 어댑터 checksum 불일치 | 사용자 경고 + 다음 Round 0 재실행 권고 |

## 11. 호출되는 외부 자산

- `engines/godot.md`, `engines/unity.md` — 엔진별 어댑터 데이터
- `prompts/prototype-build-loop/round0-scaffold.md` — Round 0 본문
- `prompts/prototype-build-loop/roundN-patch.md` — Round N 본문
- `pipeline.yaml.steps[5].iteration_log.schema.round_variants` — 로그 스키마

## 12. spec 참조

설계 근거: `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md`
```

- [ ] **Step 3: 스모크 테스트**

```bash
bash tests/build_loop_smoke.sh
```
Expected: PASS 만, FAIL 0.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/prototype-build-loop/SKILL.md
git commit -m "feat(build-loop): add core SKILL.md (lifecycle + auto-detect rules)"
```

---

## Task 11: README.md 1줄 안내 추가 (선택)

**Files:**
- Modify: `README.md`

- [ ] **Step 1: README.md "다음 단계" 섹션 교체 (정확 anchor)**

old_string:
```markdown
## 다음 단계

본 파이프라인의 출력 패밀리(`06-integrated-spec.md` + `06-art-bible.md` + `06-tech-spec.md`)를 가지고 프로토타입 → 본 게임 빌드업. 빌드업 워크플로우는 별도로 설계한다.
```

new_string:
```markdown
## 다음 단계

본 파이프라인의 출력 패밀리(`06-integrated-spec.md` + `06-art-bible.md` + `06-tech-spec.md` + `06-changelog.md`)를 가지고 프로토타입 빌드로 이어진다.

### prototype-build-loop (v0.3~)

같은 레포의 `prototype-build-loop` 스킬이 단계 7 산출물을 입력으로 받아 Godot/Unity 프로토타입 빌드와 라운드 단위 AI 수정을 진행한다.

\`\`\`
"프로토타입 시작"  /  /prototype-start
\`\`\`

자세한 내용: [prototype-build-loop spec](docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md)
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(readme): add prototype-build-loop pointer in next-steps"
```

---

## Task 12: 통합 검증 — 전체 스모크 테스트 + 양 스모크 동시 통과

**Files:** (검증만, 수정 ✕)

- [ ] **Step 1: build_loop_smoke 전체 PASS**

```bash
bash tests/build_loop_smoke.sh
```
Expected: `PASS: N / FAIL: 0 / WARN: 0` (또는 N=충분히 높음).

- [ ] **Step 2: 기존 pipeline_smoke 도 PASS (회귀 ✕)**

```bash
bash tests/pipeline_smoke.sh
```
Expected: `FAIL: 0` (v0.3 변경이 기존 게이트를 깨지 않았음).

- [ ] **Step 3: YAML 파싱 재확인**

```bash
python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); print(d['pipeline']['version']); print(list(d['state_schema']['resume_fields'].keys()))"
```
Expected: `0.3` + `['sub_progress', 'last_pause_reason', 'last_pause_at', 'last_user_response_at', 'build_state']` (또는 build_state 포함된 리스트).

- [ ] **Step 4: SessionStart 훅 실행 검증**

```bash
bash .claude/hooks/session-start.sh
```
Expected: 활성 프로젝트 없음 메시지 + 프로토타입 안내 줄 추가됨.

- [ ] **Step 5: 종료 commit (선택, 모든 작업이 단일 PR 이면 생략)**

```bash
git log --oneline -15
```
Expected: Task 1~11 의 11~12개 commit 이 깨끗하게 보임.

---

## Task 13: 라이브 검증 시나리오 (수동)

**Files:** (사용자 수동 실행)

- [ ] **Step 1: 테스트 슬러그 준비**

기존 `sail-and-cast` 슬러그가 단계 7 통과 상태이면 그대로. 아니면 새 슬러그 1 개를 단계 1~7 까지 빠르게 진행 (또는 placeholder 산출물 4 종 수동 작성).

- [ ] **Step 2: Round 0 (Godot)**

```
사용자: 프로토타입 시작
스킬:   ... 엔진 선택 → "Godot 4"
스킬:   ... 스캐폴드 계획 표시 → 사용자 OK
스킬:   ... build/godot/ 생성 + git init + ITERATION_LOG v0
```
검증: `workspace/<slug>/build/godot/` 존재, `ITERATION_LOG.md` 에 `## v0 — 초기 환경` 항목 있음.

- [ ] **Step 3: Round 1 (자동 감지)**

```
사용자: 어종 움직임 좀 더 빠르게 했으면 좋겠어
스킬:   (자동 감지) Round 1 진입
스킬:   SSOT §B·§G.1 영향. 패치 제안: ...
사용자: OK
스킬:   적용 완료. ITERATION_LOG v1 항목 추가.
```
검증: `ITERATION_LOG.md` 에 `## v1 — ...` 5 필드 항목.

- [ ] **Step 4: Snapshot**

```
사용자: 스냅샷 v0.1-poc 찍어줘
스킬:   git status 확인 → tag 생성
```
검증: `cd workspace/<slug>/build/godot && git tag --list` 에 `v0.1-poc`.

- [ ] **Step 5: Unity 도 같은 시나리오 1 회**

새 슬러그에서 Round 0 시 "Unity 6" 선택 → Step 2~4 동일 수행. (Unity 는 init 명령이 manual 이므로 사용자가 Unity Hub 통해 프로젝트 생성 후 스킬에 알려주는 흐름)

- [ ] **Step 6: 결과 정리**

수동 검증 결과를 `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md` 끝에 *검증 노트* 섹션으로 1 회 append (날짜·결과 1~2 줄). 또는 별도 보고.

---

## 완료 기준

- [ ] Task 1~12 모두 commit + 스모크 테스트 통과
- [ ] Task 13 (수동 라이브) 성공 (Godot 1·Unity 1 시나리오)
- [ ] 회귀 테스트: 기존 `pipeline_smoke.sh` PASS 유지
- [ ] CHANGELOG (pipeline.yaml) 에 v0.3 항목 정확히 기재됨

## 참조

- 설계: `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md`
- 기존 스킬 패턴: `.claude/skills/concept-pipeline/SKILL.md`
- 기존 스모크 테스트: `tests/pipeline_smoke.sh`
- 기존 훅: `.claude/hooks/session-start.sh`
