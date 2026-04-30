---
title: FTUE & 온보딩 — 첫 세션이 D1 잔존을 결정한다
collection: gdd-evaluation
axis: C
theory_id: ftue-onboarding
keywords: [FTUE, first-time-user-experience, onboarding, tutorial, D1-retention, drop-off, funnel, contextual-learning, D1, churn]
applies_to: [evaluation, creation]
related: [04-flow-theory, 05-cognitive-load, 06-laws-of-ux]
last_updated: 2026-04-28
---

# FTUE & 온보딩 — 첫 세션이 D1 잔존을 결정한다

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: C — 인지적 수용성 (Cognition)
- **이론 ID (Theory ID)**: ftue-onboarding
- **이론명**: First-Time User Experience / 온보딩 디자인
- **분류 키워드**: axis-C, cognition, onboarding, retention, drop-off, first-session, D1
- **이론 키워드**: FTUE, first-time-user-experience, onboarding, tutorial, D1-retention, drop-off, funnel, contextual-learning, D1, churn
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 04-flow-theory, 05-cognitive-load, 06-laws-of-ux

## TL;DR

First-Time User Experience(FTUE)는 사용자가 앱을 처음 실행한 순간부터 코어 메커니즘을 이해하고 흥미를 느끼기까지의 모든 상호작용이다. 모바일 앱의 평균은 D3까지 77% 이탈, D1 retention 산업 평균 24%다. FTUE 설계는 "재미를 빨리 보여주기 + 인지 부하 최소화 + 강제 단계 최소 + 첫 결제·광고 노출 지연"이라는 네 원칙으로 요약된다. 평가자는 GDD가 첫 5분 funnel을 단계별로 정량 설계했고, 각 단계의 허용 이탈률을 명시했는지를 본다.

## 1. FTUE의 정의와 범위

### 1.1 시작과 끝

- **시작**: 앱 실행(또는 그 직전 — 스토어 페이지·광고).
- **끝**: 사용자가 코어 루프를 자율적으로 즐기기 시작하는 시점.
- 캐주얼: 5~15분.
- RPG/복잡 게임: 30분~수 시간.

### 1.2 포함되는 것

- 로딩, 다운로드, 설치
- 닉네임·아바타·캐릭터 생성
- 튜토리얼·첫 스테이지
- 첫 보상·첫 성취
- 첫 메타 시스템 노출(인벤토리·맵)
- 첫 사회적 만남(친구·길드 안내)

## 2. 왜 그렇게 중요한가

### 2.1 통계

- 평균 앱은 D3까지 77% 이탈.
- D1 retention 24%(산업 평균), 30% 이상이 양호.
- D7 retention 12~15%가 양호.
- 게임 진행도가 좋으면 67.1%가 계속 플레이(Antidote 데이터).

### 2.2 비용 측면

- CPI(인스톨당 광고비) × 인스톨 = 마케팅 투자.
- D1 이탈자는 LTV 0.
- D1 retention 5%p 개선 = LTV 약 25~30% 개선.

## 3. 4가지 핵심 원칙

### 3.1 재미를 빨리 보여줘라(Get to the Fun Fast)

- 첫 30초 안에 코어 메커니즘 1회 체험.
- 광고에서 보여준 핵심 액션을 즉시 경험하게.
- 스토리·로어는 짧게 또는 나중에.

### 3.2 인지 부하 최소화(Cognitive Load Minimization)

- 첫 세션엔 1~2개 메커니즘만.
- 텍스트 < 시각 시연.
- Worked Example: "이렇게 → 너도 해봐".

### 3.3 강제 단계 최소화(Reduce Friction)

- 즉시 "Play as Guest" 가능, 계정 연동은 나중에.
- 패치 다운로드는 백그라운드.
- 첫 캐릭터는 빠른 기본값 + 나중에 변경 가능.

### 3.4 첫 결제·광고 노출 지연(Delay Monetization Pressure)

- 첫 세션에 IAP 팝업 → D1 retention 평균 -8%p (Antidote).
- 첫 광고는 적어도 첫 세션 후반 또는 D2.
- 첫 결제 권유는 첫 성취 후, 자연스러운 맥락에서.

## 4. FTUE Funnel — 정량 설계

### 4.1 표준 funnel 단계

```
앱 실행 (100%)
  ↓ 로딩·설치 (-5~10%)
인스톨 완료 (90~95%)
  ↓ 첫 화면 (-10~20%)
캐릭터/닉네임 생성 (75~85%)
  ↓ 첫 액션 (-10~15%)
첫 액션 수행 (65~75%)
  ↓ 첫 보상 (-5~10%)
첫 보상 획득 (60~70%)
  ↓ 자율 플레이 시작 (-15~25%)
자율 플레이 (45~55%)
  ↓ D1 (-50~70%)
D1 복귀 (24~30%, 양호 시)
```

### 4.2 단계별 병목 진단

| 단계 | 허용 이탈 | 병목 시 의심 |
|------|---------|------------|
| 인스톨 → 첫 화면 | < 15% | 로딩 시간, 다운로드 크기, 크래시 |
| 첫 화면 → 캐릭터 생성 | < 15% | 첫 인상, 시각·사운드 첫 임팩트 |
| 캐릭터 생성 → 첫 액션 | < 15% | 생성 단계가 너무 길거나 복잡 |
| 첫 액션 → 첫 보상 | < 10% | 첫 액션이 어렵거나 불명확 |
| 첫 보상 → 자율 | < 25% | 자율 플레이의 다음 목표 부재 |

### 4.3 GDD에 명시할 것

```yaml
FTUE_Funnel:
  target_d1_retention: 32%
  
  step_targets:
    - name: install_to_first_screen
      target_drop: 7%
      kpi_threshold: 12%
    - name: first_action
      target_drop: 8%
      kpi_threshold: 15%
    - name: first_reward
      target_drop: 5%
    ...
  
  monitoring:
    a_b_test_required: true
    minimum_sample_size: 1000
    iteration_frequency: weekly
```

## 5. 흔한 실패 패턴

### 5.1 텍스트 폭격

- 첫 화면에 5줄 이상의 설명, 게임 시작 못 함.
- 해결: 한 화면에 한 정보, 짧은 안내, 시각 우선.

### 5.2 강제 컷신·로어

- 트레일러 액션 보고 왔는데 20분 컷신.
- 해결: 컷신은 짧게(1분 이내) 또는 스킵 가능.

### 5.3 격리된 튜토리얼

- 별도 샌드박스에서 학습 후 본 게임 진입 시 다시 길 잃음.
- 해결: 본 게임 첫 챕터에 튜토리얼 통합.

### 5.4 너무 많은 단계

- 회원 가입 → 약관 → 캐릭터 생성 → 마을 진입 → 마침내 첫 액션.
- 해결: 모든 비-게임 단계를 게임 후로 미루거나 게스트 시작.

### 5.5 첫 세션 광고/결제

- 첫 보스 클리어 직후 결제 팝업 → 좌절.
- 해결: 첫 세션에 결제 0회, 광고 0~1회 이내.

### 5.6 단순 따라하기 → 본 게임에서 길 잃음

- "여기 탭하세요"만 따라했더니 무엇을 했는지 모름.
- 해결: 능동적 의사결정 포함, "선택해서 해보세요".

### 5.7 핵심 재미가 늦게 등장

- "20시간 플레이하면 진짜 재미있어진다" → 95%가 그 전에 떠남.
- 해결: 재미의 핵심 조각을 첫 5분 안에 맛보기.

## 6. FTUE 설계 패턴

### 6.1 Narrative-Driven Tutorial

- 튜토리얼이 이야기 안에 자연스럽게 포함.
- 예: 친한 NPC가 "고블린이 다가와! 이걸로 막아!" → 공격 학습.
- *Half-Life 2* 도입부, *Portal* 첫 챕터.

### 6.2 Progressive Disclosure

- 메커니즘이 챕터별로 1~2개씩 점진 도입.
- 신규 시스템 도입 시 작은 데모 → 즉시 사용.

### 6.3 First Win Within 60 Seconds

- 첫 60초에 작은 승리(전투 1회·퍼즐 1개·미션 1개) 보장.
- Achievement 욕구 즉시 충족.

### 6.4 Contextual Hints

- 처음 보는 UI 요소에 자동 툴팁.
- 사용자가 30초 이상 멈춰 있으면 힌트.

### 6.5 Personalization

- 닉네임·아바타·테마를 통한 정체성 부여.
- "내 캐릭터"라는 감각 형성 → Endowment Effect.

### 6.6 Visible Progress

- 진행도 바, 다음 보상 미리보기.
- Goal-gradient effect로 다음 단계 동기화.

## 7. GDD 평가 체크리스트

### 7.1 첫 인상

- ✅ 첫 화면 로딩 < 5초
- ✅ 첫 30초 안에 코어 메커니즘 체험
- ✅ 첫 60초 안에 첫 성공 경험
- ⚠️ 첫 5분 안에 컷신 ≥ 2분
- ❌ 첫 화면이 회원 가입 폼

### 7.2 학습 곡선

- ✅ 첫 세션에 가르치는 메커니즘 ≤ 2개
- ✅ Worked Example 패턴 사용
- ✅ Contextual Learning(이야기 안 학습)
- ❌ "탭해" 외 능동적 결정 부재

### 7.3 마찰 최소화

- ✅ 게스트 시작 가능
- ✅ 비-게임 단계(약관·계정) 후순위
- ✅ 패치 다운로드 백그라운드
- ⚠️ 5단계 이상 클릭 후 첫 액션

### 7.4 동기 유지

- ✅ 다음 목표 항상 시각화
- ✅ 첫 세션 종료 시 "다음에 할 것" 명시
- ✅ 다음 보상 미리보기
- ❌ 첫 세션 종료 시 다음 목표 부재

### 7.5 BM 보호

- ✅ 첫 세션 IAP 팝업 0회
- ✅ 첫 세션 광고 ≤ 1회 (보상형)
- ✅ 첫 결제 유도는 D2 이후 + 첫 성취 후
- ❌ 첫 세션에 시즌 패스·가챠 강제 노출

## 8. 작성 가이드

### 8.1 첫 5분 시나리오

```markdown
## FTUE — 첫 5분

**0:00~0:05** 앱 실행, 즉시 로고(스킵 가능)
**0:05~0:30** 첫 화면, 게스트 시작 버튼, 단 1번의 탭
**0:30~1:00** 캐릭터 자동 생성(빠른 기본값), 첫 NPC 등장
**1:00~2:00** 코어 액션 #1 학습(시범 → 따라하기)
**2:00~3:00** 첫 도전, 작은 승리, 보상 1개
**3:00~4:00** 코어 액션 #2 학습
**4:00~5:00** 통합 도전, 자율 플레이 진입, 다음 목표 노출
```

### 8.2 A/B 테스트 계획

- 첫 화면 디자인 A vs B
- 캐릭터 생성 단계 수 A(1단계) vs B(3단계)
- 첫 광고 시점 A(첫 세션 후반) vs B(D2)
- 첫 결제 팝업 A(D2) vs B(D7)

### 8.3 측정 지표

- 단계별 통과율
- 단계별 평균 시간
- D1 / D7 / D30 retention
- 첫 결제 시점 분포
- 첫 세션 길이 분포

## 9. A/B 테스트 사례 — 일반적 발견

| 변경 | 평균 효과 |
|------|---------|
| 첫 광고 D2로 미루기 | D1 retention +3~5%p |
| 첫 결제 팝업 D7로 미루기 | LTV -1% (단기 매출), +5~8% (장기) |
| 캐릭터 생성 단계 1단계로 줄임 | 통과율 +10~15%p |
| 강제 컷신 → 스킵 가능 | D1 retention +1~3%p |
| 첫 30초 안 액션 보장 | D1 retention +5~10%p |

## 10. 다른 이론과의 관계

- **Cognitive Load**: FTUE의 학습 부분은 CLT 위반 시 즉시 실패.
- **Flow**: 첫 Microflow 진입 시간 = D1 retention의 강한 예측 변수.
- **SDT**: 첫 성취(Competence) + 첫 선택(Autonomy)이 첫 세션의 두 축.
- **Octalysis**: 신규 사용자에겐 Drive 2(Accomplishment) + 3(Empowerment) 우선, Drive 6/8(Black Hat) 지양.
- **Goal-gradient**: 첫 세션 종료 시 다음 목표 시각화로 D1 복귀 동기.

## 11. 참고 문헌

- [Mastering FTUE in Video Games — DesignTheGame](https://www.designthegame.com/learning/tutorial/mastering-impression-critical-role-ftue-video-games)
- [What is the FTUE? — DesignTheGame](https://www.designthegame.com/learning/tutorial/what-first-time-user-experience-ftue)
- [FTUE in Mobile Games — Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/first-time-user-experience)
- [10 First-Time User Experience Best Practices — Unity](https://unity.com/how-to/10-first-time-user-experience-tips-games)
- [10 Tips for a Great FTUE in F2P — GameAnalytics](https://www.gameanalytics.com/blog/tips-for-a-great-first-time-user-experience-ftue-in-f2p-games)
- [FTUE Antidote Playbook — Antidote.gg](https://antidote.gg/ftue-the-antidote-playbook/)
- [Mobile Game Onboarding: Top UX Strategies — Medium](https://medium.com/@amol346bhalerao/mobile-game-onboarding-top-ux-strategies-that-boost-retention-6ef266f433cb)
- [FTUE: 5 Tips for Mobile Games — Keewano](https://keewano.com/blog/first-time-user-experience-ftue-mobile-games/)
- [Designing a Great First-Time User Experience — Gamigion](https://www.gamigion.com/designing-a-great-first-time-user-experience/)
