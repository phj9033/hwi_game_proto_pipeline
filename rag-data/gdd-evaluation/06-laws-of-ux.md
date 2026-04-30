---
title: Laws of UX — 게임 인터페이스 평가 7대 법칙
collection: gdd-evaluation
axis: C
theory_id: laws-of-ux
keywords: [laws-of-ux, Hicks-law, Fitts-law, Millers-law, Jakobs-law, aesthetic-usability, goal-gradient, tunneling, game-UI, HUD-design]
applies_to: [evaluation, creation]
related: [05-cognitive-load, 07-ftue-onboarding]
last_updated: 2026-04-28
---

# Laws of UX — 게임 인터페이스 평가 7대 법칙

## 검색 메타 (Searchable Metadata)

- **평가 축 (Axis)**: C — 인지적 수용성 (Cognition)
- **이론 ID (Theory ID)**: laws-of-ux
- **이론명**: Laws of UX (UX 법칙)
- **분류 키워드**: axis-C, cognition, UI-design, HUD, UX-laws, interface-evaluation
- **이론 키워드**: laws-of-ux, Hicks-law, Fitts-law, Millers-law, Jakobs-law, aesthetic-usability, goal-gradient, tunneling, game-UI, HUD-design
- **적용 용도**: GDD 평가, GDD 작성
- **연관 이론**: 05-cognitive-load, 07-ftue-onboarding

## TL;DR

UX 법칙은 인간 인지·운동의 일반 원리를 디자인 원칙으로 정리한 휴리스틱 모음이다. 게임 UI에 가장 중요한 법칙은 **Hick(선택지 수)·Fitts(타겟 크기와 거리)·Miller(작업 기억)·Jakob(친숙성)·Aesthetic-Usability(미적 사용성)·Goal-gradient(목표 근접 동기)·Tunneling(주의 좁아짐)**의 7가지다. 평가자는 GDD의 UI/UX 섹션이 이 법칙들과 어떻게 정렬되었고, 위반할 때 그 이유가 정당한지를 본다.

## 1. 게임에서 UX 법칙이 중요한 이유

- 게임 UI는 한정된 화면에 많은 정보를 동시 노출.
- 인지 부하 + 시간 압박 + 입력 정밀도가 동시에 요구됨.
- 일반 웹·앱 UX보다 더 엄격한 적용이 필요.
- 잘못된 UI는 코어 메커니즘의 즐거움까지 가린다.

## 2. Hick's Law — 선택지의 수와 결정 시간

### 2.1 정의

> 선택지가 늘수록 결정 시간은 로그함수적으로 증가한다.

- 수식: T = b · log₂(n + 1)
- T = 결정 시간, n = 선택지 수.

### 2.2 게임 적용

- 메인 메뉴: 5개 이내 권장.
- 핫바/스킬바: 8개 이내 + 카테고리화.
- 인벤토리: 그리드 + 필터/정렬.
- 라디얼 메뉴: 4~8개 옵션, 시각적 분리.

### 2.3 위반 신호

- ❌ 첫 화면에 10개 이상의 메뉴 버튼.
- ⚠️ 캐릭터 선택 화면에 50개 이상 캐릭터, 필터 없음.
- ⚠️ 스킬이 20개인데 모두 동등 표시.

### 2.4 게임 디자인 트릭

- 동적 메뉴: 상황별로 표시 옵션 변화.
- 점진 공개: 신규 사용자에겐 핵심 메뉴만, 진행하며 추가.
- 즐겨찾기·핀: 자주 쓰는 항목을 상단 고정.

## 3. Fitts's Law — 타겟 크기·거리와 도달 시간

### 3.1 정의

> 타겟 도달 시간은 거리에 비례, 크기에 반비례.

- 수식: T = a + b · log₂(D/W + 1)
- D = 거리, W = 타겟 크기.

### 3.2 게임 적용

- **모바일**: 터치 타겟 ≥ 44pt(iOS) / 48dp(Android), 권장 ≥ 64px.
- **긴급 액션 버튼**(공격·스킬·회피): 화면 가장자리·엄지 손이 닿는 영역.
- **중요도와 크기 비례**: 메인 액션 > 보조 액션 > 메뉴.
- **데드 존**: 가장자리 안전 영역(노치·홈 인디케이터 회피).

### 3.3 PC/콘솔 적용

- 마우스 게임: 메뉴 모서리는 무한 거리(0,0 마우스 위치 = 도달 보장).
- 콘솔 패드: 컨텍스트 액션 버튼은 항상 같은 버튼(Y/△).

### 3.4 위반 신호

- ❌ 모바일에서 회피 버튼이 화면 중앙(엄지 손이 닿지 않음).
- ⚠️ 작은 X 닫기 버튼이 화면 모서리에 위치.
- ⚠️ 결제 확인 버튼이 너무 크고 가까워 실수 결제 유발.

## 4. Miller's Law — 7±2 청크의 한계

### 4.1 정의

> 인간 작업 기억은 한 번에 약 7±2개 정보 청크를 보유.

### 4.2 게임 적용

- HUD 상시 정보 ≤ 7개.
- 인벤토리 카테고리 ≤ 9개.
- 스킬 핫바 ≤ 8슬롯.
- 길드 채팅 알림 묶음 ≤ 5개.

### 4.3 청킹 전략

- 비슷한 정보 그룹화: 자원·통화 묶음, HP·MP·스태미너 묶음.
- 시각 위계로 1차 정보(중요)와 2차 정보(보조) 분리.

### 4.4 위반 신호

- ❌ HUD에 동시 표시 ≥ 12개 위젯.
- ⚠️ 인벤토리 평면 리스트 100+ 아이템.

## 5. Jakob's Law — 친숙함의 힘

### 5.1 정의

> 사용자는 익숙한 인터페이스를 선호한다.

- 이유: 학습 비용이 들지 않음.
- Jakob Nielsen 명명.

### 5.2 게임 장르 표준

| 장르 | 표준 컨벤션 |
|------|-----------|
| FPS | WASD 이동, 마우스 시점, 좌클릭 사격 |
| RPG | I = 인벤토리, M = 맵, ESC = 메뉴 |
| MOBA | QWER = 스킬, B = 상점, Tab = 스코어보드 |
| 모바일 캐주얼 | 좌상단 = 자원, 우상단 = 설정/메일, 하단 = 메인 액션 |

### 5.3 적용 원칙

- 장르 표준은 깨지 않는 게 기본.
- 깨려면 **명확한 보상**이 있어야 함(혁신성, 핵심 차별화).
- 깨더라도 옵션으로 표준 키맵 제공.

### 5.4 위반 신호

- ❌ FPS인데 이동 키가 ESDF, 정당화 부재.
- ⚠️ RPG인데 인벤토리가 P 키.

## 6. Aesthetic-Usability Effect — 미적 사용성

### 6.1 정의

> 사용자는 아름다운 디자인을 더 사용하기 쉽다고 인식한다.

- 사용성 문제도 미적 만족이 있으면 더 쉽게 용서받음.
- 단, 핵심 기능까지 가리면 안 됨.

### 6.2 게임 적용

- HUD는 게임 아트 스타일과 통합.
- 이펙트·애니메이션이 정보 가독성을 보조해야 함(가리지 않게).
- 폴리시 시간은 핵심 UI에 가장 먼저.

### 6.3 위반 신호

- ⚠️ 화려한 이펙트가 HP 위급 알림을 가림.
- ⚠️ 미적 일관성 부재(메뉴는 픽셀, 인게임은 3D 사실주의).

## 7. Goal-Gradient Effect — 목표 근접 동기

### 7.1 정의

> 목표가 가까워질수록 행동 동기가 증가한다.

- 출처: Hull(1932) 동물학.
- 인간에서도 강한 효과 입증.

### 7.2 게임 적용

- 진행 바: 다음 보상까지 90% 도달했음을 시각화.
- 시즌 패스: "다음 보상 미리보기" 노출.
- 레벨업 직전: 추가 경험치 강조.

### 7.3 디자인 트릭 — 가짜 진행

- 시작 시점에 가짜로 20% 진행도를 미리 표시(0이 아닌 상태로 시작).
- 빈 채로 시작하는 것보다 첫 진행이 더 빠르게 느껴짐.

### 7.4 위반 신호

- ⚠️ 진행도가 시각화되지 않거나 작게 표시.
- ⚠️ 보상 미리보기 부재.

## 8. Tunneling(인지적 터널링)

### 8.1 정의

> 특정 목표에 집중하면 주변 정보를 무시하게 된다.

- 운전 중 휴대폰 보면 주변 사고 신호 못 봄과 같은 원리.
- 게임에서는 전투 중·퍼즐 풀이 중 발생.

### 8.2 게임 적용

- **위급 알림은 시각·청각·진동 다채널**: HP < 20%일 때 화면 적색 비네팅 + 사운드 + 진동.
- **터널 외 정보를 줄이기**: 전투 중 메일·이벤트 알림 자동 보류.
- **방향 표시**: 적이 화면 밖에 있으면 화면 가장자리 표식.

### 8.3 위반 신호

- ⚠️ HP 위급 알림이 작은 텍스트 + 단일 채널.
- ⚠️ 전투 중 무관 알림(시즌 광고)이 핵심 HUD 가림.

## 9. 추가 법칙(보조)

### 9.1 Law of Proximity (근접성)

- 가까이 배치된 요소는 그룹으로 인식됨.
- HP·방어력은 함께, 자원은 별도 그룹.

### 9.2 Law of Common Region

- 같은 박스/영역 안의 요소는 관련됨.
- 인벤토리 카테고리 박스, 길드 멤버 박스.

### 9.3 Peak-End Rule

- 경험의 평가는 절정·종결의 평균.
- 시즌 종료 직전 큰 보상으로 마무리.
- 매치 종료 후 MVP·하이라이트 노출.

### 9.4 Doherty Threshold

- 시스템 응답 < 400ms일 때 사용자 만족 ↑.
- 게임은 이보다 더 엄격(< 100ms 권장).

## 10. GDD 평가 체크리스트

### 10.1 메뉴·메뉴 트리

- ✅ 메인 메뉴 ≤ 5 항목, 그 외는 카테고리화
- ✅ 메뉴 깊이 ≤ 3단계
- ✅ 신규 사용자에게 처음에는 핵심 메뉴만 표시

### 10.2 HUD

- ✅ 상시 표시 정보 ≤ 7개
- ✅ HP·자원은 시각 위계 최상위
- ✅ 위급 알림 다채널(시각+청각+진동)

### 10.3 입력

- ✅ 모바일 터치 타겟 ≥ 44pt
- ✅ 콘솔/PC는 장르 표준 키맵 + 커스텀 옵션
- ✅ 입력 응답 < 100ms

### 10.4 진행·동기

- ✅ 다음 보상 시각화
- ✅ 진행도 항상 표시(가짜 시작 진행도 권장)
- ✅ 시즌·매치 종료에 강한 마무리

### 10.5 예술·기술 균형

- ✅ 폴리시가 코어 UI에 우선 투자됨
- ✅ 이펙트가 정보를 가리지 않음
- ✅ 아트 스타일과 UI 일관성

## 11. 안티패턴

- **메뉴 폭주**: 첫 화면에 모든 기능 노출 → Hick 위반.
- **작은 모바일 버튼**: 손가락 정밀도 무시 → Fitts 위반.
- **HUD 과다**: 동시 정보 ≥ 10 → Miller 위반.
- **장르 깨기**: 정당화 없이 표준 깨기 → Jakob 위반.
- **이펙트 우선**: 화려함이 기능을 가림 → Aesthetic-Usability 오용.
- **진행도 부재**: 다음 목표 보이지 않음 → Goal-gradient 미활용.
- **알림 폭격**: 모든 알림 동등 노출 → Tunneling 무시.

## 12. 다른 이론과의 관계

- **Cognitive Load Theory**: Miller·Hick 법칙은 CLT의 작업 기억 한계와 직결.
- **Flow Theory**: UI가 입력 응답성·통제감을 해치면 Flow 불가.
- **FTUE**: 첫 세션의 UI 친숙도(Jakob)가 D1 retention과 강한 상관.

## 13. 참고 문헌

- [Laws of UX — Home](https://lawsofux.com/)
- [The 9 Laws of UX Design — CursorUp](https://www.cursorup.com/blog/laws-of-ux)
- [UX Laws — UXToast](https://www.uxtoast.com/ux-laws/)
- [21 Laws of UX — UX Design Institute](https://www.uxdesigninstitute.com/blog/laws-of-ux/)
- [The Laws of UX: 28 Simple Rules — Nulab](https://nulab.com/learn/design-and-ux/laws-of-ux/)
- [UX laws we break to create immersive games — Quantic Lab](https://www.quanticlab.com/ux-laws-we-break-to-create-immersive-games/)
- [Laws of UX: Helpful to Game Development — Reddit](https://www.reddit.com/r/gamedev/comments/ao3sxd/laws_of_ux_helpful_to_game_development/)
- [Laws of UX Design: Key Principles — Banani](https://www.banani.co/blog/laws-of-ux-design)
