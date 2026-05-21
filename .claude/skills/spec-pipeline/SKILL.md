---
name: spec-pipeline
description: 컨셉 텍스트 1회 입력 → 게임 상세기획서(GDD) · 기술명세서 · 아트명세서 3개 문서를 자동 생성한다. 4 게이트 최소 개입 + 끝단 2 문서 병렬 subagent. PKM-recall 1회 응축 호출로 사용자 누적 지식 활용. 기존 concept-pipeline 과 독립 — 같은 workspace 슬러그에 공존 가능. 트리거 - "/spec-pipeline", "스펙 파이프라인 시작", "3종 명세서 만들자", "이어서 (재개)".
---

# Spec Pipeline — 자동 흐름 스킬

## 역할
~/concept-pipeline/ 의 데이터 주도 파이프라인 실행기. 트리거되면 끝까지 흐름을 끌어가며, 4 게이트 (G1~G4) 에서만 사용자에게 묻는다.

## 입력 데이터
- `~/concept-pipeline/spec-pipeline.yaml` — 단계+게이트 정의 (불변)
- `~/concept-pipeline/prompts/spec/<NN>-*.md` — 단계별 LLM 프롬프트
- `~/concept-pipeline/workspace/.active` — 활성 슬러그 (1줄)
- `~/concept-pipeline/workspace/<slug>/state.yaml` — 진행 상태 (`spec_pipeline:` 네임스페이스 사용)

## 산출물 (workspace/<slug>/)
- `concept.md` — 입력 원문 (Step 0)
- `inference.yaml` — 추론 결과 (Step 1)
- `pkm-recall.md` — PKM 회상 (Step 2)
- `gdd.md` — 게임 상세기획서 master (Step 3)
- `style-options.md` — 아트 스타일 후보 3개 (Step 4)
- `tech-spec.md` — 기술명세서 (Step 5 worker)
- `art-spec.md` — 아트명세서 (Step 5 worker)

## 부팅 — 신규 vs 재개
1. `workspace/.active` 존재 확인
2. 존재 → `state.yaml.spec_pipeline` 키 읽기
   - 키 없음 → 신규 spec-pipeline 시작 여부 사용자에게 물음
   - 키 있고 `status: in_progress` → 재개 (마지막 통과 게이트 다음부터)
   - 키 있고 `status: done` → "다시 만들기 / 이어보기" 선택
3. 부재 → 슬러그 1회 입력 받음

## 흐름

### Step 0 — 입력 수신
1. 활성 슬러그 확인 (없으면 사용자에게 새 슬러그 요청 — kebab-case 검증)
2. "컨셉 텍스트를 붙여넣어 주세요 (분량 자유 — 1문장 ~ 몇 페이지)" 멀티라인 1회 입력
3. 10자 미만이면 1회 재요청 (그래도 짧으면 그대로 진행)
4. `workspace/<slug>/concept.md` 에 저장 + `state.yaml` 의 `spec_pipeline.step_0` 채움
5. `current_step: 1` 로 마킹 후 Step 1 진입

### Step 1 — 장르·메카닉 추론
1. `prompts/spec/01-inference.md` 의 지시를 따라 `concept.md` 를 분석
2. 결과를 `workspace/<slug>/inference.yaml` 에 yaml 로 저장
3. `error: too_short` 인 경우 사용자에게 1~2문장 추가 힌트 요청 → 재추론 1회. 또 실패하면 그대로 진행 (게이트 표시는 빈 inference 로)

### G1 — 추론 결과 확인 (사용자 게이트)
표시 포맷:
```
[추론 결과]
장르: <genre>
서브장르: <sub_genres or "—">
코어 메카닉:
  1. <name> — <why>
  2. ...
플레이어 판타지: <player_fantasy>
톤·무드: <tone_mood>
비교작:
  - <title> — <why>
  ...
모호한 차원: <ambiguities or "없음">

[선택]
  a. 이대로 진행 (accept)
  e. 특정 필드 수정 (edit)
  r. 다시 추론 (redo)
```

- accept → `state.yaml` `gate_g1: { passed_at: <now>, user_action: accept }` → Step 2 진입
- edit → 사용자가 필드명+새값 입력 → inference.yaml 갱신 → 다시 G1 표시
- redo → Step 1 재실행 (Phase E8 가드: 동일 게이트 3회 누적 시 "수동 편집 권장" 안내)

## 기존 스킬과의 관계
- concept-pipeline / auto-pipeline / prototype-build-loop 와 **독립 진입점**
- 같은 슬러그의 기존 산출물 (예: `06-tech-spec.md`) 과 신규 산출물 (`tech-spec.md`) 은 파일명이 달라 공존
- 본 스킬은 위 3개 스킬의 파일을 1바이트도 수정하지 않는다 (`tests/spec_pipeline_no_regression.sh` 로 단언)
