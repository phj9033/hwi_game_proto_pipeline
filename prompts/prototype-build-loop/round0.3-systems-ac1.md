# Round 0.3 — §C 시스템 + AC1 (auto-build substep, stop 라인)

`auto-build-orchestrator.md` 의 3번째 단계. 자동 빌드의 **stop 라인** — AC §I 가설 1번이 *측정 가능한 인프라까지* 닿으면 substep 완료.

## 입력
- `06-integrated-spec.md` §I AC 1번 (가설·측정 방법)
- `06-integrated-spec.md` §C (시스템·메타) — AC1 측정에 필수인 1~2개만 선별
- `06-tech-spec.md` §I (AC ↔ §C 매핑, 명시되어 있으면)
- `engines/{engine}.md` *테스트 매트릭스 형식*
- 0.2 완료된 `build/{engine}/` 트리

## 출력
- AC1 측정에 필수인 §C 시스템 1~2개 구현
- AC1 테스트 함수 + 실행 인프라 (어댑터 *테스트 매트릭스 형식*)
- AC1 테스트 실행 → 결과 출력 (pass/fail 무관)
- commit + ITERATION_LOG v0.3

## 절차

1. **AC1 필수 §C 선별**
   - tech-spec §I 에 AC↔§C 매핑이 명시되어 있으면 그대로 사용
   - 없으면 LLM 추론: AC1 가설을 측정하는 데 필요한 최소 §C 시스템 1~2개
   - **선별 결과를 ITERATION_LOG v0.3 에 명시** (사용자가 추후 검토 가능)

2. **§C 시스템 구현**
   - tech-spec §F 의 해당 시스템 모듈 (0.1 에서 스텁) 에 최소 동작 구현
   - placeholder 데이터·hardcoded 값 OK

3. **AC1 테스트 함수 작성**
   - 어댑터의 *테스트 매트릭스 형식* 따름 (Godot: GUT 또는 native test, Unity: EditMode test)
   - AC1 의 측정 지점에 계측 (assert·로그)
   - 실행 인프라: `godot --headless --test ac1` 등

4. **테스트 실행 (결과 무관)**
   - 명령 실행 → stdout / 로그 파일에 결과 기록
   - pass/fail 무관, **실행되어 결과가 출력** 되면 OK
   - 실행 자체가 실패 (테스트 인프라 부재·컴파일 오류) → orchestrator 에 failed_at="0.3" 반환

5. **commit**
   ```
   Round 0.3: §C systems for AC1 + test scaffold

   {진단 1줄: 어떤 §C 가 선별되었나, AC1 테스트 결과 요약}

   변경:
   - {시스템 모듈 N개}
   - {테스트 함수 1개}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.3 — §C 시스템 + AC1 (YYYY-MM-DD)
   **구현 §C**: {AC1 필수 시스템 N개}
   **AC1 테스트**: {테스트 함수명}
   **실행 결과**: {원문 1~3줄, pass/fail 명시}
   **다음 라운드 권고**: {fail 인 경우 가설 진단 1줄, pass 면 "정상"}
   ```

7. **state.yaml 갱신**
   - `build_state.current_substep = "0.3"`

8. **orchestrator 에 성공 반환** → 0.4 진행
