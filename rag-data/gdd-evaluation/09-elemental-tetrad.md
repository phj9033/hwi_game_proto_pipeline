---
title: Elemental Tetrad — Schell의 4요소 통합 게임 디자인 프레임워크
collection: gdd-evaluation
axis: D
theory_id: elemental-tetrad
keywords: [Elemental-Tetrad, Jesse-Schell, mechanics, story, aesthetics, technology, art-of-game-design, holographic-vision]
applies_to: [evaluation, creation]
related: [08-mda-rmda]
last_updated: 2026-04-28
---

# Elemental Tetrad — Schell의 4요소 통합 게임 디자인 프레임워크

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: D — 시스템 정합성 (Coherence)
- **이론 ID (Theory ID)**: elemental-tetrad
- **이론명**: Elemental Tetrad (Schell)
- **분류 키워드**: axis-D, coherence, four-elements, mechanics-story-aesthetics-technology, holographic-vision
- **이론 키워드**: Elemental-Tetrad, Jesse-Schell, mechanics, story, aesthetics, technology, art-of-game-design, holographic-vision
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 08-mda-rmda

## TL;DR

Jesse Schell이 *The Art of Game Design: A Book of Lenses* (2008)에서 제시한 Elemental Tetrad는 게임을 **Mechanics(규칙)·Story(서사)·Aesthetics(감각)·Technology(기술)** 4 요소로 분해하는 프레임워크다. MDA의 한계 — 서사·기술 미포함 — 를 보완하며, **각 요소가 서로를 지지해야 좋은 게임**이라는 통합 원칙을 강조한다. 평가자는 GDD가 4 요소 모두를 균형 있게 다루는지, 한 요소가 다른 3개를 지지·강화하는지를 본다.

## 1. 이론 배경

### 1.1 출처

- *The Art of Game Design: A Book of Lenses* by Jesse Schell (2008, 2014, 2019).
- 100개 이상의 "렌즈(Lenses)" 카드 시스템.
- The Elemental Tetrad는 그중 1개 렌즈, 가장 자주 인용됨.

### 1.2 MDA에 대한 보완

- MDA는 Aesthetics를 다루지만 Story·Technology를 별도로 모델링하지 않음.
- Schell의 통찰: Story와 Technology도 게임의 본질 요소.
- 4축 모두 동등하게 중요.

## 2. 4 요소

### 2.1 Mechanics (메커니즘)

> "게임의 절차와 규칙."

Schell은 6 종으로 분해:
- **Space**: 게임이 펼쳐지는 공간(가상·물리).
- **Objects**: 플레이어가 사용하는 도구·아이템·캐릭터.
- **Actions**: 플레이어 행동.
- **Rules**: 게임 환경 규칙.
- **Skills**: 신체·정신·사회적 능력.
- **Chance**: 무작위성·불확실성.

### 2.2 Story (서사)

> "플롯·캐릭터·세계로 만드는 이야기."

- 게임에 서사가 항상 필수는 아님(*Tetris*, *Go* 등 추상 게임).
- 그러나 서사가 있는 경우 다른 요소를 강하게 지지함.
- 분기·다중 결말 등 메커니즘적 서사도 포함.

### 2.3 Aesthetics (미학)

> "보이고, 들리고, 만져지고, 맛보고, 느껴지는 것."

- 시청각, 햅틱, 음악, UI의 시각 스타일.
- 가장 직접적으로 플레이어 감각에 도달.
- 다른 3 요소가 어떻게 인지되는지를 결정.

### 2.4 Technology (기술)

> "게임을 가능하게 하는 하드웨어·소프트웨어·물리적 부품."

- 엔진·플랫폼·하드웨어 한계.
- 두 종류:
  - **Foundational Technology**: 새로운 경험을 가능하게 함(VR, 고출력 GPU).
  - **Decorational Technology**: 기존 경험을 향상(고해상도 텍스처).

## 3. 가시성 위계

```
        Aesthetics ← 가시(플레이어가 직접 인지)
        ├── 
        Mechanics ← 부분 가시(규칙은 학습되어야 인지)
        │
        Story ← 부분 가시(이야기는 시간을 두고 전달)
        │
        Technology ← 비가시(플레이어가 거의 인지하지 않음)
```

- Aesthetics는 첫 인상에 가장 큰 영향.
- Technology는 잘 작동할 때는 보이지 않고, 망가질 때만 보임.
- 디자이너는 가시·비가시 양면의 균형을 봐야 한다 — Schell은 이를 "Holographic Vision"이라 부름.

## 4. 4 요소의 상호 지지

### 4.1 *Silent Hill*의 안개 — 통합 사례

- **Technology 한계**: 당시 PS1 GPU의 드로 디스턴스 부족.
- **Mechanic 활용**: 안개로 시야 제한 → 적이 가까이 와야 보임.
- **Aesthetic 효과**: 공포·긴장·불안.
- **Story 강화**: 미스터리한 마을의 분위기.

→ 기술적 약점을 4 요소 통합으로 강점으로 전환한 명작 사례.

### 4.2 *Portal*의 양자 도약

- **Mechanic**: 포털 이동.
- **Technology**: 실시간 렌더링, 물리 엔진.
- **Story**: GLaDOS의 광기, 테스트 챔버의 의미.
- **Aesthetic**: 깨끗한 시각, 차가운 사운드.

→ 4 요소가 서로를 지지하며 상승 작용.

## 5. GDD 평가 체크리스트

### 5.1 4 요소 균형

- ✅ Mechanics 명세가 코드 수준으로 작성되었는가
- ✅ Story 또는 그 의도적 부재가 명시되었는가
- ✅ Aesthetics(시청각·UI 스타일)가 콘셉트 아트·무드보드와 함께 제시되었는가
- ✅ Technology 선택의 이유와 한계가 명시되었는가
- ⚠️ 한 요소만 압도적으로 강조 — 나머지는 보강 부재
- ❌ 한 요소가 사실상 부재 (예: 서사 단순 텍스트, 기술 선택 막연)

### 5.2 상호 지지

- ✅ 각 요소가 다른 요소를 어떻게 지원하는지 명시되어 있는가
- ✅ 기술적 한계가 메커니즘·미학에 어떻게 반영되는지 다루는가
- ⚠️ 요소 간 연결이 자의적 ("아트는 멋지게, 기술은 알아서")
- ❌ 요소 간 모순 (예: 사실주의 의도 + 픽셀 아트 + 저사양 모바일)

### 5.3 가시·비가시 균형

- ✅ 사용자가 직접 보는 Aesthetics에 충분한 폴리시 시간 배정
- ✅ 비가시 Technology의 안정성·성능에 대한 계획
- ⚠️ Aesthetics 폴리시만 강조, Technology 결함이 노출

## 6. 작성 가이드

### 6.1 4 요소 매트릭스

GDD에 다음 표를 명시 권장:

```markdown
## Elemental Tetrad

| 요소 | 핵심 정의 | 다른 요소 지지 |
|------|---------|------------|
| **Mechanics** | 코어 루프 규칙 + AI 시스템 | Story의 분기를 메커니즘적으로 차별화. Aesthetics의 폴리시를 지원. |
| **Story** | 시즌별 메인 서사 + 캐릭터 호감도 | Mechanics에 분기 트리거 제공. Aesthetics에 분위기 가이드. |
| **Aesthetics** | 셀 셰이딩 + 오케스트라 사운드 | Story의 정서를 시청각으로 강화. Mechanics 피드백을 시각화. |
| **Technology** | Unity 6 / 모바일 60FPS / 클라우드 세이브 | Mechanics 복잡도의 한계. Aesthetics 폴리시의 천장. |
```

### 6.2 트레이드오프 명시

```markdown
## Tetrad Trade-offs

- Mechanics 복잡도 ↑ → Technology 성능 부담 ↑ → Aesthetics 폴리시 ↓
- Story 분기 ↑ → 콘텐츠 양 ↑ → 양산 비용 ↑
- Aesthetics 사실주의 → Technology 사양 요구 ↑ → 모바일 호환 어려움

따라서 본 프로젝트는:
- Mechanics 깊이는 보존하되 동시 처리 객체 수 제한
- Story는 메인 분기 3개로 한정, 사이드 스토리는 라이브 운영
- Aesthetics는 양식화된 셀 셰이딩으로 사양 부담 완화
```

## 7. MDA vs Tetrad — 어느 것을 쓸까

| 기준 | MDA 적합 | Tetrad 적합 |
|------|---------|------------|
| 추상 게임(보드, 퍼즐) | ✅ | △ (Story 약함) |
| 내러티브 게임(RPG, 어드벤처) | △ | ✅ |
| 기술 의존도 높음(VR, AAA) | △ | ✅ |
| 학술 분석 | ✅ | △ |
| 산업 GDD 작성 | △ | ✅ (산문 친화) |

**권장**: 두 프레임워크는 상호 배타가 아니라 보완. MDA로 메커니즘↔감정 정합성을 검증하고, Tetrad로 서사·기술까지 포함한 종합 평가.

## 8. 안티패턴

- **단축 시각**: Aesthetics만 보고 다른 3개 무시.
- **요소 격리**: 4 요소가 따로 작업되어 출시 시점에 어긋남.
- **Story 후순위**: 메커니즘 완성 후 서사를 덮어 씌움 → 어색함.
- **Technology 막판 검토**: 양산 후반에야 사양 부족 발견.
- **Aesthetic 유행 추종**: 게임 정체성 무시한 트렌드 디자인.

## 9. 다른 이론과의 관계

- **MDA**: Mechanics와 Aesthetics는 동일 정의, Tetrad가 Story·Technology 추가.
- **RMDA**: Mechanics를 Entity/Responsibility로 분리한 것은 Tetrad의 Mechanics 6 종 분해와 친화적.
- **Living Document**: GDD의 4 요소 섹션이 모두 살아있는 문서로 유지되어야.
- **Vertical Slice**: 4 요소 모두 통합된 1~2 스테이지를 보여주는 것이 Vertical Slice의 목적.

## 10. 참고 문헌

- [Elemental Tetrad — Wikipedia](https://en.wikipedia.org/wiki/Elemental_tetrad)
- [The Elemental Tetrad — Skeleton Code Machine](https://www.skeletoncodemachine.com/p/elemental-tetrad)
- [Analysis of Game Design Framework Through Elemental Tetrad — ResearchGate](https://www.researchgate.net/publication/360245512_Analysis_of_Game_Design_Framework_Through_Elemental_Tetrad)
- [The Art of Game Design: A Book of Lenses — Game Studies Wiki](https://game-studies.fandom.com/wiki/The_Art_of_Game_Design:_A_Book_of_Lenses)
- [The Elemental Tetrad: Connecting Mechanics, Story, Aesthetics, Technology — Get Creative Today](https://getcreativetoday.com/the-elemental-tetrad-connecting-mechanics-story-aesthetics-and-technology/)
- [The Elements of Game Design — Lakitu's Dev Cartridge](https://lakitusdevcartridge.wordpress.com/2012/07/05/the-elements-of-game-design/)
- [A Working Theory of Game Design — First Person Scholar](https://www.firstpersonscholar.com/a-working-theory-of-game-design/)
- Schell, J. (2008/2014/2019). *The Art of Game Design: A Book of Lenses.* CRC Press.
