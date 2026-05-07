---
title: GDD Evaluation Collection — Index
collection: gdd-evaluation
axis: ALL
theory_id: index
keywords: [GDD, evaluation, framework, index, 5-axis-model]
applies_to: [evaluation, creation, navigation]
related: [all]
last_updated: 2026-04-28
---

# GDD Evaluation Knowledge Base — 인덱스

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: ALL — 5축 통합 인덱스
- **이론 ID (Theory ID)**: index
- **이론명**: GDD Evaluation 5-Axis Framework Index
- **분류 키워드**: axis-A, axis-B, axis-C, axis-D, axis-E, framework-index, navigation
- **이론 키워드**: GDD, evaluation, framework, index, 5-axis-model, structure, motivation, cognition, coherence, viability
- **적용 용도**: 컬렉션 탐색, 워크플로우 가이드
- **연관 이론**: 00~14 전체

본 컬렉션은 게임기획서(Game Design Document)의 **평가**와 **작성** 양쪽 작업에 활용 가능한 이론·프레임워크 모음이다. `gdd-evaluation` 컬렉션에 적재 가능한 자료. 추후 RAG 시스템 연결 시 검색·인용 가능.

## 5-Axis Evaluation Model — 평가 골격

| 축 | 이름 | 핵심 질문 | 소속 이론 문서 |
|----|------|----------|--------------|
| **A** | 구조적 완성도(Structure) | 누구든 같은 그림을 그릴 수 있는가? | `00-living-document` |
| **B** | 심리적 동기(Motivation) | 플레이어가 왜 다음 세션을 여는가? | `01-sdt-pens`, `02-bartle-hexad`, `03-octalysis` |
| **C** | 인지적 수용성(Cognition) | 학습 부담이 즐거움을 가리지 않는가? | `04-flow-theory`, `05-cognitive-load`, `06-laws-of-ux`, `07-ftue-onboarding` |
| **D** | 시스템 정합성(Coherence) | 메커니즘이 의도한 감정으로 수렴하는가? | `08-mda-rmda`, `09-elemental-tetrad` |
| **E** | 실현·지속성(Viability) | 약속을 지킬 수 있고, 지킬 가치가 있는가? | `10-vertical-slice-scope`, `11-f2p-kpi`, `12-loss-aversion-bm`, `13-variable-ratio-ethics`, `14-publisher-greenlight` |

## 문서 카탈로그

### Axis A — 구조적 완성도

- `00-living-document.md` — 모던 GDD 작성 원칙, Living Document, 12 섹션 체크리스트, 안티패턴

### Axis B — 심리적 동기

- `01-sdt-pens.md` — Self-Determination Theory(Ryan & Deci) + PENS(Player Experience of Need Satisfaction)
- `02-bartle-hexad.md` — Bartle 4 player types + Marczewski HEXAD 6 user types
- `03-octalysis.md` — Yu-kai Chou Octalysis 8 Core Drives + White/Black Hat 균형

### Axis C — 인지적 수용성

- `04-flow-theory.md` — Csikszentmihalyi Flow, 채널 모델, Macroflow/Microflow, Dynamic Difficulty Adjustment
- `05-cognitive-load.md` — Sweller Cognitive Load Theory(Intrinsic/Extraneous/Germane), 워크드 익잼플
- `06-laws-of-ux.md` — Hick / Fitts / Miller / Jakob / Aesthetic-Usability / Goal-gradient / Tunneling
- `07-ftue-onboarding.md` — First-Time User Experience, 튜토리얼 funnel, D1 retention 최적화

### Axis D — 시스템 정합성

- `08-mda-rmda.md` — MDA Framework(Hunicke et al.) + RMDA(Entities/Responsibilities) 재정의
- `09-elemental-tetrad.md` — Jesse Schell의 4요소(Mechanics/Story/Aesthetics/Technology)

### Axis E — 실현·지속성

- `10-vertical-slice-scope.md` — Vertical Slice 마일스톤, MoSCoW 우선순위, 스코프 크립 방어
- `11-f2p-kpi.md` — F2P/GaaS KPI 12종 공식·벤치마크(DAU/MAU, Retention, ARPU, LTV, ROAS)
- `12-loss-aversion-bm.md` — Prospect Theory, Loss Aversion, Endowment Effect, 윤리적 BM
- `13-variable-ratio-ethics.md` — Skinner 변동 비율 강화, 도파민 루프, 가챠/루트박스 윤리
- `14-publisher-greenlight.md` — 퍼블리셔 평가 단계, 피치덱, USP, 3C 평가, 2025~2026 트렌드

## 평가 워크플로우 (Evaluation Workflow)

GDD 평가 시 권장 RAG 검색 시퀀스:

```
1. 구조 점검 → 00-living-document
2. 타겟 동기 분석 → 01-sdt-pens + 02-bartle-hexad + 03-octalysis
3. 학습/UX 검증 → 05-cognitive-load + 06-laws-of-ux + 07-ftue-onboarding
4. 메커니즘↔감정 정합 → 08-mda-rmda (+ 09-elemental-tetrad)
5. 난이도/도전 곡선 → 04-flow-theory
6. 프로덕션 리스크 → 10-vertical-slice-scope
7. 비즈니스 건전성 → 11-f2p-kpi + 12-loss-aversion-bm + 13-variable-ratio-ethics
8. 퍼블리싱 적합성 → 14-publisher-greenlight
```

각 단계에서 **각 이론 문서의 "GDD 평가 체크리스트" 섹션**을 회수하여 ✅/⚠️/❌로 채점한다.

## 작성 워크플로우 (Creation Workflow)

새 GDD를 작성/보강할 때 권장 시퀀스:

```
1. 비전 압축 → 00-living-document(One-pager 템플릿)
2. 타겟 동기 설계 → 01-sdt-pens(욕구 매핑) → 02-bartle-hexad(타겟 유형 분포)
3. 코어 루프 설계 → 04-flow-theory(channel) + 08-mda-rmda(M↔A 역추적)
4. 튜토리얼/UI 설계 → 05-cognitive-load + 06-laws-of-ux + 07-ftue-onboarding
5. 동인 강화/보완 → 03-octalysis(8 Core Drives 점검)
6. 프로덕션 계획 → 10-vertical-slice-scope(MoSCoW + 마일스톤)
7. KPI/BM 설계 → 11-f2p-kpi + 12-loss-aversion-bm + 13-variable-ratio-ethics(윤리 검토)
8. 피치 준비 → 14-publisher-greenlight
```

## 표준 frontmatter 스키마

각 이론 문서는 동일한 frontmatter를 사용한다:

```yaml
---
title: <이론 한국어명>
collection: gdd-evaluation
axis: A | B | C | D | E
theory_id: <slug>
keywords: [<영문 키워드>...]
applies_to: [evaluation, creation]
related: [<관련 theory_id>...]
last_updated: 2026-04-28
---
```

`axis` 필터로 특정 평가 축 전체를, `theory_id` 직접 매칭으로 단일 이론을, `keywords`로 자유 검색을 지원한다.

## 컬렉션 적재 가이드

추후 RAG 시스템 연결 시 적재 절차 별도 정리. (현재 RAG 미연결)

## 관련 외부 문서

- `../gdd_psychology_integrated_analysis.md` — 본 컬렉션의 통합 요약본(전체 5축 모델 한 문서로 압축)
- `../gddmake.md` — 본 작업의 출발점이 된 원본 요약 보고서
- `../bb3-application/bb3-application-notes.md` — BB3(Bubble Burst 3) 캐주얼/라이브 운영 적용 메모
