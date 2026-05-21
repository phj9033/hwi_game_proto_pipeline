# spec-pipeline 설계 (2026-05-21)

> 컨셉 텍스트 1회 입력 → PKM 회상 결합 → 게임 상세기획서(GDD) · 기술명세서 · 아트명세서 3개 산출
> 기존 `concept-pipeline` / `auto-pipeline` / `prototype-build-loop` 와 **독립 진입점**. 기존 스킬 파일 무수정.

## 1. 동기

기존 `concept-pipeline` 의 두 약점을 신규 파이프라인으로 분리해 해결한다.

1. **3산출물 분기가 부자연** — 단계 6 의 SSOT + art-bible + tech-spec 패밀리는 "인용만 허용" 제약이 너무 빡빡해 각 시점 문서가 얕아진다.
2. **지식 미활용** — 레포 내 `rag-data/` 는 미연결 상태로 LLM 자체 지식만으로 7단계가 흐른다.

신규 파이프라인은 다음을 가진다.

- **GDD 중심 + 2개 파생** 구조 (인용 제약 ✕, 자유 재서술 허용)
- **pkm-recall** 을 단계 2 에 1회 응축 호출 → 채택된 항목만 후속 단계에 주입
- **4 게이트 최소 개입** + 끝단 2 문서 병렬 subagent 작성

## 2. 비-목표

- LLM 출력 품질 자동 채점 / 토큰 비용 회귀
- 특정 엔진 (Godot / Unity) 가정 — 엔진 비종속 추상 수준 유지
- 기존 `concept-pipeline` / `auto-pipeline` / `prototype-build-loop` 의 기능·구조 변경
- 외부 게임 사례 웹검색 / `rag-data/` 컬렉션 접근 (PKM 만 사용)

## 3. 사용자 의사 결정 결과 요약

| 결정 | 값 |
|------|----|
| 지식 소스 | pkm-recall 1종 |
| 사용자 개입 수준 | 최소 (4 게이트) |
| 3 문서 관계 | GDD 중심 + 2개 파생 |
| 입력 분량 | 자유 (1문장 ~ 긴 메모 모두 OK) |
| PKM 검색 범위 | PKM 전체 (프로젝트 무관) |
| 멈춤 지점 4개 | G1 추론 결과 / G2 PKM 관련성 / G3 GDD 초안 / G4 아트 스타일 선택 |

## 4. 아키텍처 개요

- **스킬 이름**: `spec-pipeline`
- **위치**: `.claude/skills/spec-pipeline/SKILL.md`
- **데이터 파일**: 신규 `spec-pipeline.yaml` (기존 `pipeline.yaml` 미터치, 별도)
- **프롬프트 디렉토리**: 신규 `prompts/spec/` (기존 `prompts/01-concept.md` 등과 충돌 ✕)
- **워크스페이스**: 기존 `workspace/<slug>/` 재사용. 신규 파일명 (`concept.md`, `gdd.md`, `tech-spec.md`, `art-spec.md`) 으로 충돌 회피
- **state.yaml**: 기존 키와 다른 `spec_pipeline:` 네임스페이스로 공존 가능

**트리거**: `/spec-pipeline`, "스펙 파이프라인 시작", "3종 명세서 만들자", "이어서" (재개).

**기존 스킬과의 관계**: 독립 진입점. 같은 슬러그의 기존 concept-pipeline 산출물이 있어도 공존 가능. 본 spec 은 기존 스킬 파일을 1바이트도 수정하지 않는다 (회귀 가드 테스트로 단언).

## 5. 파이프라인 단계 + 4 게이트

```
[Step 0] 입력 수신
  ├─ 활성 슬러그 확인 (없으면 사용자에게 요청)
  ├─ "컨셉 텍스트를 붙여넣어 주세요" 멀티라인 1회 입력
  └─ workspace/<slug>/concept.md 저장

[Step 1] 장르·메카닉 추론
  ├─ LLM: 컨셉 → {장르, 코어 메카닉 3~5, 플레이어 판타지, 톤·무드, 비교작 3} 추출
  ├─ workspace/<slug>/inference.yaml 저장
  └─ ⛔ G1 게이트: 추론 결과 표시 → [accept / edit / redo]

[Step 2] PKM 회상
  ├─ pkm-recall 호출 (PKM 전체)
  ├─ 쿼리 = G1 inference 의 차원별 자동 생성 (장르 / 메카닉별 / 톤 / 비교작) → 5~7개 호출
  ├─ 결과 통합·중복 제거·점수화
  └─ ⛔ G2 게이트: 점수 3 이상 / 상한 8개 항목 표시 → 사용자 채택 번호 선택

[Step 3] GDD master 생성
  ├─ 입력 = concept + inference + G2 채택 PKM
  ├─ prompts/spec/03-gdd.md
  ├─ workspace/<slug>/gdd.md
  └─ ⛔ G3 게이트: GDD 표시 → [accept / partial-edit / redo]
      ├─ partial-edit: 사용자가 섹션 번호 지정 → 해당 섹션만 재생성

[Step 4] 아트 스타일 옵션 + 선택
  ├─ LLM: GDD §2 톤·무드 → 아트 스타일 후보 3 (예: 픽셀아트 / 셀룰러 / 로우폴리)
  │   각각 레퍼런스 키워드·팔레트·해상도 가이드 포함
  └─ ⛔ G4 게이트: 1개 선택

[Step 5] 병렬 작성 (subagent 2개 동시 디스패치)
  ├─ Agent: tech-spec-writer
  │   prompts/spec/05a-tech.md
  │   입력 = GDD + G2 채택 PKM + inference
  │   출력 = workspace/<slug>/tech-spec.md
  └─ Agent: art-spec-writer
      prompts/spec/05b-art.md
      입력 = GDD + G4 선택된 스타일 + G2 채택 PKM
      출력 = workspace/<slug>/art-spec.md

[Step 6] 완료 리포트
  ├─ 3 산출물 경로 + 핵심 결정 요약 표시
  └─ state.yaml status = done
```

**핵심 설계 의도**:
- PKM 회상은 **G2 1회로 응축** → 이후 단계는 채택된 회상만 컨텍스트로
- **G3 까지 직렬** (마스터 문서 검토가 가장 무거움), 이후 **G4 + 병렬 워커** 로 빠르게
- G3 partial-edit 은 섹션 단위 재생성 → 전체 재작성 대비 토큰 절약

## 6. 데이터 플로우 + state.yaml 스키마

### 6.1 파일 흐름

```
concept.md ─┬─► inference.yaml ─┬─► pkm-recall.md ─┬─► gdd.md ─┬─► style-options.md ─┬─► tech-spec.md
            │                   │                  │           │                     └─► art-spec.md
            └ G1 ──────────────┘ G2 ──────────────┘ G3 ───────┘ G4 ─────────────────┘
```

### 6.2 state.yaml (`spec_pipeline:` 네임스페이스)

```yaml
spec_pipeline:
  version: 1
  slug: dragon-cafe
  created_at: 2026-05-21T10:00:00Z
  updated_at: 2026-05-21T10:42:00Z
  current_step: 3        # 0~6
  last_gate: G2          # 마지막 통과 게이트
  status: in_progress    # in_progress | done | aborted

  step_0:
    concept_path: concept.md
    input_chars: 412

  step_1:
    inference_path: inference.yaml
    gate_g1:
      passed_at: 2026-05-21T10:05:00Z
      user_action: accept   # accept | edit | redo
      edits: null

  step_2:
    recall_path: pkm-recall.md
    raw_items: 12
    skipped_reason: null    # "pkm-recall unavailable" | "no results"
    gate_g2:
      passed_at: 2026-05-21T10:12:00Z
      adopted_item_ids: [r1, r3, r7, r9]

  step_3:
    gdd_path: gdd.md
    gate_g3:
      passed_at: null
      user_action: pending  # accept | partial-edit | redo | pending
      partial_edits: []     # ["§4.2", "§7"] 같은 섹션 ID

  step_4:
    style_options_path: style-options.md
    gate_g4:
      passed_at: null
      selected: null        # 'A' | 'B' | 'C'

  step_5:
    tech_spec_path: tech-spec.md
    art_spec_path: art-spec.md
    subagent_dispatched_at: null
    subagent_completed_at: null
    tech_failed: false
    art_failed: false
```

### 6.3 재개 로직

- 세션 진입 시 `state.yaml` 의 `current_step` + `last_gate` 읽음
- 마지막 통과 게이트 다음 지점부터 재시작
- 각 게이트 출력 파일이 존재하면 LLM 재추론 ✕, 디스크에서 로드만
- 기존 파이프라인의 SessionStart 훅과 호환 (활성 슬러그 표시는 기존 훅이 처리)

## 7. PKM 회상 (Step 2)

### 7.1 호출 위치

G1 통과 직후 1회만. 이후 단계는 절대 pkm-recall 재호출 ✕.

### 7.2 쿼리 자동 생성

G1 inference 결과로부터 쿼리 세트 구성:

```
쿼리 세트 = [
  "<장르> 게임 디자인 결정",
  "<코어 메카닉 #1> 시스템 패턴",
  "<코어 메카닉 #2> 시스템 패턴",
  "<코어 메카닉 #3> 시스템 패턴",
  "<톤·무드 키워드> 아트 디렉션",
  "<비교작 #1> 분석",
  "<비교작 #2> 분석",
]
```

총 5~7회 순차 호출. 결과 통합 후 중복 제거.

### 7.3 관련성 필터링

- pkm-recall 응답에 점수가 없으면 LLM 이 각 항목을 0~5 로 자체 점수화 (concept + inference 와의 의미 거리)
- **3점 이상**만 G2 게이트 표시 후보
- 표시 항목 **상한 8개** (사용자 결정 피로 회피)

### 7.4 G2 게이트 표시 포맷

```
[1] (4.5) [PKM/game-design] 자원관리 게임 자원노드 패턴 ─ "노드 수보다 노드 가치 다양성이..."
    why: "<코어 메카닉 #2> 시스템 패턴" 쿼리 매치
[2] (4.1) [PKM/post-mortem] dragon-cafe 후기 ─ "초반 5분..."
    why: "<비교작 #1> 분석" 쿼리 매치
...

채택할 항목 번호를 쉼표로 (예: 1,3,5  / "전체" / "건너뛰기"):
```

### 7.5 채택 항목 후속 사용

- 채택 항목의 본문을 `pkm-recall.md` 의 `## ADOPTED` 섹션에 보존
- Step 3 GDD 프롬프트에 `<adopted-knowledge>` 블록으로 인라인 주입
- Step 5 tech-spec-writer / art-spec-writer subagent 에도 동일 블록 전달

### 7.6 폴백

| 상황 | 처리 |
|------|------|
| pkm-recall 미설치 / 호출 실패 | `step_2.skipped_reason = "pkm-recall unavailable"` 마킹 → G2 건너뛰고 G3 직진. 사용자에게 안내. |
| 결과 0 항목 / 모두 점수 < 3 | G2 자동 통과 ("관련 PKM 없음 — 그대로 진행" 안내) |

## 8. 산출 문서 템플릿

### 8.1 `gdd.md` — 게임 상세기획서 (master, 8~12 페이지 분량)

```
1.  한 줄 정의 + 엘리베이터 피치
2.  플레이어 판타지 / 타겟 / 톤
3.  코어 루프 (시작→중간→끝, 다이어그램 텍스트)
4.  시스템 (각 시스템마다 4.x.1 목적 / 4.x.2 규칙 / 4.x.3 상호작용)
5.  진행·페이싱 (세션 5분/30분/2시간 곡선)
6.  메타 진행 (있다면)
7.  컨텐츠 종류 + 1회차 분량 견적
8.  UX / 정보 흐름 (HUD, 메뉴, 알림)
9.  승리·실패 조건 + Fail State
10. 첫 5분 시나리오
11. 비전 차별점
12. 변경 이력
```

### 8.2 `tech-spec.md` — 기술명세서

엔진 비종속 / 추상 수준 유지 (특정 엔진 가정은 `prototype-build-loop` 영역).

```
1.  모듈 분해 (GDD §4 시스템 → 코드 책임 단위 1:1+ 매핑)
2.  데이터 모델 (엔티티/컴포넌트/리소스)
3.  상태머신 (게임 흐름 FSM, 시스템별 FSM)
4.  시스템 간 의존성 그래프 + 통신 방식
5.  영속성 (저장 대상 / 형식 힌트 / 마이그레이션 자리)
6.  핵심 알고리즘 노트 (절차 생성·AI·충돌 등 해당시만)
7.  입력·디바이스 가정
8.  성능 예산 (프레임당 비용·메모리 추정)
9.  테스트 전략 — Acceptance Criteria (GDD §4 규칙 ↔ 검증법)
10. 외부 의존 / 라이선스 고려
```

### 8.3 `art-spec.md` — 아트명세서

G4 에서 선택된 스타일 1개 기준.

```
1.  스타일 정의 (선택된 옵션 본문 — 레퍼런스 키워드, 무드)
2.  컬러 팔레트 (최소 5색, hex)
3.  해상도·캔버스 규칙 (스프라이트/배경/UI)
4.  카메라·구도 가이드
5.  캐릭터·NPC 슬롯표
6.  환경·배경 슬롯표
7.  오브젝트·아이템 슬롯표
8.  UI·아이콘 슬롯표
9.  VFX·이펙트 슬롯표
10. 에셋 생성 프롬프트 (각 슬롯 1프롬프트)
11. 일관성 체크리스트
```

**슬롯표 1행 포맷**:

```
| ID  | 이름   | 카테고리   | 용도 (GDD §X.x 참조) | 해상도 | 우선순위 | 상태 |
| C01 | 주인공 | character | 플레이어 조작 (§3)   | 64x64  | P0       | TBD  |
```

ID prefix: C=character, E=environment, O=object, U=ui, V=vfx

**에셋 생성 프롬프트 포맷**:

```
[C01 — 주인공]
prompt: "pixel art, 64x64 sprite of a stranded astronaut, ..."
negative: "blurry, low-res, signature"
style anchor: §1 컬러 팔레트 #ff..., #00...
ref keywords: <스타일 정의의 키워드>
```

**일관성 자동 체크 의도**: 모든 프롬프트는 §1 의 스타일 키워드와 §2 팔레트 중 하나 이상을 본문에 명시적으로 인용. 누락 슬롯 (GDD 컨텐츠에 등장했으나 슬롯표에 없는 ID) 은 writer 가 보고.

## 9. Subagent 디스패치 (Step 5)

### 9.1 디스패치 시점

G4 통과 즉시. 두 워커를 **동일 메시지에서 병렬** 호출 (Agent 툴 2개를 1 응답에서).

### 9.2 워커 1 — tech-spec-writer

- `subagent_type: general-purpose`
- 입력: GDD 전문 + G2 채택 PKM + inference.yaml (인라인)
- 역할: §1~10 구조의 `tech-spec.md` 작성
- 제약:
  - 엔진 비종속 (특정 엔진 가정 ✕)
  - GDD §4 시스템 → 모듈 매핑 1:1 이상 (누락 시 보고)
  - 분량 가이드 (각 섹션 글자수 힌트)
- 출력: Write 툴로 `workspace/<slug>/tech-spec.md`
- 완료 보고: 200단어 이내 (경로 + 누락/이슈)

### 9.3 워커 2 — art-spec-writer

- `subagent_type: general-purpose`
- 입력: GDD 전문 + style-options.md 의 채택 옵션 + G2 채택 PKM
- 역할: §1~11 구조의 `art-spec.md` 작성
- 제약:
  - 모든 에셋 프롬프트는 §1 스타일 키워드 + §2 팔레트 본문에 포함
  - 슬롯 ID 카테고리별 prefix
- 출력: Write 툴로 `workspace/<slug>/art-spec.md`
- 완료 보고: 200단어 이내

### 9.4 컨텍스트 격리 효과

- 메인 컨텍스트엔 워커 200단어 보고만 남음
- GDD/PKM 본문 토큰은 워커에 격리 → 메인 세션 컨텍스트 보존
- 두 문서가 서로 영향 받지 않음. 일관성은 둘 다 GDD 를 anchor 로 삼는 것으로 보장.

### 9.5 실패·재시도

- 워커 "Write 실패" 보고 시 → 메인이 동일 프롬프트로 1회 재호출 (자동 재시도 1회 한정)
- 2회 모두 실패 → state.yaml `step_5.<which>_failed: true` 마킹 후 사용자에게 보고
- 양쪽 모두 실패 → 메인이 인라인 폴백 작성 (E11)

### 9.6 사후 검증 (메인 수행)

- 두 파일 존재 + 비어있지 않음 + 헤딩 수 최소치 충족 (tech ≥ 10 H1, art ≥ 11 H1)
- 통과 시 `status: done`. 누락 시 어느 문서가 부실한지 사용자에게 보고

## 10. 에러 처리 + 엣지 케이스

| # | 시나리오 | 처리 |
|---|---------|------|
| E1 | 트리거 시 활성 슬러그 없음 | 슬러그 1회 입력. 빈 문자열·공백·기존 슬러그 충돌 시 재요청 |
| E2 | 활성 슬러그가 기존 concept-pipeline 진행 중 | 신규 spec_pipeline 키네임스페이스로 공존. 사용자에게 "어느 쪽 이어가기?" 1회 확인 |
| E3 | 컨셉 텍스트 10자 미만 | 1회 재요청. 그래도 짧으면 그대로 진행 |
| E4 | G1 추론에서 장르/메카닉 추출 실패 | "1~2문장 추가 힌트" 요청 → 재추론 1회 |
| E5 | pkm-recall 호출 실패 / 미설치 | step_2 `skipped (no PKM)` 마킹, G2 건너뛰고 G3 직진 |
| E6 | pkm-recall 결과 0 항목 / 모두 점수 < 3 | G2 자동 통과 |
| E7 | G3 GDD partial-edit | 사용자가 섹션 번호 지정 → 해당 섹션만 재생성, 다른 섹션 보존 |
| E8 | G3 "다시 작성" 무한 루프 | 동일 게이트 재요청 3회 누적 시 "수동 편집 권장" 안내 + abort 옵션 |
| E9 | G4 스타일 옵션 생성 실패 | 폴백 — 픽셀아트 / 셀룰러 / 미니멀 3개 기본 옵션 |
| E10 | Step 5 워커 1개만 실패 (자동 재시도 1회 후) | 다른 1개는 정상 저장. 실패한 1개만 마킹 → 재시도 슬래시 안내 |
| E11 | Step 5 워커 2개 모두 실패 | 메인이 인라인 작성 폴백 (메인 컨텍스트로 GDD 재로드 — 토큰 비용 감수) |
| E12 | 세션 중간 종료 후 재개 시 출력 파일 일부만 존재 | state.yaml + 파일 존재 여부로 entry point 결정. 파일 있고 state 가 not done → "보존 / 덮어쓰기" 1회 물음 |
| E13 | 같은 슬러그로 재트리거 (done 상태) | "다시 만들기 / 이어보기" 선택. 다시 만들기 시 `<file>.bak.<timestamp>` 백업 후 새로 시작 |
| E14 | 슬러그명에 공백/특수문자 | kebab-case 변환 후 사용자 확인 |
| E15 | workspace/<slug> 디렉토리 부재 | 자동 생성 |

**state.yaml 손상 시**: 파싱 실패 → 사용자 보고 + `state.yaml.bak.<timestamp>` 백업 후 step_0 부터 재시작 옵션. 자동 복구 ✕ (조용한 데이터 손실 회피).

## 11. 테스트 전략

### 11.1 T1 — 단위 / 데이터 검증

| 대상 | 검증 |
|------|------|
| `spec-pipeline.yaml` 파싱 | yaml 유효성 + 필수 키 (`steps`, `gates`, `outputs`) 존재 |
| state.yaml 스키마 | 단계 진입 후 상태 키가 채워지는지 (예: step_1 종료 → `inference_path` 가 존재 파일 가리킴) |
| 출력 파일 헤딩 수 | `gdd.md` ≥ 12 H1, `tech-spec.md` ≥ 10 H1, `art-spec.md` ≥ 11 H1 |
| art-spec 슬롯 일관성 | 모든 에셋 프롬프트에 §1 스타일 키워드 + §2 팔레트 hex 중 1개 이상 포함 |

위치: `tests/spec_pipeline/` (bash + python, 기존 tests 구조 따름).

### 11.2 T2 — 골든 시나리오 회귀 (end-to-end)

3개 입력 컨셉 고정 + 고정 결정으로 통과시키는 회귀.

```
tests/spec_pipeline/golden/
  ├─ short-pitch.txt       (1문장 입력)
  ├─ medium-paragraph.txt  (8문장 입력)
  └─ long-memo.txt         (긴 메모 입력)
```

각 입력에 대해 사전 정의된 G1/G2/G3/G4 응답으로 통과 → `gdd.md` / `tech-spec.md` / `art-spec.md` 생성 + T1 구조 체크 통과 검증.

LLM 내용 정확성은 단정 ✕. 구조·존재·길이만.

### 11.3 T3 — PKM 폴백 회귀

- PKM 미설치 환경 시뮬레이션 → `step_2.skipped (no PKM)` + G2 건너뛰기
- PKM 결과 0개 → G2 자동 통과

### 11.4 T4 — 재개 회귀

각 게이트 직후 인위적 중단 → state.yaml 만으로 다음 세션이 정확한 지점에서 이어가는지.

### 11.5 T5 — 기존 스킬 무변경 가드

`tests/spec_pipeline/no_regression.sh`:

```bash
# baseline 태그(=current main)와 비교해 다음 디렉토리에서 modified == 0,
# added 만 허용:
#   .claude/skills/concept-pipeline/
#   .claude/skills/auto-pipeline/
#   .claude/skills/prototype-build-loop/
```

기존 prototype-build-loop 의 baseline 태그 패턴을 따른다.

### 11.6 비-목표

- LLM 출력 품질 자동 채점 ✕
- 토큰 비용 회귀 ✕
- 시각적 비교 ✕

## 12. 디렉토리 영향

```
~/concept-pipeline/
├── spec-pipeline.yaml                          # 신규
├── .claude/
│   └── skills/
│       └── spec-pipeline/                       # 신규
│           └── SKILL.md
├── prompts/
│   └── spec/                                    # 신규
│       ├── 01-inference.md
│       ├── 02-pkm-query.md
│       ├── 03-gdd.md
│       ├── 04-style-options.md
│       ├── 05a-tech.md
│       └── 05b-art.md
├── tests/
│   └── spec_pipeline/                           # 신규
│       ├── golden/
│       ├── unit/
│       ├── resume.sh
│       └── no_regression.sh
└── workspace/<slug>/
    ├── concept.md                               # 신규 (입력 원문)
    ├── inference.yaml                           # 신규
    ├── pkm-recall.md                            # 신규
    ├── gdd.md                                   # 신규 (master)
    ├── style-options.md                         # 신규
    ├── tech-spec.md                             # 신규
    ├── art-spec.md                              # 신규
    └── state.yaml                               # 키 네임스페이스 `spec_pipeline:` 추가
```

**기존 파일 무수정**: `pipeline.yaml`, `config.yaml`, 기존 `prompts/*.md`, 기존 `.claude/skills/*/`, 기존 hooks/commands. T5 회귀 테스트로 단언.

## 13. 향후 확장 가능성 (이번 spec 범위 외)

- `/sp-status`, `/sp-redo <step>` 같은 슬래시 유틸리티 (기존 cp-* 패턴 차용)
- `prototype-build-loop` 입력 어댑터: 본 파이프라인 산출(`gdd.md`/`tech-spec.md`/`art-spec.md`)을 prototype-build-loop 게이트 입력으로 받아들이는 어댑터 한 단
- 아트 스타일 옵션 후보를 PKM 회상으로 보강

위 3개는 별도 spec / iteration 으로 분리한다.
