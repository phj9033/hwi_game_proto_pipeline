# concept-pipeline

게임 컨셉부터 프로토타입 준비까지를 7단계 데이터 주도 파이프라인으로 관리한다.
스킬 1개로 자동 흐름을 진행하고, 사용자 결정 필요한 지점에서만 멈춘다.

## 핵심 원칙

- **로직은 데이터, 실행은 AI**: 단계 정의는 `pipeline.yaml`, 튜닝값은 `config.yaml`. Claude 가 이 데이터를 읽고 단계를 실행한다.
- **자동 흐름 + 결정 지점 멈춤**: 스킬이 자동으로 진행하다 사용자 응답이 필요한 곳에서만 정지. 응답 받으면 자동 재개.
- **세션 끊겨도 재개**: 진행 상태가 `workspace/<slug>/state.yaml` 에 영구 저장. 새 세션에서도 이어가기 가능.
- **RAG는 선택적**: hwicortex 컬렉션이 없어도 즉시 시작 가능. 컬렉션 추가 시 자동 활성화.
- **CCGS와 분리**: ~/concept-pipeline/ 에 자기완결적으로 독립.

## 7단계

| # | 이름 | 모드 | 산출물 |
|---|------|------|-------|
| 1 | 게임 컨셉 정립 | 대화 | `01-concept.md` |
| 2 | 3개 메카닉·장르 분기 초안 | AI 생성 + RAG | `02-draft-A/B/C.md` |
| 3 | 초안 저장 검증 | 게이트 (자동) | — |
| 4 | 5-Axis 평가 + 점수화 | AI 평가 + RAG | `04-eval-report.md` |
| 5 | 선택 드래프트 상세 확장 | 대화 + RAG | `05-detailed-gdd.md` |
| 6 | 디자인·개발 통합 명세서 | 대화 | `06-integrated-spec.md` |
| 7 | 프로토타입 준비 완료 | 게이트 (자동) | (완료 보고) |

## 설치

### 사전 요구사항
- [Claude Code](https://claude.com/claude-code) CLI 설치
- (선택) [hwicortex](https://github.com/...) — RAG 컬렉션 사용 시. 없어도 즉시 시작 가능 (LLM 자체 지식으로 대체).

### 클론 & 첫 실행

```bash
# 1) 클론 (권장 위치: 홈 디렉토리)
git clone <repo-url> ~/concept-pipeline
cd ~/concept-pipeline

# 2) (선택) RAG 컬렉션 등록 — rag-data/README.md 참고
#    스킵해도 동작함

# 3) Claude Code 진입
claude

# 4) 새 게임 컨셉 시작
"컨셉 파이프라인 시작"
```

스킬이 자동 로드되며 활성 프로젝트 슬러그를 묻는 것부터 시작합니다.

> **클론 위치**: `~/concept-pipeline` 외 경로에 두어도 동작합니다. 단, `rag-data/README.md` 등 문서의 예시 명령은 `~/concept-pipeline` 기준이므로 본인 경로로 치환하세요.

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
"컨셉 파이프라인 시작"                # 자연어 (신규/재개 자동 판단)
"게임 컨셉 만들자"                    # 자연어
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
| 6 | 9 섹션 incremental 합의 |
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
  📌 활성 프로젝트: dragon-cafe (1/7 단계, 3 섹션 작성)
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
├── pipeline.yaml                  # 단계 정의 + state.yaml 스키마 (불변)
├── config.yaml                    # 5-Axis 가중치, RAG 매핑 (튜닝 가능)
├── .claude/
│   ├── skills/
│   │   └── concept-pipeline/
│   │       └── SKILL.md           # 메인 자동 흐름 스킬
│   ├── commands/                  # 유틸리티 슬래시
│   │   ├── cp-status.md
│   │   └── cp-redo.md
│   ├── hooks/
│   │   └── session-start.sh       # 진입 시 활성 프로젝트 안내
│   └── settings.json              # 훅 등록
├── prompts/                       # 단계별 LLM 프롬프트
│   ├── 01-concept.md
│   ├── 02-draft.md
│   ├── 04-eval.md
│   ├── 05-expand.md
│   └── 06-spec.md
├── workspace/                     # 프로젝트별 작업 공간
│   ├── .active                    # 활성 프로젝트 슬러그 (1줄 텍스트)
│   └── <project-slug>/
│       ├── state.yaml             # 진행 상태 (스킬이 매 단계 갱신)
│       ├── 01-concept.md
│       ├── 02-draft-A.md
│       ├── 02-draft-B.md
│       ├── 02-draft-C.md
│       ├── 04-eval-report.md
│       ├── 05-detailed-gdd.md
│       └── 06-integrated-spec.md
├── docs/
│   └── rag-additions.md           # RAG 컬렉션 추가 권장 문서 카탈로그
└── README.md
```

## RAG 통합 (hwicortex)

- **현재 활성**: `gdd-evaluation` (5-Axis 14개 이론 문서) — 4·5단계에서 활용
- **신규 등록 권장**: `docs/rag-additions.md` 참고
- **미등록 컬렉션은 자동으로 LLM 자체 지식으로 대체** — 즉시 시작 가능

## 다음 단계

본 파이프라인의 출력 `06-integrated-spec.md` 를 가지고 프로토타입 → 본 게임 빌드업. 빌드업 워크플로우는 별도로 설계한다.

## 알려진 이슈 / TODO

- **`ITERATION_LOG.md` 명세 미정**: 단계 6c (`prompts/06c-tech-spec.md`)가 "있으면 참고 입력으로 쓴다"고만 언급. 작성 시점·트리거·스키마가 파이프라인에 정의되어 있지 않음. → 별도 보강 필요.

## 라이선스

[MIT](LICENSE)
