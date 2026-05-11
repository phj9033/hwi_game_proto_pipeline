# Round 0.1 — Scaffold (auto-build substep)

본 substep 은 `auto-build-orchestrator.md` 의 1번째 단계로 자동 호출된다.

## 입력
- 단계 7 통과 (`state.yaml.completed_steps` 에 id=7)
- `06-tech-spec.md` (§F 모듈, §G 시그널·Resource)
- `engines/{선택 엔진}.md` (어댑터)
- 사용자 선택: 엔진 (`godot` / `unity`)

## 출력
- `workspace/<slug>/build/{engine}/` 디렉토리 + scaffold (모듈·시그널·Resource·디렉토리 트리)
- `workspace/<slug>/build/engine.yaml`
- `workspace/<slug>/ITERATION_LOG.md` 에 v0.1 항목
- `workspace/<slug>/state.yaml.build_state.current_substep = "0.1"` (진행 중) → `null` (substep 0.4 완료 후)

## 절차

1. **전제 검증**
   - 단계 7 게이트 통과 OR 4종 산출물 존재
   - 누락 시 거부 + 안내

2. **어댑터 로드·검증**
   - `engines/{engine}.md` frontmatter 파싱
   - 7 필수 H2 헤더 검증 (smoke test 와 동일 패턴)
   - `required_tools` 의 명령이 실제 PATH 에 있는지 사용자에게 확인

3. **스캐폴드 계획 표시**
   - 생성될 디렉토리·파일 트리 미리보기 (한 화면 이내)
   - **자동 모드에선 사용자 확인 ✕** (orchestrator 가 이미 1회 받았으므로) — 단, 어댑터의 *프로젝트 init* 가 destructive (기존 디렉토리 덮어쓰기) 면 1회 확인

4. **스캐폴드 생성**
   - 어댑터의 *프로젝트 init 절차* 1~6 순차 실행
   - tech-spec §F 모듈 → 어댑터 *모듈 매핑* 규칙으로 빈 파일·시그니처
   - tech-spec §G 시그널 → 어댑터 *시그널 매핑* 으로 정의 파일
   - tech-spec §G Resource → 어댑터 *Resource 매핑* 으로 클래스
   - 디렉토리 트리 생성 (`scenes/`, `scripts/`, `resources/`, `data/`, `tests/`, `art/`)

5. **성공 기준 검증**
   - 어댑터의 `init_command` 실행 → exit 0 확인
   - 실패 시 orchestrator 에 failed_at="0.1" 반환

6. **git init + commit**
   - `cd build/{engine}/ && git init && git add . && git commit -m "Round 0.1: scaffold (engine={engine})"`

7. **메타 갱신**
   - `engine.yaml` 작성 (engine, version, project_path, initialized_at, adapter_file, adapter_checksum)
   - `state.yaml`:
     - `artifacts.engine = {engine}`
     - `artifacts.build_initialized = true`
     - `build_state.current_substep = "0.1"`
     - `build_state.auto_build_status = "in_progress"`
     - `build_state.system_keywords` (SSOT §C·§B 추출, 캐시)

8. **ITERATION_LOG append**
   ```
   ## v0.1 — Scaffold (YYYY-MM-DD)
   **엔진**: {engine} {version}
   **모듈**: tech-spec §F 의 N 항목 스텁
   **시그널·Resource**: §G 의 N 시그널, N Resource
   ```

9. **orchestrator 에 성공 반환** → 다음 substep (0.2) 진행
