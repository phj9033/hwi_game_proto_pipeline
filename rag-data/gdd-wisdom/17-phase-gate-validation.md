---
title: Phase Gate 검증 패턴
collection: gdd-wisdom
axis: E
theory_id: phase-gate-validation
keywords: [phase-gate, gate-check, milestone, transition, validation, PASS-CONCERNS-FAIL, blocker, advance]
applies_to: [evaluation]
related: [vertical-slice-scope, high-risk-system-identification, cross-gdd-consistency]
last_updated: 2026-04-28
---

# Phase Gate 검증 패턴

> 단계 전환 = 명시적 결정 지점. "통과했나?" 가 정량 답변 가능해야.
> 게이트 없이 다음 단계 진입 = 디자인·기술 부채 누적.

## 핵심 원리

게이트는 *체크포인트*. 다음 시점에 통과해야 함:

| 게이트 | 통과 후 진입할 단계 |
|--------|-------------------|
| Concept Gate | Systems Design |
| Systems Design Gate | Technical Setup |
| Technical Setup Gate | Pre-Production |
| Pre-Production Gate | Production |
| Production Gate | Polish |
| Polish Gate | Release |

본 파이프라인 적용:
- 단계 3 (드래프트 저장 게이트) — 컨셉→평가 진입 검증
- 단계 7 (프로토타입 준비 게이트) — 명세→프로토타입 진입 검증

---

## 게이트의 3 가지 verdict

### ✅ PASS
모든 요구사항 만족. 즉시 다음 단계 진입.

### ⚠️ CONCERNS
일부 요구사항 미달, 그러나 *알려진* 위험. 다음 결정 가능:
1. 위험을 인지하고 진행 (사용자 명시적 승인 필요)
2. 위험 완화 후 재검증
3. 진행 차단 (FAIL 처리)

### ❌ FAIL
필수 요구사항 미달. 진행 불가. 누락된 산출물 작성 후 재검증.

---

## 게이트 요구사항 정의

각 게이트는 *필수* 요구사항 목록:

```markdown
## Gate: <이름>

### Required Artifacts (필수 산출물)
- [ ] artifact 1
- [ ] artifact 2
- [ ] ...

### Required Validations (필수 검증)
- [ ] validation 1 result == PASS
- [ ] validation 2 result == PASS or CONCERNS

### Hard Gate (강제 차단 조건)
다음 중 하나라도 해당 시 자동 FAIL:
- 조건 1
- 조건 2
- ...
```

---

## 본 파이프라인 게이트

### 단계 3 게이트 — 드래프트 저장 검증

진입 후보: 단계 4 (5-Axis 평가)

```markdown
## Required Artifacts
- [ ] workspace/<slug>/02-draft-A.md 존재
- [ ] workspace/<slug>/02-draft-B.md 존재
- [ ] workspace/<slug>/02-draft-C.md 존재

## Required Validations
- [ ] 각 드래프트가 ~800~1500 단어 범위
- [ ] 각 드래프트에 검증 가설 (H-1, H-2, H-3) 존재
- [ ] 3 드래프트가 서로 *의미 있게 다른* 분기 (메카닉 또는 장르)

## Hard Gate
- 3 드래프트 중 어느 하나라도 누락 → FAIL
- 3 드래프트가 사실상 동일 (분기 의미 없음) → CONCERNS
```

### 단계 7 게이트 — 프로토타입 준비 완료

진입 후보: 다음 워크플로우 (프로토타입 → 본 게임 빌드업)

```markdown
## Required Artifacts
- [ ] workspace/<slug>/06-integrated-spec.md 존재
- [ ] 9 섹션 (A~I) 모두 완성
- [ ] H. 프로토타입 가설 최소 3개 명시
- [ ] I. 인수 기준 최소 5개 명시

## Required Validations
- [ ] 모든 H 가설이 *측정 가능* (정량 또는 명확 boolean)
- [ ] 모든 AC 가 *환경 명시* (해상도·FPS·하드웨어)
- [ ] F. 아키텍처 지도의 핵심 결정 3~5개 명시
- [ ] G. 데이터 스키마 최소 1개 예시

## Hard Gate
- 9 섹션 중 누락 → FAIL
- H 가설 측정 불가능 → FAIL
- I 인수 기준 측정 불가능 → FAIL
```

---

## 외부 워크플로우 게이트 (참고)

본 파이프라인 외부지만 *다음 워크플로우*에서 활용:

### Concept Gate (CCGS Phase 1 → 2)
```markdown
## Required
- 게임 컨셉 문서 (8섹션 GDD 와 별개의 컨셉 양식)
- 게임 기둥 3개 + 안티 기둥 3개
- 시스템 인덱스 (모든 시스템 + 의존성 + 우선순위)
- 엔진 결정 (technical-preferences.md 명시)
- 위험 점수 매겨진 시스템 인덱스
```

### Systems Design Gate (Phase 2 → 3)
```markdown
## Required
- 모든 MVP 시스템 GDD (8섹션 완성, design-review APPROVED)
- Cross-GDD 리뷰 PASS 또는 CONCERNS
- 모든 GDD 의 의존성 양방향 일치
- 모든 GDD 의 기둥 정렬 명시
```

### Technical Setup Gate (Phase 3 → 4)
```markdown
## Required
- 마스터 아키텍처 문서
- 최소 3개 ADR (Accepted)
- 아키텍처 추적성 매트릭스 (Coverage ≥ 80%, Gap = 0)
- Control Manifest
- 접근성 요구사항 문서 (Tier commit)
```

### Pre-Production Gate (Phase 4 → 5)
```markdown
## Required (Hard Gate)
- 최소 1개 UX 스펙 작성·리뷰됨
- 최소 1개 프로토타입 (README + 가설)
- 스토리 파일 (구현 단위로 분해)
- 최소 1개 스프린트 계획
- **Vertical Slice 플레이테스트 리포트** (3 세션 이상, 무가이드)

→ Vertical Slice 미플레이테스트 시 자동 FAIL (가장 흔한 실패 원인)
```

---

## 게이트 검증 절차

```
1. 게이트 정의 확인 (Required Artifacts + Validations + Hard Gate)
2. 각 항목 체크 (자동화 가능한 것은 자동, 나머지 수동)
3. 결과 종합:
   - 모두 PASS → ✅ PASS
   - Hard Gate 위반 → ❌ FAIL
   - 일부 미달 (Hard 외) → ⚠️ CONCERNS
4. CONCERNS 시 사용자 결정:
   - 인지하고 진행 (사유 기록)
   - 완화 후 재검증
   - FAIL 처리
5. PASS 시 stage 진행 (production/stage.txt 갱신 등)
6. FAIL 시 차단 + 누락 항목 체크리스트 보고
```

---

## CONCERNS 처리

CONCERNS 는 *위험 인지된 진행*. 무시하면 안 됨.

### 사용자 결정 양식

```markdown
## Phase Gate CONCERNS — 사용자 결정

### Gate: <이름>
### Date: <YYYY-MM-DD>

### CONCERNS 항목
1. [항목] - [구체적 미달 내용]
2. ...

### 사용자 선택
- [ ] (A) 인지하고 강제 진행 — 사유 기록 필수
- [ ] (B) 완화 후 재검증
- [ ] (C) FAIL 로 다운그레이드 (진행 차단)

### 사유 / 완화 계획 (선택 A 또는 B 시)
...

### 서명
사용자: <이름>
일시: <YYYY-MM-DD>
```

→ 강제 진행 시 *기록*. 6개월 후 "왜 진행했지?" 답 가능해야.

---

## 안티패턴

### 1. 게이트 없이 진행
"빨리 가자" → 디자인 부채 누적 → 6개월 후 모든 시스템 재설계.

해결: 게이트 의무. 통과 안 하면 다음 단계 차단.

### 2. 게이트가 사실상 자동 PASS
요구사항이 너무 약하거나 검증 안 함.

해결: 각 요구사항이 *측정 가능*. Hard Gate 1개 이상.

### 3. CONCERNS 무시
"CONCERNS 도 PASS 와 비슷한 거지" → 위험 누적.

해결: CONCERNS 시 사용자 명시적 결정 + 사유 기록.

### 4. FAIL 후 무한 retry
같은 누락이 반복 → 게이트 통과만 우회 시도.

해결: FAIL 1회 후 *왜 누락됐는지* 분석. 절차 개선.

### 5. 게이트 후 재검증 안 함
PASS 받은 후 변경 발생 → 게이트 결과 stale.

해결: 큰 변경 후 게이트 재검증. 디자인 변경 propagation.

---

## 검증 체크리스트

게이트 정의 시:
- [ ] Required Artifacts 명시 (체크리스트 형태)
- [ ] Required Validations 명시 (PASS 기준 정량)
- [ ] Hard Gate 1개 이상
- [ ] verdict (PASS/CONCERNS/FAIL) 결정 절차 명시

게이트 검증 시:
- [ ] 모든 항목 자동/수동 체크
- [ ] verdict 결과 명시
- [ ] CONCERNS 시 사용자 결정 + 기록
- [ ] FAIL 시 누락 항목 보고
- [ ] PASS 시 stage 진행 + 갱신
