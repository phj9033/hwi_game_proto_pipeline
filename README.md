# concept-pipeline

게임 컨셉부터 프로토타입 준비까지를 **7단계 데이터 주도 파이프라인**으로 관리한다.
스킬 1개로 자동 흐름을 진행하고, 사용자 결정 필요한 지점에서만 멈춘다.

> **상태**: 단계 6 출력이 *3 산출물 패밀리* (SSOT + 아트 바이블 + 테크 스펙) 로 확장됨.
> 단계 7 게이트는 세 파일 모두 검증.

## 핵심 원칙

- **로직은 데이터, 실행은 AI**: 단계 정의는 `pipeline.yaml`, 튜닝값은 `config.yaml`. Claude 가 이 데이터를 읽고 단계를 실행한다.
- **자동 흐름 + 결정 지점 멈춤**: 스킬이 자동으로 진행하다 사용자 응답이 필요한 곳에서만 정지. 응답 받으면 자동 재개.
- **세션 끊겨도 재개**: 진행 상태가 `workspace/<slug>/state.yaml` 에 영구 저장. 새 세션에서도 이어가기 가능.
- **RAG 미연결**: 현재 RAG 시스템 미연결 — LLM 자체 지식으로 진행. 추후 RAG 연결 예정.
- **자기완결**: `~/concept-pipeline/` 한 디렉토리만으로 동작. 외부 프로젝트 의존 없음.

## 7단계 개요

| # | 이름 | 모드 | 산출물 |
|---|------|------|-------|
| 1 | 게임 컨셉 정립 | 대화 | `01-concept.md` |
| 2 | 3개 메카닉·장르 분기 초안 | AI 생성 + RAG | `02-draft-A/B/C.md` |
| 3 | 초안 저장 검증 | 게이트 (자동) | — |
| 4 | 5-Axis 평가 + 점수화 | AI 평가 + RAG | `04-eval-report.md` |
| 5 | 선택 드래프트 상세 확장 | 대화 + RAG | `05-detailed-gdd.md` |
| 6 | 디자인·개발 통합 명세서 (3 산출물 패밀리) | 대화 + 자동 생성 | `06-integrated-spec.md` (SSOT) <br> `06-art-bible.md` <br> `06-tech-spec.md` |
| 7 | 프로토타입 준비 완료 | 게이트 (자동) | (완료 보고) |

### 단계 6 패밀리 원칙

```
06-integrated-spec.md   ← SSOT (단일 진실). 9섹션 (A~I) + 변경이력
06-art-bible.md         ← 아트 시점. SSOT §E·§G.1 인용 + 슬롯·프롬프트·치수
06-tech-spec.md         ← 개발 시점. SSOT §F·§G·§H 인용 + 모듈·코드 매핑·테스트
```

룰 변경은 **SSOT 한 곳만** 수정 → drift 차단. 시점 문서는 *인용·확장* 만, *복제 ✕*.

## 설치

### 사전 요구사항
- [Claude Code](https://claude.com/claude-code) CLI 설치

### 클론 & 첫 실행

```bash
# 1) 클론 (권장 위치: 홈 디렉토리)
git clone https://github.com/phj9033/hwi_game_proto_pipeline.git ~/concept-pipeline
cd ~/concept-pipeline

# 2) (선택) RAG 컬렉션 등록 — rag-data/README.md 참고
#    스킵해도 동작함

# 3) Claude Code 진입
claude

# 4) 새 게임 컨셉 시작
"컨셉 파이프라인 시작"
```

스킬이 자동 로드되며 활성 프로젝트 슬러그를 묻는 것부터 시작한다.

> **클론 위치**: `~/concept-pipeline` 외 경로에 두어도 동작한다. 단 `rag-data/README.md` 등 문서의 예시 명령은 `~/concept-pipeline` 기준이므로 본인 경로로 치환.
> **session-start 훅**: 기본값 `$HOME/concept-pipeline`. 다른 경로면 환경변수로 오버라이드:
> ```bash
> export CONCEPT_PIPELINE_ROOT="$HOME/work/concept-pipeline"
> ```
> (`.zshrc` / `.bashrc` 에 박아두면 셸 재시작 후 자동 적용)

## 사용법

### 1. 세션 시작

```bash
cd ~/concept-pipeline
claude
```

세션 시작 시 활성 프로젝트 상태가 자동 표시된다 (SessionStart 훅).

### 2. 트리거

다음 중 어느 방식이든 가능:

```
/concept-pipeline                    # 슬래시
"컨셉 파이프라인 시작"                # 자연어 (신규)
"게임 컨셉 만들자"                    # 자연어 (신규)
"이어서 하자"                         # 자연어 (재개)
```

스킬이 트리거되면 활성 프로젝트가 있으면 재개, 없으면 새 슬러그를 묻는다.

### 3. 진행

스킬이 자동으로 단계를 흘려보낸다. 사용자 결정이 필요한 지점에서만 멈춤:

| 단계 | 멈춤 지점 |
|------|----------|
| 1 | 6 섹션 Q&A (각 1~2 질문) |
| 2 | 분기 축 자동/지정 + 비교 표 OK |
| 3 | 자동 통과 |
| 4 | A/B/C 선택 |
| 5 | 약점 보강 방향 + 섹션별 합의 |
| 6 | SSOT 9섹션 incremental 합의 → 이후 art-bible·tech-spec 자동 생성 |
| 7 | 자동 완료 보고 |

### 4. 유틸리티 슬래시

```
/cp-status              # 빠른 진행 상황 표시 (스킬 발동 없이)
/cp-redo <step-id>      # 특정 단계 재실행 (백업 후)
```

## 세션 끊김 / 재개 시나리오

```
[세션 1]
$ cd ~/concept-pipeline && claude
사용자: 컨셉 파이프라인 시작
스킬:   프로젝트 슬러그?
사용자: dragon-cafe
스킬:   ▶ 1단계 컨셉 정립 시작
        엘리베이터 피치를 한두 문장으로 알려주세요.
사용자: ...
... (3섹션까지 진행)
[세션 종료 / 컴퓨터 재부팅 / 다른 작업으로 컨텍스트 전환]

[세션 2 — 다음 날]
$ cd ~/concept-pipeline && claude
SessionStart 훅:
  📌 활성 프로젝트: dragon-cafe
     현재 단계: 1/7 — 컨셉 정립
     마지막 멈춤: "엘리베이터 피치 ~ 게임 기둥 작성됨, 코어 루프 응답 대기"
  이어가려면 "이어서 하자" 또는 /concept-pipeline

사용자: 이어서 하자
스킬:   dragon-cafe 의 1단계 코어 루프부터 이어갑니다.
        한 번의 플레이 사이클이 어떻게 흘러가나요?
사용자: ...
```

## 디렉토리 구조

```
~/concept-pipeline/
├── pipeline.yaml                       # 단계 정의 + state.yaml 스키마
├── config.yaml                         # 5-Axis 가중치, RAG 매핑 (튜닝 가능)
├── .claude/
│   ├── skills/
│   │   └── concept-pipeline/
│   │       └── SKILL.md                # 메인 자동 흐름 스킬
│   ├── commands/
│   │   ├── cp-status.md                # /cp-status 슬래시
│   │   └── cp-redo.md                  # /cp-redo <step> 슬래시
│   ├── hooks/
│   │   └── session-start.sh            # 진입 시 활성 프로젝트 안내
│   └── settings.json                   # 훅 등록
├── prompts/                            # 단계별 LLM 프롬프트
│   ├── 01-concept.md
│   ├── 02-draft.md
│   ├── 04-eval.md
│   ├── 05-expand.md
│   ├── 06-spec.md                      # SSOT 작성
│   ├── 06b-art-bible.md                # 아트 시점 (SSOT 후 자동)
│   └── 06c-tech-spec.md                # 개발 시점 (SSOT 후 자동)
├── rag-data/                           # RAG 컬렉션 (자기완결)
│   ├── README.md
│   ├── USE-CASES.md
│   ├── rag-additions.md                # 등록 권장 카탈로그
│   ├── gdd-evaluation/                 # 5-Axis 이론 14문서 + index
│   ├── gdd-wisdom/                     # GDD 메타 표준 17문서 + index
│   └── architecture-patterns/          # 아키텍처 표준 10문서 + index
├── workspace/                          # 프로젝트별 작업 공간 (.gitignore)
│   ├── .active                         # 활성 슬러그 (1줄)
│   └── <project-slug>/
│       ├── state.yaml                  # 진행 상태
│       ├── 01-concept.md
│       ├── 02-draft-A/B/C.md
│       ├── 04-eval-report.md
│       ├── 05-detailed-gdd.md
│       ├── 06-integrated-spec.md       # SSOT
│       ├── 06-art-bible.md
│       └── 06-tech-spec.md
├── LICENSE                             # MIT
└── README.md                           # 본 문서
```

> `workspace/<slug>/`, `workspace/.active` 는 `.gitignore` 처리됨. 각 사용자가 자기 슬러그로 시작.

## RAG 통합 (미연결)

3 개 컬렉션 자료가 `rag-data/` 에 자기완결로 포함됨. **현재 RAG 시스템 미연결** — 단계 진입 시 알림만 표시되고 LLM 자체 지식으로 진행됨. 추후 RAG 연결 시 `pipeline.yaml.steps[*].rag_queries` 정의 그대로 활용 가능.

| 컬렉션 | 역할 | 문서 수 | 사용 단계 |
|--------|------|---------|-----------|
| `gdd-evaluation` | 학술 이론 (5-Axis) | 14 + index | 4, 5, 6 |
| `gdd-wisdom` | GDD 메타 표준 | 17 + index | 2, 4, 5, 6 |
| `architecture-patterns` | 아키텍처 표준 | 10 + index | 4, 5, 6 |

## 다음 단계

본 파이프라인의 출력 패밀리(`06-integrated-spec.md` + `06-art-bible.md` + `06-tech-spec.md` + `06-changelog.md`)를 가지고 프로토타입 빌드로 이어진다.

### prototype-build-loop (v0.3~)

같은 레포의 `prototype-build-loop` 스킬이 단계 7 산출물을 입력으로 받아 Godot/Unity 프로토타입 빌드와 라운드 단위 AI 수정을 진행한다.

```
"프로토타입 시작"  /  /prototype-start
```

자세한 내용: [prototype-build-loop spec](docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md)

### auto-pipeline (v0.7~)

기존 두 스킬을 묶어 **컨셉 + 엔진 2회 입력만으로 끝까지 자동** 진행하는 별도 진입점. 결정 지점은 LLM 추천 + critic 자체 비평으로 자동 채택, 종료는 3축 체크리스트 + 라운드 상한으로 판정. 픽셀아트 디폴트 (외부 디자인 툴 부재 환경 가정).

    "/auto-pipeline" 또는 "오토 파이프라인 시작"
    → 컨셉 텍스트 + 엔진 (godot/unity) 1회 입력
    → 끝까지 자동 (세션 끊기면 "이어서" 한마디로 재개)

자세한 내용: [auto-pipeline spec](docs/superpowers/specs/2026-05-19-auto-pipeline-design.md)

## 알려진 이슈 / TODO

- **현재 알려진 이슈 없음** — v0.2 에서 ITERATION_LOG.md 정식 등재 (`pipeline.yaml` 단계 6 `iteration_log` 섹션 참조), session-start.sh 환경변수화, 단계 7 게이트 강화 완료.

## 라이선스

[MIT](LICENSE)
