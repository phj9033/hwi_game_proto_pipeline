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
