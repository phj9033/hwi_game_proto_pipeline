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
(전체 7단계 + 4 게이트 로직 — Phase B~F 에서 단계별로 채움)

## 기존 스킬과의 관계
- concept-pipeline / auto-pipeline / prototype-build-loop 와 **독립 진입점**
- 같은 슬러그의 기존 산출물 (예: `06-tech-spec.md`) 과 신규 산출물 (`tech-spec.md`) 은 파일명이 달라 공존
- 본 스킬은 위 3개 스킬의 파일을 1바이트도 수정하지 않는다 (`tests/spec_pipeline_no_regression.sh` 로 단언)
