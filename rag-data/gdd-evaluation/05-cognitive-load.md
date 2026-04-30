---
title: 인지 부하 이론(Cognitive Load Theory) — 학습·튜토리얼 설계의 골격
collection: gdd-evaluation
axis: C
theory_id: cognitive-load
keywords: [cognitive-load-theory, CLT, Sweller, intrinsic-load, extraneous-load, germane-load, working-memory, schema, worked-example, tutorial-design]
applies_to: [evaluation, creation]
related: [04-flow-theory, 06-laws-of-ux, 07-ftue-onboarding]
last_updated: 2026-04-28
---

# 인지 부하 이론(Cognitive Load Theory) — 학습·튜토리얼 설계의 골격

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: C — 인지적 수용성 (Cognition)
- **이론 ID (Theory ID)**: cognitive-load
- **이론명**: 인지 부하 이론 / Cognitive Load Theory (CLT)
- **분류 키워드**: axis-C, cognition, working-memory, learning, tutorial-design
- **이론 키워드**: cognitive-load-theory, CLT, Sweller, intrinsic-load, extraneous-load, germane-load, working-memory, schema, worked-example, tutorial-design
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 04-flow-theory, 06-laws-of-ux, 07-ftue-onboarding

## TL;DR

John Sweller(1988~)의 인지 부하 이론은 인간 작업 기억이 약 **7±2 청크(Miller), 동시 처리 2~4개**로 매우 제한적이라는 사실에서 출발한다. 학습은 이 한계 안에서 외재적 부하(Extraneous)를 최소화하고 본질적 부하(Intrinsic)를 단계화하며 생산적 부하(Germane)로 스키마를 형성하는 과정이다. 게임 튜토리얼·UI·메커니즘 도입에서 이를 위반하면 학습 실패 → 첫 세션 이탈로 직결된다.

## 1. 이론 배경

### 1.1 출발

- 1980년대 후반 Sweller가 문제 해결 학습 연구에서 시작.
- 발견: 동일 내용이라도 **표현 방식**에 따라 학습 효율이 크게 달라짐.
- 작업 기억의 한계가 학습 병목임을 강조.

### 1.2 작업 기억의 제약

- 처리 가능: ~7 청크(George Miller, 1956), 5~9 범위.
- 동시 통합 처리: 2~4개.
- 지속: 약 20초.
- 장기 기억으로 이동(스키마 형성)에는 반복·통합·연습 필요.

## 2. 3가지 인지 부하

### 2.1 Intrinsic(본질적) 부하

> 콘텐츠 자체의 복잡도 + 학습자의 사전 지식.

- 변경 어려움(콘텐츠가 본질적으로 복잡하면 그대로 복잡).
- **단계화** 가능: 동시 변수 ≤ 2개로 시작 → 점진 도입.
- 사전 지식 많은 학습자(전문가)에겐 같은 콘텐츠도 부하 낮음.

**게임 함의**:
- 신규 플레이어에겐 1개 메커니즘부터.
- 다음 메커니즘은 1단계가 자동화된 후에야 도입.

### 2.2 Extraneous(외재적) 부하

> 잘못된 표현·UI로 인한 불필요한 부하.

- 디자이너가 통제 가능한 영역.
- 줄이는 것이 핵심 목표.

**게임 함의**:
- 텍스트로 설명하지 말고 시각적으로 보여주기.
- 한 화면에 한 정보.
- 방해 요소(움직이는 배경, 광고, 알림) 제거.
- 일관된 UI 위치·아이콘.

### 2.3 Germane(생산적) 부하

> 스키마 형성에 쓰이는 부하.

- 학습 내용을 장기 기억으로 옮기는 작업.
- 적정 부담은 학습에 필요(연습·반복·변형).

**게임 함의**:
- 같은 메커니즘을 다양한 맥락에서 반복.
- 워크드 익잼플(시범 후 따라하기).
- 챕터 끝의 통합 연습.

### 2.4 합산 모델 vs 재정의

- **전통**: Intrinsic + Extraneous + Germane = Total Load.
- **최신**: Germane은 별도 부하가 아니라 "Intrinsic 처리에 배분된 자원" → 이중 모델.
- 핵심은 같음: 외재 부하를 줄이고, 본질 부하 처리 자원을 확보하라.

## 3. 핵심 효과(Effects)

### 3.1 Worked Example Effect

> 처음 배울 때 직접 풀이보다 시범 풀이를 보는 것이 효과적.

- 게임: 첫 등장 시 시스템이 시범 → 플레이어가 동일 패턴 수행.
- 예: *Portal*의 첫 챕터, *Half-Life 2*의 안내 NPC.

### 3.2 Split-Attention Effect

> 시각·언어 정보가 떨어져 있으면 부하 ↑.

- 게임: 화면 한쪽에 적, 반대쪽에 텍스트 설명 → 부하 증가.
- 해결: 적 위에 직접 안내, 텍스트는 짧고 인접하게.

### 3.3 Modality Effect

> 시각 + 청각 동시 사용이 시각 + 텍스트보다 효과적.

- 게임: 음성 안내 + 시각 강조 > 화면 텍스트 + 시각 강조.

### 3.4 Redundancy Effect

> 동일 정보를 여러 채널로 중복 제시하면 오히려 부하 ↑.

- 게임: 음성 안내가 있는데 텍스트 자막 + 화면 텍스트 + 사운드 큐 동시 → 부하.
- 단, 청각 의존자 보호를 위한 **선택적** 자막은 별개.

### 3.5 Element Interactivity

> 요소 간 상호작용 많을수록 본질 부하 ↑.

- 게임: 단일 액션(공격) vs 콤보(공격+방향+타이밍+자원).
- 콤보는 각 요소를 먼저 자동화한 뒤 결합 학습.

## 4. 게임 튜토리얼 황금 규칙

### 4.1 Show, Don't Tell

- 텍스트 설명보다 시각 시연.
- 한 화면에 한 메커니즘.

### 4.2 Contextual Learning

- 이야기 안에서 학습.
- "탭하여 공격" 대신 "고블린이 도망치기 전 공격하세요".

### 4.3 Schema Stacking

- 1단계 메커니즘이 자동화된 후 2단계 도입.
- 자동화까지 5~10분 권장(메커니즘 복잡도에 따라).

### 4.4 Spaced Practice

- 한 세션에 모든 것 가르치지 말고 여러 세션에 분산.
- 첫 세션: 코어 루프 1.
- 둘째 세션: 메타 +1.

### 4.5 Failure-tolerant Sandbox

- 실패해도 자원·진행 손실이 적은 안전 구간.
- 실패 시 "왜 실패했는지" 명시(Competence 욕구 충족과 결합).

## 5. UI/HUD 설계 원칙

### 5.1 Miller's Law 적용

- HUD 동시 표시 정보 ≤ 7개.
- 인벤토리는 카테고리화 → 한 번에 보이는 항목 ≤ 9.

### 5.2 시각 위계

- 가장 중요(HP·자원) > 중요(미니맵·목표) > 보조(시간·점수).
- 색상·크기·위치로 위계 표현.

### 5.3 알림 통합

- 동시 알림 ≥ 3 → 큐로 처리.
- 위급 알림(HP 위험)은 다른 알림보다 우선.

## 6. GDD 평가 체크리스트

### 6.1 튜토리얼 평가

- ✅ 첫 5분 안에 코어 루프 1회 완주가 가능한가
- ✅ 동시에 학습할 메커니즘이 ≤ 2개인가
- ✅ 텍스트보다 시각 시연이 우선되는가
- ✅ Worked Example(시범 → 따라하기) 패턴이 사용되는가
- ✅ 실패 허용 안전 구간이 있는가
- ⚠️ 한 화면에 텍스트 + 음성 + 자막이 모두 동시
- ❌ 첫 세션에서 5개 이상의 시스템을 한 번에 설명

### 6.2 UI/HUD 평가

- ✅ 동시 정보 표시 ≤ 7개
- ✅ 시각 위계가 명확(HP·자원이 가장 두드러짐)
- ✅ 신규 사용자에게 처음에는 핵심 HUD만 노출(점진 공개)
- ⚠️ 광고·이벤트 알림이 코어 HUD를 가리는 시점이 있는가
- ❌ 모든 정보를 항상 표시 → 학습 부하 폭증

### 6.3 메커니즘 도입 평가

- ✅ 새 메커니즘이 충분한 간격으로 도입되는가(권장: 챕터별 1개)
- ✅ 통합 도전(여러 메커니즘 결합) 전에 각각의 자동화 시간이 있는가
- ⚠️ "복잡함" 자체가 매력 포인트로 마케팅되었지만 학습 비용은 미고려
- ❌ 모든 메커니즘이 첫 챕터에 한꺼번에 등장

## 7. 작성 가이드 — CLT 정렬 GDD

### 7.1 메커니즘 도입 일정표

| 시점 | 도입 메커니즘 | 자동화까지 예상 시간 | 다음 메커니즘 도입 가능 시점 |
|------|------------|------------------|--------------------------|
| D0(첫 세션) | 코어 루프 (이동·기본 액션) | 5~10분 | D1 |
| D1 | 자원 관리 | 10~20분 | D3 |
| D3 | 빌드/장비 | 30분~1시간 | D7 |
| D7 | 메타 시스템 | 수 시간 | — |

### 7.2 Tutorial Funnel 모니터링

```
앱 실행(100%) 
  → 캐릭터 생성(80%)
  → 첫 액션(70%) 
  → 첫 보상(60%)
  → 자율 플레이 시작(50%) 
  → D1 복귀(24%, 산업 평균)
```

각 단계에서 -10%p 이상 떨어지면 해당 단계 학습 부하 점검.

### 7.3 UI 정보 우선순위 명시

```yaml
HUD:
  always_visible:
    - hp
    - main_resource
    - mini_map
  
  contextual:
    - quest_objective: when_active
    - skill_cooldown: when_used
  
  hidden_initially:
    - leaderboard
    - season_progress
  
  unlock_at:
    leaderboard: D3
    season_progress: D7
```

## 8. 안티패턴

- **All-at-Once Tutorial**: 모든 시스템을 첫 세션에 설명 → 학습 실패.
- **Wall of Text**: 5줄 이상의 텍스트 설명 → 외재 부하 폭증.
- **Hidden Critical Info**: HP가 위급한데 알림이 작거나 다른 효과에 묻힘.
- **Constant Notifications**: 모든 작은 보상에 큰 알림 → 인지 자원 낭비.
- **Inconsistent UI**: 같은 기능이 화면마다 다른 위치 → 외재 부하.
- **Tutorial in Sandbox**: 본 게임과 분리된 환경에서 학습 → 본 게임 진입 시 재학습 필요.

## 9. 다른 이론과의 관계

- **Flow Theory**: 인지 부하가 과하면 Flow 진입 불가. 도전이 적정해도 외재 부하가 높으면 불안.
- **Laws of UX (Hick·Miller)**: CLT의 작업 기억 한계와 직결.
- **FTUE**: CLT 위반은 첫 세션 이탈의 가장 큰 원인.
- **SDT(Competence)**: 학습 부하가 적정해야 Competence 욕구가 충족됨.

## 10. 참고 문헌

- [Cognitive Load — Wikipedia](https://en.wikipedia.org/wiki/Cognitive_load)
- [Sweller (2010) — Element Interactivity and Intrinsic, Extraneous, Germane Cognitive Load (Springer)](https://link.springer.com/article/10.1007/s10648-010-9128-5)
- [Sweller (2011) — Cognitive Load Theory chapter (PDF)](https://www.emrahakman.com/wp-content/uploads/2024/10/Cognitive-Load-Sweller-2011.pdf)
- [Cognitive Load Theory — The Decision Lab](https://thedecisionlab.com/reference-guide/psychology/cognitive-load-theory)
- [Cognitive Load Theory — ScienceDirect](https://www.sciencedirect.com/topics/psychology/cognitive-load-theory)
- [Cognitive Load Theory and Instructional Design — UKY (PDF)](https://www.uky.edu/~gmswan3/544/Cognitive_Load_&_ID.pdf)
- [Cognitive Load Theory: Research that Teachers Need to Understand — NSW Education (PDF)](https://education.nsw.gov.au/content/dam/main-education/about-us/educational-data/cese/2017-cognitive-load-theory.pdf)
- [From CLT to Collaborative Cognitive Load Theory — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC6435105/)
