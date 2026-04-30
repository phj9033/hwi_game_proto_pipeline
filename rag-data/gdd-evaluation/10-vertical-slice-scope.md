---
title: Vertical Slice & 스코프 관리 — 인디 프로덕션 핵심 마일스톤
collection: gdd-evaluation
axis: E
theory_id: vertical-slice-scope
keywords: [vertical-slice, scope-creep, MoSCoW, milestones, prototype, MVP, production, indie-development, risk-management]
applies_to: [evaluation, creation]
related: [00-living-document, 14-publisher-greenlight]
last_updated: 2026-04-28
---

# Vertical Slice & 스코프 관리 — 인디 프로덕션 핵심 마일스톤

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: E — 실현·지속성 (Viability)
- **이론 ID (Theory ID)**: vertical-slice-scope
- **이론명**: Vertical Slice + 스코프 관리
- **분류 키워드**: axis-E, viability, production, scope-management, milestone, indie-production
- **이론 키워드**: vertical-slice, scope-creep, MoSCoW, milestones, prototype, MVP, production, indie-development, risk-management
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 00-living-document, 14-publisher-greenlight

## TL;DR

인디 게임의 70% 이상이 "스코프 과대"로 실패한다. 스코프 크립은 나쁜 아이디어가 아니라 **관리되지 않은 좋은 아이디어**의 결과다. 이를 방어하는 표준 도구가 **Vertical Slice**(1~3개월 동안 만든 본 게임의 1/N 축소판)와 **MoSCoW 우선순위**다. 평가자는 GDD가 마일스톤별 'Done 정의'를 객관적으로 명시하고, "Won't (this version)"를 명시적으로 두는지를 본다.

## 1. 스코프 크립의 본질

### 1.1 통계

- Gamasutra 조사: 인디 70% 이상이 "스코프 과대"를 실패 원인으로 꼽음.
- 실제로는 '나쁜 아이디어'보다 '우선순위 부재'가 원인.
- 게임 개발은 Scope·Time·Cost 삼각관계 — 셋 다 최대화 불가.

### 1.2 5가지 흔한 원인

1. **Vision Drift**: 중간 핵심 비전 변경 + 재스코프 생략.
2. **Feature Frenzy**: "이것도 멋질 거야" 추가 누적.
3. **Communication Breakdown**: 분야 간 연계 부재.
4. **Feedback Overload**: 너무 많은 의견을 모두 수용.
5. **Sunk Cost**: "이미 시작했으니 못 멈춰".

## 2. 마일스톤 표준

| 단계 | 목적 | 산출물 | "Done" 정의 |
|------|------|--------|-------------|
| **Concept** | 비전 압축 | One-pager + 무드보드 | 한 호흡 피치 가능 |
| **Prototype** | 코어 루프 검증 | Greybox 빌드 | "이 메커니즘이 재미있는가?" 답 가능 |
| **Vertical Slice** | 양산 가능성 입증 | 1~3개월 Near-final 1~2 스테이지 | "양산하면 어떤 모습?" 보여줌 |
| **Alpha** | 모든 코어 시스템 구현 | Feature complete | 메커니즘 차원 새 추가 없음 |
| **Beta** | 콘텐츠·밸런스 완성 | Content complete | 신규 자산 추가 없음 |
| **GM** | 검수·인증 통과 | 출시 후보 | 치명 버그 0 |

### 2.1 Done 정의의 객관성

각 마일스톤의 'Done'은 다음 형식이 권장:
- **측정 가능**: "FPS 60 유지", "크래시 < 0.1%"
- **조건문**: "메인 메뉴 → 첫 매치 → 결과 화면까지 이상 없음"
- **버전 관리**: 마일스톤 빌드는 별도 브랜치/태그.

### 2.2 안티패턴

- "Game almost done" 같은 모호한 마일스톤.
- 한 마일스톤에 너무 많은 항목 → 늘 미달성.
- 마일스톤 변경 시 사유 미기록.

## 3. Vertical Slice — 양산의 증명

### 3.1 정의

> 본 게임의 1/N 축소판. 1~3개월 동안 만들어지는 Near-final 품질 1~2 스테이지.

### 3.2 위치

- Prototype 후, 본격 양산 전.
- "이 메커니즘이 재미있다"가 검증된 후, "이 게임을 양산하면 어떻게 보일까?"의 답.

### 3.3 가치

- **퍼블리셔/투자자에 대한 증거**: PowerPoint만으론 사인 안 함.
- **양산 견적**: Slice의 시간·비용 × N = 본 게임 견적.
- **리스크 발견**: 통합 단계의 문제(시스템 간 충돌)를 일찍 발견.

### 3.4 "Hero Mode" 함정

- 슬라이스 만들 때 무리한 야근·외주로 품질 끌어올리면 양산 속도 비현실적.
- 결과: 본 게임 양산 시 일정 미스 → 퍼블리셔 신뢰 파괴.
- 해결: 일상 페이스로 만들기, 투입 시간·인력 정확히 기록.

### 3.5 "Art Demo" 함정

- 시각적으로 화려하지만 코어 메커니즘은 반쪽 → 의미 없는 슬라이스.
- 해결: 메커니즘 + 비주얼 + 사운드 + UX 모두 통합.

## 4. MoSCoW 우선순위

### 4.1 4 카테고리

| 카테고리 | 정의 | 예 |
|---------|------|----|
| **Must** | 없으면 게임 성립 불가 | 코어 루프, 핵심 컨트롤 |
| **Should** | 없으면 약속 깨짐 | 핵심 메타, 첫 시즌 콘텐츠 |
| **Could** | 있으면 좋음 | 부가 미니게임, 컬렉션 |
| **Won't (this version)** | 차기 검토 | 모드 지원, 멀티플레이 |

### 4.2 "Won't"의 중요성

- 명시적으로 두지 않으면 "Could"로 슬며시 되돌아옴.
- "이번 버전엔 안 함"을 정직하게 적는 것이 스코프 보호의 핵심.

### 4.3 비율 가이드

- Must: 60% 노력
- Should: 25% 노력
- Could: 10% 노력
- Won't: 0% (검토만)

비율이 무너지면(예: Should가 50%) 스코프 위험 신호.

## 5. 스코프 방어 전술

### 5.1 MVP 정의

- 최소한의 즐길 거리.
- 코어 루프 1개 + 진행 1개 + UI 핵심.
- "이게 부족해도 게임으로 성립"하는 최소.

### 5.2 코어 루프 잠금

- 다른 모든 것보다 코어 루프 완성 우선.
- 코어 루프 미검증 상태에서 메타·BM·콘텐츠 작업 금지.

### 5.3 데드라인 우선

- 데드라인을 먼저 정하고, 그에 맞춰 스코프 자름.
- 데드라인을 늘려 스코프 맞추는 것은 위험(개발자 번아웃, 자금 고갈).

### 5.4 의견 필터

- 모든 피드백을 수용하지 않음.
- 의견 수용 기준: Design Pillars 부합 + Must 항목 영향.

## 6. 프로토타입과의 관계

### 6.1 Prototype의 역할

- 메커니즘이 재미있는지 검증.
- Greybox(저품질 비주얼) 허용.
- 빠른 반복(1~2주 단위).

### 6.2 Prototype → Vertical Slice 전환

- Prototype 검증된 메커니즘 → Vertical Slice에서 비주얼·사운드·UX 통합.
- Prototype 없이 바로 Vertical Slice는 위험: 양질 시각화한 부적합 게임 만들 수 있음.

## 7. GDD 평가 체크리스트

### 7.1 마일스톤

- ✅ 모든 마일스톤에 객관적 Done 정의가 있는가
- ✅ 각 마일스톤 일정에 버퍼(예: 20%)가 포함되어 있는가
- ✅ 마일스톤 의존성이 명시되었는가
- ⚠️ 마일스톤 일정이 "낙관적" → 현실 비교 시 부족
- ❌ Done 정의가 "거의 완성" 같은 모호 표현

### 7.2 Vertical Slice

- ✅ Vertical Slice 일정이 1~3개월 범위인가
- ✅ Slice 범위(스테이지·시스템)가 구체적으로 명시되었는가
- ✅ Slice 만들 때 투입 시간·인력 측정 계획이 있는가
- ⚠️ "Hero Mode" 노력이 전제되어 있음
- ❌ Slice 없이 본 양산 진입 계획

### 7.3 MoSCoW

- ✅ 모든 기능이 Must/Should/Could/Won't로 분류되었는가
- ✅ "Won't (this version)" 목록이 명시적으로 존재하는가
- ✅ 카테고리 비율이 60/25/10/0에 가까운가
- ⚠️ Must가 80% 이상 → 스코프 과대
- ❌ MoSCoW 미사용, 위시리스트 형태

### 7.4 리스크 관리

- ✅ Top 5 리스크와 대응 계획 명시
- ✅ 스코프 크립 발생 시 절차 명시
- ⚠️ "리스크 없음" 또는 "개발팀이 알아서"

## 8. 작성 가이드

### 8.1 마일스톤 정의 템플릿

```yaml
milestone:
  name: Vertical Slice
  start: 2026-06-01
  end: 2026-08-31
  
  done_criteria:
    - 1~2 스테이지가 Near-final 품질로 완료
    - 코어 루프 + 메타 시스템 통합
    - 60 FPS 안정 (타겟 기기)
    - 크래시 < 0.5%
    - 외부 플레이테스터 5명 이상 검증
  
  dependencies:
    - prototype_validated: true
    - art_style_locked: true
  
  buffer: 20%
  
  exit_review:
    required_attendees: [director, lead_designer, lead_artist, lead_engineer, producer]
    decision: [proceed_to_alpha, extend_slice, re-scope, cancel]
```

### 8.2 MoSCoW 시트 예시

```markdown
## Feature Prioritization (MoSCoW)

### Must (필수, 60% 노력)
- 코어 루프 (매치 3 + 부스터)
- 1 시즌 분량 콘텐츠 (스테이지 50개)
- 친구·길드 기본 시스템
- 5개 코스튬 + 5개 보드
- 광고·IAP 기본 통합

### Should (강력 권장, 25%)
- 시즌 패스 1회분
- 일일 미션 시스템
- 길드 협동 1종

### Could (있으면 좋음, 10%)
- 추가 부스터 3종
- 길드 채팅 이모티콘 풀
- 아바타 커스터마이징

### Won't (이번 버전 미포함)
- 멀티플레이 PvP 모드
- 사용자 생성 스테이지
- 크로스 플랫폼 진척 동기화
```

## 9. 안티패턴

- **Wish-list GDD**: 우선순위 없는 기능 나열.
- **Hero Mode Slice**: 야근·외주로 슬라이스 품질 부풀림.
- **Art Demo**: 비주얼만 화려, 메커니즘은 반쪽.
- **Won't 카테고리 부재**: 잘 보류된 아이디어가 다시 슬며시 들어옴.
- **Done 모호**: "완성"이 무엇인지 정의 안 됨.
- **Feedback Sponge**: 모든 의견을 수용 → 비전 흐려짐.
- **Sunk Cost Trap**: "이미 너무 만들었으니 못 빼겠어요".

## 10. 다른 이론과의 관계

- **Living Document**: 마일스톤·MoSCoW는 GDD의 핵심 모듈.
- **Publisher Greenlight**: Vertical Slice는 그린라이트의 핵심 증거.
- **F2P KPI**: 스코프 적정성은 KPI 달성 가능성과 직결.
- **Tetrad**: 4 요소(M·S·A·T) 모두 통합된 슬라이스가 가치 있음.

## 11. 참고 문헌

- [Scope Creep in Videogame Development — Toño Game Consultants](https://tonogameconsultants.com/scope-creep/)
- [Scope Creep in Indie Games — Wayline](https://www.wayline.io/blog/scope-creep-indie-games-avoiding-development-hell)
- [What Is a Vertical Slice — Toño Game Consultants](https://tonogameconsultants.com/vertical-slice/)
- [Make the Game You've Always Wanted to Play — Toño](https://tonogameconsultants.com/vertical-slice-4/)
- [Game Project Milestones for Indie Devs — Wayline](https://www.wayline.io/blog/game-project-milestones-indie-devs-planning)
- [Evolve Your Game Prototype Into a Vertical Slice — Toño](https://tonogameconsultants.com/prototype-to-production/)
- [Why Every Studio Needs Prototyping — Toño](https://tonogameconsultants.com/prototyping-games/)
- [What Is A Vertical Slice — GIANTY](https://www.gianty.com/vertical-slice-game-development/)
- [GameDev Protips: Kick Scope Creep — Daniel Doan (Medium)](https://medium.com/@doandaniel/gamedev-protips-how-to-kick-scope-creep-in-the-ass-and-ship-your-indie-game-8fa3051500d1)
- [Killing Scope Creep — GameMakerBlog](https://gamemakerblog.com/2017/02/21/gamedev-behind-the-scenes-2-killing-scope-creep-and-finishing-your-game/)
