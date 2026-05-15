# Round 0.4 — §D UX 흐름 + §G 데이터 인스턴스 (auto-build substep)

`auto-build-orchestrator.md` 의 4번째 단계. 시스템이 굴러간 위에 **UX 진입로·콘텐츠 인스턴스** 를 채워 사용자가 직접 플레이 가능한 상태로 끌어올린다.

## 입력
- `06-integrated-spec.md` §D (UX 흐름 — 메뉴·HUD·스크린 전이)
- `06-integrated-spec.md` §G (데이터 스키마 — 콘텐츠 인스턴스 정의)
- `06-tech-spec.md` §F·§G (UI 모듈·Resource 매핑)
- `engines/{engine}.md` 의 *UX 매핑 / Resource 컨벤션*
- 0.3 완료된 `build/{engine}/` 트리

## 출력
- §D 의 UX 진입로 (start → main loop → end/loop 회귀) 작동
- §G 정의 콘텐츠 인스턴스 일괄 등록 (캐릭터·아이템·맵·이벤트 등 — SSOT 에 명시된 모든 인스턴스)
- 사용자가 빌드 실행 → 메뉴부터 코어 루프 1주기까지 끊김 없이 플레이 가능
- commit + ITERATION_LOG v0.4

## 절차

1. **§D UX 흐름 추출**
   - 메뉴·HUD·스크린·상태 전이 파싱
   - 어댑터 *UX 매핑* 패턴 따름 (Godot: Scene tree + 시그널, Unity: Scene + UIDocument)

2. **UX 진입로 구현**
   - 시작 화면 (placeholder UI OK) → 메인 게임 진입 → 종료/회귀
   - HUD: 코어 루프에서 갱신되는 상태 1~N개 표시 (점수·체력·진행도 등 §D 에 명시된 것)
   - 화면 전이는 어댑터 시그널·이벤트로 wire

3. **§G 데이터 인스턴스 등록**
   - SSOT §G 의 모든 콘텐츠 정의 (캐릭터·아이템·맵·이벤트 등) → 어댑터 Resource 형식으로 일괄 생성
   - 인스턴스 수가 많으면 (>20) 일괄 생성 스크립트 또는 데이터 파일 import 사용
   - 0.3 에서 구현된 §C 시스템이 이 인스턴스들을 로드·소비하도록 wiring
   - **§G 가 비어있거나 콘텐츠 인스턴스 정의 부재** → ITERATION_LOG 에 "§G 콘텐츠 정의 부족 — Round N 으로 위임" 명시 후 UX 만 진행 (failed_at 아님)

4. **smoke 플레이 검증**
   - 어댑터 init_command 실행 → 빌드 OK
   - 헤드리스 1주기 실행 (메뉴 → 코어 루프 1 cycle → 종료) → 끊김 없이 통과 확인
   - 실패 시 orchestrator 에 failed_at="0.4" 반환

5. **commit**
   ```
   Round 0.4: §D UX + §G content instances (N)

   {요약: UX 화면 N개, 콘텐츠 인스턴스 N개, 1주기 smoke OK}

   변경:
   - {UI scene·prefab 파일}
   - {데이터 Resource N개}
   - {wiring 파일}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.4 — §D UX + §G 데이터 인스턴스 (YYYY-MM-DD)
   **UX 진입로**: {메뉴 → 메인 → 종료, 화면 N개}
   **HUD 상태**: {표시 항목 1~N}
   **콘텐츠 인스턴스**: {카테고리별 count — 예: 캐릭터 N, 아이템 N, 맵 N}
   **1주기 smoke 결과**: {pass/fail + 1줄}
   ```

7. **state.yaml 갱신**
   - `build_state.current_substep = "0.4"`

8. **orchestrator 에 성공 반환** → 0.5 진행
