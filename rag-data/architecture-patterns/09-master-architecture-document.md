---
title: 마스터 아키텍처 문서 작성 패턴
collection: architecture-patterns
axis: E
theory_id: master-architecture-document
keywords: [master-architecture, architecture-document, system-boundaries, data-flow, integration-points, blueprint, layer-overview]
applies_to: [creation, implementation]
related: [adr-template, system-interface-contract, traceability-matrix, system-layering]
last_updated: 2026-04-28
---

# 마스터 아키텍처 문서

> 모든 ADR 의 *상위 골격*. "이 게임의 시스템이 어떻게 어울려 작동하는가" 의 한 화면 view.
> 단계 6 통합 명세서의 F. 아키텍처 지도 섹션의 베이스.

## 핵심 원리

ADR 들은 *각각의 결정*을 다룸. 그러나 *전체 그림*은 ADR 만으로 안 보임.

마스터 아키텍처 문서가 답하는 질문:
- 어떤 시스템들이 있고, 어느 레이어에 속하는가?
- 시스템 간 데이터가 어떻게 흐르는가?
- 외부 의존성이 무엇인가 (라이브러리·엔진·서비스)?
- 빌드·배포는 어떻게 되는가?
- 핵심 결정 (ADR) 의 *지도*는?

→ **30분 안에 새 합류자가 시스템 그림 이해 가능** 이 통과 기준.

---

## 표준 8 섹션

```markdown
# Master Architecture Document — <게임명>

> Version: 0.X
> Last Updated: YYYY-MM-DD
> Engine: <Godot 4.6 / Unity 2023.x / UE 5.x 등>
> ADRs Referenced: ADR-001 ~ ADR-N

---

## 1. Executive Summary
한 문단 요약. 어떤 게임의 어떤 아키텍처인가?

## 2. System Inventory & Layering
모든 시스템 + 레이어 + 우선순위 표.

## 3. Data Flow Map
시스템 간 데이터 흐름 다이어그램 + 설명.

## 4. Integration Points
외부 의존성 (엔진 SDK, 라이브러리, 서비스, 에셋).

## 5. Key Architecture Decisions
핵심 ADR 5~10개의 한 줄 요약 + 링크.

## 6. Build & Deployment
빌드 파이프라인, 타겟 플랫폼, 환경 변수, 배포 단계.

## 7. Performance Budgets
FPS·메모리·draw call·로딩 시간 등의 예산.

## 8. Open Questions / Risks
미결정 사항, 알려진 위험.
```

---

## 1. Executive Summary

```markdown
## 1. Executive Summary

본 게임은 [장르] 의 [엔진] 기반 [플랫폼] 게임이다.
아키텍처는 [핵심 패턴 1~2개] 를 채택하여 [목표 1·2] 를 달성한다.

핵심 결정:
- 메카닉: [한 문장]
- 데이터: [한 문장]
- 통신: [한 문장]
- 렌더링: [한 문장]
```

예시:
```markdown
본 게임은 2D 캐주얼 아케이드 낚시 게임이다. Godot 4.6 + GDScript 로 PC (Windows/macOS) 데스크톱 출시.

아키텍처는 4-layer (Foundation/Core/Feature/Presentation) + 시그널 기반 통신 + Resource 데이터 흐름 패턴을 채택하여 솔로 개발자의 빠른 반복과 시스템 격리를 달성한다.

핵심 결정:
- 메카닉: 두더지잡기식 클릭 액션 (단일 코어 메카닉)
- 데이터: ObjectDatabase Resource (15종 오브젝트, 데이터 주도)
- 통신: 시그널 + SpawnConfig Resource (단방향 데이터 흐름)
- 렌더링: 2D Forward+ (Vulkan 백엔드)
```

---

## 2. System Inventory & Layering

```markdown
## 2. System Inventory & Layering

### Foundation (3)
| # | 시스템 | 책임 |
|---|--------|------|
| 1 | 입력 핸들러 | 마우스·키보드·패드 통합 입력 |
| 2 | 씬 매니저 | 메뉴↔게임↔결과 전환 |
| 3 | 오브젝트 DB | 모든 오브젝트의 순수 데이터 저장소 |

### Core (4)
| # | 시스템 | 책임 |
|---|--------|------|
| 4 | 런 매니저 | 런 생명주기 |
| 5 | 행동 아키타입 | 4~5종 오브젝트 동작 패턴 |
| 6 | 스포너 | 가중치 랜덤·풀링 |
| 7 | 미니게임 | 코어 메카닉 (캐치) |

### Feature (3)
| # | 시스템 | 책임 |
|---|--------|------|
| 8 | 난이도 디렉터 | SpawnConfig 갱신 |
| 9 | 스코어링 | 점수·콤보·결과 |
| 10 | (VS) 영구 업그레이드 | 런 간 진보 |

### Presentation (2)
| # | 시스템 | 책임 |
|---|--------|------|
| 11 | HUD | 실시간 정보 표시 |
| 12 | 메뉴 시스템 | 메인 메뉴·결과 화면·옵션 |
```

---

## 3. Data Flow Map

```markdown
## 3. Data Flow Map

```
┌──────────────────┐
│  입력 핸들러     │ Foundation
└────────┬─────────┘
         │ mouse_clicked(pos)
         ▼
┌──────────────────┐
│   미니게임       │ Core
└────────┬─────────┘
         │ object_caught(id, value)
         ▼
┌──────────────────┐         ┌──────────────────┐
│   스코어링       │────────▶│      HUD         │
└──────────────────┘         └──────────────────┘
   Feature                        Presentation

       (난이도 디렉터)
              │
              │ SpawnConfig (Resource)
              ▼
       (스포너) → (오브젝트 풀)
                       │
                       ▼
                  (미니게임)
```

### 핵심 흐름

1. **입력 → 미니게임 → 스코어링 → HUD** (게임플레이 main path)
2. **난이도 디렉터 → SpawnConfig → 스포너** (단방향 설정 흐름)
3. **런 매니저 → (모든 시스템)** (paused/resumed 시그널 broadcast)
```

→ 다이어그램 형식: ASCII, mermaid, 또는 외부 이미지 첨부.

---

## 4. Integration Points

```markdown
## 4. Integration Points

### Engine
- Godot 4.6
- Renderer: Vulkan (Forward+)
- Physics: Jolt (4.6 기본값)
- Language: GDScript 100% (C# 미사용)

### Libraries / Addons
| 이름 | 버전 | 용도 | ADR |
|------|------|------|-----|
| (없음) | - | - | - |

→ MVP 외부 라이브러리 0개. 의존성 최소화.

### Services
| 서비스 | 용도 | 옵션? |
|--------|------|------|
| (없음) | - | - |

→ 단일 플레이어, 오프라인. 외부 서비스 없음.

### Assets
- 사운드: 자체 제작 + free 에셋 (BGM 5곡, SFX 30종)
- 이미지: 자체 제작 픽셀 아트 (16-bit 스타일)
- 폰트: Determination Mono (오픈 라이센스)
```

---

## 5. Key Architecture Decisions

```markdown
## 5. Key Architecture Decisions

본 섹션은 ADR 들의 *지도*. 자세한 내용은 각 ADR 참조.

| ADR | 제목 | 결정 한 줄 | 영향 |
|-----|------|-----------|------|
| ADR-001 | 통신 패턴 | 시그널 기반 (직접 호출 금지) | 모든 시스템 |
| ADR-002 | 데이터 흐름 | Resource (불변) + Service (변경 가능) | 데이터 처리 |
| ADR-003 | 레이어링 | Foundation/Core/Feature/Presentation 4계층 | 모든 시스템 |
| ADR-004 | 상태 머신 | FSM 채택 (Behavior Tree 거부) | NPC, 메뉴 |
| ADR-005 | 세이브 형식 | JSON + ISaveable 인터페이스 | 세이브 시스템 (VS) |

각 ADR 의 Status 와 dependencies 는 traceability matrix 참조 (`docs/architecture/architecture-traceability.md`).
```

---

## 6. Build & Deployment

```markdown
## 6. Build & Deployment

### 환경
| 환경 | 용도 | 빌드 명령 |
|------|------|----------|
| dev | 로컬 개발 | godot --editor |
| staging | 테스트 빌드 | godot --export-debug |
| release | 출시 빌드 | godot --export-release |

### 타겟 플랫폼
- Windows x64 (.exe)
- macOS Universal (.app)
- Linux x64 (시도하지 않음, 추후)

### 빌드 파이프라인
1. main 브랜치 push
2. GitHub Actions 트리거
3. Godot headless 로 export
4. Steam Cloud 업로드 (release 만)

### 환경 변수
- GODOT_VERSION=4.6
- BUILD_NUMBER (CI 자동 설정)
- (시크릿) STEAM_API_KEY
```

---

## 7. Performance Budgets

```markdown
## 7. Performance Budgets

| 항목 | 예산 | 측정 환경 |
|------|------|----------|
| FPS | 60 (target), 30 (minimum) | M1 Mac, 1080p |
| Frame budget | 16.6ms (60fps) | M1 Mac |
| Memory ceiling | 512MB | M1 Mac |
| Draw calls | < 200 | 2D 픽셀 아트 |
| 로딩 시간 | < 5초 (메뉴→게임) | SSD 기준 |
| 빌드 크기 | < 100MB (압축) | Steam 권장 |

### 측정 방식
- FPS·frame time: Godot profiler
- Memory: Activity Monitor / Performance Monitor
- Draw calls: Godot debug overlay

### 위반 시 대응
- ≥ 1 frame 초과: BLOCKING — perf-profile 실행
- 메모리 초과: BLOCKING — 누수 검사
- Draw call 초과: ADVISORY — 배칭·LOD 검토
```

---

## 8. Open Questions / Risks

```markdown
## 8. Open Questions / Risks

### Open Questions
- [ ] OQ-1: macOS 의 Apple Silicon vs Intel 빌드 분리? (성능 vs 단순성)
- [ ] OQ-2: 키보드 입력의 키 리매핑 시스템? (접근성 tier 결정에 따라)

### Known Risks
- 🔴 Critical: 미니게임 코어 (위험 점수 18) — 프로토타입 완료 후 평가
- 🟠 High: 난이도 디렉터 (위험 점수 14) — 백업 옵션 1
- 🟡 Medium: 세이브/로드 (Phase 2 신규 시스템)

각 위험의 자세한 분석은 `design/risk-register.md` 참조.
```

---

## 안티패턴

### 1. ADR 만, 마스터 문서 없음
각 ADR 은 잘 적혀있지만 *전체 그림*이 없음 → 새 합류자가 시스템 이해 못함.

해결: 마스터 문서를 ADR 들의 지도로. 30분 view.

---

### 2. 마스터 문서가 ADR 의 복사
각 ADR 의 본문을 그대로 옮김 → 변경 시 두 곳 갱신 필요 → stale.

해결: 마스터는 *요약*만. 자세한 내용은 ADR 참조 (링크).

---

### 3. 마스터 문서 갱신 누락
ADR 추가됐는데 마스터 미갱신 → 마스터 stale.

해결: ADR 추가/변경 시 마스터 동시 갱신 (또는 매트릭스로 자동).

---

### 4. 다이어그램 없음
Data Flow Map 섹션이 텍스트만 → 시스템 관계 한눈에 안 들어옴.

해결: ASCII 또는 mermaid 또는 이미지. 한 화면 view 필수.

---

### 5. Performance Budget 없음
"60fps 유지" 만 적고 나머지 (메모리·draw call·로딩) 없음.

해결: 측정 가능한 모든 차원에 예산.

---

## 본 파이프라인 적용

### 단계 6 (통합 명세서) F. 아키텍처 지도 섹션

본 파이프라인은 *간소판* 마스터 아키텍처를 작성:
- 통합 명세서의 F 섹션이 위 8섹션의 *압축판* (1~2 페이지)
- 풀 마스터 아키텍처는 다음 워크플로우 (프로토타입→빌드업) 에서 확장

```markdown
## F. 아키텍처 지도 (단계 6 출력)

### F.1 시스템·레이어 (8 섹션 중 2 의 압축)
[표]

### F.2 데이터 흐름 (8 섹션 중 3 의 압축)
[다이어그램]

### F.3 핵심 결정 3~5 개 (ADR 미니 양식)
- 결정 1: 시그널 기반 통신
- 결정 2: Resource 데이터 흐름
- 결정 3: 4-layer 시스템
...

### F.4 외부 의존성 (8 섹션 중 4)
- 엔진: Godot 4.6
- 라이브러리: 없음
```

---

## 검증 체크리스트

마스터 아키텍처 작성 후:

- [ ] 8 섹션 모두 존재
- [ ] Executive Summary 한 문단
- [ ] 모든 시스템이 inventory 에 + 레이어 할당
- [ ] Data Flow Map 다이어그램 (텍스트/이미지)
- [ ] 외부 의존성 모두 명시 (없으면 "없음" 명시)
- [ ] 핵심 ADR 5~10개 한 줄 요약 + 링크
- [ ] Performance Budgets 측정 환경 명시
- [ ] Open Questions / Risks 정리
- [ ] 새 합류자가 30분 안에 이해 가능 (자기 검증)
- [ ] 갱신 시 traceability matrix 자동 갱신 트리거
