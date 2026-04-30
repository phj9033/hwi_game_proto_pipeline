---
title: F2P / GaaS KPI — 12종 핵심 지표 공식·벤치마크
collection: gdd-evaluation
axis: E
theory_id: f2p-kpi
keywords: [KPI, F2P, GaaS, DAU, MAU, retention, churn, ARPU, ARPDAU, ARPPU, LTV, CAC, ROAS, conversion, stickiness]
applies_to: [evaluation, creation]
related: [12-loss-aversion-bm, 13-variable-ratio-ethics, 07-ftue-onboarding]
last_updated: 2026-04-28
---

# F2P / GaaS KPI — 12종 핵심 지표 공식·벤치마크

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: E — 실현·지속성 (Viability)
- **이론 ID (Theory ID)**: f2p-kpi
- **이론명**: F2P / GaaS 핵심 KPI
- **분류 키워드**: axis-E, viability, KPI, monetization, retention, business-metrics
- **이론 키워드**: KPI, F2P, GaaS, DAU, MAU, retention, churn, ARPU, ARPDAU, ARPPU, LTV, CAC, ROAS, conversion, stickiness
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 12-loss-aversion-bm, 13-variable-ratio-ethics, 07-ftue-onboarding

## TL;DR

F2P/GaaS 게임의 건강 상태는 **참여(DAU/MAU·Stickiness)·잔존(Retention/Churn)·매출(ARPU·ARPDAU·ARPPU)·전환(Conversion)·UA 효율(CPI·LTV·ROAS)** 5 군집의 12종 핵심 지표로 측정된다. GDD는 단순히 "재미있을 것"이 아니라 "어떤 시스템이 어떤 KPI를 어떻게 견인하는가"를 명시해야 한다. 평가자는 허영 지표(Vanity Metric)가 아닌 실제 수익성·잔존을 나타내는 지표를 사용했는지를 본다.

## 1. 분류와 관계

```
[참여]
DAU ── DAU/MAU(Stickiness) ── MAU
   │
   ↓
[잔존]
Day 1 Retention → Day 7 → Day 30 ─── Churn(=1-Retention)
   │
   ↓
[매출]
ARPU ── ARPDAU(daily) / ARPPU(payer only)
   │
   ↓
[전환]
Conversion (paying user %)
   │
   ↓
[UA 효율]
CPI/CAC ── LTV ── ROAS ── LTV/CAC ratio
```

## 2. 참여(Engagement) 지표

### 2.1 DAU (Daily Active Users)

> 하루에 게임을 실행한 고유 사용자.

- 기본 정의는 단순 실행. 회사에 따라 "X분 이상 플레이"로 강화.
- 평가 시 정의를 명확히 — 회사 간 비교 시 정의 차이 주의.

### 2.2 MAU (Monthly Active Users)

> 30일 내 게임을 실행한 고유 사용자.

### 2.3 Stickiness Ratio (DAU/MAU)

```
Stickiness = (DAU / MAU) × 100
```

- 5% (캐주얼 평균 이하)
- 15~20% (성공적 모바일 게임)
- 50%+ (매일 사용 앱; 카카오톡·페이스북급)

**해석**: "월 사용자 중 일 사용자 비율" — 습관 형성도.

## 3. 잔존(Retention) & 이탈(Churn)

### 3.1 Retention Rate

> 코호트(특정 날 다운로드한 사용자 그룹) 중 N일 후 복귀한 비율.

```
Retention(D=N) = (Returning users on day N) / (Cohort size on day 0)
```

### 3.2 핵심 시점 — D1, D7, D30

| 시점 | 의미 | 양호 기준(모바일) | 우수 |
|------|------|---------------|------|
| D1 | 다음날 복귀 | ≥ 30% | ≥ 40% |
| D3 | 3일 후 | ≥ 17% | ≥ 25% |
| D7 | 1주 후 | ≥ 12% | ≥ 18% |
| D30 | 30일 후 | ≥ 5% | ≥ 10% |

> 평균 앱은 D3까지 77% 이탈. 게임은 평균보다 높은 D1 retention을 보임(콘텐츠가 즐거움 자체).

### 3.3 Churn Rate

```
Churn = 1 - Retention = (Churned users) / (Cohort size)
```

월간 → 연간 환산:
```
Annual Churn = 1 - (1 - Monthly Churn)^12
```

예: 월 5% churn → 연 46% churn.

### 3.4 Cohort Analysis

- 코호트별로 분리하여 추적.
- 신규 광고 캠페인 코호트 vs 기존 사용자.
- 시즌·이벤트 코호트.

## 4. 매출(Monetization) 지표

### 4.1 ARPU (Average Revenue Per User)

```
Monthly ARPU = Monthly Revenue / MAU
Daily ARPU = Daily Revenue / DAU
```

### 4.2 ARPDAU (Average Revenue Per Daily Active User)

```
ARPDAU = Daily Revenue / DAU
```

- 라이브 운영 핵심 지표.
- 매일 모니터링.

### 4.3 ARPPU (Average Revenue Per Paying User)

```
ARPPU = Total Revenue / Paying Users
```

- 결제자만 대상.
- ARPU vs ARPPU 차이가 크면 "소수가 매출 대부분 견인" 신호(Whale 의존).

### 4.4 산업 평균(2025~2026, 모바일 기준 추정)

| 장르 | ARPDAU |
|------|--------|
| 캐주얼 퍼즐 | $0.05~$0.20 |
| 미드코어 RPG | $0.30~$0.80 |
| 하드코어 전략 | $1.00+ |
| 가챠 RPG | $0.50~$2.00 |

## 5. 전환(Conversion)

### 5.1 Conversion Rate

```
Conversion = (Paying Users) / (Total Users) × 100
```

### 5.2 산업 평균

- F2P 모바일 평균: 1~5%.
- 하드코어 가챠: 5~10%.
- 캐주얼: 1~3%.

### 5.3 첫 결제 분포

- 첫 결제 시점 분포가 LTV 곡선 결정.
- 첫 결제 D1~D3 비율이 높으면 결제 친화적 게임.

## 6. UA 효율 — CPI, LTV, ROAS

### 6.1 CPI (Cost Per Install) / CAC (Customer Acquisition Cost)

```
CPI = Ad Spend / New Installs
CAC = Total UA Spend / New Customers
```

### 6.2 LTV (Lifetime Value) — 단순 공식

```
LTV (simple) = ARPU / Monthly Churn
```

예: ARPU $1, 월 churn 5% → LTV = $20.

### 6.3 LTV — Retention 기반

```
LTV = ∑ (Daily Retention[d] × ARPDAU)
      d=0 to ∞ (또는 90일/180일 등 cap)
```

- 더 정확하지만 데이터 필요.
- D7 ROAS로 미래 LTV 예측 가능.

### 6.4 ROAS (Return on Ad Spend)

```
ROAS = Revenue from cohort / Ad Spend on cohort
```

- D7 ROAS 29% 도달 시 대략 D90에서 손익분기점(Singular).
- 캠페인별·국가별 ROAS 추적.

### 6.5 LTV / CAC Ratio

```
LTV / CAC ≥ 3 → 건전
LTV / CAC < 1 → 적자 캠페인
```

## 7. 세션 지표

### 7.1 Session Length

- 평균 세션 길이.
- 캐주얼: 5~10분.
- 미드코어: 15~30분.
- 너무 길면 피로 누적 가능.

### 7.2 Session Frequency

- 일일 세션 수.
- 캐주얼: 4~6회.
- 미드코어: 2~3회.

### 7.3 Time to First Action

- 앱 실행 → 첫 의미 있는 액션까지 시간.
- < 30초가 양호.

## 8. KPI ↔ 시스템 매핑

| KPI | 자극 시스템 | 심리적 메커니즘 |
|-----|------------|--------------|
| **D1 Retention** | FTUE 품질, 첫 보상 | 첫 성취(Competence) |
| **D7 Retention** | 일일 미션, 진행 곡선 | 습관 형성, Goal-gradient |
| **D30 Retention** | 길드, 시즌 패스 | Relatedness, 장기 목표 |
| **Conversion** | 첫 결제 패키지, 한정 상점 | Endowment, Loss Aversion |
| **ARPDAU** | 시즌 패스, 가챠 | Variable Ratio, Scarcity |
| **Session Length** | 코어 루프 보상 빈도 | Microflow |
| **Session Frequency** | 일일 보상, 친구 알림 | Loss Aversion, Social |

## 9. GDD 평가 체크리스트

### 9.1 KPI 목표 명시

- ✅ 핵심 KPI 5종(D1·D7·D30·ARPDAU·Conversion) 목표가 명시되었는가
- ✅ 목표가 산업 벤치마크와 비교되었는가
- ✅ 각 KPI를 견인할 시스템이 명시적으로 매핑되었는가
- ⚠️ "DAU 100만 달성"만 있고 어떻게는 부재
- ❌ KPI 목표 부재 또는 허영 지표(다운로드 수만)

### 9.2 BM 모델 명시

- ✅ IAP / 광고 / 시즌 패스 비중 명시
- ✅ 무료 사용자도 코어 즐거움 도달 가능
- ✅ 결제 깊이별 대상(Whale/Dolphin/Minnow) 시나리오
- ⚠️ Whale 의존 80% 이상 → 리스크 큰 BM
- ❌ BM 모델이 산업 평균에서 크게 벗어나는데 정당화 부재

### 9.3 KPI 모니터링

- ✅ A/B 테스트 가능한 인프라 명시
- ✅ 코호트 분석 도구 명시(Singular·GameAnalytics·Adjust 등)
- ✅ 핵심 KPI 일간 대시보드 계획
- ❌ KPI를 측정할 도구·체계 부재

### 9.4 윤리 균형

- ✅ Conversion 추구가 PENS 자율성·유능성을 침식하지 않는가
- ✅ Loss Aversion 마케팅이 객관적 사실 범위 내인가
- ✅ Whale 보호 가드(결제 한도, 가족 알림)
- ⚠️ 단기 ARPDAU 극대화에 BM 집중

## 10. 작성 가이드

### 10.1 KPI 목표 시트

```yaml
kpi_targets:
  global_launch_year_1:
    dau_avg: 200000
    mau_avg: 1500000
    stickiness: 13%
    
    retention:
      d1: 32%
      d7: 14%
      d30: 6%
    
    monetization:
      arpdau: 0.15
      arppu: 12
      conversion: 2.5%
    
    ua:
      cpi_target: 2.50
      ltv_target: 8.50
      ltv_cac_ratio: 3.4
```

### 10.2 KPI ↔ 시스템 매핑 표

GDD 끝부분에 다음 표 권장:

```markdown
| 시스템 | 영향 KPI | 심리학 근거 |
|--------|---------|----------|
| FTUE 5분 룰 | D1 +5%p | Cognitive Load + First Win |
| 일일 미션 | D7 +3%p, Session Freq +0.5 | Loss Aversion |
| 시즌 패스 | ARPDAU +20%, D30 +2%p | Goal-gradient + Endowment |
| 길드 협동 | D30 +5%p | Relatedness |
| 첫 결제 패키지 | Conversion +0.5%p | Anchor + Endowment |
```

## 11. 안티패턴

- **허영 지표 의존**: 다운로드 수, 가입자 수만 자랑.
- **D1만 강조**: D7·D30 무시 → 단기 매출 후 침식.
- **Whale 의존**: 0.1%가 매출 80% → 리스크.
- **무차별 결제 유도**: PENS 침식, 사용자 신뢰 파괴.
- **Conversion 강제**: 무료 콘텐츠 차단 → D7 retention 폭락.
- **세션 길이 강요**: 자동 시청·강제 광고로 세션 부풀림.

## 12. 다른 이론과의 관계

- **SDT/PENS**: 외적 보상(매출) 추구가 PENS 점수와 충돌하지 않게.
- **FTUE**: D1 retention의 단일 가장 큰 결정 요인.
- **Loss Aversion**: Conversion·ARPDAU의 행동경제학 기반.
- **Variable Ratio**: 가챠 매출의 메커니즘적 기반.
- **Living Document**: KPI 결과는 GDD에 반영되어야 — KPI 미달 시스템은 재설계.

## 13. 참고 문헌

- [Free to Play and Its KPIs — GameAnalytics](https://www.gameanalytics.com/blog/free-play-key-performance-indicators)
- [Free to Play and Its Key Performance Indicators — Game Developer](https://www.gamedeveloper.com/business/free-to-play-and-its-key-performance-indicators)
- [Free Game Analytics: Retention, LTV, DAU, ARPDAU — Singular](https://www.singular.net/blog/game-analytics-dau/)
- [How to Calculate Game ARPU — Playio](https://blog.playio.co/how-to-calculate-game-arpu)
- [15 Key Mobile Game Metrics — Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/key-mobile-game-metrics)
- [Gaming KPI Dashboard Template — SimpleKPI](https://www.simplekpi.com/KPI-Dashboard-Examples/Gaming-KPI-Dashboard-Example)
- [Customer Retention KPIs — ChurnKey](https://churnkey.co/blog/customer-retention-kpis/)
- [Churn Rate Formula — WallStreetPrep](https://www.wallstreetprep.com/knowledge/churn-rate/)
- [10 Important Game Metrics — LinkedIn (Sharma)](https://www.linkedin.com/pulse/10-important-game-metrics-marketer-developer-must-know-sharma-1e)
- [10 Essential Metrics for Game Developers — Airbridge](https://www.airbridge.io/en/blog/10-essential-metrics-all-game-developers-should-look-out-for)
