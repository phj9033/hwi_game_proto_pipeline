# Round 0.4 — Art placeholder + 프롬프트 파일 (auto-build substep)

`auto-build-orchestrator.md` 의 4번째 (마지막) 단계.

## 입력
- `06-art-bible.md` (§Z 슬롯 맵 — slot_id / category / size / palette_ref / 설명)
- `engines/{engine}.md` 의 *에셋 로드 컨벤션*
- `.claude/skills/prototype-build-loop/tools/gen_placeholders.py`
- 0.3 완료된 `build/{engine}/` 트리

## 출력
- `build/{engine}/art/{slot_id}.png` (N개)
- `build/{engine}/art/{slot_id}.prompt.md` (N개)
- 코드에서 placeholder 경로 참조 연결 (어댑터 컨벤션)
- commit + ITERATION_LOG v0.4
- (조건부) art-bible 에 신규 컬럼 보강 + `06-changelog.md` 1줄

## 절차

1. **art-bible §Z 슬롯 맵 파싱**
   - `tools/gen_placeholders.py` 의 `parse_slot_map()` 호출
   - `category`·`palette_ref` 컬럼 부재 시 (구 형식 art-bible) → LLM 추론으로 보강, art-bible 의 슬롯 행에 두 컬럼 append, `06-changelog.md` 에 1줄:
     ```
     - YYYY-MM-DD v0.4 — art-bible 슬롯 맵 category/palette_ref 보강 (auto-build 호환성)
     ```

2. **placeholder 생성**
   - `python3 .claude/skills/prototype-build-loop/tools/gen_placeholders.py --art-bible workspace/<slug>/06-art-bible.md --out-dir workspace/<slug>/build/{engine}/art/`
   - 결과 요약 확인 (count, 카테고리 분포)

3. **코드 연결 — 어댑터 *에셋 로드 컨벤션* 적용**
   - 어댑터에 명시된 패턴 (예: Godot 의 `preload("res://art/{slot_id}.png")`) 으로 적어도 1개 슬롯이 scene/resource 에서 로드되도록 wiring
   - 0.1~0.3 에서 생성된 모듈·시그널·Resource 중 art 슬롯을 참조하는 곳에 경로 박음
   - 모든 슬롯 wiring 은 무리 — 코어 루프에 등장하는 슬롯 1~2개만 자동, 나머지는 미사용 자산으로 art/ 에 대기

4. **smoke 검증**
   - 어댑터의 init_command 재실행 → 빌드 OK 확인 (placeholder 경로 오류 ✕)
   - 실패 시 orchestrator 에 failed_at="0.4" 반환

5. **commit**
   ```
   Round 0.4: art placeholders + prompt files (N slots)

   {요약: 슬롯 N개, 카테고리 분포, wired 슬롯 N개}

   변경:
   - art/ (PNG N + prompt.md N)
   - {wiring 된 scene/resource 파일}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.4 — Art placeholder (YYYY-MM-DD)
   **슬롯 수**: N
   **카테고리 분포**: creature N, character N, object N, ui N, effect N
   **placeholder 규칙**: gen_placeholders.py 카테고리 매핑 (creature=circle/primary, character=rect_tall/accent, object=rect/secondary, ui=rect_round/neutral, effect=diamond/highlight)
   **프롬프트 파일 경로**: build/{engine}/art/{slot_id}.prompt.md
   **wired 슬롯**: {wiring 된 슬롯 id 목록}
   ```

7. **state.yaml 갱신 (auto-build 완료)**
   - `build_state.current_substep = null`
   - `build_state.auto_build_status = "completed"`
   - `build_state.current_round = 0` (substep 모두 완료, Round 0 으로 마감)

8. **orchestrator 에 최종 성공 반환** → 사용자에게 자동 빌드 완료 보고
