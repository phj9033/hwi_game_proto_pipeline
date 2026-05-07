# rag-data 유즈케이스 — 기획자 1인 Q&A 도구

> 3 컬렉션(`gdd-evaluation` / `gdd-wisdom` / `architecture-patterns`) 을 **단일 기획자의 일상 GDD 작업 보조** 로 어떻게 쓰는지 정리. (RAG 시스템 미연결 — 추후 연결 예정)
> 본 디렉토리 README.md 가 *컬렉션이 무엇인지* 라면, 본 문서는 *그것으로 무엇을 묻는지*.

## 사용 의도

**범위:** 기획서 평가 · 작성 · 수정 중 문의 응답.
**범위 밖:** 전 게임개발 수명주기 자동화 (CI·PR 봇·코드리뷰·LiveOps), 조직 차원 도구화 (온보딩·채용·외주 스펙 자동화), 본 컨셉 파이프라인의 단계별 자동 retrieval 박기.

3 모드로 나뉨:
- **수정·문의** (매일 발생, 빈도 1위) — 채팅에 자연어로 ad-hoc 질문
- **평가** (회당 가치 큼) — 외부/내부 GDD 점검, 슬래시 커맨드 묶음
- **작성** (신규 컨셉마다) — 백지에서 양식 부트스트랩

---

## 🔥 수정·문의 모드 — ad-hoc Q&A (Top 7)

기획 작업 중 채팅창에 자연어로 묻는 패턴. 빈도 1위, 가치 1위.

### 1. 심리학적 보강·진단 ★
**예시 질의:** *"이 메카닉 어떻게 더 중독성/몰입감 있게?"* / *"여기 동기 부여가 약한데 왜?"*
**retrieval:** `gdd-evaluation/01-sdt-pens`, `02-bartle-hexad`, `03-octalysis`, `04-flow-theory`, `12-loss-aversion-bm`, `13-variable-ratio-ethics`
**답변 형태:** 이론 근거 + 보강 옵션 N개 + 윤리 가드

### 2. UX/UI 진단·처방 ★
**예시 질의:** *"메뉴 옵션 7개 OK?"* / *"HUD가 산만한데"* / *"버튼 위치 모바일에서 어디?"*
**retrieval:** `gdd-evaluation/06-laws-of-ux`, `05-cognitive-load`, `07-ftue-onboarding`, `gdd-wisdom/14-accessibility-requirements`, `15-ux-spec-pattern`, `05-game-feel-spec`
**답변 형태:** 법칙 진단 + 모바일 가정 처방 + 접근성 가드

### 3. 플레이어 이탈·좌절 원인 분석
**예시 질의:** *"여기서 다들 그만둘 것 같은데"*
**retrieval:** Flow + CLT + FTUE
**답변 형태:** 진단 (스킬-난이도, 작업기억, 첫 N분 게이트) + 처방

### 4. 시스템·기둥 정합성 점검
**예시 질의:** *"이 두 기둥이 충돌하는 느낌"* / *"이 시스템 의존 어디서 끊지?"*
**retrieval:** `gdd-wisdom/02-pillar-and-antipillar`, `03-system-layering`, `04-bidirectional-dependency`
**답변 형태:** 분리선 후보 / 우선순위 명시 / 해소 옵션

### 5. BM 윤리 가드
**예시 질의:** *"이 가챠/패스 OK?"*
**retrieval:** `gdd-evaluation/12-loss-aversion-bm`, `13-variable-ratio-ethics`, `11-f2p-kpi`
**답변 형태:** 임계 진단 + 완화책

### 6. 비슷한 이론·사례 검색
**예시 질의:** *"이 메카닉 비슷한 이론 있나?"*
**retrieval:** keyword 매칭 (전 컬렉션)
**답변 형태:** 이론 ID + 한 줄 요약 + 관련 안티패턴

### 7. 모순·일관성 1분 체크
**예시 질의:** *"방금 쓴 이 단락 GDD 다른 섹션이랑 모순 없나?"*
**retrieval:** `gdd-wisdom/08-cross-gdd-consistency`
**답변 형태:** 의심 항목 N개 + 해소 제안

---

## 📋 평가 모드 — GDD 점검 (회당 가치 큼)

### 8. 안티패턴 자동 형광펜
**입력:** GDD 통째로
**retrieval:** `gdd-wisdom/06-gdd-antipatterns`
**출력:** 줄 단위 *"이건 안티패턴 #N (이유)"* 코멘트

### 9. 5-Axis 균형 진단
**retrieval:** `gdd-evaluation` 14종 ↔ axis 매핑
**출력:** axis 별 점수 + *"B축 약함, 결핍 N가지"* 한 장 요약

### 10. 8섹션 누락·약함 점검
**retrieval:** `gdd-wisdom/01-8section-gdd-standard`
**출력:** 빈/얕은 섹션 자동 표시 → 30초 완성도 등급

### 11. 고위험 시스템 식별
**retrieval:** `gdd-wisdom/09-high-risk-system-identification`
**출력:** *"이 GDD에서 먼저 검증해야 할 시스템 N개"* 리스크 한 줄

---

## ✍️ 작성 모드 — 백지에서 시작 (신규 컨셉마다)

### 12. 8섹션 GDD 골격 부트스트랩
**입력:** 컨셉 한 단락
**retrieval:** `gdd-wisdom/01-8section-gdd-standard`
**출력:** 빈 8섹션 + 가이드 질문

### 13. 기둥/안티기둥 후보 도출
**retrieval:** `gdd-wisdom/02-pillar-and-antipillar`, `gdd-evaluation/03-octalysis`, `09-elemental-tetrad`
**출력:** 기둥 후보 N개 + 각각의 안티기둥

### 14. Game Feel 명세 부트스트랩
**입력:** 정점 모먼트
**retrieval:** `gdd-wisdom/05-game-feel-spec`, `gdd-evaluation/04-flow-theory`, `06-laws-of-ux`
**출력:** Game Feel 양식 자동 채움 (모바일 가정 주입 가능)

### 15. 플레이어 여정 / 난이도 / 경제 양식
**retrieval:** `gdd-wisdom/11-player-journey-mapping`, `12-difficulty-curve-design`, `13-economy-model-design`
**출력:** 양식에 컨셉 변수 자동 대입한 1차 초안

---

## 사용성 — 어떻게 쓰나

| 모드 | 적용 방식 | 이유 |
|------|----------|------|
| **수정·문의 (1~7)** | Claude Code 채팅에 컬렉션 항상 retrieval. 자연어로 그냥 질문 | 질문이 비정형이라 슬래시 커맨드 부적합 |
| **평가 (8~11)** | `/gdd-review <파일>` 한 방에 묶음 리포트 *(아직 미구현, 권장 셋업)* | 정형 산출물, 묶음 호출이 효율 |
| **작성 (12~15)** | `/gdd-init <컨셉>` 한 방에 골격 *(아직 미구현, 권장 셋업)* | 신규 시작 가속 |

---

## 우선순위

**Top 3 — 셋업 즉시 ROI**
1. 심리학적 보강·진단 (#1) — 매일 발생
2. UX/UI 진단·처방 (#2) — 매일 발생
3. 안티패턴 형광펜 (#8) — 평가 시 즉시 효과

**최소 셋업 = 채팅 기본 retrieval + `/gdd-review` 1개 슬래시 커맨드** *(슬래시 커맨드는 아직 미구현, 권장 셋업)*.
이 조합이면 1~11 커버. 12~15 작성용은 후순위.

---

## 셋업 가이드

### 1) 채팅 기본 retrieval (수정·문의 1~7 커버)

추후 RAG 시스템 연결 시 Claude Code 컨텍스트에 3 컬렉션 자동 retrieval 박을 예정.
(현재는 미연결 — LLM 자체 지식으로 답변)

### 2) `/gdd-review` 슬래시 커맨드 (평가 8~11) — 아직 미구현, 권장 셋업

평가 묶음 호출. 입력: GDD 파일 경로. 출력: 안티패턴 형광펜 + 5-Axis 점수 + 8섹션 완성도 + 고위험 시스템.

> 현재 미존재. 본 문서의 추천 셋업이며 필요 시 구현 (`~/.claude/commands/` 또는 프로젝트 `.claude/commands/` 에 정의).

### 3) `/gdd-init` 슬래시 커맨드 (작성 12~15) — 아직 미구현, 권장 셋업

작성 부트스트랩. 입력: 컨셉 한 단락. 출력: 8섹션 빈 양식 + 기둥 후보 + Game Feel 빈 명세.

> 현재 미존재. 본 문서의 추천 셋업이며 필요 시 구현.

---

## 갱신

본 문서는 *살아있는 문서*. 새 유즈케이스·질의 패턴 발견 시 추가.
컬렉션 자체의 갱신은 `README.md` 의 갱신 절차 따름.
