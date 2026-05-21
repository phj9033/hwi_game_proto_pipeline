---
name: spec-pipeline
description: 컨셉 텍스트 1회 입력 → 게임 상세기획서(GDD) · 기술명세서 · 아트명세서 3개 문서를 자동 생성한다. 4 게이트 최소 개입 + 끝단 2 문서 병렬 subagent. PKM-recall 1회 응축 호출로 사용자 누적 지식 활용. 기존 concept-pipeline 과 독립 — 같은 workspace 슬러그에 공존 가능. 트리거 - "/spec-pipeline", "스펙 파이프라인 시작", "3종 명세서 만들자", "이어서 (재개)".
---

# Spec Pipeline — 자동 흐름 스킬

## 역할
~/concept-pipeline/ 의 데이터 주도 파이프라인 실행기. 트리거되면 끝까지 흐름을 끌어가며, 4 게이트 (G1~G4) 에서만 사용자에게 묻는다.

## 입력 데이터
- `~/concept-pipeline/spec-pipeline.yaml` — 단계+게이트 정의 (불변)
- `~/concept-pipeline/prompts/spec/<NN>-*.md` — 단계별 LLM 프롬프트
- `~/concept-pipeline/workspace/.active` — 활성 슬러그 (1줄)
- `~/concept-pipeline/workspace/<slug>/state.yaml` — 진행 상태 (`spec_pipeline:` 네임스페이스 사용)

## 산출물 (workspace/<slug>/)
- `concept.md` — 입력 원문 (Step 0)
- `inference.yaml` — 추론 결과 (Step 1)
- `pkm-recall.md` — PKM 회상 (Step 2)
- `gdd.md` — 게임 상세기획서 master (Step 3)
- `style-options.md` — 아트 스타일 후보 3개 (Step 4)
- `tech-spec.md` — 기술명세서 (Step 5 worker)
- `art-spec.md` — 아트명세서 (Step 5 worker)

## 부팅 — 신규 vs 재개
1. `workspace/.active` 존재 확인
2. 존재 → `state.yaml.spec_pipeline` 키 읽기
   - 키 없음 → 신규 spec-pipeline 시작 여부 사용자에게 물음
   - 키 있고 `status: in_progress` → 재개 (마지막 통과 게이트 다음부터)
   - 키 있고 `status: done` → "다시 만들기 / 이어보기" 선택
3. 부재 → 슬러그 1회 입력 받음

## 흐름

### Step 0 — 입력 수신
1. 활성 슬러그 확인 (없으면 사용자에게 새 슬러그 요청 — kebab-case 검증)
2. "컨셉 텍스트를 붙여넣어 주세요 (분량 자유 — 1문장 ~ 몇 페이지)" 멀티라인 1회 입력
3. 10자 미만이면 1회 재요청 (그래도 짧으면 그대로 진행)
4. `workspace/<slug>/concept.md` 에 저장 + `state.yaml` 의 `spec_pipeline.step_0` 채움
5. `current_step: 1` 로 마킹 후 Step 1 진입

### Step 1 — 장르·메카닉 추론
1. `prompts/spec/01-inference.md` 의 지시를 따라 `concept.md` 를 분석
2. 결과를 `workspace/<slug>/inference.yaml` 에 yaml 로 저장
3. `error: too_short` 인 경우 사용자에게 1~2문장 추가 힌트 요청 → 재추론 1회. 또 실패하면 그대로 진행 (게이트 표시는 빈 inference 로)

### G1 — 추론 결과 확인 (사용자 게이트)
표시 포맷:
```
[추론 결과]
장르: <genre>
서브장르: <sub_genres or "—">
코어 메카닉:
  1. <name> — <why>
  2. ...
플레이어 판타지: <player_fantasy>
톤·무드: <tone_mood>
비교작:
  - <title> — <why>
  ...
모호한 차원: <ambiguities or "없음">

[선택]
  a. 이대로 진행 (accept)
  e. 특정 필드 수정 (edit)
  r. 다시 추론 (redo)
```

- accept → `state.yaml` `gate_g1: { passed_at: <now>, user_action: accept }` → Step 2 진입
- edit → 사용자가 필드명+새값 입력 → inference.yaml 갱신 → 다시 G1 표시
- redo → Step 1 재실행 (Phase E8 가드: 동일 게이트 3회 누적 시 "수동 편집 권장" 안내)

### Step 2 — PKM 회상
1. `prompts/spec/02-pkm-query.md` 의 지시를 따라 pkm-recall 스킬을 5~7회 순차 호출
   - 호출 실패 (스킬 없음/오류) 시 `pkm-recall.md` 에 `# SKIPPED: pkm-recall unavailable` 만 쓰고 `state.yaml.step_2.skipped_reason = "pkm-recall unavailable"` 마킹 → G2 건너뛰고 Step 3 으로 직진
2. 결과를 점수화해 `workspace/<slug>/pkm-recall.md` 의 CANDIDATES 섹션에 ≥ 3점 항목 최대 8개로 저장
3. CANDIDATES 가 0개면 사용자에게 "관련 PKM 없음 — 그대로 진행" 안내 후 G2 자동 통과

### G2 — PKM 관련성 검증 게이트
표시 포맷:
```
[PKM 회상 결과 — {N}개 후보]

[1] (4.5) [PKM/game-design] 자원관리 게임 자원노드 패턴
    why: "<core_mechanic #2> 시스템 패턴" 쿼리 매치
    excerpt: "노드 수보다 노드 가치 다양성이 ..."

[2] (4.1) ...

채택 항목 번호를 쉼표로 (예: 1,3,5)
또는: "전체" / "건너뛰기"
선택:
```

- 채택 항목의 본문을 `pkm-recall.md` 의 `## ADOPTED` 섹션에 복사 (Step 3/5 에서 인용 위해)
- `state.yaml.spec_pipeline.step_2.gate_g2.adopted_item_ids` 에 ID 배열 저장
- `state.yaml.last_gate = G2` 마킹 후 Step 3 진입

### Step 3 — GDD master 생성
1. `prompts/spec/03-gdd.md` 의 지시를 따라 `workspace/<slug>/gdd.md` 작성
2. 작성 후 H1 개수 검증 — 12개 미만이면 1회 재시도. 그래도 실패하면 사용자에게 보고
3. `state.yaml.spec_pipeline.step_3.gdd_path = "gdd.md"` 마킹

### G3 — GDD 초안 확인
표시 포맷:
```
[GDD 초안 — gdd.md (헤딩 12/12)]

# 1. 한 줄 정의 + 엘리베이터 피치
<본문 일부 첫 200자>
...

# 2. 플레이어 판타지 / 타겟 / 톤
<...>
... (각 섹션 첫 200자만 요약 표시)

[선택]
  a. 이대로 진행 (accept)
  p. 섹션 부분 수정 (partial-edit)  — 섹션 번호 쉼표 입력 (예: §4.2, §7)
  r. 전체 다시 작성 (redo)
```

- accept → `gate_g3: { passed_at: <now>, user_action: accept }` → Step 4 진입
- partial-edit → 섹션 ID 받음 + (선택) 사용자 추가 지시 1~2문장 받음 → `03-gdd-partial.md` 실행 → 다시 G3 표시
- redo → Step 3 재실행
- **3회 누적 (G3 표시 카운트 ≥ 3) 시**: "G3 가 3번째입니다. 수동 편집을 권장합니다 (현재 gdd.md 그대로 두고 Step 4 로 진행 / 일시 abort) — 선택?" 표시

### Step 4 — 아트 스타일 옵션
1. `prompts/spec/04-style-options.md` 의 지시를 따라 `workspace/<slug>/style-options.md` 작성
2. Option A/B/C 3개 모두 존재하는지 검증 (각 ## H2 헤더 확인)

### G4 — 아트 스타일 선택
표시 포맷:
```
[아트 스타일 후보 3개]

A. <스타일 이름>
   레퍼런스: <키워드>
   팔레트: <5색 hex>
   어울리는 이유: <한 줄>

B. <스타일 이름>
   ...

C. <스타일 이름>
   ...

선택 (a/b/c):
```

- 선택 받으면 `state.yaml.spec_pipeline.step_4.gate_g4.selected = "A"|"B"|"C"`
- Step 5 진입

### Step 5 — 병렬 작성 (subagent 2개 동시 디스패치)

**디스패치 시점**: G4 통과 즉시.
**중요**: 두 Agent 호출을 **동일 응답 메시지 내에서 병렬** 호출 (Agent 툴 2개를 1 응답에 배치).

```
Agent(
  subagent_type=general-purpose,
  description="Tech spec writer",
  prompt=<prompts/spec/05a-tech.md 의 본문 + 입력 데이터 인라인>
)

Agent(
  subagent_type=general-purpose,
  description="Art spec writer",
  prompt=<prompts/spec/05b-art.md 의 본문 + 입력 데이터 (선택된 옵션 명시) 인라인>
)
```

`state.yaml.spec_pipeline.step_5.subagent_dispatched_at = <now>`.

### Step 5.5 — 사후 검증
두 워커 보고를 받은 후:
1. `tech-spec.md` 존재 + 비어있지 않음 + H1 ≥ 10 → 통과. 실패 시 `tech_failed: true` 마킹.
2. `art-spec.md` 존재 + 비어있지 않음 + H1 ≥ 11 → 통과. 실패 시 `art_failed: true` 마킹.
3. art-spec §10 의 에셋 프롬프트가 §1 키워드 + §2 hex 중 1개 이상 인용했는지 grep — 누락 행 수 보고 (실패는 ✕, 경고만)

### Step 5.6 — 워커 재시도 (실패한 경우만)
- 한쪽만 실패 → 동일 프롬프트 1회 재시도 (Agent 1개)
- 양쪽 실패 → 메인이 인라인 폴백 작성 (GDD 재로드, 토큰 비용 감수)
- 재시도 후에도 실패 → 사용자에게 어느 문서가 부실한지 보고 + 수동 작성 안내

`state.yaml.spec_pipeline.step_5.subagent_completed_at = <now>`.

### Step 6 — 완료 리포트
표시 포맷:
```
[spec-pipeline 완료]
산출물:
  📄 workspace/<slug>/gdd.md          (게임 상세기획서, H1 N개)
  ⚙️  workspace/<slug>/tech-spec.md    (기술명세서, H1 N개)
  🎨 workspace/<slug>/art-spec.md     (아트명세서, H1 N개, 슬롯 N개)

주요 결정:
  - 장르: <genre>
  - 스타일: <selected style name>
  - PKM 참조: N개 채택

다음 단계 (선택):
  - 프로토타입 빌드: "프로토타입 시작" 또는 /prototype-start (별도 입력 필요)
  - 산출물 검토 후 부분 재작성: /sp-redo step_3 (추후 추가)
```

`state.yaml.spec_pipeline.status = "done"` 마킹 후 종료.

## 기존 스킬과의 관계
- concept-pipeline / auto-pipeline / prototype-build-loop 와 **독립 진입점**
- 같은 슬러그의 기존 산출물 (예: `06-tech-spec.md`) 과 신규 산출물 (`tech-spec.md`) 은 파일명이 달라 공존
- 본 스킬은 위 3개 스킬의 파일을 1바이트도 수정하지 않는다 (`tests/spec_pipeline_no_regression.sh` 로 단언)
