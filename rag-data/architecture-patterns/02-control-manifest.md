---
title: Control Manifest 양식
collection: architecture-patterns
axis: E
theory_id: control-manifest
keywords: [control-manifest, programmer-rules, required, forbidden, guardrails, layer-rules, staleness]
applies_to: [implementation, evaluation]
related: [adr-template, system-layering]
last_updated: 2026-04-28
---

# Control Manifest 양식

> ADR 들이 *왜* 라면, Control Manifest 는 *바로 무엇을 해라/하지마라*.
> 프로그래머가 한 화면에 보고 즉시 적용 가능한 *플랫(flat)* 규칙 시트.

## 왜 필요한가

ADR 은 의사결정 문서다. 깊이 있고 길다. 매번 코드 짤 때마다 ADR 10개를 다 읽기는 비현실적.

Control Manifest 는 ADR 들에서 *행동 규칙*만 추출하여 한 곳에 모은 시트:

- 코드 layer 별로 정리 (gameplay/, ai/, ui/, core/ 등)
- 카테고리별로 정리 (Required / Forbidden / Guardrails)
- 한 줄 규칙. 자세한 이유는 해당 ADR 참조 링크

---

## 형식

### 헤더

```markdown
# Control Manifest

> Manifest Version: 2026-04-28
> Source ADRs: ADR-001, ADR-002, ADR-005, ADR-008, ADR-012
> 변경 시: 모든 영향받는 ADR 을 재검토하고 Manifest Version 갱신

이 문서는 코드 작성 시 따라야 할 플랫 규칙 시트다.
각 규칙의 이유는 출처 ADR 을 참조하라.
```

### 본체 (레이어별)

```markdown
## Layer: src/core/ (Foundation)

### Required (반드시 한다)
- ✅ 모든 public API 에 doc comment (출처: ADR-002 코딩 표준)
- ✅ 새 시스템은 ADR 부터 작성 후 코드 (출처: ADR-001 의사결정 절차)
- ✅ 핵심 데이터는 Resource 로 정의 (출처: ADR-005 데이터 주도)

### Forbidden (절대 안 한다)
- ❌ 게임 룰 로직 포함 금지 — Foundation 은 인프라만 (출처: ADR-008 레이어링)
- ❌ 다른 레이어 시스템에 의존 금지 (출처: ADR-008)
- ❌ 글로벌 상태 변수 (출처: ADR-002)

### Guardrails (조건부 허용·주의)
- ⚠️ 외부 라이브러리 추가는 ADR 통과 후 (출처: ADR-001)
- ⚠️ 성능 critical 코드는 perf-profile 통과 필요 (출처: ADR-012)

---

## Layer: src/gameplay/ (Core / Feature)

### Required
- ✅ 모든 시스템은 GDD 8섹션 표준 따름 (출처: ADR-002, gdd-wisdom)
- ✅ 의존성 양방향 명시 (출처: ADR-008, gdd-wisdom)
- ✅ 시그널 기반 통신 (출처: ADR-003 통신 패턴)
- ✅ 모든 수치는 데이터 파일에서 로드 (하드코딩 금지) (출처: ADR-005)

### Forbidden
- ❌ Foundation 시스템 직접 변경 (출처: ADR-008)
- ❌ Presentation 시스템 호출 — 시그널만 (출처: ADR-008)
- ❌ 매직 넘버 (출처: ADR-002 코딩 표준)

### Guardrails
- ⚠️ 한 시스템의 상위 의존 5개 초과 시 분해 검토 (출처: gdd-wisdom 양방향 의존)
- ⚠️ 컬레쇼브쥬 사용 시 메모리 누수 검사 (출처: ADR-012)

---

## Layer: src/ui/ (Presentation)

### Required
- ✅ 모든 UI 는 데이터 바인딩 (시스템 상태 *읽기* 만) (출처: ADR-008, ADR-010)
- ✅ 입력은 시그널로 위임 (UI 가 직접 게임 상태 변경 안 함) (출처: ADR-008)

### Forbidden
- ❌ UI 가 시스템 상태 직접 변경 (출처: ADR-008)
- ❌ UI 노드에 게임 룰 함수 (출처: ADR-008)

### Guardrails
- ⚠️ 큰 리스트는 가상 스크롤 (수십 개 이상) (출처: ADR-010)
```

---

## 갱신 절차

### Manifest Version 의미

`Manifest Version: 2026-04-28` 은 이 manifest 가 마지막으로 갱신된 날짜.

스토리 (작업 단위) 는 이 버전을 *embedding* 한다:

```yaml
# story.yaml
manifest_version: 2026-04-28
```

스토리 작성 후 manifest 가 변경되면 → 스토리는 *stale* 표시. `/story-readiness` 검증 시 경고.

### 갱신 시 절차

1. 영향받는 ADR 결정·변경 (ADR 라이프사이클 따름)
2. Control Manifest 의 해당 규칙 갱신
3. `Manifest Version` 날짜 갱신
4. 진행 중인 스토리들 재검증 (stale 표시되는 것 처리)
5. 신규 스토리는 새 버전 embed

---

## 일반 규칙 (모든 레이어 공통)

```markdown
## All Layers — Universal Rules

### Required
- ✅ 의미 있는 변수·함수 이름 (snake_case 또는 camelCase, 프로젝트 규약 따름)
- ✅ 모든 commit 은 디자인 문서 또는 ADR 참조
- ✅ public API 변경 시 의존하는 모든 시스템 GDD·코드 업데이트

### Forbidden
- ❌ 디버그 코드 main 브랜치 commit
- ❌ 비밀값 (.env, API key) commit
- ❌ Test 비활성화로 CI 통과
- ❌ Hooks 우회 (--no-verify, --no-gpg-sign)

### Guardrails
- ⚠️ 외부 의존 추가는 라이센스 검토
- ⚠️ 성능 영향 큰 변경은 perf-profile 통과
```

---

## 출처 ADR 인용 규칙

각 규칙 끝에 출처 ADR 명시. 형식:

```
✅ 규칙 본문 (출처: ADR-XXX 제목 키워드)
```

여러 ADR 에서 유래하면:
```
✅ 규칙 본문 (출처: ADR-001, ADR-005)
```

ADR 외 출처 (gdd-wisdom 같은 RAG):
```
✅ 규칙 본문 (출처: gdd-wisdom/04-bidirectional-dependency)
```

---

## 안티패턴

### 1. ADR 없이 추가된 규칙
"왜 이 규칙?" 답 못함. 출처 없는 규칙은 정당성 약함.

해결: 모든 규칙에 출처 ADR. 예외 시 별도 ADR 작성.

---

### 2. Control Manifest 만 변경
ADR 은 그대로 두고 Manifest 만 수정. 두 문서 불일치.

해결: 규칙 변경 = ADR 변경. ADR 라이프사이클 통과 후 Manifest 갱신.

---

### 3. 너무 많은 규칙
한 레이어에 100+ 규칙. 프로그래머가 매번 다 읽기 비현실적.

해결: 핵심만. 보통 레이어당 5~15 규칙. 더 많으면 분해 검토.

---

### 4. Manifest 가 stale
ADR 이 변경됐지만 Manifest 는 그대로. 스토리들이 잘못된 규칙으로 진행.

해결: Manifest Version 갱신 자동화. CI 에서 ADR 변경 감지 시 Manifest 검토 알림.

---

## 검증 체크리스트

Manifest 작성/갱신 후:

- [ ] 헤더에 Manifest Version + Source ADRs 명시
- [ ] 각 레이어별로 Required / Forbidden / Guardrails 분리
- [ ] 모든 규칙에 출처 ADR 또는 RAG 참조
- [ ] 한 줄로 명확한 규칙 (긴 설명은 출처 ADR 에)
- [ ] 일반 규칙 (Universal) 별도 섹션
- [ ] Manifest Version 갱신 시 영향받는 스토리 재검증 절차 따름
