---
title: 손실 회피 & 행동경제학 — Prospect Theory 기반 BM 윤리
collection: gdd-evaluation
axis: E
theory_id: loss-aversion-bm
keywords: [loss-aversion, prospect-theory, Kahneman, Tversky, endowment-effect, sunk-cost, FOMO, scarcity, battle-pass, ethical-monetization]
applies_to: [evaluation, creation]
related: [03-octalysis, 11-f2p-kpi, 13-variable-ratio-ethics]
last_updated: 2026-04-28
---

# 손실 회피 & 행동경제학 — Prospect Theory 기반 BM 윤리

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: E — 실현·지속성 (Viability)
- **이론 ID (Theory ID)**: loss-aversion-bm
- **이론명**: Loss Aversion + Prospect Theory 기반 BM 윤리
- **분류 키워드**: axis-E, viability, behavioral-economics, monetization-ethics, BM-design
- **이론 키워드**: loss-aversion, prospect-theory, Kahneman, Tversky, endowment-effect, sunk-cost, FOMO, scarcity, battle-pass, ethical-monetization
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 03-octalysis, 11-f2p-kpi, 13-variable-ratio-ethics

## TL;DR

Daniel Kahneman과 Amos Tversky의 Prospect Theory(1979)는 인간이 동일 가치의 이득과 손실을 비대칭적으로 평가한다는 사실을 입증했다 — **손실의 고통은 이득의 약 2배**(Loss Aversion). 이 편향이 게임 BM의 강력한 도구로 활용되며, 동시에 윤리적 위험의 진원지다. 평가자는 GDD가 손실 회피·소유 효과·매몰 비용·확률 가중을 어떻게 활용하고 있으며, 그 활용이 사용자 신뢰를 침식하는 선을 넘지 않는지를 본다.

## 1. 이론 배경

### 1.1 Prospect Theory의 출발

- 1979년 Kahneman·Tversky의 논문.
- 기존 기대 효용 이론(Expected Utility)이 인간의 실제 의사결정과 어긋남을 입증.
- Kahneman은 2002년 노벨 경제학상 수상.

### 1.2 핵심 발견

- **손실 회피**: 손실의 고통 ≈ 이득 기쁨의 2배.
- **참조점 의존**: 절대값이 아닌 변화로 평가.
- **확률 가중**: 작은 확률은 과대 평가, 중간 확률은 과소 평가.
- **위험 태도**: 이득 영역에선 위험 회피, 손실 영역에선 위험 추구.

## 2. Loss Aversion (손실 회피)

### 2.1 정의

> "잃지 않으려는 욕구가 얻으려는 욕구보다 강하다."

- $100을 잃는 고통 ≈ $200을 얻는 기쁨.
- 행동 비대칭의 원천.

### 2.2 게임 적용 — 윤리적

- **컴백 보상**: "오랜만에 돌아오신 당신을 위해" — 잃은 진행도 보상.
- **연속 보상**: 출석 7일 → 큰 보상. 끊기면 다시 1일부터.
- **시즌 진행도 보존**: 결제하지 않아도 진행도 유지.

### 2.3 게임 적용 — 위험

- **시간 압박**: "1시간 안에 결제하지 않으면 사라집니다" → FOMO 마케팅.
- **진행도 위협**: 결제 안 하면 진행도 손실 위협.
- **PvP 강등**: 일정 기간 미접속 시 랭크 하락 위협.

### 2.4 균형 가이드

- 손실 회피는 **자연스럽게** 활용해도 윤리적: 출석, 시즌 패스, 컴백.
- **인공적으로 손실을 만들어 결제 강요**하면 윤리 선 넘음.
- 사용자가 "내가 가진 것을 잃을까봐 결제했다"고 느끼면 신뢰 파괴.

## 3. Endowment Effect (소유 효과)

### 3.1 정의

> 사람은 자기가 소유한 것을 객관적 가치보다 더 높게 평가한다.

- 소유 전: $50 가치.
- 소유 후: 이를 팔라면 $100을 요구.

### 3.2 Pseudo-Endowment

> 실제로 소유하지 않아도 "거의 가진 것 같은" 상태에서도 손실 회피 작동.

- 무료 시즌 패스 진행도 → 사용자는 "이미 내 보상"이라 인식.
- 결제 안 하면 "소유한 것을 잃는 것"처럼 느낌.

### 3.3 게임 적용 — 윤리적

- **컬렉션 시스템**: 모은 것 자체가 즐거움.
- **펫·하우스**: 시간 들여 키운 것에 애착.
- **캐릭터 호감도**: 관계 발전 자체가 가치.

### 3.4 게임 적용 — 위험

- **Battle Pass 무료 트랙 보상 노출**: 결제 안 하면 보상 잠금 → "이미 내 것을 빼앗기는 느낌".
- **체험판 후 차단**: "30일 무료 → 결제 안 하면 진행도 사라짐".

### 3.5 균형 가이드

- 무료 사용자가 "충분한 진행"을 느낄 수 있게 보장.
- 결제는 "추가 가치"여야지 "기본 권리 회복"이면 안 됨.

## 4. Sunk Cost Fallacy (매몰 비용)

### 4.1 정의

> 이미 투입한 시간·돈을 회수하려는 비합리적 행동.

### 4.2 게임 적용

- **장기 게임**: 100시간 플레이한 사용자는 떠나기 어려움.
- **결제 누적**: 누적 결제액이 클수록 더 결제하는 경향.
- **시즌 패스 절반**: 절반 진행 후 결제 → 매몰 비용 회수 욕구.

### 4.3 윤리적 활용

- 장기 성장 시스템: 노력의 보상이 명확.
- 누적 진행 가시화: 사용자가 자기 진척을 자랑할 수 있게.

### 4.4 위험한 활용

- 무한 그라인드: 끝없이 시간 투입 강요.
- "이만큼 했는데 멈출 수 없어요" — 게임 중독성 강화.

## 5. Probability Weighting (확률 가중)

### 5.1 정의

> 사람은 작은 확률을 과대 평가하고 중간 확률을 과소 평가한다.

- 0.1% 가챠 → 실제보다 더 가능해 보임.
- 50% 확률 → 실제보다 덜 매력적.

### 5.2 게임 적용 — 가챠

- 가챠 메커니즘의 행동경제학적 기반.
- 0.5% SSR 캐릭터는 객관 확률보다 강하게 동기화.

### 5.3 위험

- 확률 비공개·기만 표기는 법적·윤리 문제.
- 중복 가챠(픽업 + 일반) 결합으로 실질 확률 모호화.

### 5.4 규제 추세

- 다수 국가에서 가챠 확률 공개 의무화(한국, 중국 등).
- EU·미국 일부 주 법안 추진 중.

## 6. FOMO (Fear of Missing Out)

### 6.1 메커니즘

- 손실 회피 + 사회적 영향(다른 사람들이 가지고 있다는 압박).

### 6.2 게임 적용 — 윤리적

- 시즌 한정 콘텐츠: 시즌 동안 충분히 즐길 시간 제공.
- 이벤트: 사용자가 즐거움을 위해 참여.

### 6.3 위험

- "1시간 안에 결제!"
- "친구 50명이 이미 이 아이템 소유" → 사회적 압박.
- 시간 제한이 너무 짧아 합리적 결정 어려움.

## 7. Battle Pass — 행동경제학의 집약체

### 7.1 구조

- 무료 트랙 + 유료 트랙.
- 무료 사용자도 진행도 누적.
- 유료 트랙의 보상이 가시적으로 노출.

### 7.2 작동하는 편향들

| 편향 | 작동 방식 |
|------|---------|
| **Endowment** | 무료 진행도가 "이미 내 것" 느낌 |
| **Loss Aversion** | 시즌 종료 시 "잃을 것"이라는 압박 |
| **Sunk Cost** | 진행할수록 결제로 회수 욕구 ↑ |
| **Goal-gradient** | 다음 보상까지 시각화 |
| **Scarcity** | 시즌 한정 — 시간 압박 |

### 7.3 윤리적 Battle Pass

- 가격이 합리적 (월 5~15달러 권장).
- 무료 트랙도 충분히 즐길 만함.
- 시즌 길이 충분(2~3개월).
- 결제 시점이 "성취 후" — 부담 없는 맥락.

### 7.4 위험한 Battle Pass

- 무료 트랙이 사실상 무의미.
- 시즌 너무 짧아 결제 강요.
- "결제 안 하면 다음 시즌 시작에 불리" — 영구적 손실 위협.

## 8. GDD 평가 체크리스트

### 8.1 손실 회피 활용

- ✅ 컴백 보상이 있는가
- ✅ 연속 보상이 끊겨도 즉시 다시 시작 가능한가
- ⚠️ 시간 압박 결제 팝업이 5분 이내 카운트다운인가
- ❌ 결제 안 하면 영구 진행 손실

### 8.2 소유 효과 활용

- ✅ 컬렉션·펫·하우스 같은 소유 시스템이 있는가
- ✅ 무료 사용자도 충분한 소유 경험 가능한가
- ⚠️ Battle Pass 무료 트랙이 사실상 잠겨 있는가
- ❌ 모든 소유가 결제 후에만 가능

### 8.3 매몰 비용 활용

- ✅ 장기 진행 보상이 명확하게 가시화되는가
- ✅ 자발적 누적 진행이 자연스러운가
- ⚠️ 무한 그라인드가 매출 핵심인가

### 8.4 확률 시스템

- ✅ 가챠 확률이 GDD와 게임 내 모두 공개되는가
- ✅ 중복 가챠 시 실질 확률이 명시되는가
- ✅ Pity 시스템(연속 실패 시 보상)이 있는가
- ⚠️ 확률 표기와 실제가 다를 수 있는 구조
- ❌ 청소년 가챠 한도 없음

### 8.5 FOMO 활용

- ✅ 한정 콘텐츠의 시간이 충분(2주 이상 권장)한가
- ✅ 못 얻은 보상이 다음 기회로 다시 등장하는가
- ⚠️ 영구 한정 보상이 너무 많아 신규 사용자 진입 장벽
- ❌ 1~2시간 카운트다운 결제 강요

### 8.6 Whale 보호

- ✅ 결제 한도(일·월) 옵션 제공
- ✅ 미성년자 보호 가드(가족 알림, 결제 한도)
- ✅ 환불 정책 명시
- ❌ 결제 무한, 보호 가드 부재

## 9. 작성 가이드 — 윤리적 BM

### 9.1 BM 윤리 원칙

```markdown
## BM Ethical Principles

1. **무료로 코어 즐거움**: 결제 없이도 게임의 핵심 재미 모두 도달 가능
2. **결제는 추가 가치**: 시간 단축, 표현(코스튬), 편의에 한정. P2W 금지
3. **확률 투명**: 모든 무작위 시스템의 확률 공개
4. **합리적 시간**: 시간 제한은 의사결정 가능한 길이(최소 24시간)
5. **사용자 보호**: 결제 한도 옵션, 미성년자 보호, 환불 정책
```

### 9.2 BM 시뮬레이션 표

```yaml
revenue_simulation:
  total_revenue_share:
    iap: 65%
    ads: 25%
    battle_pass: 10%
  
  payer_breakdown:
    minnow_<10_usd: 50%   # 매출 비중 10%
    dolphin_10_100: 35%   # 매출 비중 35%
    whale_100+: 15%       # 매출 비중 55%
  
  whale_protection:
    daily_limit_option: true
    monthly_limit_default: 500_usd_for_minor
    parental_alert: true
```

## 10. 안티패턴

- **다크 패턴**: 결제 버튼이 너무 크고 닫기 작음.
- **시간 압박**: 결제 결정에 5분 미만.
- **거짓 희소성**: "마지막 기회" 후 다음 주에 다시.
- **확률 모호**: 중복 시스템으로 실질 확률 흐림.
- **Sunk Cost 의존**: "이만큼 결제했는데 그만둘래?" 메시지.
- **Whale 무보호**: 무한 결제, 보호 가드 0.

## 11. 다른 이론과의 관계

- **Octalysis**: Drive 6(Scarcity), 7(Unpredictability), 8(Loss)의 행동경제학 기반.
- **SDT**: 외적 보상 의존이 PENS 자율성·유능성 침식.
- **Variable Ratio**: 가챠는 Variable Ratio + Probability Weighting 결합.
- **F2P KPI**: Conversion·ARPDAU는 이 편향들의 활용 결과.

## 12. 참고 문헌

- [Game Economy & Monetization – Loss Aversion — Fortunov](https://fortunovi.com/2021/01/26/game-economy-monetization-loss-aversion/)
- [The Consumer Psychology of Microtransactions in F2P Games — Salakari (PDF)](https://www.utupub.fi/bitstream/10024/179584/1/Salakari_Pessi_opinn%C3%A4yte.pdf)
- [Gacha Game: Prospect Theory Meets Optimal Pricing — Tan Gan (arXiv)](https://arxiv.org/pdf/2208.03602)
- [Loss Aversion Theory — IxDF](https://www.interaction-design.org/literature/article/loss-aversion-theory-the-economics-of-design)
- [The Psychology of Microtransactions — Number Analytics](https://www.numberanalytics.com/blog/psychology-microtransactions-game-design)
- [Testing Loss Aversion in an Adventure Game — Phillips et al.](https://hci.usask.ca/wp-content/cache/mendeley-file-cache/6eb59aeb-38be-37ad-950c-7c625cb4cce2.pdf)
- [Loss Aversion in Social Games — Hamari (PDF)](https://www.researchgate.net/profile/Juho_Hamari/publication/262261651_Perspectives_from_behavioral_economics_to_analyzing_game_design_patterns_loss_aversion_in_social_games/file/72e7e5372672d8e4c7.pdf)
- [Beyond Predatory Practices: Ethical Game Design — ACM](https://dl.acm.org/doi/pdf/10.1145/3673805.3673836)
- [Loss Aversion — BehavioralEconomics.com](https://www.behavioraleconomics.com/resources/mini-encyclopedia-of-be/loss-aversion/)
- Kahneman, D. & Tversky, A. (1979). "Prospect Theory: An Analysis of Decision under Risk." *Econometrica*, 47(2), 263–291.
