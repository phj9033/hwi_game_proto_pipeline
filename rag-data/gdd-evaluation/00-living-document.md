---
title: 살아있는 GDD(Living Document) — 모던 게임기획서 작성·평가 원칙
collection: gdd-evaluation
axis: A
theory_id: living-document
keywords: [GDD, living-document, MoSCoW, design-pillars, vision-statement, modular-documentation, scope-management, collaboration]
applies_to: [evaluation, creation]
related: [10-vertical-slice-scope, 14-publisher-greenlight]
last_updated: 2026-04-28
---

# 살아있는 GDD(Living Document) — 모던 게임기획서 작성·평가 원칙

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: A — 구조적 완성도 (Structure)
- **이론 ID (Theory ID)**: living-document
- **이론명**: 살아있는 GDD / Modern Living Document
- **분류 키워드**: axis-A, structure, GDD-structure, document-quality
- **이론 키워드**: GDD, living-document, MoSCoW, design-pillars, vision-statement, modular-documentation, scope-management, collaboration
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 10-vertical-slice-scope, 14-publisher-greenlight

## TL;DR

전통적 100페이지짜리 워드 문서형 GDD는 사실상 폐기되었다. 현대 GDD는 **20~40페이지 모듈형 + 일일 갱신 + 협업 기반 + 시각 자료 우선**으로 정의되며, "거짓말하지 않는 단일 진실원(Single Source of Truth)"이라는 점이 가장 중요하다. 평가자는 문서의 양이 아니라 **신선도(Recency)·접근성(Accessibility)·소유권(Ownership)·정렬도(Alignment)**를 본다.

## 1. 배경 — 왜 전통적 GDD는 무너졌는가

| 실패 원인 | 설명 |
|----------|------|
| **유지비용** | 게임은 매주 변하지만 100쪽 PDF는 연 1~2회만 업데이트됨 → "거짓말하는 문서" |
| **접근성** | 공유 드라이브에 잠긴 거대 PDF는 검색·코멘트·협업 불가 |
| **참여 부재** | 1인이 작성하고 위에서 위임 → 팀원 주인의식 없음 |
| **시각 빈약** | 텍스트 위주 → 다이내믹·UI·플로우가 전달되지 않음 |
| **스코프 폭주** | 우선순위 없는 위시리스트 → Scope Creep의 직접 원인 |

> 인디 스튜디오 70% 이상이 "스코프 과대"를 실패 원인으로 꼽으며, 그 첫 단계는 거의 항상 미숙한 GDD다.

## 2. 모던 GDD의 4가지 정의 속성

### 2.1 Living Document(살아있는 문서)

- 매일~매주 단위로 갱신.
- 변경 이력이 추적 가능(Notion/Confluence 페이지 히스토리, Git PR).
- "동결 시점"이 없으며, 출시 시점에도 갱신된다.

### 2.2 Modular(모듈형)

- 섹션이 독립적으로 갱신 가능.
- 코어 루프 / 경제 / 레벨 디자인 / UX / 기술 / 프로덕션이 각각의 페이지/문서로 분리.
- 한 섹션이 길어지면 또 분기(예: `Economy.md` → `Economy/Currency.md`, `Economy/Sinks.md`).

### 2.3 Collaborative(협업 기반)

- 모든 분야(아트·프로그래머·QA·BM·운영) 참여.
- 코멘트·리뷰가 즉시 가능한 도구 사용.
- "디렉터 위임"이 아니라 "팀 합의"의 기록.

### 2.4 Visual-first(시각 우선)

- 와이어프레임, 플로우차트, 콘셉트 아트가 텍스트와 동등.
- 메커니즘은 가능하면 동영상/GIF/다이어그램으로 보강.
- "예쁜 이미지"가 아닌 "이해를 돕는 시각화" 기준.

## 3. 핵심 구성 섹션 — 12 항목 표준

| # | 섹션 | 필수 포함 | 평가 포인트 |
|---|------|----------|-----------|
| 1 | **One-Sentence Pitch** | 25단어 이내, 장르·플랫폼·USP 압축 | 낯선 사람에게 한 호흡으로 설명되는가 |
| 2 | **Design Pillars (3개)** | 모든 의사결정의 기준 가치 3가지 | 기능 추가 시 기둥에 부합 여부 즉답 가능한가 |
| 3 | **Core Loop & Meta Loop** | 30초~5분 코어, 1일~1주 메타 | 각 루프가 어떤 감정을 유발하고 어떻게 연결되는가 |
| 4 | **Player Fantasy & TG** | 페르소나, 타겟 유형 분포 | 모순(예: 하드코어+라이트)이 없는가 |
| 5 | **Mechanics Spec** | 입력→상태 변화→출력, 엣지 케이스 | 디자이너 없이 프로그래머가 구현 가능한가 |
| 6 | **Progression & Economy** | 화폐·자원 흐름도, 성장 곡선 | 인플레/디플레 시나리오 명시되었는가 |
| 7 | **UX/UI Wireframes** | 정보 우선순위, HUD 그리드, 터치 영역 | UX 법칙(Fitts·Hick·Miller) 검토되었는가 |
| 8 | **Narrative Beats** | 도입·전개·절정·결말 + 분기 | 분기가 메커니즘적으로 차별화되는가 |
| 9 | **Technical Plan** | 엔진·플랫폼 한계, 의존성, 리스크/대안 | 핵심 기술 실패 시 Plan B 있는가 |
| 10 | **Production Plan** | 마일스톤, MoSCoW 우선순위 | 각 마일스톤의 'Done 정의'가 객관적인가 |
| 11 | **KPI & BM Strategy** | 잔존/매출 목표, BM 모델, ROI 시뮬 | 허영 지표가 아닌 실수익성 모델인가 |
| 12 | **Risks & Mitigations** | 기술·시장·인력·법적 리스크 | 리스크별 대응 비용·시나리오가 정량화되었는가 |

## 4. One-Page Pitch 템플릿(작성용)

```
# <게임 제목>

**한 줄 피치**: <25단어 이내 설명>

**장르 / 플랫폼**: <장르> / <플랫폼>
**타겟 오디언스**: <연령·성향·핵심 페르소나 1~2명>

**Design Pillars (3)**:
1. <기둥 A — 1줄 설명>
2. <기둥 B — 1줄 설명>
3. <기둥 C — 1줄 설명>

**핵심 USP (3)**:
- <차별점 A>
- <차별점 B>
- <차별점 C>

**경쟁/벤치마크**:
- 성공작 X와 비슷하지만 ___
- 평작 Y의 ___ 문제를 ___로 해결

**의도한 핵심 감정 (Aesthetics)**:
- <Sensation/Fantasy/Challenge/Discovery 등 1~3개>

**리스크 Top 3**:
1. ...
2. ...
3. ...
```

## 5. Design Pillars 작성 원칙

- **3개 권장**: 너무 적으면 모호, 너무 많으면 의사결정 기준이 무너짐.
- **동사 + 형용사**로 작성: "전투는 즉각적으로 보상한다", "탐험은 항상 의미 있는 발견으로 끝난다".
- **트레이드오프를 내장**: "그래픽 폴리시 < 반응성"처럼 무엇을 포기하는지 명시되면 강력.
- **테스트 가능**: "이 기능이 기둥 X에 부합하는가?"에 yes/no로 답할 수 있어야 함.

## 6. MoSCoW — 우선순위 표기 표준

| 카테고리 | 정의 | GDD 표기 예 |
|---------|------|-------------|
| **Must** | 없으면 게임이 성립 안 됨 | 코어 루프, 핵심 컨트롤 |
| **Should** | 없으면 약속이 깨짐 | 핵심 메타, 첫 시즌 콘텐츠 |
| **Could** | 있으면 좋음 | 부가 미니게임, 컬렉션 |
| **Won't (this version)** | 차기 검토 | 모드 지원, 멀티플레이 |

> "Won't"를 명시적으로 두는 것이 핵심이다. 명시되지 않은 아이디어는 슬며시 다시 등장해 스코프를 잠식한다.

## 7. GDD 평가 체크리스트

### 7.1 신선도 (Recency)

- ✅ 마지막 수정일이 30일 이내인가
- ✅ 최근 14일 내 코멘트/리뷰가 있는가
- ✅ 최근 빌드와 GDD 내용이 일치하는가(스팟 체크)
- ❌ "수정일 미상" 또는 "수정 이력 추적 불가"

### 7.2 접근성 (Accessibility)

- ✅ 검색 가능한 도구에 호스팅되었는가(Notion/Confluence/Git)
- ✅ 팀 누구나 30초 안에 핵심 정보를 찾을 수 있는가
- ✅ 비기술 직군(아트/사운드)도 이해할 수 있게 시각화되었는가
- ❌ "공유 드라이브에 PDF 1개"

### 7.3 소유권 (Ownership)

- ✅ 각 섹션에 담당자가 명시되었는가
- ✅ 변경 시 리뷰 프로세스가 정의되었는가
- ✅ 팀원 인터뷰 시 "내 문서이기도 하다"고 답하는가
- ❌ "디렉터가 다 씀, 우린 본 적 없음"

### 7.4 정렬도 (Alignment)

- ✅ 한 줄 피치, 디자인 기둥, 핵심 메커니즘이 서로 모순되지 않는가
- ✅ 의도한 감정(Aesthetics)이 메커니즘으로부터 자연스럽게 도출되는가
- ✅ KPI 목표가 시스템 설계와 연결되어 있는가
- ❌ "비전은 코어 게임플레이지만 실제 비중은 메타에 80%"

### 7.5 신호 비율 (Signal vs. Noise)

- ✅ "TBD" 비율이 30% 미만인가
- ✅ 추상어(혁신, 압도적, 직관적)가 정량 지표로 뒷받침되는가
- ✅ 코드 수준 명세(엣지 케이스, 실패 상태)가 포함되었는가
- ❌ "멋진 연출"만 있고 어떤 멋인지 묘사 부재

## 8. 흔한 실패 패턴(Anti-patterns)

### 8.1 Wish-list GDD

- 우선순위 없이 모든 기능 나열.
- "MoSCoW 분류 없음" + "Won't this version 빈칸".
- → 출시까지 기능 절반은 빠지고, 기획자도 무엇이 살아남았는지 모름.

### 8.2 Monolithic PDF

- 1개 거대 문서, 검색·코멘트·갱신 어려움.
- → 빌드와 GDD가 점점 다른 게임이 됨.

### 8.3 Top-down Decree

- 디렉터/기획팀 1인 작성, 다른 직군은 "보고만 받음".
- → 협업 도구라기보다 "지시문" 형태. 팀 갈등의 씨앗.

### 8.4 Buzzword GDD

- "혁신적 비선형 서사", "압도적 몰입감" 같은 추상어 가득.
- 정량·구체 명세 부재.
- → 평가자/퍼블리셔의 첫 의심 신호.

### 8.5 Snapshot Trap

- 완성 후 "동결" 선언.
- → 빌드 변경이 GDD에 반영되지 않음. 살아있지 않은 문서.

### 8.6 Half-finished Feature Stubs

- "이 부분은 추후에"가 핵심 메커니즘 옆에 붙어 있음.
- → 평가자에게 "이 게임은 아직 검증되지 않은 상상"이라는 신호.

## 9. 도구 권장(2025~2026)

| 도구 | 강점 | 약점 |
|------|------|------|
| **Notion** | 협업·검색·임베드 우수, 모듈형 | 대규모 시 성능 저하 |
| **Confluence** | 엔터프라이즈, JIRA 연계 | UX가 다소 무겁고 학습 비용 |
| **Codecks** | 게임 개발 특화 카드 시스템 | 학습 곡선 |
| **GitBook / Outline** | 문서 중심, 마크다운 친화 | 풍부한 시각 통합은 약함 |
| **Google Docs** | 즉시성, 코멘트 | 모듈성·검색 부족 |

## 10. RAG 활용 가이드(평가/작성 용도)

- **평가 시**: 본 문서의 §7 체크리스트와 함께 평가할 GDD 본문을 RAG에 함께 넣고 "Recency/Accessibility/Ownership/Alignment 각각 점수"를 요청.
- **작성 시**: §3의 12 섹션 표를 토대로 비어 있는 항목을 식별, §4 One-Page Pitch부터 시작.
- **검수 시**: 안티패턴 §8과 GDD를 비교하여 해당 패턴 여부를 진단.

## 11. 참고 문헌

- [How to Write a Game Design Document — GitBook](https://www.gitbook.com/blog/how-to-write-a-game-design-document)
- [Game Design Document: Definition, Template, Example — GameDesignSkills](https://gamedesignskills.com/game-design/document/)
- [Writing Modern Game Design Documents — Codecks](https://www.codecks.io/blog/writing-modern-game-design-documents/)
- [From GDD Graveyard to Living Document — Wayline](https://www.wayline.io/blog/lean-gdd-game-design-documentation)
- [Game Design Document Steps & Best Practices 2025 — Document360](https://document360.com/blog/write-game-design-document/)
- [Game Design Document — Wikipedia](https://en.wikipedia.org/wiki/Game_design_document)
- [Free Game Design Document Template — Indie Game Academy](https://indiegameacademy.com/free-game-design-document-template-how-to-guide/)
- [Game Design Document Template and Examples — Nuclino](https://www.nuclino.com/articles/game-design-document-template)
