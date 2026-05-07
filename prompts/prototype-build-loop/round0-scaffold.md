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
