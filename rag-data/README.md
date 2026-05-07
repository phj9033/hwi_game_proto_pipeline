# rag-data — concept-pipeline 의 RAG 자산

> 본 파이프라인이 사용하는 모든 RAG 컬렉션을 한 곳에 보관.
> 자기완결적 — 다른 디렉토리 없이도 모든 자산이 여기 있음.

## 목적

- **자기완결**: 외부 의존 없이 본 디렉토리만으로 모든 RAG 자산 보유
- **재사용**: 다른 게임 프로젝트에서도 동일 자산 활용 (디렉토리 통째로 복사)
- **RAG ready**: 추후 RAG 시스템 연결 시 그대로 적재 가능한 표준 frontmatter 양식 유지
- **즉시 시작 보장**: 등록 안 해도 사람이 읽을 수 있는 표준 문서

## 컬렉션 (3개)

### `gdd-evaluation/` — 학술 이론 라이브러리 (14 docs + index)
게임 디자인 평가의 학술적 근거. 5-Axis 모델 기반.
- 00 Living Document 원칙
- 01 SDT/PENS, 02 Bartle/HEXAD, 03 Octalysis (동기 이론)
- 04 Flow, 05 Cognitive Load, 06 Laws of UX, 07 FTUE (인지·UX 이론)
- 08 MDA/RMDA, 09 Elemental Tetrad (정합성 이론)
- 10 Vertical Slice, 11 F2P KPI, 12 Loss Aversion, 13 Variable Ratio, 14 Publisher Greenlight (실현·BM)

자세한 내용: `gdd-evaluation/index.md`

> 본 자료는 외부 출처에서 복사된 스냅샷 — 본 디렉토리는 **자기완결성·휴대성** 목적.
> 원본이 변경되면 수동 동기화 필요.

### `gdd-wisdom/` — GDD 메타 원칙·표준 (9 docs + index)
GDD 작성·검증의 운영 표준 (CCGS distilled).
- 01 8섹션 GDD 표준
- 02 게임 기둥과 안티 기둥
- 03 시스템 레이어링 (Foundation/Core/Feature/Presentation)
- 04 의존성 양방향 규약
- 05 Game Feel 명세 양식
- 06 GDD 안티패턴 모음
- 07 브레인스토밍 프로세스 패턴
- 08 Cross-GDD 일관성 검증 패턴
- 09 고위험 시스템 식별 패턴

자세한 내용: `gdd-wisdom/index.md`

### `architecture-patterns/` — 아키텍처 표준 (5 docs + index)
기술적 결정·시스템 통신의 운영 표준 (CCGS distilled).
- 01 ADR 미니 템플릿
- 02 Control Manifest 양식
- 03 TR-ID 시스템
- 04 테스트 증거 매트릭스
- 05 시스템 인터페이스 계약 패턴

자세한 내용: `architecture-patterns/index.md`

## 컬렉션 간 관계

| 컬렉션 | 역할 | 보완 관계 |
|--------|------|-----------|
| `gdd-evaluation` | *왜* (학술 이론) | gdd-wisdom 의 *어떻게* 와 상보적 |
| `gdd-wisdom` | *어떻게* (운영 표준) | gdd-evaluation 의 이론을 실무 표준으로 |
| `architecture-patterns` | *코드 수준* (기술 표준) | gdd-wisdom 보다 한 단계 더 구현 측 |

## RAG 시스템 연결 (추후)

현재 본 디렉토리 자료는 RAG 시스템에 미연결 상태. 추후 연결 시 각 컬렉션 디렉토리(`gdd-evaluation/`, `gdd-wisdom/`, `architecture-patterns/`)를 그대로 적재.

컬렉션별 자세한 자료 구조는 각 디렉토리의 `index.md` 참조.

## 갱신

각 컬렉션은 *살아있는 문서*. 새 패턴·안티패턴 발견 시 업데이트.

## frontmatter 표준

세 컬렉션 모두 동일 양식:

```yaml
---
title: <한글명>
collection: gdd-evaluation | gdd-wisdom | architecture-patterns
axis: A | B | C | D | E | ALL
theory_id: <slug>
keywords: [<영문 키워드>...]
applies_to: [creation, evaluation, implementation]
related: [<관련 theory_id>...]
last_updated: <YYYY-MM-DD>
---
```

`axis` 필터·`theory_id` 매칭·`keywords` 검색 모두 지원.

## 5-Axis 매핑 (3 컬렉션 통합)

| Axis | gdd-evaluation | gdd-wisdom | architecture-patterns |
|------|---------------|-----------|----------------------|
| A 구조 | 00 Living Document | 01 8섹션, 06 안티패턴 | — |
| B 동기 | 01·02·03 (SDT/Bartle/Octalysis) | 07 브레인스토밍 | — |
| C 인지 | 04·05·06·07 (Flow/CLT/UX/FTUE) | 05 Game Feel | — |
| D 정합 | 08·09 (MDA·Tetrad) | 02 기둥, 03 레이어, 04 양방향, 08 Cross-GDD | 05 시스템 인터페이스 |
| E 실현 | 10·11·12·13·14 | 09 고위험 시스템 | 01 ADR, 02 Manifest, 03 TR-ID, 04 테스트 증거 |

## 미사용 컬렉션 결정

다음은 본 파이프라인에서 사용하지 않기로 결정:

- ❌ `gdd-references` — 실증 GDD 예시. 운영 표준만 추출하기로 함.
- ❌ `genre-mechanic-lexicon` — 장르·메카닉 카탈로그. 필요 시 추후.
- ❌ `personal-archive` — 개인 아카이브. 필요 시 추후.

## 라이센스·출처

- `gdd-evaluation/`: 외부 출처에서 복사된 스냅샷
- `gdd-wisdom/`, `architecture-patterns/`: CCGS (Claude Code Game Studios) 프로젝트 운영 결과 distilled
  - 단일 게임 프로젝트 종속에서 분리하여 일반화
