# Round 0.3 — §C 시스템 전체 + AC 테스트 (auto-build substep)

`auto-build-orchestrator.md` 의 3번째 단계. 자동 빌드의 **시스템 완성 라인** — SSOT §C 인벤토리의 모든 시스템을 최소 동작까지 구현하고, §I 인수 기준 테스트 함수를 모두 작성한다.

## 입력
- `06-integrated-spec.md` §C (시스템 인벤토리 전체)
- `06-integrated-spec.md` §I (AC 전체)
- `06-tech-spec.md` §I (AC ↔ §C 매핑, 명시되어 있으면)
- `06-tech-spec.md` §F (모듈 매핑)
- `engines/{engine}.md` *테스트 매트릭스 형식*
- 0.2 완료된 `build/{engine}/` 트리

## 출력
- §C 의 모든 시스템 최소 구현 (placeholder·hardcoded 값 OK)
- §I 의 모든 AC 에 대응하는 테스트 함수 + 실행 인프라
- AC 테스트 실행 → 결과 출력 (pass/fail 무관, 단 *실행 자체* 는 통과)
- commit + ITERATION_LOG v0.3

## 절차

1. **§C 시스템 리스트 추출**
   - SSOT §C 본문 파싱 → 시스템명·역할·의존성 N개
   - tech-spec §F 의 해당 모듈 매핑 확인 (0.1 에서 스텁 생성됨)

2. **§I AC ↔ §C 매핑**
   - tech-spec §I 에 매핑 명시 → 그대로 사용
   - 없으면 LLM 추론으로 AC ↔ §C 연결 (ITERATION_LOG 에 추론 결과 명시)

3. **§C 시스템 일괄 구현**
   - 각 시스템 스텁에 최소 동작 채움 (placeholder 데이터·hardcoded 값 OK)
   - 시스템 간 의존성은 어댑터 *시그널·이벤트* 패턴 따름
   - 시스템 1개 실패가 substep 전체를 중단시키지 않음 — 실패 시스템은 ITERATION_LOG `다음 라운드 권고` 에 명시
   - 단, *과반 이상* 시스템 실패 시 → failed_at="0.3" 으로 orchestrator 신호

4. **§I AC 테스트 함수 일괄 작성**
   - 어댑터 *테스트 매트릭스 형식* 따름 (Godot: GUT/native test, Unity: EditMode test)
   - 각 AC 의 측정 지점에 계측 (assert·로그)
   - 실행 인프라 1세트 (`godot --headless --test ac` 식)

5. **테스트 일괄 실행 (결과 무관)**
   - 명령 실행 → stdout/로그에 모든 AC 결과 기록
   - pass/fail 무관, **모든 테스트가 실행되어 결과가 출력** 되면 OK
   - 실행 자체 실패 (테스트 인프라 부재·컴파일 오류) → orchestrator 에 failed_at="0.3" 반환

6. **commit**
   ```
   Round 0.3: §C systems (N) + AC tests (M)

   {진단 1줄: §C 구현 수, AC pass/fail 분포}

   변경:
   - {시스템 모듈 N개}
   - {AC 테스트 함수 M개}
   ```

7. **ITERATION_LOG append**
   ```
   ## v0.3 — §C 시스템 + AC 테스트 (YYYY-MM-DD)
   **구현 §C**: {시스템 N개 — 정상/부분/실패 분류}
   **AC ↔ §C 매핑**: {tech-spec §I 인용 또는 LLM 추론}
   **AC 테스트**: {테스트 함수 M개}
   **실행 결과**: {요약 — pass M-x, fail x, 실행 자체 실패 0}
   **다음 라운드 권고**: {fail 인 AC 가설 진단 1~3줄, 부분 구현 시스템 명시}
   ```

8. **state.yaml 갱신**
   - `build_state.current_substep = "0.3"`

9. **orchestrator 에 성공 반환** → 0.4 진행
