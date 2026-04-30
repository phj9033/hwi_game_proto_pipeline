---
title: ADR (Architecture Decision Record) 미니 템플릿
collection: architecture-patterns
axis: E
theory_id: adr-template
keywords: [ADR, architecture, decision-record, template, status, context, consequences, dependencies, engine-compatibility]
applies_to: [creation, implementation]
related: [control-manifest, tr-id-system]
last_updated: 2026-04-28
---

# ADR — Architecture Decision Record 미니 템플릿

> 모든 *되돌리기 어려운* 기술적 결정은 ADR 로 기록한다.
> "왜 이렇게 만들었는가" 를 6개월 후의 본인·새 합류자가 알 수 있게.

## 핵심 원리

코드는 *무엇을* 하는지 보여준다. ADR 은 *왜* 그 방식인지 보여준다. 둘 다 있어야 유지보수 가능.

ADR 을 적어야 할 결정의 신호:
- 한 번 도입하면 빼기 어려움 (DB 스키마, 핵심 라이브러리, 아키텍처 패턴)
- 다른 결정에 제약을 가함 (이걸 정하면 X 와 Y 가 자동으로 정해짐)
- 디자이너·다른 팀원이 영향받음 (UI 프레임워크, 입력 시스템)
- "그때 왜 이렇게 했지?" 라는 질문이 나올 가능성

ADR 을 안 적어도 되는 결정:
- 함수 이름·변수 명명
- 5분 안에 되돌릴 수 있는 것
- 한 파일 안에서 끝나는 패턴

---

## 미니 템플릿 (8 섹션)

```markdown
# ADR-<번호>: <결정 제목>

## Status
Proposed | Accepted | Superseded by ADR-<X> | Deprecated

> 라이프사이클: Proposed → Accepted → (필요 시) Superseded.
> 절대 Accepted 를 건너뛰지 말 것 — Proposed 를 참조하는 스토리는 자동 차단.

## Context
이 결정이 필요한 배경. 무슨 문제를 풀려고 하는가?
- 현 상황: ...
- 제약: ...
- 결정의 트리거 (왜 지금?): ...

## Decision
선택한 방법. 한 문장으로 압축 가능해야.

> 결정: <X 를 사용한다>. 이유: <핵심 근거 1줄>

## Alternatives Considered
검토했지만 거부한 옵션들. 각각 거부 이유 1줄.

| 옵션 | 거부 이유 |
|------|----------|
| 옵션 A | ... |
| 옵션 B | ... |

## Consequences

### Positive
- 어떤 문제가 해결되는가
- 어떤 가능성이 열리는가

### Negative
- 어떤 비용이 드는가 (개발·런타임·유지보수)
- 어떤 옵션이 막히는가

### Risks
- 결정이 잘못됐을 때 신호 (어떤 증상이 나타나면 재검토)
- 완화책

## Dependencies

### Depends On
- <ADR-X>: 이 결정이 X 를 전제함

### Enables
- <ADR-Y>: 이 결정이 통과되면 Y 가 가능해짐

### Blocks
- <ADR-Z>: 이 결정이 결정되어야 Z 를 진행할 수 있음

### Ordering Note
이 ADR 은 <단계/시점> 에 결정되어야 함. 늦으면 X 작업 차단.

## Engine Compatibility
- 엔진 버전: Godot 4.6 / Unity 2023.X / UE 5.4 등
- 호환성: 호환 / 부분 호환 / 비호환
- 검증 방법: 어떻게 호환을 확인했나 (또는 검증 필요 명시)

## GDD Requirements Addressed
이 ADR 이 어느 GDD 요구사항을 만족하는가:
- TR-MOV-001: 캐릭터 이동의 가속/감속 명세 충족
- TR-INPUT-003: 입력 지연 < 50ms 충족

(TR-ID 는 tr-registry.yaml 에 정의된 stable identifier)
```

---

## 작성 예시

### ADR-001: 상태 머신 vs 행동 트리 (NPC AI)

```markdown
# ADR-001: NPC AI 에 상태 머신 (FSM) 채택

## Status
Accepted (2026-03-15)

## Context
- MVP 의 NPC 는 4종 (낚시터 손님 NPC, 가게 NPC, 스토리 NPC, 보스 NPC)
- 각 NPC 의 행동은 평균 5~7 상태로 표현 가능
- 게임플레이 프로그래머 1명, AI 전문가 0명
- Godot 4.6 의 내장 노드 시스템 활용 가능

## Decision
유한 상태 머신(FSM) 을 채택. Godot 의 `Node` + 커스텀 `StateMachine.gd` 컴포지션.

## Alternatives Considered

| 옵션 | 거부 이유 |
|------|----------|
| 행동 트리 (Behavior Tree) | 4종 NPC 의 복잡도 부족. BT 의 표현력 과잉. |
| Utility AI | 유틸리티 함수 튜닝 노력 > FSM 작성 노력 |
| GOAP (Goal-Oriented Action Planning) | 솔로 개발 스코프 외 |

## Consequences

### Positive
- 코드 단순. 디버깅 쉬움.
- Godot 시그널 시스템과 자연스러운 통합.
- 디자이너가 상태 다이어그램으로 직접 명세 가능.

### Negative
- 상태 수가 10 이상 되면 관리 복잡.
- 동시 상태 표현 어려움 (예: "걷기 + 인사" 동시).

### Risks
- VS 단계에서 NPC 가 7종 이상 → BT 마이그레이션 검토 필요.
- 동시 상태 요구가 많아지면 → 하이브리드 (FSM + 컴포넌트) 검토.

## Dependencies

### Depends On
- ADR-000: 시그널 기반 통신 패턴 (시그널로 상태 전환)

### Enables
- 모든 NPC 시스템 GDD (FSM 으로 상태 명세 가능)

### Blocks
- (없음)

### Ordering Note
NPC 첫 시스템 GDD 작성 전에 결정 필요. 늦으면 NPC GDD 의 상태 명세 형식 흔들림.

## Engine Compatibility
- 엔진: Godot 4.6
- 호환성: 호환
- 검증: 프로토타입에서 4 상태 FSM 동작 확인 (2026-03-10)

## GDD Requirements Addressed
- TR-NPC-001: NPC 행동 패턴 명세 형식
- TR-NPC-002: NPC 상태 전환 트리거 정의
```

---

## Status Lifecycle

```
[Proposed]
     │ (검토 + 승인)
     ↓
[Accepted] ← 정상 운영 상태
     │
     ├──→ [Superseded by ADR-X]  (새 결정으로 대체)
     └──→ [Deprecated]            (기능 제거됨)
```

### 규칙

- **Proposed → Accepted 절대 건너뛰지 말 것**: 새로 도입되는 결정은 항상 Accepted 까지 명시적 전환.
- **스토리 차단 규칙**: Proposed 상태인 ADR 을 참조하는 구현 스토리는 자동 차단. 결정 안 끝났는데 코드 작성 안 됨.
- **Superseded 시**: 기존 ADR 의 Status 를 변경하고 새 ADR 작성. 기존 ADR 삭제 금지 (역사 보존).

---

## TR-ID 연동

ADR 의 "GDD Requirements Addressed" 섹션은 stable ID 를 사용. 별 문서 `tr-id-system.md` 참조.

```
GDD 의 요구사항 → TR-ID 부여 → ADR 에 인용
```

GDD 본문이 변경돼도 TR-ID 는 유지. ADR 인용이 stale 되지 않음.

---

## 안티패턴

### 1. 너무 많은 ADR
모든 함수 이름까지 ADR 로 적음 → 검토 부담만 증가.

해결: "되돌리기 어려운" 결정만. 보통 한 프로젝트당 10~30개.

---

### 2. 너무 적은 ADR
중요한 결정이 어디 적혀있는지 모름. "그때 왜 이렇게 했지?" 가 답 안 됨.

해결: 핵심 결정 (엔진·언어·핵심 라이브러리·핵심 패턴) 은 무조건 ADR.

---

### 3. Context 빈약
"X 를 한다" 만 적고 *왜* 가 없음.

해결: Context 는 ADR 의 핵심. 6개월 후 본인이 읽고 이해 가능해야.

---

### 4. Alternatives 없음
"이게 맞다" 라고만 적힘. 다른 옵션 검토 흔적 없음.

해결: 최소 2개 이상 대안 + 거부 이유. 없으면 "검토 부족" 으로 NEEDS REVISION.

---

### 5. Risks 누락
긍정 결과만 적고 위험 없음.

해결: 모든 결정에 위험 있음. "이 결정이 잘못이라는 걸 어떻게 알아챌까?" 답하기.

---

## 검증 체크리스트

ADR 작성 후:

- [ ] 8 섹션 모두 존재
- [ ] Status 정확 (Proposed / Accepted / Superseded / Deprecated)
- [ ] Context 가 *왜 지금* 이 결정이 필요한지 답함
- [ ] Decision 이 한 문장으로 압축 가능
- [ ] Alternatives 최소 2개 + 거부 이유
- [ ] Consequences Positive·Negative·Risks 모두
- [ ] Dependencies 명시 (Depends On / Enables / Blocks)
- [ ] Engine Compatibility 검증됨 (또는 검증 필요 명시)
- [ ] TR-ID 인용 시 tr-registry.yaml 에 존재 확인
