---
title: gdd-wisdom 컬렉션 인덱스
collection: gdd-wisdom
axis: ALL
theory_id: index
keywords: [GDD, wisdom, standards, principles, index, navigation]
applies_to: [creation, evaluation, navigation]
related: [all]
last_updated: 2026-04-28
---

# gdd-wisdom — 메타 원칙·표준 컬렉션

> 게임 디자인 문서의 *작성 표준*과 *검증 원칙*. CCGS 프로젝트 운영 중 축적된 자산을 추출.
> 본 컬렉션은 `gdd-evaluation` 의 학술 이론과 상보적이다 — gdd-evaluation 이 *왜* 라면, gdd-wisdom 은 *어떻게*.

## 목적

- GDD 를 작성할 때 빠지지 말아야 할 구조·규약 제공
- GDD 를 검증할 때 차단해야 할 안티패턴 제공
- "이 프로젝트의 GDD 는 이렇게 생겨야 한다" 라는 표준 명문화

## 5-Axis 매핑

| Axis | 본 컬렉션의 기여 |
|------|-----------------|
| A 구조적 완성도 | 8섹션 표준, 안티패턴 |
| B 심리적 동기 | 브레인스토밍 (동기 매핑) |
| C 인지적 수용성 | Game Feel 명세 |
| D 시스템 정합성 | 레이어링, 양방향 의존성, 기둥/안티기둥, Cross-GDD 일관성 |
| E 실현·지속성 | 고위험 시스템 식별 (그 외는 architecture-patterns 컬렉션) |

## 문서 카탈로그

### 1. 8섹션 GDD 표준 (`01-8section-gdd-standard.md`)
모든 시스템 GDD 가 따라야 할 8개 섹션 (Overview / Player Fantasy / Detailed Rules / Formulas / Edge Cases / Dependencies / Tuning Knobs / Acceptance Criteria) 의 정확한 정의·예시·검증 기준.

**적용**: 단계 5 (상세 확장), 단계 6 (통합 명세서)

---

### 2. 게임 기둥과 안티 기둥 (`02-pillar-and-antipillar.md`)
3개 기둥 + 3개 안티 기둥 구조. 슬로건·메카닉 함의·측정 신호의 형식. drift 감지와 시스템-기둥 정렬 패턴.

**적용**: 단계 1 (컨셉 정립), 단계 5 (확장 시 기둥 정렬 검증)

---

### 3. 시스템 레이어링 (`03-system-layering.md`)
Foundation / Core / Feature / Presentation 4개 레이어 정의. 의존 방향 규칙 (위→아래만). 레이어 식별 절차와 위반 사례.

**적용**: 단계 2 (분기 초안 시 시스템 분류), 단계 5 (시스템 인벤토리)

---

### 4. 의존성 양방향 규약 (`04-bidirectional-dependency.md`)
A → B 의존 시 B 의 GDD 도 A 를 명시해야 한다는 규칙. 결합 강도 분류 (strong/medium/weak). 검증 절차와 흔한 실패 패턴.

**적용**: 단계 5 (시스템 인벤토리), 단계 6 (인터페이스 계약)

---

### 5. Game Feel 명세 양식 (`05-game-feel-spec.md`)
입력 반응성·애니메이션 페이즈·임팩트 모먼트·무게감·오디오·비주얼 주스의 6 차원. 모든 차원의 정량 명세 양식.

**적용**: 단계 5 (시스템 확장 시 Game Feel 섹션 작성), 단계 6 (UX 흐름 + 비주얼/오디오 톤)

---

### 6. GDD 안티패턴 모음 (`06-gdd-antipatterns.md`)
8섹션별로 반복되는 실수들. 일반 안티패턴 4개 + 섹션별 30+ 안티패턴 + 메타 안티패턴.

**적용**: 단계 4 (평가 시 차단 패턴), 단계 5·6 (작성 중 자가 점검)

---

### 7. 브레인스토밍 프로세스 패턴 (`07-brainstorm-process.md`)
6단계 발산→수렴 프로세스 (의도 → 10 시드 → 2~3 선정 → MDA·동기 분석 → 1 선정 → 컨셉 문서화). MDA 분해, Bartle/Octalysis 동기 매핑, 비교 게임 분석.

**적용**: 단계 1 (컨셉 정립의 깊이 확보)

---

### 8. Cross-GDD 일관성 검증 패턴 (`08-cross-gdd-consistency.md`)
9개 카테고리의 cross-review 검증 (의존성 양방향·룰 충돌·소유권 충돌·공식 범위·stale 참조·AC cross-check·기둥 drift·인지 부하·지배 전략). BLOCKING/WARNING/INFO 분류.

**적용**: 단계 4 (5-Axis 평가 보강 — 시스템 간 정합성)

---

### 9. 고위험 시스템 식별 패턴 (`09-high-risk-system-identification.md`)
4 차원 위험 점수 (의존도·신규성·복잡도·디자인 리스크) + 위험 매트릭스 + 대응 전략 (프로토타입 먼저·완화 계획·우선순위 상위·여유 일정).

**적용**: 단계 2 (분기 초안 시 위험 분포 평가), 단계 5 (확장 우선순위 결정)

---

### 10. 협업 프로토콜 (Q→O→D→D→A) (`10-collaborative-protocol.md`)
Question → Options → Decision → Draft → Approval 5단계 메타 패턴. AI=상담자, 사용자=결정자. 모든 단계 대화의 운영 표준. 안티패턴과 자기 점검 신호.

**적용**: 모든 단계 — 본 파이프라인의 *대화 톤*을 정의

---

### 11. Player Journey 매핑 (`11-player-journey-mapping.md`)
3개 시간 스케일 (세션·런·진보) 의 플레이어 여정. 감정 곡선·정보 발견 곡선·이탈 신호 식별.

**적용**: 단계 1 (컨셉의 시간축 깊이), 단계 5 (UX 흐름)

---

### 12. 난이도 곡선 설계 (`12-difficulty-curve-design.md`)
5 가지 곡선 형태 (Linear/Stepped/Exp/S/Sawtooth) + 도전 차원 6개 + DDA 패턴 + 페이싱.

**적용**: 단계 5 (시스템 확장 시 난이도 곡선 명세)

---

### 13. 경제 모델 설계 (`13-economy-model-design.md`)
Source/Sink 균형, 변환율, 인플레이션 통제 5 패턴, F2P vs Premium, 시뮬레이션 검증.

**적용**: 단계 5 (재화·경제 시스템 있는 게임)

---

### 14. 접근성 요구사항 (`14-accessibility-requirements.md`)
4 축 (시각·운동·인지·청각) × 4 tier (Basic/Standard/Comprehensive/Exemplary). 컨셉 단계 commit 의무.

**적용**: 단계 1 (Tier commit), 단계 6 (UX 흐름의 접근성 옵션)

---

### 15. UX 명세 패턴 (`15-ux-spec-pattern.md`)
3 가지 명세 (Screen/Flow Spec, HUD Design, Interaction Pattern Library) + 16 표준 패턴 + 게임 특화 패턴.

**적용**: 단계 6 (D. UX 흐름 섹션)

---

### 16. 비주얼·오디오 바이블 (`16-visual-and-audio-bible.md`)
Art Bible (색팔레트·라이팅·아트 스타일) + Sound Bible (BGM 무드·SFX 카테고리·믹싱). 자산 일관성 보장.

**적용**: 단계 6 (E. 비주얼·오디오 톤)

---

### 17. Phase Gate 검증 (`17-phase-gate-validation.md`)
PASS/CONCERNS/FAIL 판정 + Required Artifacts/Validations + Hard Gate. CONCERNS 시 사용자 결정 절차.

**적용**: 단계 3·7 게이트 + 외부 워크플로우 단계 전환

---

## 사용 가이드

### 운영 시 (모든 대화)
- `10-collaborative-protocol.md` — Q→O→D→D→A 패턴 적용. 메타 운영 표준.

### 작성 시
새 GDD 를 작성할 때 다음 순서로 참조:
1. `07-brainstorm-process.md` — 컨셉 발산·수렴 거쳤는가?
2. `02-pillar-and-antipillar.md` — 기둥에 부합하는가?
3. `03-system-layering.md` — 어느 레이어인가?
4. `09-high-risk-system-identification.md` — 위험 점수 매겼는가?
5. `01-8section-gdd-standard.md` — 8섹션 따르고 있는가?
6. `04-bidirectional-dependency.md` — 의존성 양방향?
7. `05-game-feel-spec.md` — feel 차원 모두 명세?
8. `06-gdd-antipatterns.md` — 안티패턴 자가 점검

### 검토 시
GDD 검토할 때:
1. `01-8section-gdd-standard.md` 의 검증 체크리스트
2. `06-gdd-antipatterns.md` 의 안티패턴 체크리스트
3. `04-bidirectional-dependency.md` 의 양방향 검증
4. `08-cross-gdd-consistency.md` 의 9 카테고리 cross-review

### RAG 회수 시
hwicortex 쿼리 예시:
```bash
# 8섹션 표준 회수
hwicortex query "8 section GDD overview fantasy rules formulas" -c gdd-wisdom -n 3

# 안티패턴 회수
hwicortex query "GDD antipattern vague language TBD" -c gdd-wisdom -n 3

# 레이어링 회수
hwicortex query "system layering foundation core feature presentation" -c gdd-wisdom -n 3

# Game Feel 회수
hwicortex query "game feel input responsiveness ms frames hit pause" -c gdd-wisdom -n 3

# 브레인스토밍 회수
hwicortex query "brainstorm 10 seeds MDA motivation Bartle Octalysis" -c gdd-wisdom -n 3

# Cross-GDD 일관성 회수
hwicortex query "cross GDD consistency rule contradiction stale ownership conflict" -c gdd-wisdom -n 3

# 고위험 시스템 회수
hwicortex query "high risk system dependency density novelty complexity" -c gdd-wisdom -n 3
```

## 표준 frontmatter

각 문서는 동일 frontmatter 사용 (gdd-evaluation 과 일치):

```yaml
---
title: <한글명>
collection: gdd-wisdom
axis: A | C | D
theory_id: <slug>
keywords: [...]
applies_to: [creation, evaluation, implementation]
related: [<관련 theory_id>...]
last_updated: 2026-04-28
---
```

## 등록 명령

```bash
hwicortex collection add ~/concept-pipeline/rag-data/gdd-wisdom \
  --name gdd-wisdom \
  --pattern "**/*.md"

hwicortex context add "qmd://gdd-wisdom/" \
  "GDD 메타 원칙·표준 컬렉션. 8섹션 표준, 기둥/안티기둥, 레이어링, 양방향 의존성, Game Feel, 안티패턴."

hwicortex update && hwicortex embed
```

이후 `~/concept-pipeline/config.yaml` 의 `gdd-wisdom.status: pending` → `ready` 변경.
