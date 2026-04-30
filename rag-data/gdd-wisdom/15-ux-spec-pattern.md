---
title: UX 명세 패턴 (UX Spec / HUD / Interaction Pattern)
collection: gdd-wisdom
axis: C
theory_id: ux-spec-pattern
keywords: [UX, screen, flow, HUD, interaction-pattern, wireframe, state-diagram, data-binding, input-mapping, layout-zone]
applies_to: [creation, implementation]
related: [laws-of-ux, accessibility-requirements, game-feel-spec]
last_updated: 2026-04-28
---

# UX 명세 패턴

> UX = User Experience. 화면·흐름·상호작용을 *명세 가능한 단위*로 분해.
> 단계 6 통합 명세서의 D 섹션 (UX 흐름) 작성 시 적용.

## 3가지 명세 유형

| 유형 | 단위 | 예시 |
|------|------|------|
| **Screen / Flow Spec** | 화면 1개 또는 화면 흐름 | 메인 메뉴, 게임 화면, 결과 화면 |
| **HUD Design** | 게임 중 오버레이 | 체력바, 점수, 콤보, 미니맵 |
| **Interaction Pattern Library** | 재사용 가능한 상호작용 | 버튼, 슬라이더, 인벤토리 슬롯 |

---

## 1. Screen / Flow Spec

화면 1개 또는 연결된 화면 흐름의 명세.

### 필수 섹션

```markdown
# UX Spec — <화면명>

## Player Need (플레이어 필요)
이 화면에서 플레이어가 *무엇을* 하려는가? 1~2 줄.
예: "현재 진행 상황을 확인하고 다음 런 시작"

## Layout Zones (레이아웃 영역)
화면을 영역으로 분해 (3~7 영역):
- Header (상단): ...
- Main Content (중앙): ...
- Sidebar (좌/우): ...
- Footer (하단): ...

각 영역마다:
- 표시 정보
- 차지 비율 (%)
- 우선순위 (필수·중요·부가)

## States (상태)
화면이 가질 수 있는 상태들:
- Default (기본)
- Loading (로딩 중)
- Empty (데이터 없음)
- Error (에러)
- Modal active (모달 활성)
- ...

각 상태마다:
- 트리거 (언제 진입)
- 시각 변화
- 가능한 사용자 액션

## Interaction Map (상호작용 지도)
사용자 액션 → 결과 매핑:

| 입력 | 위치 | 결과 |
|------|------|------|
| 클릭 | "시작" 버튼 | 게임 화면 전이 |
| Tab | 어디든 | 다음 인터랙티브 요소 포커스 |
| Esc | 어디든 | 이전 화면 또는 종료 다이얼로그 |
| ... | ... | ... |

## Data Requirements (데이터 요구)
이 화면이 표시하기 위해 필요한 데이터:
- player.name (string)
- player.high_score (int)
- recent_runs (array of Run)
- ...

## Events Fired (이벤트 발행)
이 화면이 발생시키는 이벤트:
- start_run_requested
- settings_opened
- ...

## Accessibility (접근성)
- 키보드 네비: Tab 순서, Enter 활성, Esc 취소
- 스크린 리더: 각 영역의 ARIA 레이블
- 색맹: 색 외 정보 (아이콘·텍스트)
- 텍스트 크기: 100~150% 확대 시 레이아웃 유지

## Localization (현지화)
- 텍스트 길이 변화 (영→한 1.5배, 영→독 1.3배)
- RTL (아랍어·히브리어) 지원 시 레이아웃 미러링
```

### Wireframe (텍스트 또는 ASCII)

```
┌─────────────────────────────────────┐
│ [로고]              [설정] [종료]   │ ← Header
├─────────────────────────────────────┤
│                                     │
│         최고 점수: 12,345           │
│                                     │
│        ┌─────────────────┐          │ ← Main Content
│        │     게임 시작    │          │
│        └─────────────────┘          │
│        ┌─────────────────┐          │
│        │     도감 보기    │          │
│        └─────────────────┘          │
│                                     │
├─────────────────────────────────────┤
│ v0.1.0           © 2026 Studio      │ ← Footer
└─────────────────────────────────────┘
```

---

## 2. HUD Design

게임 중 오버레이. 게임플레이를 방해하지 않으면서 핵심 정보 제공.

### HUD 원칙 (Laws of UX 적용)

- **Hick**: 동시 표시 요소 ≤ 7. 초과 시 인지 부하.
- **Fitts**: 자주 쓰는 요소 = 큰 + 가까운
- **Goal-gradient**: 목표 근접 시 시각 강화 (예: 콤보 카운터 빛남)
- **Tunneling**: 결정적 순간엔 다른 정보 페이드 (정점 시 점수 외 흐림)

### HUD 명세 양식

```markdown
# HUD Design — <게임명>

## Layout (배치)
화면을 9분할 (3×3 그리드) 또는 역할별:
- 좌상: 플레이어 정보 (체력·이름)
- 중상: 알림·이벤트
- 우상: 환경 정보 (시간·미니맵)
- 좌하: 빠른 액션
- 중하: 핵심 자원 (점수·콤보)
- 우하: 보조 정보
- 중앙: (보통 비움 - 게임플레이)

## Element 명세

### Element: 체력 바
- 위치: 좌상 (10px, 10px)
- 크기: 200×30px
- 표시 정보: 현재 체력 / 최대 체력
- 시각:
  - 정상 (>50%): 녹색 그라데이션
  - 주의 (50-25%): 황색
  - 위험 (<25%): 빨강 + 깜빡임
- 애니메이션: 데미지 시 0.3초 흔들림, 회복 시 0.5초 페이드인
- 접근성: 색 외 패턴 (체력 < 25% 시 ! 아이콘)

### Element: 점수
- 위치: 중하 (화면 가운데)
- 크기: 60px 폰트
- 표시: 현재 점수 (콤마 구분, 6자리)
- 애니메이션:
  - 증가: 0.2초 카운트업
  - 콤보 ≥ 5: 1.2x 스케일 펄스
- 접근성: 텍스트 음성 출력 옵션

### Element: 콤보 인디케이터
- 위치: 점수 아래
- 표시: 콤보 ≥ 2 일 때만
- 시각: 흰색 → 황금색 (콤보 5+)
- 사라짐: 콤보 끊김 시 0.5초 페이드아웃
```

### HUD 정보 위계

```
필수 (항상 표시):  체력, 점수
중요 (조건 표시):  콤보 (≥2), 알림 (있을 때)
부가 (옵션 표시):  미니맵, FPS, 디버그
```

---

## 3. Interaction Pattern Library

재사용 가능한 상호작용 단위. 게임 전반에 일관성 부여.

### 표준 16 패턴 (모든 게임 권장)

1. **Button (버튼)** - 클릭 → 액션
2. **Toggle (토글)** - 켜기/끄기
3. **Slider (슬라이더)** - 연속값 조절
4. **Dropdown (드롭다운)** - 옵션 선택
5. **Checkbox (체크박스)** - 다중 선택
6. **Radio (라디오)** - 단일 선택
7. **Text Input (텍스트 입력)** - 자유 입력
8. **Number Input (숫자 입력)** - 수치 입력
9. **List (리스트)** - 항목 표시
10. **Grid (그리드)** - 2D 배치
11. **Tab (탭)** - 화면 분할
12. **Accordion (아코디언)** - 접기/펴기
13. **Modal (모달)** - 팝업 오버레이
14. **Tooltip (툴팁)** - 호버 정보
15. **Notification (알림)** - 일시 메시지
16. **Progress Bar (진행률)** - 작업 진행

### 게임 특화 패턴

각 게임이 필요로 하는 추가:
- **Inventory Slot** (인벤토리 슬롯) - 드래그·드롭, 아이콘
- **Ability Icon** (스킬 아이콘) - 쿨다운, 핫키
- **HUD Bar** (체력·자원 바) - 변화 애니메이션
- **Dialogue Box** (대화창) - 텍스트 진행, 선택지
- **Card** (카드) - 카드 게임 메카닉
- **Tile** (타일) - 그리드 게임 단위
- **Shop Item** (상점 아이템) - 가격, 구매 버튼

### 패턴 명세 양식

```markdown
## Pattern: Inventory Slot

### Variants (변형)
- empty (비어있음)
- filled (아이템 있음)
- selected (선택됨)
- locked (잠김)
- highlighted (강조 — 신규 등)

### Visual States
- empty: 회색 사각형 + 점선 테두리
- filled: 아이템 아이콘 + 실선 테두리
- selected: 황색 테두리 + 1.05x 스케일
- locked: 자물쇠 아이콘
- highlighted: 황금 글로우, 0.5초 펄스

### Interactions
- Hover: 툴팁 표시 (300ms 지연)
- Click: 선택 (selected 상태)
- Drag: 다른 슬롯으로 이동
- Right-click: 컨텍스트 메뉴 (사용·버리기 등)

### Sounds
- Hover: SFX_ui_hover.wav (-3dB)
- Click: SFX_ui_select.wav
- Drag start: SFX_inventory_pickup.wav
- Drop: SFX_inventory_place.wav

### Accessibility
- Keyboard: Tab 으로 포커스, Enter 로 선택, 방향키로 이동
- Screen reader: "[Slot N: Item name, Quantity X]"
- Color: 상태가 색 외 (테두리 두께·아이콘) 으로도 구분
```

---

## 통합 사용 패턴 (단계 6 작성 시)

```
단계 6 통합 명세서 D. UX 흐름 작성:

1. 주요 화면 식별 (3~5개)
   → 각각 Screen Spec 양식 적용
2. HUD 식별
   → HUD Design 양식 적용
3. 게임 특화 인터랙션 식별
   → Interaction Pattern Library 항목 추가
4. 통합 검증:
   - 모든 화면이 인터랙션 패턴을 일관되게 사용
   - 접근성 요구 (gdd-wisdom 14) 모든 화면 적용
```

---

## 안티패턴

### 1. 와이어프레임 없이 텍스트만
"중앙에 점수, 좌상에 체력" → 비율·크기·간격 모호.

해결: ASCII 또는 텍스트 와이어프레임. 정확한 픽셀은 아니더라도 *관계*는 명확.

### 2. 상태 누락
Default 만 명세, Loading/Error/Empty 누락.
→ 구현 시 누락 발견 → 임시 처리 → 일관성 깨짐.

해결: 모든 상태 미리 식별 + 시각·인터랙션 명세.

### 3. 인터랙션 패턴 일관성 없음
화면마다 버튼 동작·툴팁 지연 다름.

해결: Pattern Library 한 곳 정의 + 모든 화면 참조.

### 4. 접근성·현지화 후순위
"기본 디자인 끝나고 추가" → 레이아웃 깨짐.

해결: 명세 시점부터 접근성·현지화 필드 의무.

### 5. HUD 정보 폭주
9분할 모두 채움 → 인지 부하.

해결: 정보 위계 (필수·중요·부가). 부가는 옵션으로.

---

## 검증 체크리스트

각 화면 / HUD / 패턴 작성 후:

- [ ] Player Need 명시
- [ ] Layout Zones 분해 (3~7 영역)
- [ ] States 모두 식별 (default 외 최소 3개)
- [ ] Interaction Map 완성 (모든 입력 → 결과)
- [ ] Data Requirements 명시
- [ ] Events Fired 명시
- [ ] Accessibility 4축 모두 점검
- [ ] Localization 길이·RTL 영향 점검
- [ ] Wireframe (텍스트 또는 이미지) 첨부
- [ ] HUD: 정보 위계 적용 (≤ 7 동시 표시)
- [ ] Interaction: Pattern Library 항목과 일치
