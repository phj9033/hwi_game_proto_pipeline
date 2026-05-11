# Round 0.2 — 코어 루프 (auto-build substep)

`auto-build-orchestrator.md` 의 2번째 단계. Round 0.1 (scaffold) 완료 직후 자동 호출.

## 입력
- `06-integrated-spec.md` §B 코어 메카닉
- `06-tech-spec.md` §F (코어 모듈) + §G (시그널)
- `engines/{engine}.md` 의 *코어 루프 매핑* 규칙
- 0.1 완료된 `build/{engine}/` 트리

## 출력
- §B 의 *입력 → 동작 → 결과 → 다음 사이클* 1 cycle 이 끊김 없이 굴러가는 최소 구현 (placeholder 데이터·hardcoded 값 OK)
- commit + ITERATION_LOG v0.2

## 절차

1. **§B 코어 메카닉 추출**
   - SSOT §B 본문 파싱 → 핵심 메카닉 1개 + 1 cycle 의 입력·동작·결과 식별
   - 어댑터 *코어 루프 매핑* 패턴 따름 (Godot: `_process` / `_input` / signal 흐름, Unity: Update / Event)

2. **scaffold 의 코어 모듈 파일에 최소 구현**
   - tech-spec §F 코어 모듈 (0.1 에서 빈 스텁으로 생성됨) → §B 흐름 채움
   - hardcoded 값 OK, 수치는 SSOT §B 명시 값 우선 (없으면 합리적 기본)
   - 신호 흐름: 입력 시그널 → 처리 모듈 → 결과 시그널 → 다음 사이클 트리거

3. **수동 트리거 또는 자동 진행 확인**
   - 코어 루프가 한 번 실행되어 입력 → 동작 → 결과 흐름이 통과되는지 확인 (예: 헤드리스 모드 1초 실행 후 stdout 에 1 cycle 로그)

4. **성공 기준**
   - 어댑터의 *코어 루프 smoke* 명령 (있으면) 실행 → 1 cycle 로그 출력
   - 없으면 정적 검사: 입력→동작→결과 3 지점 모두 코드 경로 존재 확인
   - 실패 시 orchestrator 에 failed_at="0.2" 반환

5. **commit**
   ```
   Round 0.2: core loop (§B {메카닉명})

   {진단 1줄}

   변경:
   - {파일 1}: {요약}
   - {파일 2}: {요약}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.2 — 코어 루프 (YYYY-MM-DD)
   **구현 §B**: {핵심 메카닉명}
   **1 cycle 흐름**: 입력({...}) → 동작({...}) → 결과({...})
   **하드코딩**: {추후 §C 로 빠질 값 목록}
   ```

7. **state.yaml 갱신**
   - `build_state.current_substep = "0.2"`

8. **orchestrator 에 성공 반환** → 0.3 진행
