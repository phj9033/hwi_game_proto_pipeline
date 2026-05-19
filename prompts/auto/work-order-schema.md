# work-order YAML 스키마

디렉터(`auto-pipeline` SKILL.md)가 워커(Agent 서브태스크)에게 작업을 지시하는 단일 입력 형식. **append-only**, 한 워커 호출당 1 파일.

## 파일 경로

`workspace/<slug>/work-orders/{NNN}-{stage}.yaml`

- `NNN` — 0부터 시작하는 3자리 시퀀스 (예: `001`, `002`, …)
- `stage` — `stage-01-concept`, `stage-04-eval`, `build-r0-substep-0.1`, `verify-r3`, `critic-r2-c`, `pkm-fetch-s01` 등

## 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `order_id` | string | ✓ | 파일명과 동일 |
| `worker_type` | enum | ✓ | concept-stage / build-substep / critic / verify / pkm-fetch |
| `stage` | int \| string | ✓ | 1~7 또는 "r0.1" 등 |
| `goal` | string | ✓ | 한 문장 작업 목표 |
| `inputs` | list[path] | ✓ | 워커가 읽을 파일 경로 |
| `prompt_file` | path | (concept-stage / build-substep 만) | 기존 prompts/ 경로 |
| `policy` | object | ✓ | art_default, engine, self_critique 등 |
| `constraints` | object | ✓ | output_path, decision_required 등 |
| `tier` | int | | 1~3 (재시도 tier), 첫 시도 시 1 |
| `parent_order_id` | string \| null | | Tier 3 분할 시 원 work-order |

## 예제 1 — concept-stage 워커 (단계 4 평가)

```yaml
order_id: "003-stage-04-eval"
worker_type: concept-stage
stage: 4
goal: "A/B/C 5-Axis 평가 + 1위 선정"
inputs:
  - workspace/dragon-cafe/02-draft-A.md
  - workspace/dragon-cafe/02-draft-B.md
  - workspace/dragon-cafe/02-draft-C.md
  - workspace/dragon-cafe/pkm-cache/stage-04-rag.md
prompt_file: prompts/04-eval.md
policy:
  art_default: pixel_art
  engine: godot
  self_critique: true
constraints:
  output_path: workspace/dragon-cafe/04-eval-report.md
  decision_required: true
tier: 1
parent_order_id: null
```

## 예제 2 — verify 워커 (Round 2 종료 점검)

```yaml
order_id: "047-verify-r2"
worker_type: verify
stage: "r2"
goal: "Round 2 종료 후 3축 체크리스트 점검"
inputs:
  - workspace/dragon-cafe/06-integrated-spec.md
  - workspace/dragon-cafe/06-art-bible.md
  - workspace/dragon-cafe/06-tech-spec.md
  - workspace/dragon-cafe/build/godot/
policy:
  engine: godot
constraints:
  output_path: workspace/dragon-cafe/worker-reports/047-verify-r2.md
  thresholds:
    ac_pass_rate: 1.0
    ssot_coverage: 0.9
    art_slot_fill: 1.0
tier: 1
parent_order_id: null
```

## 예제 3 — pkm-fetch 워커 (단계 5 시작)

```yaml
order_id: "008-pkm-fetch-s05"
worker_type: pkm-fetch
stage: 5
goal: "단계 5 RAG 쿼리 결과 캐시 생성"
inputs:
  - pipeline.yaml
policy:
  pkm_scope: project   # pkm search 의 --scope. 미링크 시 wiki 폴백
constraints:
  output_path: workspace/dragon-cafe/pkm-cache/stage-05-rag.md
  query_source: pipeline.yaml.steps[4].rag_queries
tier: 1
parent_order_id: null
```

## 검증 규칙

- `worker_type=concept-stage` 또는 `build-substep` → `prompt_file` 필수
- `worker_type=pkm-fetch` → `policy.pkm_scope` 필수
- `worker_type=verify` → `constraints.thresholds` 필수
- `tier=3` → `parent_order_id` 필수

## 변경 이력

| 버전 | 날짜 | 내용 |
|------|------|------|
| 0.1 | 2026-05-19 | 초안 (auto-pipeline 도입) |
