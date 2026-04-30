# RAG 추가 권장 문서 카탈로그

> 본 파이프라인이 hwicortex RAG로 회수해서 더 정확한 출력을 내기 위해, 신규 등록하면 좋을 컬렉션과 자료 목록.
> 
> **현재 상태**:
> - ✅ `gdd-evaluation` 등록됨 (5-Axis 14개 이론)
> - 🟡 `gdd-wisdom` 작성됨 (`rag-data/gdd-wisdom/`), 등록 대기
> - 🟡 `architecture-patterns` 작성됨 (`rag-data/architecture-patterns/`), 등록 대기
> - ⏸ `indie-postmortems`, `market-snapshots` 미작성 (선택)

---

## 우선순위 매트릭스

| 우선순위 | 컬렉션 | 영향받는 단계 | 상태 |
|----------|--------|--------------|------|
| 🔴 P0 | `gdd-wisdom` | 2, 4, 5, 6 | ✅ 작성 완료 → 등록만 하면 됨 |
| 🔴 P0 | `architecture-patterns` | 4, 5, 6 | ✅ 작성 완료 → 등록만 하면 됨 |
| 🟡 P1 | `indie-postmortems` | 4 (Axis E) | ⏸ 외부 자료 수집 필요 |
| 🟡 P1 | `market-snapshots` | 4 (Axis E) | ⏸ 외부 자료 수집 필요 |

---

## P0 — 즉시 등록 가능 (자료 작성 완료)

### 1. `gdd-wisdom` — GDD 메타 원칙·표준 ★ 작성 완료

**위치**: `~/concept-pipeline/rag-data/gdd-wisdom/`

**포함**:
- 8섹션 GDD 표준
- 게임 기둥과 안티 기둥
- 시스템 레이어링 (Foundation/Core/Feature/Presentation)
- 의존성 양방향 규약
- Game Feel 명세 양식
- GDD 안티패턴 모음

**용도**: 단계 2 (분기 초안 시 표준 형식), 단계 4 (평가 시 안티패턴 차단), 단계 5·6 (작성 시 표준 적용).

**등록 명령**:
```bash
hwicortex collection add ~/concept-pipeline/rag-data/gdd-wisdom \
  --name gdd-wisdom \
  --pattern "**/*.md"

hwicortex context add "qmd://gdd-wisdom/" \
  "GDD 메타 원칙·표준. 8섹션 표준, 기둥/안티기둥, 레이어링, 양방향 의존성, Game Feel, 안티패턴."

hwicortex update && hwicortex embed
```

등록 후 `~/concept-pipeline/config.yaml` 의 `gdd-wisdom.status` → `ready`.

---

### 2. `architecture-patterns` — 아키텍처 표준 ★ 작성 완료

**위치**: `~/concept-pipeline/rag-data/architecture-patterns/`

**포함**:
- ADR 미니 템플릿
- Control Manifest 양식
- TR-ID 시스템
- 테스트 증거 매트릭스
- 시스템 인터페이스 계약 패턴

**용도**: 단계 4 (Axis E 평가), 단계 5 (시스템 인터페이스 계약), 단계 6 (통합 명세서의 F·G·I 섹션).

**등록 명령**:
```bash
hwicortex collection add ~/concept-pipeline/rag-data/architecture-patterns \
  --name architecture-patterns \
  --pattern "**/*.md"

hwicortex context add "qmd://architecture-patterns/" \
  "아키텍처 표준. ADR, Control Manifest, TR-ID, 테스트 증거 매트릭스, 시스템 인터페이스 계약."

hwicortex update && hwicortex embed
```

등록 후 `config.yaml` 의 `architecture-patterns.status` → `ready`.

---

## P1 — 자료 수집 후 등록

### 3. `indie-postmortems` — 인디 포스트모템

**용도**: 4단계 Axis E (실현·지속성) 평가 시 "이런 스코프는 실제로 가능했는지" 근거 회수.

**핵심 자료**:
- **GDC Vault 공개 포스트모템** — youtube.com/c/Gdconf
  - 검색어: "postmortem", "indie postmortem", "what went right what went wrong"
  - 솔로/소규모 사례 우선: Lucas Pope (Papers Please), Edmund McMillen (Isaac), Eric Barone (Stardew)
- **155 Indie Postmortems Study** (Game Developer 저널, 2022)
  - 실패 패턴 통계 (스코프 30%, 마케팅 20%, ...)
- **Gamasutra/Game Developer 포스트모템 아카이브**
  - https://www.gamedeveloper.com/category/business
- **Steam 100인 인디 인터뷰** (Howtomarketagame 블로그)
- **/r/gamedev 회고 글 모음**

**구성 권장**:
```
indie-postmortems/
├── 00-failure-patterns.md         # 통계 요약
├── solo-developer/
│   ├── stardew-valley.md
│   ├── papers-please.md
│   └── ...
├── small-team/
│   ├── celeste.md
│   ├── hades.md
│   └── ...
└── lessons-by-axis/
    ├── scope-creep.md             # Axis E 직접 매핑
    ├── motivation-failure.md      # Axis B
    ├── cognition-overload.md      # Axis C
    └── ...
```

**최소 출발점**: 본인이 좋아하는 게임 5개 + 실패 사례 5개의 포스트모템만 정리해도 시작.

---

### 4. `market-snapshots` — 시장 데이터 스냅샷

**용도**: 4단계 Axis E (시장성) 평가 시 "이 장르의 실제 매출/도달 가능성" 근거.

**핵심 자료**:
- **gamalytic** — 장르별 Steam 매출 분포 보고서
  - https://gamalytic.com/blog
- **VG Insights** — 인디 시장 분기별 보고서
  - https://vginsights.com/insights
- **SteamDB 차트** — 동시접속자, 리뷰 수, 가격 분포
  - https://steamdb.info/charts/
- **How To Market A Game** (Chris Zukowski) — 인디 마케팅·디스커버리 데이터
  - https://howtomarketagame.com/
- **Steam NextFest 결과 보고서** (분기별)
- **Itch.io top sellers** + **Korean 인디 데이터** (스토브인디 연간 보고서)

**갱신 주기**: 6개월마다 신규 보고서 추가. 너무 오래된 데이터는 archive 처리.

---

## 등록 후 체크리스트

새 컬렉션 등록 시 확인:

```bash
# 1. 등록
hwicortex collection add <path> --name <name> --pattern "**/*.md"

# 2. 컨텍스트 추가 (검색 정확도 향상)
hwicortex context add "qmd://<name>/" "<설명>"

# 3. 인덱싱 + 임베딩
hwicortex update && hwicortex embed

# 4. 상태 확인
hwicortex status
hwicortex ls <name>

# 5. 테스트 쿼리
hwicortex query "<테스트 검색어>" -c <name> --json -n 3
```

이후 `~/concept-pipeline/config.yaml` 의 해당 컬렉션 `status: pending` → `status: ready` 로 수정.

---

## 빠른 시작 — P0 두 컬렉션 한번에 등록

```bash
cd ~/concept-pipeline

hwicortex collection add ./rag-data/gdd-wisdom --name gdd-wisdom --pattern "**/*.md"
hwicortex context add "qmd://gdd-wisdom/" \
  "GDD 메타 원칙·표준. 8섹션 표준, 기둥/안티기둥, 레이어링, 양방향 의존성, Game Feel, 안티패턴."

hwicortex collection add ./rag-data/architecture-patterns --name architecture-patterns --pattern "**/*.md"
hwicortex context add "qmd://architecture-patterns/" \
  "아키텍처 표준. ADR, Control Manifest, TR-ID, 테스트 증거 매트릭스, 시스템 인터페이스 계약."

hwicortex update && hwicortex embed
hwicortex query "8 section GDD standard" -c gdd-wisdom -n 3
hwicortex query "ADR template" -c architecture-patterns -n 3
```

테스트 쿼리가 결과 반환하면 `config.yaml` 의 `status` 둘 다 `ready` 로 변경하고 첫 파이프라인 사이클 시작.

---

## 결정 — 미사용 컬렉션

다음 컬렉션은 본 파이프라인에서 사용하지 않기로 결정:

- ❌ `gdd-references` — 운영 표준만 추출하기로 함 (실증 GDD 예시 미포함)
- ❌ `genre-mechanic-lexicon` — 필요 시 추후 결정
- ❌ `personal-archive` — 필요 시 추후 결정

이유: 첫 사이클은 검증된 표준 + 학술 이론 + 평가 루브릭만으로 충분히 작동. 나머지는 첫 사이클 결과 보고 결정.
