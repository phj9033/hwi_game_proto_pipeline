# worker-report YAML 스키마

워커(Agent 서브태스크)가 작업 완료 후 디렉터에게 결과를 회수하는 단일 출력 형식. **append-only**, work-order 1개당 1 보고서.

## 파일 경로

`workspace/<slug>/worker-reports/{NNN}-{stage}.md`

- `NNN`·`stage` 는 대응 work-order 와 동일 ID

## 파일 구조

`.md` 파일 상단에 YAML frontmatter, 본문에 사람이 읽을 요약·이슈·에러 로그.

```markdown
---
order_id: "003-stage-04-eval"
worker_type: concept-stage
status: completed              # completed | failed | partial
started_at: "2026-05-19T10:23:11Z"
completed_at: "2026-05-19T10:25:48Z"
outputs:
  - path: workspace/dragon-cafe/04-eval-report.md
    summary: "5-Axis 평균 A=3.8 B=4.2 C=3.5. B 가 1위."
decision_proposal:              # decision_required=true 시 필수
  choice: "B"
  rationale: "B 의 Depth 4.5, Novelty 4.0 이 결정적..."
issues: []                      # 빈 리스트면 정상
tier_used: 1                    # 이 보고가 몇 번째 tier 시도였나
---

## 요약
(사람이 읽을 본문)

## 이슈 / 미달 항목
(있으면 bullet)

## 에러 로그
(failed/partial 일 때만)
```

## 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `order_id` | string | ✓ | 대응 work-order |
| `worker_type` | enum | ✓ | work-order 와 동일 |
| `status` | enum | ✓ | completed / failed / partial |
| `started_at` | ISO 8601 | ✓ | 워커 시작 UTC |
| `completed_at` | ISO 8601 | ✓ | 워커 종료 UTC |
| `outputs` | list[object] | ✓ | path, summary 쌍 |
| `decision_proposal` | object | decision_required=true 시 | choice, rationale |
| `issues` | list[string] | ✓ | 빈 리스트라도 명시 |
| `tier_used` | int | ✓ | 1 / 2 / 3 |

## status 별 디렉터 동작

| status | 디렉터 동작 |
|--------|-----------|
| completed | decisions.log append, state.yaml 갱신, 다음 work-order 디스패치 |
| partial | tier+1 로 같은 work-order 재시도 (보강 수행) |
| failed | tier+1 로 재시도. tier=3 실패 후 누적 5회 도달 시 우회 |

## verify 워커 전용 추가 필드

verify 워커의 frontmatter 에 `verify_axes` 추가:

```yaml
verify_axes:
  ac_pass_rate: 0.85          # AC 테스트 PASS 비율 (0~1)
  ssot_coverage: 0.92         # SSOT 9섹션 covered 율 (0~1)
  art_slot_fill: 1.00         # art-bible 슬롯 채움률 (0~1)
verdict: FAIL                  # PASS | FAIL
failing_items:
  - "AC §I-3 (인벤토리 슬롯 한계) 미통과"
  - "SSOT §F.2 (저장 구조) 빈 슬롯"
```

## 변경 이력

| 버전 | 날짜 | 내용 |
|------|------|------|
| 0.1 | 2026-05-19 | 초안 (auto-pipeline 도입) |
