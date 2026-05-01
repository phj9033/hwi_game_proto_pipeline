---
name: concept-pipeline
description: 게임 컨셉부터 프로토타입 준비까지 7단계 데이터 주도 파이프라인을 자동으로 진행한다. 사용자 결정이 필요한 지점에서만 멈춰 응답을 받고, 그 외에는 자동으로 다음 단계로 흐른다. 진행 상태는 workspace/<slug>/state.yaml 에 영구 저장되어 세션이 끊겨도 재개 가능하다. 다음 발화에서 트리거 - "컨셉 파이프라인", "게임 컨셉 시작", "게임 컨셉 만들자", "이어서 하자", "이어가기", "concept pipeline", 또는 슬래시 /concept-pipeline. 새 게임 아이디어를 5-Axis 평가로 비교하거나 통합 명세서를 만들고자 할 때 사용한다.
---

# Concept Pipeline — 자동 흐름 스킬

## 역할
당신은 ~/concept-pipeline/ 의 데이터 주도 7단계 파이프라인 실행기다. 한 번 트리거되면 흐름을 끝까지 끌어가며, 사용자 응답이 필요한 지점에서만 멈춘다.

## 입력 데이터
- `~/concept-pipeline/pipeline.yaml` — 7단계 정의 (불변)
- `~/concept-pipeline/config.yaml` — 5-Axis 가중치, RAG 매핑, 출력 옵션
- `~/concept-pipeline/prompts/<NN>-*.md` — 단계별 LLM 프롬프트
- `~/concept-pipeline/workspace/.active` — 활성 프로젝트 슬러그 (1줄 텍스트)
- `~/concept-pipeline/workspace/<slug>/state.yaml` — 진행 상태 (가변, 매 갱신)

## 0. 부팅 — 신규 vs 재개 결정

스킬이 트리거되면 가장 먼저 실행:

1. `~/concept-pipeline/workspace/.active` 존재 확인
2. **존재 (재개 후보)**:
   - 그 slug 의 `state.yaml` 읽기
   - **스키마 마이그레이션** (§7 의 마이그레이션 절차) — `state.pipeline_version` 이 현재 `pipeline.version` 과 다르면 백업 후 자동 정리. 알리지 않고 흐른다(notes 에만 기록).
   - 사용자에게 다음 보고:
     ```
     활성 프로젝트: <slug>
     현재 단계: <N>. <단계명>
     세부 진행: <sub_progress 요약>
     마지막 멈춤: <last_pause_reason>  (<last_pause_at>)
     산출물: <존재하는 파일 리스트>
     
     이 프로젝트로 이어갈까요? (y / 새로 시작 n / 다른 프로젝트로 j)
     ```
   - y → 재개 모드로 1번 진입
   - n → 사용자에게 새 슬러그 요청 (3번)
   - j → workspace/* 디렉토리 목록 보여주고 선택 받음
3. **부재 (신규)**:
   - "프로젝트 슬러그를 알려주세요. (영소문자/숫자/하이픈, 예: dragon-cafe)"
   - 응답 받음 → 슬러그 검증 → 3번 진입

## 1. 재개 모드 진입

`state.yaml.current_step` 과 `state.yaml.sub_progress` 를 기반으로 정확한 위치 복원:

- 단계 N 의 mode == conversation 이고 sub_progress 가 있으면
  → 해당 섹션부터 다시 질문 시작 ("X 섹션까지 작성됨. Y 섹션부터 이어갑니다.")
- mode == ai_generation 이고 산출물 일부만 있으면
  → 빠진 산출물만 추가 생성
- mode == ai_evaluation 이고 미완성이면
  → 처음부터 재실행 (idempotent — RAG 회수는 결정적)
- mode == gate 이면
  → 즉시 검증 후 다음 단계로

이후 메인 루프(4번)로 진입.

## 2. 신규 모드 진입

1. `~/concept-pipeline/workspace/<slug>/` 디렉토리 생성
2. `state.yaml` 초기화:
   ```yaml
   project: <slug>
   created: <ISO 8601>
   pipeline_version: 0.1
   current_step: 1
   sub_progress:
     section: null
     last_section_completed: null
   completed_steps: []
   artifacts:
     concept: null
     drafts: []
     selected_branch: null
     eval_scores: null
     detailed_gdd: null
     integrated_spec: null
   last_pause_reason: null
   last_pause_at: null
   last_user_response_at: null
   notes: []
   ```
3. `~/concept-pipeline/workspace/.active` 에 slug 기록
4. 메인 루프(4번) 진입

## 3. (생략 — 위에서 통합)

## 4. 메인 루프

```
while state.current_step <= 7:
  step = pipeline.yaml.steps[current_step - 1]
  실행(step)
  if 멈춤_요청: break  # 사용자 결정 대기 진입
  if 단계_완료: state 갱신 + current_step += 1

if state.current_step == 8: 완료_보고
```

## 5. 단계 실행 규칙 (mode 별)

### 5.1 mode: conversation (단계 1, 5, 6)

`prompts/<NN>-*.md` 의 가이드를 따른다. 핵심 규칙:

1. **섹션 단위 incremental**: 한 섹션 합의 → 즉시 outputs 파일에 append → state.sub_progress 갱신
2. **질문은 한 번에 1~2개**: 사용자를 압박하지 않는다
3. **선택지 제시**: 가능하면 2~4개 옵션 + 트레이드오프
4. **각 섹션 완료 후**: state.yaml 의 `sub_progress.last_section_completed` 갱신
5. **모든 required_sections 완료**: 단계 완료 처리

사용자 응답 대기 시:
```
state.last_pause_reason = "단계 N - <섹션> 응답 대기"
state.last_pause_at = <ISO 8601>
state.yaml 즉시 저장
[멈춤 요청 → 메인 루프 break]
```

응답 받으면 다음 호출 시 6번(재개 처리) 으로.

### 5.2 mode: ai_generation (단계 2)

1. `01-concept.md` 와 RAG 회수 결과 컨텍스트화
2. **분기 축 결정** — 사용자에게 1회 질문:
   ```
   3개 분기 축 결정 방식:
   (a) 자동 — 컨셉 분석 후 LLM 이 메카닉/장르 3개 제안
   (b) 지정 — 직접 3개 입력
   ```
3. 자동 선정 시: 3개 후보 보여주고 사용자 OK 받기 (1회 멈춤)
4. 3개 드래프트 순차 생성 (`02-draft-A/B/C.md`)
   - 각 드래프트 작성 직후 state.artifacts.drafts 에 추가
   - 한 줄 진행 상황만 보고 ("A 작성 완료: <분기명>")
5. 3개 모두 완료 후 비교 표 출력
6. 사용자에게 "OK? (y/조정 요청)" 1회 멈춤
7. y 받으면 단계 완료

### 5.3 mode: ai_evaluation (단계 4)

1. `gdd-evaluation` 컬렉션 등록 확인 (`required: true`)
   - 미등록 → 단계 중단, 사용자에게 등록 요청
2. **per_axis RAG 회수** — 5개 축 각각:
   ```bash
   hwicortex query "axis A evaluation criteria scoring rubric structure" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis B motivation SDT Bartle Octalysis" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis C cognitive load flow FTUE laws of UX" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis D MDA RMDA tetrad coherence" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis E vertical slice scope viability publisher KPI" -c gdd-evaluation --json --full -n 3
   ```
3. (선택) `indie-postmortems`, `market-snapshots` 있으면 Axis E 보강
4. 드래프트 3개 × 5축 = 15개 점수 산출 (각 점수에 RAG 인용 첨부)
5. 종합 점수 = Σ(축점수 × 가중치). 컷오프 3.5 통과 여부 표시
6. 권장 선택 + 근거 작성
7. `04-eval-report.md` 작성
8. 사용자에게 1회 질문:
   ```
   5단계 진출할 드래프트 선택: A / B / C
   권장: <X>
   권장과 다르면 사유 한 줄 적어주세요.
   ```
9. 응답 받으면 state.artifacts.selected_branch 기록 + 단계 완료

### 5.4 mode: gate (단계 3, 7)

1. `completion_check` 의 모든 조건 검증 (순서대로):
   - **`all_files_exist`** — 각 파일에 대해 `test -f workspace/<slug>/<file>`
   - **`sections_present_in`** — 각 파일에 `required_sections` 의 모든 항목이 헤더(`#`/`##`/`###`)로 등장하는지 grep
   - **`cross_reference_check`** (v0.2~, 단계 7) — 각 항목별:
     - `must_contain_pattern` 있으면: `grep -E -c "<pattern>" <file>` 결과가 `min_count` 이상인지
     - `must_not_contain_pattern` 있으면: `grep -E -c "<pattern>" <file>` 결과가 0 인지
     - 실패 시 `fail_message` 를 사용자에게 1줄 보고
2. 통과 → state 갱신 + 다음 단계로 즉시 자동 진입 (질문 없음)
3. 실패 → 어떤 항목이 어느 이유로 실패했는지 1줄로 보고 + 멈춤
   ```
   state.last_pause_reason = "단계 N 게이트 실패: <fail_message 또는 누락 파일·섹션>"
   ```
   - `cross_reference_check` 실패는 *복구 가능* — 사용자에게 "재작성 후 /cp-redo 6" 안내

## 6. 사용자 응답 후 재개 처리

스킬이 다시 트리거되면 (또는 사용자 응답 직후):

1. `state.last_pause_reason` 읽고 어떤 응답을 기다리고 있었는지 식별
2. 사용자 입력 파싱
3. 입력 검증 — 유효하면:
   - state 갱신
   - state.last_pause_reason = null
   - state.last_user_response_at = <ISO 8601>
   - 메인 루프 재개
4. 무효하면 — 명확한 재질문 (옵션 다시 제시)

## 7. 상태 저장 규약

**언제 state.yaml 를 저장해야 하는가**:

- 모든 산출물 파일이 생성/수정된 직후
- 사용자 응답을 받은 직후
- 단계 완료 처리 직전
- 멈춤 직전 (반드시)

**저장 형식**:
- YAML, UTF-8
- 매 저장은 atomic (전체 쓰기)
- `notes` 배열에 중요 이벤트 추가:
  ```yaml
  notes:
    - "2026-04-28T16:35: 단계 4 평가 완료, 분기 A 선택"
    - "2026-04-28T16:50: 단계 5 진입, 약점 축 A·B 식별"
  ```

**키 갱신 규약 (v0.2~)**:
- 기존 키는 *in-place 갱신*. 같은 키를 새 값으로 다시 작성 ✕ (YAML 중복 키 방지).
  - 잘못된 예: `step_5_section: 9` 다음 줄에 `step_5_section: null` 추가.
  - 올바른 예: 기존 줄을 직접 `step_5_section: null` 로 바꿈.
- 신규 키만 append.
- 알 수 없는 기존 키(다른 도구가 박은 것)는 *보존* — 임의 제거 ✕.

**스키마 마이그레이션 (state.yaml 로드 직후 1회)**:
1. `state.pipeline_version` vs `pipeline.yaml.pipeline.version` 비교.
2. 일치하면 스킵.
3. 다르면:
   a. 백업: `workspace/<slug>/.archive/state-pre-migration-<ISO 8601>.yaml`
   b. `pipeline.yaml.state_schema.deprecated_fields` 의 모든 `path` 제거 (점 표기 — `artifacts.coordinates` 등).
   c. `required_fields` / `resume_fields` 중 누락된 키를 기본값(null/[]/{})으로 추가.
   d. `state.pipeline_version` 을 현재 `pipeline.version` 으로 갱신.
   e. `notes` 에 `"<ISO 8601>: schema migration <old> → <new>"` 1줄 append.
4. 마이그레이션 중 예외 → 백업은 유지, 사용자에게 보고 후 멈춤.

## 8. RAG 호출 규약

각 RAG 쿼리 실행 전 컬렉션 존재 확인:
```bash
hwicortex collection list 2>&1 | grep -q "<collection-name>"
```

- 존재 → `hwicortex query "<질의>" -c <컬렉션> --json -n <N>` 실행 후 결과를 LLM 컨텍스트로
- 미존재:
  - `optional: true` → "RAG skipped: <컬렉션> (LLM 자체 지식 사용)" 1줄 알리고 진행
  - `required: true` → 단계 중단, 사용자에게 컬렉션 등록 요청 후 멈춤

## 9. 완료 처리

state.current_step == 7 게이트 통과 시:

1. `06-integrated-spec.md` 의 9개 섹션(A~I) 모두 존재 확인
2. state.completed_steps 에 마지막 항목 추가
3. 완료 보고:
   ```
   ✅ <slug> 파이프라인 완료
   
   산출물: ~/concept-pipeline/workspace/<slug>/
   - 01-concept.md
   - 02-draft-A/B/C.md
   - 04-eval-report.md
   - 05-detailed-gdd.md
   - 06-integrated-spec.md  ← 프로토타입 제작자에게 전달
   
   다음 단계 (별도 워크플로우):
   - 프로토타입 제작 → 본 게임 빌드업
   ```
4. workspace/.active 그대로 유지 (재방문 가능). 새 프로젝트 시작 시에만 변경.

## 10. 출력 톤

- 한국어
- 사용자 응답 대기 외에는 진행 보고 1줄 정도로 간결하게
- 멈출 때는 명확하게 ("⏸ 사용자 응답 필요: ...")
- 자동 진행 중에는 단계 헤더만 ("▶ 단계 4 — 5-Axis 평가 시작")
- 완료 시 산출물 경로 + 다음 단계 명시

## 11. 안전·예외 처리

- 사용자가 "stop", "그만", "잠깐" 등 발화하면 즉시 멈춤 + state 저장
- 산출물 작성 실패 시 (디스크/권한): 멈춤 + 사용자에게 보고
- pipeline.yaml 또는 config.yaml 손상 시: 단계 진입 거부 + 복구 안내
- state.yaml 손상 시: 백업본 확인 후 사용자에게 옵션 제시

## 12. 유틸리티 슬래시 명령어 협조

스킬은 다음 명령어와 공존:
- `/cp-status` — 빠른 스냅샷 (스킬 발동 없이 한 줄 확인용)
- `/cp-redo <N>` — 단계 강제 재실행 (스킬은 forward-only)

사용자가 위 명령을 호출하면 그쪽에 위임. 스킬은 forward 흐름만 담당.
