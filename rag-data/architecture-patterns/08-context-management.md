---
title: Context Management 패턴 (File-Backed State)
collection: architecture-patterns
axis: E
theory_id: context-management
keywords: [context-management, file-backed-state, incremental-write, session-recovery, compaction, state-yaml, living-document]
applies_to: [implementation, evaluation]
related: [collaborative-protocol, traceability-matrix]
last_invariants: 2026-04-28
last_updated: 2026-04-28
---

# Context Management 패턴

> 컨텍스트는 LLM 세션의 가장 *희소* 자원. 파일이 메모리, 대화는 휘발.
> 세션 끊김·압축에 안전한 작업 흐름.

## 핵심 원리

LLM 세션의 두 가지 한계:
1. **컨텍스트 윈도우**: 토큰 한도. 대화가 길어지면 압축(compaction) 필요.
2. **세션 종료**: 컴퓨터 재부팅·prompt too long 등으로 세션 사라짐.

해결:
- **파일 = 메모리**: 모든 결정·산출물을 파일에. 대화는 보조.
- **incremental write**: 섹션 합의 → 즉시 파일에 추가
- **session state**: 진행 상태를 별도 파일에 영구 저장
- **proactive compaction**: 한도 도달 전 미리 압축

---

## 1. File-Backed State (파일 기반 상태)

### 원칙

대화는 휘발한다. 파일은 영속한다. 따라서:
- 의미 있는 결정·산출물은 *항상* 파일에
- 대화 안에서만 유지되는 정보는 위험 (세션 끊기면 잃음)

### Session State File

`workspace/<project>/state.yaml` 같은 파일에 다음 기록:
- 현재 진행 단계
- 완료 이력
- 핵심 결정 사항
- 작업 중인 파일 목록
- 미해결 질문

매 *의미 있는 마일스톤* 후 갱신:
- 디자인 섹션 합의·작성됨
- 아키텍처 결정됨
- 구현 마일스톤 도달
- 테스트 결과 얻음

### 회복 시나리오

세션 끊김 후 새 세션:
1. State file 읽기
2. 작업 중이던 파일들 읽기
3. 마지막 미완료 섹션 또는 작업부터 재개

---

## 2. Incremental Write (점진적 작성)

다중 섹션 문서 작성 시:

### 잘못된 방식 (대화 누적)

```
사용자: 섹션 1 어떻게?
AI: [긴 토론]
사용자: 좋아 다음 가자.
사용자: 섹션 2 어떻게?
AI: [긴 토론]
... (8 섹션 끝)
사용자: 이제 다 쓰자.
AI: [전체 8섹션 한 번에 작성]
```

문제:
- 컨텍스트에 8섹션 분의 토론 누적 (~30~50k 토큰)
- 세션 끊기면 모든 토론 잃음
- 압축 시 손실 위험

### 올바른 방식 (incremental)

```
사용자: 섹션 1 어떻게?
AI: [짧은 토론]
사용자: 좋아.
AI: 섹션 1 을 [파일]에 작성하겠습니다. 진행할까요?
사용자: 네.
AI: [Write 도구로 섹션 1 추가]
AI: 섹션 1 완료. 다음 섹션 2 진행할까요?
사용자: 네.
... (각 섹션마다 동일)
```

장점:
- 컨텍스트에는 *현재 섹션* 토론만 (~3~5k 토큰)
- 완성된 섹션은 파일에 영속
- 세션 끊겨도 완성된 섹션 안 잃음
- 압축 시 완성 섹션 안전

---

## 3. Proactive Compaction (능동적 압축)

### 트리거

| 시점 | 행동 |
|------|------|
| 컨텍스트 60~70% 사용 | 압축 또는 `/clear` 고려 |
| 무관한 작업 전환 | `/clear` 후 새 컨텍스트로 |
| 2회 이상 같은 실수 반복 | `/clear` 후 재시도 |
| 자연스러운 분기점 | 압축 (섹션 작성 후, 커밋 후, 작업 완료 후) |

### Focused Compaction

`/compact <focus>` 패턴:
```
/compact Focus on current section design.
         Sections 1-3 are written to file.
         Working on section 4.
```

→ 현재 작업과 무관한 부분 적극 압축. 핵심만 유지.

---

## 4. Subagent Delegation (서브에이전트 위임)

### 사용 케이스

| 상황 | 직접 vs 위임 |
|------|--------------|
| 정확히 1~2 파일 안다 | 직접 |
| 여러 파일에 걸친 조사 (>5k 토큰 읽기 예상) | 위임 |
| 익숙하지 않은 코드 탐색 | 위임 |
| 광범위 검색·매핑 | 위임 |
| 빠른 단일 파일 수정 | 직접 |

### 위임 시 원칙

서브에이전트는 *별도 컨텍스트*. 자기 일 끝나면 *요약*만 반환.

이점:
- 메인 세션 컨텍스트 보호
- 서브에이전트의 raw 발견 (수십 KB) 메인 세션에 안 들어옴
- 메인 세션은 *결정* 에 집중

---

## 5. Compaction Instructions (압축 지시)

압축 시 다음 보존 필수:

```markdown
## 압축 시 보존 필수
- session-state 파일 위치 (회복용)
- 이번 세션에 수정한 파일 목록
- 핵심 디자인·아키텍처 결정 + 근거
- 진행 중 task 와 현재 단계
- agent invocation 결과 (성공·실패·차단)
- 테스트 결과
- 미해결 질문·차단 사항
- 작성 중 문서의 *어느 섹션까지* 파일에 있고 *어느 섹션이* 진행 중인지
```

---

## 6. Recovery After Crash (크래쉬 후 회복)

세션 죽음 ("prompt too long") 또는 새 세션 시작:

```
1. session-start 훅이 active.md 자동 감지·미리보기
2. 사용자가 active.md 전체 읽기
3. 부분 완성 파일들 읽기
4. 다음 미완료 섹션·작업부터 재개
```

→ 본 파이프라인의 SKILL.md 가 이 패턴 명시적 적용.

---

## Context Budget by Task Type

| 작업 | 시작 토큰 (대략) |
|------|-----------------|
| 가벼움 (read/review) | ~3k |
| 중간 (구현·1 시스템 설계) | ~8k |
| 무거움 (multi-system refactor) | ~15k |

→ 작업 시작 전 예산 추정. 초과 예상 시 분할.

---

## 안티패턴

### 1. 대화에만 결정 보관
긴 토론 후 "OK 그렇게 하자" → 파일에 안 적음 → 세션 끊기면 모두 잃음.

해결: 모든 결정 *즉시* 파일에. 대화는 보조.

### 2. 통째 작성
8 섹션 다 토론 후 한 번에 작성. 컨텍스트 폭주.

해결: 섹션 단위 incremental. 각 섹션 합의 → 즉시 파일.

### 3. State 파일 미갱신
세션 시작 시 state 읽음. 그러나 세션 진행 중 안 갱신.

해결: 매 마일스톤 후 갱신 (섹션 작성·결정·테스트 결과).

### 4. 한도 도달까지 대기
컨텍스트 95% → "이상하다" → 압축 시도 → 실패.

해결: 60~70% 시 능동적 압축.

### 5. 서브에이전트 결과를 메인에 통째 첨부
서브가 파일 5개 read → 5KB 결과 → 메인 컨텍스트에 통째 들어옴.

해결: 서브의 *요약*만 메인에. raw 데이터는 파일로 저장 후 필요 시 직접 읽기.

---

## 본 파이프라인 적용

### state.yaml 갱신 빈도

| 이벤트 | 갱신 |
|--------|------|
| 단계 진입 | current_step 갱신 |
| 섹션 합의 + 작성 | sub_progress 갱신 |
| 단계 완료 | completed_steps 추가 + artifacts 갱신 |
| 사용자 결정 (분기 선택 등) | artifacts 갱신 + notes 추가 |
| 멈춤 (대화 대기) | last_pause_reason + last_pause_at |
| 사용자 응답 | last_user_response_at + last_pause_reason 초기화 |

### 회복 시 안내

세션 시작 시 hook 이 다음 표시:
```
📌 활성 프로젝트: <slug>
   현재 단계: 5/7 — 상세 확장
   세부 진행: 3/9 섹션
   마지막 멈춤: 시스템 인벤토리 응답 대기
   이어가려면: /concept-pipeline 또는 "이어서 하자"
```

---

## 검증 체크리스트

세션 운영 시:
- [ ] state.yaml 매 마일스톤 갱신
- [ ] 모든 산출물 *섹션 단위* 점진 작성
- [ ] 컨텍스트 60~70% 시 능동 압축
- [ ] 서브에이전트는 광범위 작업·요약만 수신
- [ ] 압축 시 핵심 결정·진행 상태 보존
- [ ] 크래쉬 후 state 읽기 → 회복

설계 시:
- [ ] state 파일 스키마 명시
- [ ] 갱신 트리거 명시
- [ ] 회복 절차 자동화 (hook)
