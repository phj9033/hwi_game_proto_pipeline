---
name: prototype-build-loop
description: 게임 컨셉 파이프라인 단계 7 통과 후 프로토타입 빌드를 시작하고 라운드 단위 AI 수정을 관리한다. Godot/Unity 둘 다 지원, 시작 시 사용자 선택. ITERATION_LOG.md 에 Round 0 (초기 환경) + Round N (AI 수정) 만 기록 — 사용자 직접 수정은 누락 허용. 트리거 - "프로토타입 시작", "프로토타입 빌드", /prototype-start, /prototype-round, /prototype-snapshot. 자동 감지 - build/ 디렉토리 활성 + 사용자 발화에 수정 의도 (액션 동사 추가/수정/변경/제거/바꿔/줄여/늘려/고쳐, 평가어 어색해/안 어울려/이상해/약해/세/지루해, SSOT 시스템·메카닉 키워드) 포함 시 Round N 진입. 의문사 (어떻게/왜/뭐가/언제/어디) 우선 — 질문이면 답변만 하고 라운드 ✕.
---

# prototype-build-loop

## 1. 역할

`concept-pipeline` 단계 7 (준비 완료 게이트) 통과 후, 산출물 패밀리 (SSOT + art-bible + tech-spec + changelog) 를 입력으로 **실제 프로토타입 빌드 + 라운드 단위 AI 수정** 을 진행한다.

## 2. 모드

- **Round 0 (1회)**: 엔진 선택 + L4 스캐폴드 생성 (코어 루프 placeholder 동작)
- **Round N (반복)**: 사용자 수정 요청·피드백 → AI 패치 제안 → 사용자 승인 → 적용·로깅
- **Snapshot (선택)**: 사용자 명시 호출 → `build/{engine}/` 의 git tag

## 3. 트리거

| 동작 | 트리거 |
|------|--------|
| Round 0 | 명시: "프로토타입 시작" / "프로토타입 빌드" / `/prototype-start` |
| Round N | 자동 감지 (§5) 또는 `/prototype-round` |
| Snapshot | 명시: "스냅샷 v… 찍어줘" / `/prototype-snapshot <tag>` |

## 4. 전제

- 활성 프로젝트가 단계 7 통과 (`workspace/<slug>/state.yaml.completed_steps` 에 id=7)
- 산출물 4 종 존재: `06-integrated-spec.md`, `06-art-bible.md`, `06-tech-spec.md`, `06-changelog.md`
- pipeline.yaml.version >= "0.3"

## 5. Round N 자동 감지 규칙

### 5.1 키워드 출처

`state.yaml.build_state.system_keywords` 에 캐시된 SSOT §C 항목명 + §B 메카닉 토큰. 캐시가 비어있으면 1회 SSOT 파싱하여 채움.

### 5.2 판정 (우선순위 순)

```
입력: 사용자 발화 U

전제: workspace/<slug>/build/ 존재

규칙 1 [질문 가드, 최우선]:
  U 가 의문사 (어떻게/왜/뭐가/언제/어디/뭔가요/인가요) 로 시작 또는 끝나면
  → 라운드 ✕, 답변만

규칙 2 [액션 동사 + 대상, 신뢰도 높음]:
  U 에 액션 동사 (추가/수정/변경/제거/바꿔/줄여/늘려/고쳐/빼/넣어/강화/약화) 1개 이상
  AND
  U 에 system_keywords 또는 §B 메카닉 토큰 1개 이상
  → 라운드 ◯ 즉시 진입

규칙 3 [평가어 + 대상, 신뢰도 중간]:
  U 에 평가어 (어색해/안 어울려/이상해/약해/세/지루해/혼란스러워) 1개 이상
  AND
  대상 토큰 1개 이상
  → "수정 라운드로 처리할까요?" 1회 확인 → 사용자 OK 시 진입

규칙 4 [그 외]:
  → 라운드 ✕, 일반 응답
```

### 5.3 SSOT 자체 수정 분기

발화가 *코드·에셋* 이 아닌 *SSOT 룰* 수정이면 (예: "art-bible 에 어종 추가", "AC §I 에 항목 추가") AI 가 안내:

> "이건 SSOT 변경입니다. concept-pipeline 의 `/cp-redo 6` 로 가서 단계 6 을 재실행해야 일관성이 유지됩니다."

라운드 자체는 취소.

## 6. Round 0 절차

`prompts/prototype-build-loop/round0-scaffold.md` 참조.

요약:
1. 전제 검증 (단계 7·산출물 4종)
2. 엔진 선택 질문 ("Godot 4 / Unity 6 중?")
3. `engines/{선택}.md` 어댑터 로드·검증 (7 H2 헤더)
4. 스캐폴드 계획 표시 + 사용자 확인
5. 어댑터 *프로젝트 init 절차* 실행
6. tech-spec §F·§G·§I 매핑 → 모듈·시그널·Resource·테스트 골격 + 코어 루프 placeholder
7. `build/{engine}/` git init + 첫 commit
8. `engine.yaml`, `ITERATION_LOG.md` v0 항목, `state.yaml` 갱신

## 7. Round N 절차

`prompts/prototype-build-loop/roundN-patch.md` 참조.

요약:
1. 자동 감지 진입 (§5) 또는 `/prototype-round`
2. SSOT 영향 §섹션 식별
3. 코드 vs SSOT 분기 — SSOT 면 `/cp-redo 6` 안내 후 취소
4. 어댑터 기반 패치 제안 (diff)
5. 사용자 승인 (전체 / 부분 / 취소)
6. 적용 + `build/{engine}/` commit (메시지 §8)
7. `ITERATION_LOG.md` v{N} 항목 (5 필드)
8. SSOT 룰 영향 시 `06-changelog.md` append
9. `state.yaml.build_state` 갱신

## 8. commit 메시지 규약

`build/{engine}/` 트리의 commit 메시지 형식:

```
Round {N}: {라운드명}

{진단 1줄}

변경:
- {변경 bullet 1}
- {변경 bullet 2}
```

부분 적용 시 끝에 `(partial: <파일목록>)`.

## 9. Snapshot 절차

1. `build/{engine}/` 의 `git status` 확인
2. uncommitted 있으면 3 옵션:
   - "auto-commit 후 tag" — `git add . && git commit -m "snapshot pre-tag" && git tag <tag>`
   - "stash 후 tag" — `git stash && git tag <tag>` (사용자가 나중에 stash pop)
   - "취소" — 아무 작업 ✕
3. `state.yaml.build_state.last_snapshot = <tag>` 갱신

## 10. 에러 케이스

| 케이스 | 처리 |
|--------|------|
| 단계 7 미통과 | 거부 + 누락 산출물 안내 |
| 엔진 선택 후 어댑터 부재 | 에러 + `adapter-template.md` 복제 가이드 |
| 어댑터 §4.3 schema 위반 (필수 H2 누락) | 에러 + 누락 헤더 명시 |
| Round 0 스캐폴드 일부 실패 | 트랜잭션 ✕. 실패 지점까지 보존 + 사용자 보고 |
| 자동 감지 오인식 | 규칙 1·신뢰도 중간 확인이 1차 가드. 사용자 "취소" 가능 |
| SSOT 자체 수정 요청 | `/cp-redo 6` 안내 후 라운드 취소 |
| 스냅샷 시 uncommitted 충돌 | 3 옵션 (auto-commit/stash/취소) |
| state.yaml v0.2.1 → v0.3 마이그레이션 | (1) `.archive/state-pre-migration-{timestamp}.yaml` 백업 → (2) 누락 필드 기본값 추가 (`artifacts.engine=null`, `artifacts.build_initialized=false`, `build_state=null`) → (3) `notes` 에 `"schema migration 0.2.1 → 0.3 (build-loop fields added)"` 1줄 → (4) `pipeline_version: "0.3"` 갱신. 실패 시 백업 보존 + 사용자 보고. |
| 어댑터 checksum 불일치 | 사용자 경고 + 다음 Round 0 재실행 권고 |

## 11. 호출되는 외부 자산

- `engines/godot.md`, `engines/unity.md` — 엔진별 어댑터 데이터
- `prompts/prototype-build-loop/round0-scaffold.md` — Round 0 본문
- `prompts/prototype-build-loop/roundN-patch.md` — Round N 본문
- `pipeline.yaml.steps[5].iteration_log.schema.round_variants` — 로그 스키마

## 12. spec 참조

설계 근거: `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md`
