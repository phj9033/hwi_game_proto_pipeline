---
title: architecture-patterns 컬렉션 인덱스
collection: architecture-patterns
axis: ALL
theory_id: index
keywords: [architecture, patterns, ADR, control-manifest, TR-ID, test-evidence, system-interface, index]
applies_to: [creation, implementation, evaluation, navigation]
related: [all]
last_updated: 2026-04-28
---

# architecture-patterns — 아키텍처 표준 컬렉션

> 게임 시스템의 *기술적 구조*에 관한 운영 표준. CCGS 프로젝트에서 축적된 아키텍처 자산을 추출.
> `gdd-wisdom` 이 디자인 문서 표준이라면, 본 컬렉션은 *코드와 의사결정*의 표준이다.

## 목적

- 기술적 결정 (ADR) 의 형식·라이프사이클 규약
- 프로그래머용 행동 규칙 (Control Manifest) 패턴
- GDD ↔ ADR ↔ 코드 ↔ 테스트의 추적성 (TR-ID 시스템)
- 스토리 타입별 검증 방식 (Test Evidence Matrix)
- 시스템 간 통신 패턴 (Interface Contract)

## 5-Axis 매핑

| Axis | 본 컬렉션의 기여 |
|------|-----------------|
| A 구조적 완성도 | (gdd-wisdom 이 담당) |
| B 심리적 동기 | (gdd-evaluation 이 담당) |
| C 인지적 수용성 | (gdd-wisdom Game Feel 이 담당) |
| D 시스템 정합성 | 시스템 인터페이스 계약 |
| E 실현·지속성 | ADR, Control Manifest, TR-ID, 테스트 증거 |

## 문서 카탈로그

### 1. ADR 미니 템플릿 (`01-adr-template.md`)
Architecture Decision Record 의 8 섹션 양식 (Status / Context / Decision / Alternatives / Consequences / Dependencies / Engine Compatibility / GDD Requirements). Status 라이프사이클 (Proposed → Accepted → Superseded). 작성 가이드와 안티패턴.

**적용**: 단계 6 (통합 명세서의 F. 아키텍처 지도 — 핵심 결정 3~5개 ADR 미니 양식으로)

---

### 2. Control Manifest 양식 (`02-control-manifest.md`)
ADR 들에서 추출한 *플랫* 행동 규칙 시트. 레이어별 Required / Forbidden / Guardrails. Manifest Version 으로 staleness 감지.

**적용**: 단계 6 (통합 명세서의 F. 아키텍처 지도 — 프로그래머가 즉시 따를 규칙)

---

### 3. TR-ID 시스템 (`03-tr-id-system.md`)
GDD 요구사항에 stable identifier 부여 (`TR-MOV-001` 형식). tr-registry.yaml 단일 소스. 추가만, 재번호·삭제 금지. ADR / 스토리 / 테스트가 ID 로 인용 → GDD 텍스트 변경에 강건.

**적용**: 단계 6 (통합 명세서의 F·G·I 섹션에서 요구사항 식별), 단계 5 의 시스템별 요구사항 정리

---

### 4. 테스트 증거 매트릭스 (`04-test-evidence-matrix.md`)
스토리 타입 5개 (Logic / Integration / Visual / UI / Config) 별 필요 증거 형식. BLOCKING vs ADVISORY 게이트. 자동화 vs 수동 결정 가이드.

**적용**: 단계 6 (통합 명세서의 I. 인수 기준 — AC 별로 어떤 증거 형식)

---

### 5. 시스템 인터페이스 계약 패턴 (`05-system-interface-contract.md`)
Resource/Config (불변 데이터), 시그널 발행·구독, 의존성 주입, 단방향 데이터 흐름, 읽기/쓰기 분리, SaveableComponent. 시스템 간 통신의 5가지 핵심 패턴.

**적용**: 단계 5 (시스템 인벤토리의 인터페이스 명세), 단계 6 (시스템 인벤토리 표·아키텍처 지도)

---

### 6. 프로토타입 코드 표준 (Relaxed) (`06-prototype-code-standards.md`)
prototypes/ 디렉토리의 완화된 표준. 허용 (하드코딩, 글로벌 상태) vs 필수 (격리, README, 가설). 성공 시 production 으로 직접 마이그레이션 금지 (재작성 강제).

**적용**: 단계 7 (프로토타입 준비 완료의 *수신자* 기준), 다음 워크플로우 (프로토타입→빌드업) 의 시작점

---

### 7. 아키텍처 추적성 매트릭스 (`07-architecture-traceability-matrix.md`)
TR-ID × ADR 의 행 단위 매트릭스. Coverage 통계 (Covered/Partial/Gap), Untraced 검사, Stale 참조 검사, Living Document 갱신 패턴.

**적용**: 단계 6 (통합 명세서의 F. 아키텍처 지도 — 결정 ↔ 요구사항 매핑)

---

### 8. Context Management (`08-context-management.md`)
File-backed state, incremental write, proactive compaction, subagent delegation, crash recovery 패턴. SKILL.md 운영의 메타 패턴.

**적용**: 모든 단계 — 본 파이프라인의 SKILL.md 운영 기반

---

### 9. 마스터 아키텍처 문서 (`09-master-architecture-document.md`)
8 섹션 (Summary / Inventory / Data Flow / Integration / Decisions / Build / Performance / Risks). ADR 들의 *전체 그림*. 30분 view.

**적용**: 단계 6 (F. 아키텍처 지도 의 베이스 — 간소판으로 적용)

---

### 10. Playtest Report 구조 (`10-playtest-report-structure.md`)
11 섹션 + Hypothesis Verdict + 4 종 Verdict (PROCEED/PROCEED with adjustments/PIVOT/KILL). 다중 세션 분석.

**적용**: 단계 7 후 다음 워크플로우의 첫 산출물 양식

---

## 사용 가이드

### 작성 시 (단계 5·6)
새 시스템·결정 작성 시:
1. 결정이라면 → `01-adr-template.md` 양식
2. 시스템 인터페이스라면 → `05-system-interface-contract.md` 패턴 적용
3. 요구사항 명시라면 → `03-tr-id-system.md` 의 ID 부여
4. 검증 명세라면 → `04-test-evidence-matrix.md` 의 타입 매핑

### 검증 시 (단계 4)
평가 시 Axis E 검증:
1. ADR 형식 준수 → `01-adr-template.md` 체크리스트
2. 시스템 결합도 → `05-system-interface-contract.md` 안티패턴
3. 검증 가능성 → `04-test-evidence-matrix.md` 의 인수 기준 매핑

### RAG 회수 시
hwicortex 쿼리 예시:
```bash
# ADR 양식 회수
hwicortex query "ADR architecture decision record context consequences" -c architecture-patterns -n 3

# 시스템 인터페이스 패턴 회수
hwicortex query "system interface contract resource signal dependency injection" -c architecture-patterns -n 3

# TR-ID 회수
hwicortex query "TR-ID requirement stable identifier registry traceability" -c architecture-patterns -n 3

# 프로토타입 표준 회수
hwicortex query "prototype throwaway hypothesis README relaxed standards" -c architecture-patterns -n 3

# 추적성 매트릭스 회수
hwicortex query "traceability matrix coverage gap untraced stale" -c architecture-patterns -n 3

# 테스트 증거 매트릭스 회수
hwicortex query "test evidence story type logic integration visual UI" -c architecture-patterns -n 3
```

## 표준 frontmatter

각 문서 동일 양식:

```yaml
---
title: <한글명>
collection: architecture-patterns
axis: D | E
theory_id: <slug>
keywords: [...]
applies_to: [creation, evaluation, implementation]
related: [<관련 theory_id>...]
last_updated: 2026-04-28
---
```

## 등록 명령

```bash
hwicortex collection add ~/concept-pipeline/rag-data/architecture-patterns \
  --name architecture-patterns \
  --pattern "**/*.md"

hwicortex context add "qmd://architecture-patterns/" \
  "아키텍처 표준 컬렉션. ADR, Control Manifest, TR-ID, 테스트 증거 매트릭스, 시스템 인터페이스 계약 패턴."

hwicortex update && hwicortex embed
```

이후 `~/concept-pipeline/config.yaml` 에 `architecture-patterns.status: pending` → `ready` 변경.
