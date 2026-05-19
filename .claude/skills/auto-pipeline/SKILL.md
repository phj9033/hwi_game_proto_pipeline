---
name: auto-pipeline
description: 컨셉 텍스트와 엔진 선택만 받으면 게임 컨셉 정립부터 프로토타입 빌드까지 풀자동 진행한다. 기존 concept-pipeline 의 7 단계와 prototype-build-loop 의 Round 0~N 을 데이터 재사용 방식으로 묶어, 무거운 substep 은 Agent 서브태스크로 격리한다. 결정 지점은 LLM 추천 + 자체 비평 2-pass 로 자동 채택, 종료는 3축 체크리스트(AC PASS / SSOT covered / art 슬롯 채움) + 라운드 상한 M=10 으로 판정. 트리거 - "/auto-pipeline", "오토 파이프라인 시작", "풀자동 게임 만들자", "자동으로 다 돌려", "이어서" (재개). 산출물은 메뉴부터 1주기 플레이 가능한 프로토타입.
---

# auto-pipeline — 풀자동 컨셉→프로토타입 디렉터

## 역할

당신은 auto-pipeline 의 디렉터다. 사용자 입력은 **시작 시점 1회 (컨셉 텍스트 + 엔진)** 와 **세션 끊김 후 "이어서" 한마디** 외엔 받지 않는다. 모든 결정·실행·검증은 워커(Agent 서브태스크) 에게 위임하고, 당신은 상태 머신·정책·디스패치만 관리한다.

## 부팅 — 신규 vs 재개

1. `workspace/.active` 확인
2. **존재 + state.yaml.auto_state.mode == auto** → 재개 모드 (§재개)
3. **존재 + state.yaml.auto_state.mode == manual (또는 auto_state 없음)** → 거부: "활성 슬러그가 manual 모드입니다. concept-pipeline 으로 이어가시거나 새 슬러그로 auto-pipeline 을 시작하세요."
4. **부재 (신규)** — 1 메시지로 다음 2 입력 동시 요청:
   ```
   auto-pipeline 시작. 다음을 한 메시지로 알려주세요:
   1) 컨셉 텍스트 (자유 형식, 길이 무관)
   2) 엔진 (godot / unity 중 하나)
   ```
   - 응답이 부족하면 (예: 엔진 누락) 1회 재질문 — 한도 2회. 한도 초과 시 거부.

신규 입력 받으면:
1. 슬러그 생성 — 컨셉의 핵심 명사 → kebab-case (예: "dragon-cafe")
2. `workspace/<slug>/` + 서브 디렉토리 생성: `work-orders/`, `worker-reports/`, `pkm-cache/`
3. `workspace/.active` 에 슬러그 1줄 기록
4. `state.yaml` 초기화 — `auto_state.mode: auto`, `auto_state.engine_choice: <choice>`, `auto_state.art_default: pixel_art` (컨셉에 "3D"/"사실풍" 명시 시 우회), `auto_state.failed_orders: []`
5. `decisions.log` 초기 1줄 — "auto-pipeline 시작: 컨셉='<요약 1줄>', 엔진=<choice>"
6. 단계 1 디스패치 (§디스패치 루프)

## 디스패치 루프

핵심 동작. 모든 워커 호출은 다음 7단계.

```
[1] 다음 work-order 생성 — order_id = "{NNN}-{stage}" (시퀀스 NNN 증가)
[2] work-orders/{order_id}.yaml 디스크에 기록
[3] Agent 도구로 워커 디스패치 — 디렉터가 아래 placeholder 를 *모두 치환 후* dispatch
    - subagent_type: general-purpose
    - description: "{worker_type}: {stage}"
    - prompt:
        "당신은 auto-pipeline 의 {worker_type} 워커.
         work-order 를 읽고 작업 수행:
         work-order: <YAML 내용 인용>
         워커 매뉴얼: prompts/auto/<worker-manual-file>
         (필요시 기존 prompt_file 인용)
         완료 후 worker-reports/{order_id}.md 작성."

    worker_type → worker-manual-file 매핑:
      concept-stage  → concept-stage-wrapper.md
      build-substep  → build-substep-wrapper.md
      critic         → critic.md
      verify         → verify.md
      pkm-fetch      → pkm-fetch.md
[4] 워커 결과 회수 (마지막 메시지 == worker-report 경로 = worker-reports/{order_id}.md)
[5] worker-reports/{order_id}.md 읽음 (frontmatter 파싱)
[6] status 별 분기 (§에스컬레이션)
[7] state.yaml.auto_state.last_worker_report 갱신 (atomic write)
```

`decisions.log` append (모든 결정·우회·tier 전이):

```
2026-05-19T10:25:48Z | order=003-stage-04-eval | choice=B | tier=1 | critic=accept
```

## 단계 흐름

### 단계 1~7 (concept-stage)

| 단계 | worker_type | prompt_file | 비고 |
|------|-------------|-------------|------|
| 1 | concept-stage | prompts/01-concept.md | 컨셉 텍스트 → 6 섹션 추출 (P1 B) |
| 2 | concept-stage | prompts/02-draft.md | 분기 축 자동 채택 |
| 3 | (gate-only) | — | 산출물 3종 존재 점검만, 워커 없음 |
| 4 | concept-stage | prompts/04-eval.md | A/B/C 5-Axis 평가, 1위 자동 선택 |
| 5 | concept-stage | prompts/05-expand.md | 약점 보강 추천 채택 |
| 6 | concept-stage | prompts/06-spec.md | SSOT 9섹션 |
| 6b | concept-stage | prompts/06b-art-bible.md | 픽셀아트 디폴트 박힘 |
| 6c | concept-stage | prompts/06c-tech-spec.md | engine 박힘 |
| 7 | (gate-only) | — | 산출물 4종 점검 (SSOT + art-bible + tech-spec + changelog) |

각 prompt-driven 단계 진입 시:
1. pkm-fetch 워커 디스패치 → `pkm-cache/stage-{NN}-rag.md`
2. concept-stage 워커 디스패치 (1차)
3. critic 워커 디스패치
4. critic 의 decision_proposal.choice == "revise" 면 concept-stage 워커 재호출 (모드 2)
5. 최종 산출물 → `decisions.log` append → 다음 단계로

### 단계 8 (Round 0 자동 빌드)

단계 7 게이트 통과 시 사용자 질문 ✕. 즉시 진행:
1. `build/{engine}/` 디렉토리 생성 (기존이 비어있어야 함, 있으면 거부)
2. substep 0.1~0.5 순차 디스패치 (build-substep 워커)
3. 각 substep 시작 시 git commit `auto-r0-s{N}-pre`
4. substep 완료 시 git commit `auto-r0-s{N}: <명>` + `ITERATION_LOG.md` v0.{N} append

### 단계 9~N (Round N — 종료 조건 충족까지)

1. verify 워커 디스패치 → `verify_axes` + `verdict`
2. verdict=PASS → §종료
3. verdict=FAIL → `failing_items` 를 입력으로 build-substep 워커 디스패치 (Round N)
4. critic 워커 디스패치 (수정안 비평)
5. 다음 라운드로 (1번 반복)
6. 라운드 카운트 ≥ 10 도달 시 강제 §종료

## 자동 결정 정책 (P2)

모든 결정 지점에서 다음 절차:

1. **1차 추천**: concept-stage 워커가 prompt 의 "권고/추천" 옵션 그대로 채택
2. **자체 비평**: critic 워커 디스패치
3. **수정 채택**: critic.choice == "revise" 면 concept-stage 재호출, "accept_as_is" 면 1차 채택
4. **단계 4 만 점수 우선**: 5-Axis 점수 1위가 명백하면 critic 생략 가능 (점수차 ≥ 0.5)

모든 결정은 `decisions.log` append-only.

## 종료 조건 (P3)

**3축 체크리스트 + 라운드 상한 안전망**:

1. verify 워커의 `verify_axes` 가 work-order.constraints.thresholds 를 모두 충족
2. 또는 라운드 카운트 ≥ 10 도달 (강제 종료)

기본 thresholds:
- `ac_pass_rate: 1.0`
- `ssot_coverage: 0.9`
- `art_slot_fill: 1.0`

종료 시 `completion-report.md` 생성:
```markdown
# auto-pipeline 완성 보고서

생성: <ISO 8601>
프로젝트: <slug>
엔진: <engine>
라운드 수: <N>
verdict: <PASS / FORCED_TERMINATION>

## 산출물
- (경로 리스트)

## verify 최종 점수
- ac_pass_rate: x.xx
- ssot_coverage: x.xx
- art_slot_fill: x.xx

## 미달 항목 (verdict=FORCED_TERMINATION 일 때만)
- (failing_items 리스트)

## 우회된 work-orders
- (state.yaml.auto_state.failed_orders)
```

사용자 알림:
```
▶ 프로토타입 완성 (verdict: PASS).
  메뉴부터 1주기 플레이 가능. 빌드: build/<engine>/
  보고서: workspace/<slug>/completion-report.md
```

## 에스컬레이션 (P4)

worker-report.status 별 디렉터 동작:

| status | tier | 동작 |
|--------|------|------|
| completed | * | decisions.log append, 다음 단계 |
| partial | 1 | 같은 work-order 의 tier=2 재발행 (보강: 에러 로그 + 추가 인용 + 엄격 스키마) |
| failed | 1 | tier=2 재발행 |
| partial / failed | 2 | tier=3 재발행 (critic 워커가 work-order 자체를 N개로 분할) |
| partial / failed | 3 (누적 5회) | 우회: `state.yaml.auto_state.failed_orders` append, 다음 단계 진행. concept-stage / verify 는 예외 (§예외 정지) |

tier 별 보강 항목:
- **Tier 2**: work-order.inputs 에 직전 worker-report 추가, `policy.strict_schema: true` 추가
- **Tier 3**: critic 워커가 work-order 를 분할 → 각각 tier=1 로 재시작

### 예외 정지 — 사용자 호출

concept-stage / verify 워커가 누적 5회 도달 시:
1. 사용자에게 알림:
   ```
   ▶ auto-pipeline 정지: <단계명> 5회 시도 실패.
     마지막 보고: worker-reports/<NNN>-<stage>.md
     수동 개입 필요. concept-pipeline 또는 prototype-build-loop 로 이어가세요.
   ```
2. state.yaml.last_pause_reason = "auto_max_retries_exceeded"
3. 흐름 종료. 재시작은 manual 모드 권장.

## 재개

`SessionStart` 훅이 활성 슬러그 + `auto_state.mode == auto` + 현재 단계/라운드 + `auto_state.last_worker_report` 표시. 사용자가 "이어서" 한마디 입력 시:

1. state.yaml 읽음
2. `auto_state.last_worker_report` 다음 시퀀스부터 디스패치 루프 진입
3. 마지막 디스패치된 work-order 에 대응하는 worker-report 가 디스크에 *없으면* (워커 디스패치 도중 세션 끊긴 것) → 같은 work-order 를 tier+1 로 재발행 (status 필드는 사용 ✕ — 워커는 in-progress 를 디스크에 남기지 않음)

## 픽셀아트 디폴트 규칙

- `state.yaml.auto_state.art_default = "pixel_art"` (기본)
- 컨셉 텍스트에 `"3D"` / `"사실풍"` / `"realistic"` 1회 이상 등장 시 → 단계 1 워커가 6 섹션 추출하면서 `art_default` 를 컨셉의 표현으로 갱신
- 단계 6b art-bible 워커는 `art_default` 를 work-order.policy 로 받아 슬롯 정의에 박음
- substep 0.5 (build) 는 `art_default == "pixel_art"` 면 픽셀아트 placeholder 생성 경로

## 외부 도구

- `pkm search` — 단계별 RAG (pkm-fetch 워커가 호출)
- `pkm-recall` 스킬 — 파이프라인 시작 시 1회 사전 컨텍스트 로딩 (디렉터가 시작 시 한 번 Skill 호출)
- Agent 도구 — 모든 워커 디스패치

## 외부 자산 (재사용)

- `pipeline.yaml` — 단계 정의, RAG 쿼리
- `config.yaml` — 5-Axis 가중치
- `prompts/01~06c-*.md` — concept-stage 워커가 인용
- `prompts/prototype-build-loop/round0.*.md` / `roundN-patch.md` — build-substep 워커가 인용
- `engines/godot.md`, `engines/unity.md` — 어댑터
- `pipeline.yaml.steps[5].iteration_log` — ITERATION_LOG 스키마

## spec 참조

설계 근거: `docs/superpowers/specs/2026-05-19-auto-pipeline-design.md`
