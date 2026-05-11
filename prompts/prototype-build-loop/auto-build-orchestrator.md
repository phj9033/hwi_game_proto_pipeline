# Auto-Build Orchestrator

`prototype-build-loop` 스킬의 Round 0 진입점. 사용자가 "프로토타입 시작" 트리거 시 호출되며, substep 0.1~0.4 를 자동 연쇄 실행한다.

## 입력
- 단계 7 통과 (`state.yaml.completed_steps` 에 id=7)
- 4종 산출물 (`06-integrated-spec.md` / `06-art-bible.md` / `06-tech-spec.md` / `06-changelog.md`)
- `state.yaml.build_state.current_round` 가 null/부재 (첫 진입)
- `build/` 비어있음
- 사용자 선택 후 로드될 어댑터: `.claude/skills/prototype-build-loop/engines/{engine}.md` (godot / unity)

## 출력
- Round 0.1~0.4 모두 통과 → `build_state.auto_build_status = "completed"`, `current_round = 0` → 사용자 다음 발화부터 Round 1+ 자동 감지 (SKILL.md §5)
- 중간 실패 → `build_state.auto_build_status = "failed_at_<substep>"`, 사용자에게 3 옵션 제시

**`auto_build_status` 가능 값**: `in_progress` | `completed` | `failed_at_0.{X}` (재시도 실패 포함, 동일 값 유지) | `aborted_at_0.{X}` (사용자가 수동 전환 선택) | `null` (자동 빌드 미진입)

## 절차

1. **진입 조건 검증**
   - 위 입력 모두 만족하는지 확인
   - 불충족 시:
     - 단계 7 미통과 → 거부 + 누락 산출물 안내
     - 이미 build/ 존재 + Round 1+ 진행 중 (`state.yaml.build_state.current_round >= 1`) → "자동 빌드 ✕ (기존 프로젝트). 기존 roundN-patch 진입" 안내
     - 기존 build/ 비어있지 않지만 Round 0 도 아님 (이상 상태: build/ 파일 있음 + current_round == null) → 사용자 확인 후 처리

2. **엔진 선택 질문 (1회)**
   - "Godot 4 / Unity 6 중 어느 엔진으로?"
   - 사용자 응답 → `engines/{engine}.md` 어댑터 존재 확인

3. **자동 빌드 시작 보고**
   - "Round 0.1~0.4 자동 빌드 시작. 약 N분 예상. 중간 실패 시에만 멈춤."
   - 진행 표시 (substep 마다 1줄)

4. **substep 순차 실행**

   각 substep 은 다음 패턴 — **commit / ITERATION_LOG append / state.yaml 갱신은 각 substep 본문이 자체 수행**, orchestrator 는 성공/실패 신호만 받음:
   ```
   for sub in [0.1, 0.2, 0.3, 0.4]:
     prompts/prototype-build-loop/round{sub}-*.md 본문 따라 substep 실행
       (substep 내부에서 commit + ITERATION_LOG + state.yaml.current_substep 갱신 수행)
     성공 신호 → 다음 substep 진행
     실패 신호 → break, 실패 옵션 분기 (§5)
   ```

   각 substep 의 본문 prompt 파일:
   - 0.1: `prompts/prototype-build-loop/round0.1-scaffold.md`
   - 0.2: `prompts/prototype-build-loop/round0.2-core-loop.md`
   - 0.3: `prompts/prototype-build-loop/round0.3-systems-ac1.md`
   - 0.4: `prompts/prototype-build-loop/round0.4-art-placeholders.md`

5. **실패 시 옵션 제시**

   ```
   Round 0.{X} 실패: {원인 1~3줄}

   상태:
   - 마지막 성공: 0.{Y} (commit hash: {hash})
   - 변경 (uncommitted): {파일 목록}
   - state.yaml: auto_build_status="failed_at_0.{X}"

   옵션:
   1. 재개 — 진단 1회 반영 후 0.{X} 재시도 (재시도 1회만)
   2. 수동 전환 — 자동 abort. Round 1+ 사용자 피드백 라운드 진입. 남은 substep 은 사용자가 Round 1+ 안에서 수동 요청.
   3. 롤백 — git reset --hard {지정 substep commit}. **commit 폐기 destructive — 명시 확인 필수**.

   선택?
   ```

   - 옵션 1 (재개): substep 본문에 실패 원인 진단 1줄 추가 + 재시도. 두 번째 실패 시 옵션 1 자동 비활성, 사용자에게 "옵션 2 또는 3 만" 안내.
   - 옵션 2 (수동 전환): uncommitted 보존, `auto_build_status="aborted_at_0.{X}"`, 안내 후 종료. 사용자 다음 발화부터 Round 1+ 자동 감지. (남은 substep 의 회고 적용 슬래시 `/cp-art-rebuild` 는 추후 구현 예정 — 현재는 사용자가 Round 1+ 라운드 안에서 수동 요청)
   - 옵션 3 (롤백): 사용자 확인 ("rollback 0.{Y} commit 까지 정말? Y/N") → Y 면 `git reset --hard`, N 면 취소.

6. **최종 보고 (성공 경로)**

   ```
   자동 빌드 완료 (Round 0.1~0.4).

   요약:
   - 엔진: {engine} {version}
   - 모듈: §F N 항목
   - 코어 루프: §B {메카닉} 1 cycle 동작
   - §C 시스템: {N개 — AC1 필수}
   - AC1 테스트: {결과 원문}
   - art placeholders: N 슬롯 ({카테고리 분포})

   다음:
   - build/{engine}/ 에서 직접 빌드·플레이 → 피드백 발화 시 자동 Round 1 진입
   - art 교체: art/{slot_id}.prompt.md 참고하여 PNG 만 덮어쓰기
   ```

7. **state.yaml 최종 상태**
   - `current_round = 0`, `current_substep = null`, `auto_build_status = "completed"`

## 에러 케이스 (orchestrator 레벨)

| 케이스 | 처리 |
|--------|------|
| 엔진 선택 후 어댑터 부재 | 에러 + `adapter-template.md` 복제 가이드 |
| substep 본문 prompt 파일 누락 | 에러 + 누락 파일 명시 (구현 누락) |
| 한 substep 안에서 두 번째 실패 | 옵션 1 자동 비활성, 옵션 2/3 만 제시 |
| 사용자 응답 없이 무한 대기 | 자동 진행 ✕ — 사용자 응답이 옵션 선택의 게이트 |
