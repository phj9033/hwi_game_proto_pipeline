---
title: MDA & RMDA — Mechanics Dynamics Aesthetics 통합 분석 프레임워크
collection: gdd-evaluation
axis: D
theory_id: mda-rmda
keywords: [MDA, RMDA, Hunicke, LeBlanc, Zubek, mechanics, dynamics, aesthetics, eight-kinds-of-fun, second-order-design, entities, responsibilities]
applies_to: [evaluation, creation]
related: [09-elemental-tetrad, 04-flow-theory, 01-sdt-pens]
last_updated: 2026-04-28
---

# MDA & RMDA — Mechanics Dynamics Aesthetics 통합 분석 프레임워크

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: D — 시스템 정합성 (Coherence)
- **이론 ID (Theory ID)**: mda-rmda
- **이론명**: MDA Framework + RMDA 재정의
- **분류 키워드**: axis-D, coherence, mechanics-aesthetics-mapping, system-design, second-order-design
- **이론 키워드**: MDA, RMDA, Hunicke, LeBlanc, Zubek, mechanics, dynamics, aesthetics, eight-kinds-of-fun, second-order-design, entities, responsibilities
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 09-elemental-tetrad, 04-flow-theory, 01-sdt-pens

## TL;DR

Robin Hunicke, Marc LeBlanc, Robert Zubek(2004)의 MDA 프레임워크는 게임을 **Mechanics(규칙·데이터)**, **Dynamics(런타임 행동)**, **Aesthetics(감정 결과)** 3계층으로 분리해 설계와 분석을 가능케 한 산업 표준이다. 핵심 통찰은 "디자이너는 M→D→A로 작업하지만 플레이어는 A→D→M으로 인식"하는 비대칭성. 이 비대칭성이 GDD가 메우는 인지적 계약이다. 후속 RMDA(2021)는 Mechanics를 **Entities(객체)**와 **Responsibilities(책임)**로 재정의해 코드 수준 정합성을 보강했다.

## 1. 이론 배경

### 1.1 탄생

- 2001~2004년 GDC(Game Developers Conference)의 Game Design and Tuning Workshop에서 발표·교육.
- 디지털 게임 디자이너 3인의 공동 작업.
- 학술·산업의 다리 역할 — 비평가·연구자·개발자가 같은 어휘 공유.

### 1.2 동기

- 게임 디자인은 "Second-order Design Problem" — 디자이너가 직접 만드는 것은 규칙, 플레이어 경험은 간접 결과.
- 이 간극을 명시화하지 않으면 의도와 결과가 어긋남.

## 2. 3계층 구조

### 2.1 Mechanics (M)

> 게임의 기본 구성 요소 — 규칙, 데이터 구조, 알고리즘.

- 디자이너가 **직접** 만들고 통제.
- 예: 캐릭터 이동 속도, 공격 대미지, 점수 계산식, AI 결정 로직.

### 2.2 Dynamics (D)

> Mechanics가 플레이어 입력과 만나 발생하는 런타임 행동.

- 디자이너의 **간접** 영향 영역.
- 예: 적의 시야를 피해 우회하는 잠입 전략, 팀의 역할 분담, 메타 빌드 출현.

### 2.3 Aesthetics (A)

> Dynamics가 만들어내는 플레이어의 감정적 결과.

- 디자이너가 **의도만** 가능, 직접 통제 불가.
- 예: 긴장감, 정복감, 발견의 기쁨, 동료애.

### 2.4 비대칭의 의미

```
디자이너 시점:  Mechanics → Dynamics → Aesthetics
플레이어 시점:  Aesthetics ← Dynamics ← Mechanics
```

- 디자이너는 메커니즘을 짜며 감정을 의도.
- 플레이어는 감정을 먼저 느끼고 그 기저의 규칙을 역추적.
- 두 시점 모두를 보유한 디자이너가 좋은 GDD를 쓴다.

## 3. 8가지 재미(Aesthetics) — Eight Kinds of Fun

### 3.1 정의

| 약식 명 | 풀이 | 메커니즘 예 |
|---------|------|-------------|
| **Sensation** | Game as sense-pleasure | 입자 효과, 셰이크, 사운드 큐 |
| **Fantasy** | Game as make-believe | 로어, 의상, 역할극 |
| **Narrative** | Game as drama | 분기 대화, 컷신, 성장 서사 |
| **Challenge** | Game as obstacle course | 정밀 판정 전투, 정교한 퍼즐 |
| **Fellowship** | Game as social framework | 길드, 협동, 채팅 |
| **Discovery** | Game as uncharted territory | 비선형 맵, 수집, 비밀 |
| **Expression** | Game as self-discovery | 커스터마이징, 빌드, 사용자 콘텐츠 |
| **Submission** | Game as pastime | 일일 루틴, 자동전투, 의례 |
| (**Competition**)*9번째* | — | 랭킹, PvP |

### 3.2 게임별 Aesthetic 조합

- *Charades*: Fellowship, Expression, Challenge.
- *Quake*: Challenge, Sensation, Competition, Fantasy.
- *The Sims*: Discovery, Fantasy, Expression, Narrative.
- *Stardew Valley*: Submission, Discovery, Expression, Fellowship.

> 게임은 보통 2~4개 Aesthetic을 다른 비중으로 추구. "재미의 단일 공식"은 없다.

### 3.3 한계

- 자의적 분류라는 비판 — Aesthetic 8개가 망라적이지 않음.
- 게임마다 독자적 감정(예: *Journey*의 무명적 동행)이 있음.

## 4. 정합성 검증 — M↔A 역추적

### 4.1 검증 절차

1. GDD에서 의도한 Aesthetic 1~3개 추출.
2. 그 Aesthetic을 만들 Dynamic을 상상.
3. 그 Dynamic이 어떤 Mechanic에서 나오는지 역추적.
4. 실제 GDD의 Mechanic이 그것과 일치하는가 확인.

### 4.2 반례 — 자기 모순 GDD

> **공포 게임의 자기 모순**
>
> - **의도 A**: Fear, Tension(공포·긴장)
> - **실제 M**: 풍부한 탄약, 강력한 무기
> - **결과 D**: 적극적 사냥
> - **실제 A**: Power Fantasy(반대 감정)
>
> → MDA 정합성 실패. *Resident Evil 4*는 의도적으로 회전 사격 제한·재장전 시간으로 모순 회피.

> **협동 게임의 사회 파괴**
>
> - **의도 A**: Fellowship
> - **실제 M**: PvP 보상 ≫ 협동 보상
> - **결과 D**: 트롤링·킬 스틸
> - **실제 A**: Killers의 Competition만 강화
>
> → 보상 체계와 의도 감정의 불일치.

### 4.3 Cascading Effect

- 메커니즘 1개 변경이 Dynamic·Aesthetic 전체에 파급.
- 예: "스킬 쿨다운 5초 → 3초"
  - Dynamic: 스킬 사용 빈도 ↑, 콤보 가능
  - Aesthetic: 통제감(Sensation·Challenge) ↑
  - 동시에: 보스의 적정 난이도 깨짐 → Boredom 위험

## 5. RMDA — Redefining MDA

### 5.1 등장 배경

- MDA 비판:
  - Mechanics 정의가 너무 추상.
  - 실제 디자인 작업에 직접 적용 어려움.
- 학술 논문(MDPI Information, 2021)에서 제안.

### 5.2 핵심 — Mechanics를 둘로 분리

| 구성 | 정의 | 예 |
|------|------|----|
| **Entities (객체)** | 게임 내 데이터 단위 | 캐릭터, 적, 아이템, 환경 |
| **Responsibilities (책임)** | 각 엔티티의 동작·규칙 | "적은 시야 안 플레이어를 추격", "아이템은 사용 시 HP +50" |

### 5.3 RMDA의 가치

- 코드 수준 정합성: Entity는 클래스, Responsibility는 메서드와 매핑.
- 명세 작성이 자연스러워짐.
- 디자이너 ↔ 프로그래머 소통이 더 명확.

### 5.4 GDD 적용

```yaml
# Entity 명세
Enemy:
  type: Goblin
  hp: 100
  view_range: 8m
  
  # Responsibility 명세
  responsibilities:
    - detect_player_in_view_range
    - chase_if_detected
    - attack_if_in_melee
    - flee_if_hp_below_30%
```

## 6. GDD 평가 체크리스트

### 6.1 의도 명시

- ✅ 핵심 Aesthetic 1~3개가 명시되어 있는가
- ✅ 각 Aesthetic의 우선순위(주/부)가 결정되었는가
- ⚠️ 7개 이상의 Aesthetic을 동시에 추구
- ❌ Aesthetic 명시 부재, "재미있을 것" 외 없음

### 6.2 메커니즘↔감정 정합

- ✅ 의도 Aesthetic이 실제 Mechanic으로부터 자연스럽게 도출되는가
- ✅ 보상 구조가 의도 감정과 일치(예: Fellowship 의도면 협동 > PvP 보상)
- ⚠️ 메커니즘은 풍부한데 의도 감정과 약한 연결
- ❌ 의도와 정반대 감정을 유발할 메커니즘

### 6.3 RMDA 정합성

- ✅ 핵심 Entity(캐릭터·적·아이템)가 명시되었는가
- ✅ 각 Entity의 Responsibility가 코드 수준으로 작성되었는가
- ⚠️ Entity는 있지만 Responsibility가 산문적
- ❌ 메커니즘 명세가 "전투는 재미있게"

### 6.4 Cascading 분석

- ✅ 핵심 메커니즘 변경 시 Dynamic·Aesthetic 영향 분석 포함
- ✅ 시뮬레이션·플레이테스트로 의도 감정 검증
- ⚠️ 변경 영향 분석 부재

## 7. 작성 가이드

### 7.1 GDD 시작 시 — Aesthetic 우선

```markdown
## Game Vision

**의도한 핵심 감정 (Aesthetics)**:
1. Challenge (주) — 매 도전이 의미 있고 정복 가능
2. Discovery (부) — 매 시즌 새로운 비밀과 콘텐츠
3. Fellowship (부) — 길드 협동의 즐거움

**Aesthetic을 유발할 핵심 메커니즘**:
- Challenge → DDA + 정밀 판정 전투 + 마스터리 도전
- Discovery → 비선형 맵 + 수집 도감 + 시즌 갱신
- Fellowship → 길드 시스템 + 협동 콘텐츠 + 공유 보상
```

### 7.2 메커니즘 변경 시 체크 — Cascading 분석 표

| 변경 | Dynamic 영향 | Aesthetic 영향 | 위험 |
|------|------------|--------------|------|
| 스킬 쿨다운 5→3초 | 콤보 가능 | Sensation ↑, Challenge 변화 | 보스 난이도 재조정 필요 |

### 7.3 RMDA 명세 — Entity별 1페이지

각 핵심 Entity에 대해:
- 데이터 속성
- 책임(메서드 수준)
- 다른 Entity와의 관계
- 평가 메트릭(이 Entity가 어떤 Aesthetic 기여?)

## 8. 안티패턴

- **Aesthetic 모호**: "재미있을 것" 외 의도 감정 부재.
- **메커니즘 우선 사고**: 시스템 디자인이 화려하지만 어떤 감정을 위한 것인지 모름.
- **모순 보상**: 의도 감정과 반대를 강화하는 보상.
- **Cascading 무지**: 메커니즘 변경의 파급 미고려.
- **Dynamics 단계 생략**: M에서 A로 직접 점프, 실제 플레이어 행동 고려 부재.
- **Aesthetic 너무 많음**: 8개 모두 추구 → 정체성·매력 흐려짐.

## 9. 다른 이론과의 관계

- **Schell Tetrad**: MDA + Story + Technology로 4축 확장.
- **SDT**: Aesthetic Challenge ↔ Competence, Discovery ↔ Autonomy, Fellowship ↔ Relatedness.
- **Bartle**: Achiever ↔ Challenge, Explorer ↔ Discovery, Socializer ↔ Fellowship, Killer ↔ Competition.
- **Flow**: Challenge Aesthetic의 시간적 곡선이 Flow 채널.

## 10. 참고 문헌

- [Hunicke, LeBlanc, Zubek — MDA: A Formal Approach to Game Design (PDF)](https://users.cs.northwestern.edu/~hunicke/MDA.pdf)
- [MDA Framework — Wikipedia](https://en.wikipedia.org/wiki/MDA_framework)
- [Redefining the MDA Framework (RMDA) — MDPI](https://www.mdpi.com/2078-2489/12/10/395)
- [MDA Framework — Deliberate Game Design](https://deliberategamedesign.com/mda-framework/)
- [The MDA-model: Mechanics, Dynamics, Aesthetics — Mix](https://mixmusiceducationplatform.eu/en/mechanics-dynamics-aesthetics/)
- [MDA Game Design Framework: Meaning, Model, Examples — GameDesignSkills](https://gamedesignskills.com/game-design/mda/)
- [Revisiting the MDA Framework — Game Developer](https://www.gamedeveloper.com/design/revisiting-the-mda-framework)
- [MDA Framework — ANDREW FISCHER](https://andrewfischergames.com/blog/mda-framework)
