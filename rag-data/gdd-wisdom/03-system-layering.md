---
title: 시스템 레이어링 (Foundation/Core/Feature/Presentation)
collection: gdd-wisdom
axis: D
theory_id: system-layering
keywords: [layering, foundation, core, feature, presentation, dependency-direction, architecture, system-organization]
applies_to: [creation, evaluation, implementation]
related: [bidirectional-dependency, 8section-gdd-standard]
last_updated: 2026-04-28
---

# 시스템 레이어링

> 모든 게임 시스템은 4개 레이어 중 하나에 속한다.
> 의존성은 항상 위에서 아래로(Presentation → Foundation) 흐른다.
> 역방향 의존은 즉시 안티패턴.

## 4개 레이어

```
┌─────────────────────────────────────────┐
│ Presentation (HUD, 메뉴, 도감 UI, VFX)  │ ← 사용자에게 보이는 것
├─────────────────────────────────────────┤
│ Feature (난이도, 스코어링, 업그레이드, 도감) │ ← 게임플레이를 풍성하게
├─────────────────────────────────────────┤
│ Core (런 매니저, 미니게임, 스포너, 아키타입) │ ← 게임의 본체
├─────────────────────────────────────────┤
│ Foundation (입력, 씬, 오브젝트 DB)        │ ← 모든 시스템의 기반
└─────────────────────────────────────────┘

       의존 방향: 위 → 아래만 허용
```

---

## 레이어 정의

### Foundation (기초)

**역할**: 다른 모든 시스템이 사용하는 가장 기초적인 인프라.

**특징**:
- 다른 시스템에 의존하지 않음 (또는 외부 라이브러리만 의존)
- 한 번 정해지면 잘 안 바뀜
- 변경 시 파급 범위가 가장 큼

**예시**:
- 입력 핸들러 (마우스/키보드/패드 통합)
- 씬 매니저 (화면 전환 골격)
- 오브젝트 데이터베이스 (모든 오브젝트의 순수 데이터 저장소)
- 이벤트 버스 (글로벌 메시징)
- 리소스 로더

**금지**:
- Foundation 시스템이 게임 룰을 알아서는 안 됨 — 순수 인프라
- "오브젝트 DB 가 캐치 시 점수를 계산한다" → 안티패턴 (Foundation 이 Feature 로직 침범)

---

### Core (핵심)

**역할**: 이 게임이 *이 게임이게* 만드는 시스템들. 코어 루프의 핵심.

**특징**:
- Foundation 만 의존
- 다른 Core 시스템과 적당히 의존 가능 (단, 순환 금지)
- 게임 본체 로직이 여기 있음

**예시**:
- 런 매니저 (런 생명주기)
- 미니게임 (코어 메카닉)
- 스포너 (오브젝트 등장 로직)
- 행동 아키타입 (오브젝트 동작 패턴)
- 카메라 컨트롤러
- 캐릭터 컨트롤러

**식별 기준**:
- 이 시스템이 빠지면 게임이 *게임이 아니게* 되는가? → Yes 면 Core
- 이 시스템 없이도 단순화된 형태의 게임이 가능한가? → Yes 면 Feature

---

### Feature (기능)

**역할**: 코어 루프를 풍성하게 만드는 시스템들. 없어도 게임은 성립하지만 있으면 깊이가 생김.

**특징**:
- Foundation + Core 의존
- 다른 Feature 와 의존 가능
- MVP 에서는 빠질 수 있고, Vertical Slice 이후 추가되는 게 많음

**예시**:
- 난이도 디렉터
- 스코어링 시스템
- 영구 업그레이드
- 수집 도감
- 재화/경제
- 세이브/로드
- 업적 시스템

**식별 기준**:
- 이 시스템 빼면 게임이 단순해지지만 여전히 작동하는가? → Yes 면 Feature
- "있으면 좋은" 시스템인가? → Yes 면 Feature

---

### Presentation (제공)

**역할**: 플레이어에게 정보·피드백을 전달. 게임 본체와 분리되어야 함.

**특징**:
- Foundation + Core + Feature 모두 의존 가능
- 그러나 다른 레이어가 Presentation 을 의존해서는 안 됨
- UI/UX, VFX, 오디오 큐 등이 여기

**예시**:
- HUD (체력바, 점수, 콤보 인디케이터)
- 메뉴 시스템
- 도감/인벤토리 UI
- 결과 화면
- 화면 전환 효과
- 카메라 흔들림 (게임플레이 영향 없음, 시각만)
- BGM 매니저

**원칙**:
- Presentation 은 데이터를 *읽기만* 한다. 시스템 상태를 변경하면 안 됨.
- "HUD 의 일시정지 버튼이 게임을 멈춘다" → Presentation 이 트리거하지만 *결정*은 런 매니저 (Core) 가 함.

---

## 의존 방향 규칙

### 허용

```
Presentation → Feature → Core → Foundation
       ↘         ↘        ↓
        ─────→ Foundation
```

같은 레이어 내부 의존 가능. 단:
- Core ↔ Core: OK, 순환만 없으면
- Feature ↔ Feature: OK, 순환만 없으면
- Foundation ↔ Foundation: 가급적 피함 (가장 기초니 결합 약하게)

### 금지

❌ Core → Feature (역방향)
❌ Foundation → Core (역방향)
❌ Foundation → Feature (역방향)
❌ 어떤 레이어든 → Presentation

**예시 안티패턴**:
- 미니게임(Core) 이 도감(Feature) 의 갱신을 직접 호출 → 이벤트로 분리해야 함
- 오브젝트 DB(Foundation) 가 스코어링(Feature) 공식을 참조 → DB 는 데이터만, 공식은 스코어링이 소유

### 역방향이 필요해 보일 때

대개 **이벤트/시그널 패턴** 으로 해결:

```
[Core: 미니게임]
  → emit signal: object_caught(id, value)

[Feature: 도감]
  ← subscribe to: object_caught
  → 자기 상태 갱신
```

미니게임(Core) 은 도감(Feature) 의 존재를 모름. 도감이 미니게임을 *듣고* 반응. 의존 방향: Feature → Core (정상).

---

## 레이어 식별 절차

새 시스템 GDD 작성 시:

1. **이 시스템이 빠지면 게임이 작동하는가?**
   - No → Core 또는 Foundation
   - Yes (단순화되지만) → Feature 또는 Presentation

2. **다른 시스템이 *이 시스템의 데이터*를 사용하는가?**
   - 많이 사용 → Foundation 가능성
   - 일부 사용 → Core 가능성
   - 거의 사용 안 함 (사용자에게만 보임) → Presentation

3. **이 시스템이 게임 룰의 본질인가?**
   - Yes → Core
   - No, 룰을 풍성하게 함 → Feature
   - No, 룰과 무관하게 정보 전달 → Presentation

4. **이 시스템이 다른 시스템의 인프라인가?**
   - Yes → Foundation

---

## 시스템 인덱스에 표기

`systems-index.md` 의 각 시스템 항목에 레이어를 명시:

```
| # | 시스템 | 카테고리 | 레이어 | 우선순위 | 의존 |
|---|--------|----------|--------|----------|------|
| 1 | 입력 핸들러 | Core | Foundation | MVP | (없음) |
| 2 | 씬 매니저 | Core | Foundation | MVP | (없음) |
| 3 | 오브젝트 DB | Core | Foundation | MVP | (없음) |
| 4 | 런 매니저 | Core | Core | MVP | 씬 매니저 |
| 5 | 미니게임 | Gameplay | Core | MVP | 입력, 스포너, 런 매니저 |
| 6 | 난이도 디렉터 | Gameplay | Feature | MVP | 런 매니저, 스포너 |
| 7 | HUD | UI | Presentation | MVP | 런 매니저, 스코어링, 미니게임 |
```

---

## 검증 체크리스트

시스템 인덱스 작성 후:

- [ ] 모든 시스템이 4개 레이어 중 하나에 할당됨
- [ ] 의존성 화살표가 모두 위→아래 (또는 같은 레이어 내)
- [ ] Foundation 시스템이 게임 룰을 모름 (순수 인프라)
- [ ] Presentation 시스템이 게임 상태를 변경하지 않음 (읽기 전용)
- [ ] 역방향이 필요해 보이는 곳은 이벤트/시그널로 변환됨
- [ ] 순환 의존 없음 (`/architecture-review` 또는 수동 검증)
