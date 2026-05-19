# auto-pipeline — 풀자동 컨셉→프로토타입 파이프라인 설계

- **상태**: Draft (사용자 디자인 승인 완료, 스펙 리뷰 대기)
- **작성일**: 2026-05-19
- **선행 스킬**: `concept-pipeline` (무수정 재사용), `prototype-build-loop` (무수정 재사용)
- **신규 스킬 슬러그**: `auto-pipeline`

## 1. 목표와 비목표

### 1.1 목표
컨셉 텍스트와 엔진 선택만 받으면 게임 컨셉 정립 → 통합 명세서 (SSOT + 아트 바이블 + 테크 스펙) → 프로토타입 빌드 → 완성도 충족 라운드까지를 **사용자 추가 입력 없이** 자동 수행한다. 결과물은 메뉴부터 한 주기까지 플레이 가능한 프로토타입.

### 1.2 비목표
- 컨셉 텍스트의 충실도 평가 또는 사용자 의도 재확인 (받는 그대로 신뢰)
- 엔진 외 플랫폼 (웹, 콘솔) 빌드
- 완성도 임계 미충족 시 자동 디플로이 / 외부 배포
- 기존 두 스킬 (`concept-pipeline`, `prototype-build-loop`) 의 동작 변경

### 1.3 사용자 입력 표면
| 시점 | 입력 |
|------|------|
| 시작 시 1회 | 컨셉 텍스트 (자유 형식, 길이 무관) + 엔진 (Godot / Unity) |
| 그 외 | 없음 (세션 끊김 시에만 "이어서" 한마디로 재개) |

## 2. 핵심 정책 결정

브레인스토밍 단계에서 사용자가 확정한 5가지 정책.

| ID | 결정 사항 | 채택안 |
|----|----------|-------|
| P1 | 컨셉 입력 형태 | **자유 형식 컨셉 브리프** (LLM 이 직접 추출 + 빈 슬롯만 추론). `pkm search` 로 단계별 PKM 자동 활용 |
| P2 | 결정 지점 자동화 정책 | **2-pass 자체 비평** (1차 추천 → critic 비평 → 수정안 채택). 단계 4 는 5-Axis 점수 1위 우선, 동률·근소 차이 시 비평 라운드가 타이브레이커 |
| P3 | 종료 조건 | **3축 체크리스트 + 라운드 상한 안전망**: ① AC 테스트 전부 PASS ② SSOT 9섹션 covered 율 ≥ 임계 ③ art-bible 슬롯 채움률 100%. 라운드 상한 M = 10 |
| P4 | 실패 에스컬레이션 | **3-tier (한도 5회)**: Tier 1 재시도 ×1 → Tier 2 컨텍스트 보강 후 재시도 ×2 → Tier 3 critic 분석 + 작업 분할 ×1 → 우회 |
| P5 | 실행 모델 | **하이브리드**: 메인 디렉터는 부모 1세션, 무거운 substep (RAG, 빌드, critic, verify) 은 Agent 서브태스크로 격리. state.yaml 매 워커 완료마다 atomic write → 끊기면 다음 세션이 resume |

### 2.1 디자인 디폴트
- **아트 스타일 디폴트 = 픽셀아트** — 외부 디자인 툴 부재 + 컨셉 변경 시 같은 슬롯 재활용 목적. 컨셉 텍스트에 "3D" / "사실풍" 등 명시 반대 신호가 있을 때만 우회.
- **해상도·팔레트 디폴트**: 32×32 또는 64×64 스프라이트시트, 16색 팔레트 (엔진별 atlas 포맷은 단계 6 art-bible 워커가 결정)

## 3. 아키텍처

### 3.1 디렉터 + 워커 구조

```
┌─────────────────────────────────────────────────────────────┐
│  auto-pipeline 스킬 (디렉터)                                  │
│  ─ 상태 머신 (state.yaml 갱신)                                │
│  ─ 자동 결정 (P2), 종료 조건 (P3), 에스컬레이션 (P4)            │
│  ─ 워커 디스패치 + 결과 회수                                   │
└────────────┬────────────────────────────────────────────────┘
             │ work-orders/{NNN}-{stage}.yaml
             ▼
┌─────────────────────────────────────────────────────────────┐
│  워커 (Agent 서브태스크, stateless)                            │
│  ─ concept-stage 워커 (단계 1~7 각 1회)                       │
│  ─ build-substep 워커 (Round 0.1~0.5 / Round N 각 1회)        │
│  ─ critic 워커 (P2 자체 비평)                                  │
│  ─ verify 워커 (AC 테스트 + 3축 체크리스트)                     │
│  ─ pkm-fetch 워커 (`pkm search` 단계별 호출)                   │
└─────────────────────────────────────────────────────────────┘
             │ 파일 시스템 (모든 입출력)
             ▼
workspace/<slug>/
  ├─ 기존: state.yaml, 01-concept.md, ..., 06-*, build/
  ├─ 신규: decisions.log         (자동 결정 + 근거)
  │        work-orders/         (디렉터 → 워커 지시서)
  │        worker-reports/      (워커 → 디렉터 결과)
  │        pkm-cache/           (단계별 RAG 결과 캐시)
  │        completion-report.md (최종 보고)
```

### 3.2 기존 자산 재사용
- `pipeline.yaml` — 단계 정의 그대로
- `config.yaml` — 5-Axis 가중치 그대로
- `prompts/01~06c-*.md` — 워커가 그대로 사용
- `prototype-build-loop` 의 Round 0 substep 5개 정의 — 워커가 그대로 사용
- `pkm search` CLI — `pipeline.yaml.steps[*].rag_queries` 의 쿼리 자동 호출
- `pkm-recall` 스킬 — 파이프라인 시작 시 1회 사전 컨텍스트 로딩

### 3.3 기존 두 스킬과의 관계
- `concept-pipeline` / `prototype-build-loop` 의 SKILL.md, prompt, yaml **무수정**.
- `auto-pipeline` 은 기존 스킬을 invoke 하지 않고 데이터 (prompts, pipeline.yaml) 만 재사용.
- 사용자는 여전히 기존 두 스킬을 대화형으로 쓸 수 있음 (병존).

## 4. 컴포넌트 상세

### 4.1 디렉터 (auto-pipeline SKILL.md)

상태 머신. 책임 4가지:
1. **부트스트랩** — 컨셉 + 엔진 1회 수신 → state.yaml 초기화 → 단계 1 워커 디스패치
2. **단계 워커 결과 처리** — P2 자동 결정 → decisions.log 기록 → state.yaml 갱신 → 다음 단계 디스패치
3. **빌드 라운드 진입** — 단계 7 게이트 통과 후 사용자 질문 없이 즉시 Round 0 시작
4. **종료 판정** — 매 라운드 후 verify 워커 호출, 3축 PASS 시 종료 / 미달이면 Round N+1

P4 3-tier 에스컬레이션은 디렉터가 일괄 관리. 워커는 시도·결과만 보고.

### 4.2 워커 종류

| 워커 | 입력 | 출력 | 호출 빈도 |
|------|------|------|----------|
| **concept-stage** | work-order + prompt (`prompts/0X-*.md`) + 이전 단계 산출물 + PKM 캐시 | `0X-*.md` + worker-report | prompt-driven 단계 (1, 2, 4, 5, 6, 6b, 6c) 각 1회 + critic 비평 후 재호출 1회. **단계 3, 7 은 gate-only** (concept-stage 워커 디스패치 ✕, 디렉터가 직접 통과 점검). **단계 6 은 6 → 6b → 6c 순차 3회 디스패치** (SSOT → art-bible → tech-spec) |
| **critic** | concept-stage / build-substep 1차 출력 | 비평 + 수정안 | 단계마다 1회, build substep Tier 3 진입 시 |
| **build-substep** | substep 정의 (Round 0.1~0.5 또는 Round N 수정안) + 06-* 3 산출물 + build/ 현재 상태 + 엔진 | 코드 변경 + 빌드 로그 + worker-report | substep 당 1회 (재시도는 디렉터 관리) |
| **verify** | tech-spec §H AC + SSOT 9섹션 체크리스트 + art-bible 슬롯 + build/ | 3축 점수 + PASS/FAIL + 미달 항목 리스트 | Round 종료마다 1회 |
| **pkm-fetch** | 단계별 쿼리 (`pipeline.yaml.steps[*].rag_queries`) | `pkm-cache/{stage}-rag.md` | 단계 시작 시 1회 |

### 4.3 신규 산출물 경로

```
workspace/<slug>/
├── state.yaml                   # 기존 + auto_mode, engine, art_default 필드 추가
├── decisions.log                # append-only, 자동 결정 + critic 코멘트
├── work-orders/{NNN}-{stage}.yaml
├── worker-reports/{NNN}-{stage}.md
├── pkm-cache/{stage}-rag.md
└── completion-report.md         # 종료 시 최종 (성공·실패·미달 항목 포함)
```

### 4.4 work-order / worker-report 스키마

**work-order**
```yaml
order_id: "003-stage-04-eval"
stage: 4
goal: "A/B/C 5-Axis 평가 + 1위 선정"
inputs:
  - workspace/<slug>/02-draft-A.md
  - workspace/<slug>/02-draft-B.md
  - workspace/<slug>/02-draft-C.md
  - workspace/<slug>/pkm-cache/stage-04-rag.md
prompt_file: prompts/04-eval.md
policy:
  art_default: pixel_art
  engine: godot
  self_critique: true
constraints:
  output_path: workspace/<slug>/04-eval-report.md
  decision_required: true
```

**worker-report**
```yaml
order_id: "003-stage-04-eval"
status: completed | failed | partial
outputs:
  - path: workspace/<slug>/04-eval-report.md
    summary: "..."
decision_proposal:
  choice: "B"
  rationale: "..."
issues: []
```

## 5. 데이터 흐름

```
[T0] 사용자: "/auto-pipeline"
     디렉터: "컨셉을 알려주세요 + 엔진 선택 (Godot/Unity)"
     사용자: <컨셉 텍스트> + <엔진>             ← 유일한 사용자 입력
     ↓
[T1] 디렉터: 슬러그 생성 or 활성 슬러그 재개
     state.yaml 초기화 {mode: auto, stage: 1, engine, art_default: pixel_art}
     pkm-fetch 워커 디스패치 (단계 1 RAG)
     ↓
[T2..T7] 단계 1~7 자동 (각 단계 동일 패턴):
     1. pkm-fetch 워커 → pkm-cache/{stage}-rag.md
     2. concept-stage 워커 → 1차 산출물
     3. critic 워커 → 비평 + 수정안
     4. concept-stage 워커 (재호출) → 최종 산출물
     5. 디렉터: decisions.log append, state.yaml 갱신
     6. 단계 게이트 (3, 7) 자동 통과 점검
     ※ 단계 6 은 3 패밀리 순차 (SSOT → art-bible → tech-spec)
       art-bible/tech-spec 워커는 work-order.policy.engine 수신
     ↓
[T8] 단계 7 게이트 PASS → 사용자 질문 없이 즉시 Round 0 진입
     ↓
[T9] Round 0 자동 빌드 (substep 5개):
     0.1 scaffold → 0.2 코어 루프 §B → 0.3 §C+AC →
     0.4 §D UX + §G 콘텐츠 → 0.5 픽셀아트 placeholder
     각 substep: build-substep 워커 디스패치 + P4 3-tier 에스컬레이션
     ↓
[T10] verify 워커 → P3 3축 점검
     ① AC 테스트 PASS율 ② SSOT 9섹션 covered 율 ③ art-bible 슬롯 채움률
     ↓
[T11] 미충족 → Round N 진입:
     - 디렉터: verify 의 "미달 항목" → build-substep 워커 디스패치 (수정 모드)
     - critic 워커: 수정안 자기 비평
     - verify 재호출
     - 라운드 상한 M=10 도달 시 강제 종료
     ↓
[T12] verify PASS → completion-report.md 생성 + 사용자에게 알림
     "▶ 프로토타입 완성. 메뉴부터 1주기 플레이 가능. 빌드: build/"
```

### 5.1 데이터 이동 규칙
- 워커는 부모 컨텍스트 못 봄 — 모든 입력은 work-order 의 파일 경로로 전달
- 워커 출력도 파일 — worker-report 만 부모로 회수 (산출물 본문은 디스크에)
- pkm-cache 는 단계별 1회 생성 후 재사용 (`pkm search` 호출 폭증 차단)
- decisions.log / worker-reports/ 는 append-only
- state.yaml 매 워커 완료마다 atomic write

### 5.2 세션 재개
SessionStart 훅이 활성 슬러그 + 현재 단계 / 라운드 / 마지막 worker-report 표시. 사용자가 "이어서" 한마디 입력 시 디렉터가 가장 최근 worker-report 다음 번호부터 재개.

## 6. 에러 처리

### 6.1 실패 분류
| 분류 | 발생 예 | 진단 신호 |
|------|--------|----------|
| **T-1 일시 오류** | 빌드 타임아웃, RAG 빈 결과, 파일 권한 일시 충돌 | exit code, "timeout/transient" 패턴 |
| **T-2 컨텍스트 부족** | 산출물 누락 섹션, AC 모호 | worker-report.status=partial |
| **T-3 계획 오류** | 같은 방식 반복 실패, 의존성 부재 | T-1·T-2 모두 실패한 후 |

### 6.2 3-tier 회복 흐름
```
워커 시도 #1 (원래 work-order)
   ↓ 실패
[Tier 1] 같은 work-order 재시도 ×1               (총 ≤ 2)
   ↓ 실패
[Tier 2] work-order + 보강 (에러 로그, 추가 인용, 엄격한 스키마) ×2  (총 ≤ 4)
   ↓ 실패
[Tier 3] critic 분석 → work-order 를 N개로 분할 ×1  (절대 한도 누적 5회)
   ↓ 누적 5회 초과
[우회·로그] 미완 마킹 → state.yaml.failed_orders 추가 → 다음 단계 진행
```

### 6.3 워커별 우회 가능성
| 워커 | 우회 가능 | 우회 시 영향 |
|------|---------|------------|
| concept-stage (1~7) | 불가능 → 5회 한도 시 사용자 호출 (예외 정지) | 컨셉 미완은 후속 모두 무효 |
| critic | 가능 (1차 안 채택) | 결정 품질 ↓ |
| build-substep | 가능 (미완 마킹) | 다음 라운드 verify 가 적발 |
| verify | 불가능 → 5회 한도 시 마지막 점수로 강제 진행 | 종료 판정 신뢰도 ↓, 라운드 상한이 안전망 |
| pkm-fetch | 가능 (빈 캐시) | 단계 품질 ↓ |

### 6.4 라운드 상한 (P3 D 안전망)
- 빌드 라운드 절대 상한 M = 10 (Round 0 포함)
- 도달 시 강제 종료, completion-report 에 미달 리스트 명시
- 매 라운드 verify 결과를 decisions.log 에 기록 → 사후 M 튜닝

### 6.5 트랜잭션·롤백
- `build/` 는 매 substep 시작 시 자동 git commit (`build-r{N}-s{X}-pre`) — Tier 3 분할 실패 시 git reset 으로 원상복구 후 우회
- `workspace/<slug>/0X-*.md` 는 매 단계 시작 시 `.bak` 백업
- `decisions.log` / `worker-reports/` 는 append-only

### 6.6 로깅
- `decisions.log` — 자동 결정 + 근거 + critic 코멘트
- `worker-reports/` — 워커별 상세 (실패 시 에러 로그 포함)
- `ITERATION_LOG.md` (기존 prototype-build-loop) — Round 단위 요약
- `completion-report.md` — 최종 보고

## 7. 테스트 전략

### 7.1 테스트 매트릭스
| 종류 | 대상 | 도구 | 빈도 |
|------|------|------|------|
| 스키마 검증 | work-order / worker-report YAML | pytest + pydantic | CI |
| 디렉터 상태 머신 | state.yaml 전이 (단계 1→7, Round 0→N→완료) | pytest + 가짜 워커 | CI |
| 워커 디스패치 mock | Agent 호출 시 work-order 정확히 전달 | monkeypatch | CI |
| 재개 회복력 | 임의 worker-report 이후 state.yaml 로 재개 | pytest 시나리오 | CI |
| 3-tier 에스컬레이션 | T-1→T-2→T-3→우회 5회 한도 | pytest 에러 주입 | CI |
| smoke end-to-end | 미니 컨셉 1개 전체 흐름 (mock LLM) | pytest | 야간 |
| 엔진 양분기 | Godot / Unity 둘 다 tech-spec / 빌드 산출물 엔진 특화 | pytest 2 케이스 | CI |

### 7.2 verify 워커 자기 테스트
- 골든 케이스 (완성 빌드) → PASS 점수 ≥ 임계
- 알려진 미달 케이스 (AC 1개 미통과) → FAIL + 정확한 미달 항목 보고
- 빈 빌드 → 점수 0

### 7.3 pkm-fetch 캐싱 검증
- 같은 단계 재실행 시 `pkm search` 추가 호출 0회 (캐시 hit)
- Round N 진입 시 새 캐시 가능 (cache invalidation 정책)

### 7.4 픽셀아트 디폴트 검증
- 컨셉 텍스트 스타일 무언급 → art-bible 의 art_style = "pixel art"
- 컨셉 텍스트 "3D" / "사실풍" 명시 → 디폴트 우회
- Round 0.5 substep 이 픽셀아트 placeholder 생성 경로를 타는가

### 7.5 통합 smoke
`tests/auto_pipeline_smoke.py`:
1. 컨셉 = `"a 2D roguelike where you cook noodles for dragons"` + 엔진 = Godot
2. mock LLM (고정 응답) → 단계 1~7 통과
3. mock 빌드 (가짜 build/ 트리)
4. verify mock → 2 라운드 후 PASS
5. completion-report.md 미완 항목 0개로 생성

### 7.6 회귀 가드
- 기존 두 스킬 SKILL.md 해시가 PR 에서 변하지 않는지 CI 체크
- pipeline.yaml 호환성 (3 스킬 공동 사용)
- 기존 prompts/0X-*.md 무수정 보장

## 8. 디렉터리 구조 추가분

```
~/hwi_game_proto_pipeline/
├── .claude/
│   ├── skills/
│   │   └── auto-pipeline/
│   │       └── SKILL.md                # 본 스킬
│   └── commands/
│       └── auto-pipeline.md            # /auto-pipeline 슬래시
├── prompts/
│   ├── auto/
│   │   ├── critic.md                   # critic 워커 prompt
│   │   ├── verify.md                   # verify 워커 prompt
│   │   └── pkm-fetch.md                # pkm-fetch 워커 prompt
│   └── (기존 01~06c-*.md 그대로 재사용)
├── tests/
│   └── auto_pipeline_smoke.py
└── workspace/<slug>/
    ├── (기존 산출물 그대로)
    ├── decisions.log
    ├── work-orders/
    ├── worker-reports/
    ├── pkm-cache/
    └── completion-report.md
```

## 9. 트리거

```
/auto-pipeline                       # 슬래시
"오토 파이프라인 시작"                 # 자연어
"풀자동 게임 만들자"                   # 자연어
"자동으로 다 돌려"                     # 자연어
"이어서"                              # 재개 (세션 끊김 후)
```

## 10. 마이그레이션·호환성

- 기존 활성 슬러그 (`workspace/.active`) 가 있으면 디렉터가 `mode` 필드를 확인:
  - `mode: auto` → 본 스킬이 재개
  - `mode: manual` (기존) → 본 스킬이 거부, 기존 두 스킬 사용 안내
- 신규 슬러그는 항상 `mode: auto` 로 시작
- `state.yaml` 스키마 확장 (auto_mode, engine, art_default, failed_orders) 은 backward-compatible (기존 두 스킬은 모르는 필드 무시)

## 11. 알려진 한계

- **사용자 호출 가능 정지 지점**: concept-stage 워커가 5회 한도 도달 시 사용자에게 알림. 명세 "유저에게 묻는건 없이" 와 충돌하지만 산출물 0 보다 1회 호출이 합리적.
- **라운드 상한 M=10 도달 미완 가능성**: 강제 종료 + 미달 리포트로 처리. M 튜닝은 사후 분석 필요.
- **PKM 미연결 시 LLM 자체 지식 의존**: 기존 concept-pipeline 과 동일 한계 — `pkm search` 가 빈 결과를 반환해도 흐름은 유지.
- **세션 끊김 시 "이어서" 한마디 필요**: Claude Code 내에서 다음 세션을 자동 기동 불가. 명세 9 "유저 입력 2회" 정신은 유지되나 엄밀히는 재개 발화 1회 추가.

## 12. 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-05-19 | 초안 작성 (브레인스토밍 결과 반영). P1~P5 + 픽셀아트 디폴트 + 엔진 선택 시작 시점 통합 |
