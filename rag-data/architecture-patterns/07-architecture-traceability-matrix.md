---
title: 아키텍처 추적성 매트릭스 (Living Document)
collection: architecture-patterns
axis: E
theory_id: architecture-traceability-matrix
keywords: [traceability, matrix, coverage, gap-analysis, GDD-to-ADR, requirement-coverage, tr-id-matrix, living-document]
applies_to: [evaluation, implementation]
related: [tr-id-system, adr-template, control-manifest]
last_updated: 2026-04-28
---

# 아키텍처 추적성 매트릭스

> 모든 GDD 기술 요구사항이 어떤 ADR 로 다뤄지는지 *행 단위*로 추적하는 살아있는 매트릭스.
> Coverage 통계로 누락 (Gap) 을 즉시 식별.

## 핵심 원리

`03-tr-id-system.md` 가 *식별자 부여 규약* 이라면, 본 문서는 *식별자별 커버리지 추적* 이다.

추적성 매트릭스 = TR-ID × ADR 의 매핑 표 + Coverage 통계.

각 행 (= 1 TR-ID):
- 어느 GDD 의 어느 섹션에서 유래
- 어느 ADR (들) 이 다루는가
- Coverage 상태 (Covered / Partial / Gap)
- 비고

---

## 문서 형식

### 헤더

```markdown
# Architecture Traceability Index

> Living document — `/architecture-review` (또는 동등한 도구) 가 매 리뷰 때 갱신.
> 수동 편집은 오류 정정 시에만.

## Document Status
- **Last Updated**: 2026-04-28
- **Engine**: Godot 4.6
- **GDDs Indexed**: 11
- **ADRs Indexed**: 7
- **Last Review**: docs/architecture/architecture-review-2026-04-28.md
```

### Coverage 요약

```markdown
## Coverage Summary

| Status | Count | Percentage |
|--------|-------|-----------|
| ✅ Covered | 38 | 81% |
| ⚠️ Partial | 6 | 13% |
| ❌ Gap | 3 | 6% |
| **Total** | **47** | 100% |

목표: Covered ≥ 80%, Gap = 0
```

### 매트릭스 본체

```markdown
## Traceability Matrix

| TR-ID | 요구사항 | 출처 GDD | 출처 섹션 | ADR(들) | 상태 |
|-------|----------|---------|----------|--------|------|
| TR-MOV-001 | 캐릭터 이동 가속 100ms | movement-system.md | 4 Formulas | ADR-005 | ✅ Covered |
| TR-MOV-002 | 카메라 lag 200ms | movement-system.md | Game Feel | ADR-005 | ✅ Covered |
| TR-INPUT-003 | 키 입력 → 이동 < 16ms | input-handler.md | 8 AC | ADR-001 | ✅ Covered |
| TR-MINI-001 | 동시 활성 오브젝트 6 | whack-a-mole.md | 7 Tuning | ADR-006 | ✅ Covered |
| TR-MINI-007 | 클릭 피드백 < 100ms | whack-a-mole.md | 8 AC | ADR-006 | ✅ Covered |
| TR-MINI-012 | 일시정지 ↔ 재개 정확성 | whack-a-mole.md | 5 Edge Cases | (없음) | ❌ **Gap** |
| TR-SCORE-001 | 점수 공식 | scoring-system.md | 4 Formulas | ADR-007 | ✅ Covered |
| TR-SCORE-005 | LEGENDARY 가중치 | scoring-system.md | 7 Tuning | ADR-007 (부분) | ⚠️ Partial |
| ... | ... | ... | ... | ... | ... |
```

---

## Coverage 상태 정의

### ✅ Covered (커버됨)

요구사항이 ADR (Accepted) 로 명확히 다뤄짐. 아키텍처 결정·근거·트레이드오프 모두 명시됨.

조건:
- 최소 1개 Accepted ADR 의 "GDD Requirements Addressed" 섹션에 본 TR-ID 명시
- 그 ADR 의 Decision 이 본 요구사항을 직접 다룸
- ADR 의 Engine Compatibility 검증됨

### ⚠️ Partial (부분 커버)

요구사항의 일부만 ADR 로 다뤄짐. 또는 ADR 이 Proposed 상태.

조건 (다음 중 하나):
- ADR 이 본 TR-ID 를 다루지만 *일부 측면*만 (예: 공식만 결정, 엣지 케이스 미결정)
- ADR 이 Proposed 상태 (아직 Accepted 안 됨)
- ADR 의 Engine Compatibility 미검증

해결: 누락 측면의 별 ADR 작성 또는 기존 ADR 확장.

### ❌ Gap (미커버)

ADR 이 다루지 않는 요구사항. 즉시 결정 필요.

해결: 신규 ADR 작성 또는 기존 ADR 확장. Gap 0 까지 가야 architecture-review PASS.

---

## Cross-Cutting 식별

여러 ADR 이 동일 TR-ID 를 다룸 → 정상. 단, 책임 분리 명시.

```markdown
| TR-MINI-007 | 클릭 피드백 < 100ms | ADR-001 (입력 16ms) + ADR-006 (미니게임 84ms) | ✅ Covered |
```

→ 각 ADR 이 100ms 예산의 일부 책임. 합산 검증 필요.

---

## Untraced TR-ID 검사

`tr-registry.yaml` 에 등록됐지만 어떤 ADR 도 참조 안 함:

```markdown
## Untraced TR-IDs

다음 요구사항은 어느 ADR 도 참조하지 않음. 의도된 누락 또는 ADR 작성 필요:

- TR-INV-002: 인벤토리 슬롯 수
- TR-CODEX-001: 도감 항목 수
- TR-SAVE-003: 세이브 형식 호환성

조치: 각 TR-ID 에 대해 다음 결정 필요:
1. ADR 작성 → Gap 메우기
2. requirement 폐기 → tr-registry.yaml 에서 deprecated
3. MVP 외 (VS/Alpha) → ADR 작성 보류, 그러나 등록 유지
```

---

## Stale 참조 검사

ADR 이 deprecated TR-ID 또는 존재하지 않는 TR-ID 참조:

```markdown
## Stale References

다음 ADR 의 "GDD Requirements Addressed" 섹션에 stale 참조:

- ADR-003: TR-MINI-005 참조 (deprecated 상태, replaced_by TR-INV-001)
  → 조치: ADR-003 갱신, TR-INV-001 로 교체

- ADR-008: TR-LEGACY-001 참조 (registry 에 없음)
  → 조치: 오타 또는 옛 ID. 정확한 ID 로 교체 또는 ADR 갱신
```

---

## 갱신 절차 (Living Document 패턴)

본 매트릭스는 *수동 작성·유지하지 않음*. 자동 또는 반자동 갱신.

### 권장 갱신 트리거

| 트리거 | 갱신 동작 |
|--------|----------|
| 새 GDD 작성 | 그 GDD 의 TR-ID 후보 추출 → registry 에 등록 → 매트릭스 행 추가 (상태 ❌ Gap) |
| 새 ADR 작성 | ADR 의 "GDD Requirements Addressed" 파싱 → 해당 행 ADR 컬럼 갱신 → 상태 재계산 |
| ADR 상태 변경 (Proposed → Accepted) | 해당 행 상태 ⚠️ Partial → ✅ Covered |
| ADR Superseded | 해당 행 ADR 컬럼 새 ADR 로 교체 |
| GDD 변경 | 변경된 섹션의 TR-ID 재검토 |

### 갱신 도구

```bash
# 가상 명령
/architecture-review
  → 모든 GDD 파싱 → TR-ID 후보 추출
  → registry 에 신규 등록 (사용자 승인 필요)
  → 모든 ADR 파싱 → "GDD Requirements Addressed" 추출
  → 매트릭스 갱신 → coverage 통계 재계산
  → docs/architecture/architecture-traceability.md 자동 작성
```

---

## Gap 해결 전략

`❌ Gap` 발견 시:

### 1. 우선순위 분류
- 🔴 BLOCKING: MVP 시스템의 Gap → 즉시 ADR 작성
- 🟡 Important: VS 시스템의 Gap → 마일스톤 전 작성
- 🟢 Nice-to-have: Alpha+ 시스템 → 일정 따라

### 2. ADR 작성 또는 통합
- 새 결정 → 신규 ADR
- 기존 ADR 의 확장 → 기존 ADR 에 본 TR-ID 추가

### 3. 또는 Requirement 재고
- 정말 필요한 요구사항인가?
- MVP 에서 빼고 VS 로 미룰 수 있나?
- 다른 요구사항으로 대체 가능한가?

→ 답에 따라 ADR 작성 또는 deprecated.

---

## 본 파이프라인 단계 적용

본 파이프라인은 ADR 을 *간소화한 형태* (단계 6 의 F. 아키텍처 지도) 만 다룸. 따라서 매트릭스도 간소화 가능:

```markdown
## 단계 6 통합 명세서의 추적성 (간소판)

| 요구사항 | 어느 시스템·섹션? | 어떤 결정으로 다뤄짐? | 상태 |
|----------|------------------|---------------------|------|
| 캐릭터 이동 100ms 가속 | 시스템 인벤토리 → 캐릭터 컨트롤러 | F 섹션 결정 #2 (Tween 사용) | ✅ |
| ... | ... | ... | ... |

총 요구사항 N개, 결정 다뤄진 것 M개 → 커버리지 (M/N)%
```

→ 본 파이프라인이 단계 7 종료 시 이 간소판 매트릭스 작성. 다음 워크플로우 (프로토타입→빌드업) 가 정식 매트릭스로 확장.

---

## 안티패턴

### 1. 매트릭스 수동 작성
편집 부담 → 갱신 누락 → stale.

해결: 자동 갱신 도구. `/architecture-review` 같은 명령어 필수.

---

### 2. Gap 무시
"Gap 3개 있지만 별로 안 중요해" → 누적 → 6개월 후 30개.

해결: Gap 0 을 Architecture Review 통과 조건으로.

---

### 3. Coverage 100% 만 추구
모든 TR-ID 에 ADR 강제 → ADR 폭주.

해결: Covered 80% 목표. 나머지는 명시적 사유.

---

### 4. 매트릭스를 디자이너가 안 봄
ADR·매트릭스가 프로그래머만 이해 가능 → 디자이너 격리.

해결: 행 단위 description 은 자연어로. 디자이너가 읽을 수 있게.

---

## 검증 체크리스트

매트릭스 갱신 후:

- [ ] 모든 active TR-ID 가 행으로 존재
- [ ] 각 행에 출처 GDD·섹션 명시
- [ ] 각 행의 ADR 컬럼이 정확 (실제로 그 TR-ID 를 다루는지)
- [ ] Coverage 통계 재계산됨
- [ ] Gap 모두 우선순위 분류됨
- [ ] Stale References 0
- [ ] Untraced TR-IDs 모두 처리 결정
- [ ] Last Updated, GDDs Indexed, ADRs Indexed 갱신
