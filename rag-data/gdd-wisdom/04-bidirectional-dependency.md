---
title: 의존성 양방향 규약
collection: gdd-wisdom
axis: D
theory_id: bidirectional-dependency
keywords: [dependency, bidirectional, traceability, stale-reference, cross-reference, validation]
applies_to: [creation, evaluation]
related: [system-layering, 8section-gdd-standard]
last_updated: 2026-04-28
---

# 의존성 양방향 규약

> A 시스템이 B 시스템에 의존하면, B 시스템 GDD 도 A 의 의존을 명시해야 한다.
> 한쪽만 적은 의존은 stale reference 의 가장 흔한 원인이다.

## 핵심 원리

GDD 는 시스템 간 인터페이스를 합의한 계약서다. 계약은 양방향이다 — 한쪽만 서명한 계약은 무효.

만약 A 의 GDD 만 "B 에 의존" 이라고 적고 B 의 GDD 가 "A 가 나를 사용함" 을 모르면:

- B 가 변경될 때 A 에 영향 가는 걸 모름 → silent breakage
- B 가 폐기되거나 이름 바뀌면 A 의 의존 명시가 stale
- 새로 합류한 디자이너가 시스템 그래프를 읽으면 A→B 만 보고 B→? 흐름을 이해 못함

---

## 양방향 명시 형식

각 시스템 GDD 의 **6번 Dependencies 섹션**에 두 방향 모두 적는다.

### 형식

```markdown
## 6. Dependencies

### 상위 의존 (이 시스템이 사용하는 것들)
- **시스템명 A**:
  - 사용 인터페이스: `메서드/시그널/리소스 이름`
  - 사용 목적: 어떤 정보/동작을 받음
  - 결합 강도: strong / medium / weak
  - 양방향 검증: A 의 GDD 6번 섹션에 본 시스템이 "하위 의존"으로 명시되어야 함

### 하위 의존 (이 시스템을 사용하는 것들)
- **시스템명 B**:
  - 노출 인터페이스: `이벤트/메서드/리소스 이름`
  - 사용 패턴: B 가 어떻게 사용하는지 (구독·호출·읽기)
  - 양방향 검증: B 의 GDD 6번 섹션에 본 시스템이 "상위 의존"으로 명시되어야 함
```

### 예시

**미니게임 GDD 의 Dependencies 섹션**:

```markdown
### 상위 의존
- **입력 핸들러**:
  - 사용 인터페이스: `mouse_clicked(position)` 시그널 구독
  - 사용 목적: 사용자 클릭 위치 수신
  - 결합 강도: strong (핵심 입력 채널)
  - 양방향 검증: 입력 핸들러 GDD 의 하위 의존에 미니게임 명시됨 ✓

- **오브젝트 스포너**:
  - 사용 인터페이스: `get_active_objects()` 메서드, `object_spawned(id)` 시그널
  - 사용 목적: 활성 오브젝트 목록 조회 + 신규 등장 알림
  - 결합 강도: strong
  - 양방향 검증: 스포너 GDD 하위 의존에 미니게임 ✓

- **런 매니저**:
  - 사용 인터페이스: `paused`/`resumed` 시그널 구독
  - 사용 목적: 일시정지 상태 동기화
  - 결합 강도: medium
  - 양방향 검증: 런 매니저 GDD 하위 의존에 미니게임 ✓

### 하위 의존
- **스코어링 시스템**:
  - 노출 인터페이스: `object_caught(id, value)` 시그널 발행
  - 사용 패턴: 스코어링이 구독하여 점수 가산
  - 양방향 검증: 스코어링 GDD 상위 의존에 미니게임 ✓

- **HUD**:
  - 노출 인터페이스: `catch_count_changed(count)` 시그널
  - 사용 패턴: HUD 가 구독하여 카운트 표시
  - 양방향 검증: HUD GDD 상위 의존에 미니게임 ✓
```

**스포너 GDD 의 대응 부분**:

```markdown
### 하위 의존
- **미니게임**:
  - 노출 인터페이스: `get_active_objects()`, `object_spawned(id)`
  - 사용 패턴: 미니게임이 활성 목록 조회 + 등장 이벤트 구독
```

→ 미니게임의 "상위 의존: 스포너" ↔ 스포너의 "하위 의존: 미니게임" 일치.

---

## 결합 강도 (Coupling Strength)

| 강도 | 의미 | 예시 |
|------|------|------|
| **strong** | 인터페이스 변경 시 두 시스템 모두 코드 수정 필수 | 미니게임 ↔ 입력 핸들러 |
| **medium** | 인터페이스 변경 시 한쪽만 수정해도 됨 (어댑터 가능) | 미니게임 ↔ 런 매니저 (시그널 추가/제거) |
| **weak** | 한 시스템이 사라져도 다른 시스템 동작 (선택적 통합) | HUD ↔ 도감 (도감 없으면 그냥 숨김) |

**원칙**: strong 의존은 같은 레이어 또는 인접 레이어에서만. 멀리 떨어진 강결합은 안티패턴.

---

## 검증 절차

### 자동 검증 (권장)

스크립트로 모든 GDD 의 의존성 섹션을 파싱하여 양방향 일치 여부 검사:

```python
# pseudo
for gdd in all_gdds:
  for dep in gdd.upstream_deps:
    target = find_gdd(dep.system_name)
    assert gdd.system_name in target.downstream_deps, \
      f"Stale: {gdd} depends on {dep}, but {dep} doesn't list {gdd}"
```

### 수동 검증 (최소)

`/review-all-gdds` 또는 동등한 cross-GDD 리뷰에서:

- 각 GDD 의 상위 의존 → 대상 GDD 의 하위 의존에 명시 확인
- 각 GDD 의 하위 의존 → 대상 GDD 의 상위 의존에 명시 확인

불일치 발견 시 BLOCKING 이슈로 처리.

---

## 흔한 실패 패턴

### 1. 한쪽만 적기

```
미니게임 GDD: 상위 의존 — 스포너
스포너 GDD: (미니게임 언급 없음)
```

→ 스포너 변경 시 미니게임 영향을 모름. 6개월 후 silent break.

**해결**: 양쪽 모두 적기. 또는 자동 검증 도입.

---

### 2. 추상적 명시

```
미니게임 GDD: 상위 의존 — 입력 핸들러 (입력 받음)
```

→ 어떤 인터페이스? 시그널? 메서드? 리소스?

**해결**: 정확한 인터페이스 이름 + 호출 패턴 명시.

---

### 3. 의존성 폭주

한 시스템의 상위 의존이 7개 이상 → 그 시스템이 너무 많은 일을 함 (단일 책임 위반).

**해결**: 시스템 분해. 데이터 흐름 재설계.

---

### 4. 순환 의존

```
A → B → C → A
```

→ 한 시스템 변경 시 무한 영향 가능. 디버깅 악몽.

**해결**: 의존 방향 통일 (위→아래만). 역방향 필요 시 시그널로 분리.

---

### 5. 레이어 위반

Foundation 시스템이 Feature 시스템에 의존:

```
오브젝트 DB (Foundation) → 스코어링 (Feature)
```

→ DB 가 게임 룰을 알게 됨. 다른 게임 프로젝트에서 재사용 불가.

**해결**: DB 는 데이터만. 룰은 Feature 가 DB 를 *읽음* (역방향 안 됨).

---

## 의존 변경 시 절차

기존 GDD 의 의존성을 변경할 때:

1. 본 GDD 의 6번 섹션 수정
2. 영향받는 모든 GDD 의 6번 섹션 동시 수정
3. 양방향 일치 재검증
4. 변경 사유를 본 GDD 의 변경 로그에 기록 (또는 ADR 로 별도 작성)

**가벼운 의존성 변경 금지** — 한 GDD 만 수정하고 끝내지 말 것.

---

## 검증 체크리스트

각 GDD 작성/리뷰 시:

- [ ] 6번 Dependencies 섹션 존재
- [ ] 상위 의존 모두 명시 (사용 인터페이스 + 목적 + 결합 강도)
- [ ] 하위 의존 모두 명시 (노출 인터페이스 + 사용 패턴)
- [ ] 각 의존이 상대 GDD 에 양방향으로 일치 명시됨
- [ ] 결합 강도가 명시됨 (strong/medium/weak)
- [ ] 레이어 위반 없음 (Foundation 이 Feature 의존하지 않음 등)
- [ ] 순환 의존 없음
