# 단계 4 — 5-Axis 평가 + 점수화 (AI 평가 + RAG)

## 목적
2단계의 3개 드래프트를 동일한 학술적 루브릭(5-Axis)으로 채점하여, 5단계로 진출할 최선의 분기를 선정한다.
점수는 RAG로 회수한 이론 문서의 인용을 근거로 한다.

## 산출물
`workspace/<slug>/04-eval-report.md`

## 사전 작업

1. `01-concept.md`, `02-draft-A.md`, `02-draft-B.md`, `02-draft-C.md` 모두 읽기
2. `config.yaml` 의 `rubric` 섹션 읽기 — 가중치, 척도 정의
3. **per_axis RAG 회수** — config.yaml.rubric.axes 5개 각각 다음 명령 실행:
   ```bash
   hwicortex query "axis A evaluation criteria scoring rubric structure" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis B motivation SDT Bartle Octalysis" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis C cognitive load flow FTUE" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis D MDA RMDA tetrad coherence" -c gdd-evaluation --json --full -n 3
   hwicortex query "axis E vertical slice scope viability publisher" -c gdd-evaluation --json --full -n 3
   ```
   각 축당 3개 이론 문서 본문 회수. 회수 결과를 채점 근거 컨텍스트로 사용.

   **gdd-evaluation 컬렉션이 없으면 단계 중단** (config.yaml 에서 required: true).

4. (선택) `indie-postmortems`, `market-snapshots` 컬렉션이 있으면 Axis E 보강 회수:
   ```bash
   hwicortex query "<concept_keywords> scope failure indie" -c indie-postmortems --json -n 3
   hwicortex query "<concept_keywords> market data steam" -c market-snapshots --json -n 3
   ```

## 채점 절차

### 5축 × 3드래프트 = 15개 점수

각 (드래프트 D, 축 X) 조합에 대해:

1. 드래프트 D 의 관련 부분 추출
2. 축 X 의 RAG 회수 본문에서 평가 기준 식별
3. 1~5점 척도로 점수 부여 (config.yaml.rubric.scale_definition 참조)
4. 점수 근거 작성:
   - 핵심 평가 1줄
   - RAG 인용 1~2개 (이론명 + 짧은 발췌)
   - 강점 1개
   - 약점 1개

### 종합 점수 계산

각 드래프트마다:
```
종합점수 = (A점수 × 0.15) + (B점수 × 0.25) + (C점수 × 0.20) + (D점수 × 0.25) + (E점수 × 0.15)
```

컷오프 3.5 이상이면 통과. 미만이면 5단계 진출 비권장.

## 출력 형식 (`04-eval-report.md`)

```markdown
# 5-Axis 평가 리포트 — <project-slug>

> 평가일: <날짜>
> 평가 기준: gdd-evaluation 5-Axis 모델 (config.yaml v0.1)
> 컷오프: 3.5 / 5.0

## 요약 (Executive Summary)

| 분기 | A 구조 | B 동기 | C 인지 | D 정합 | E 실현 | **종합** | 컷오프 |
|------|:----:|:----:|:----:|:----:|:----:|:------:|:------:|
| A    |  4   |  3   |  4   |  4   |  3   | **3.65** | ✅ |
| B    |  3   |  4   |  3   |  4   |  3   | **3.45** | ❌ |
| C    |  4   |  4   |  3   |  3   |  4   | **3.55** | ✅ |

**권장 선택**: 분기 [X] — <한 줄 근거>

---

## 분기별 상세 평가

### 분기 A: <분기명>

#### Axis A — 구조적 완성도 (점수: X / 5, 가중치 15%)

**평가**: ...

**RAG 인용**:
> "..." — `00-living-document.md`

**강점**: ...
**약점**: ...

#### Axis B — 심리적 동기 (점수: X / 5, 가중치 25%)
(반복)

#### Axis C, D, E
(반복)

**분기 A 종합**: X.XX / 5.0 — [통과/미달]

#### 분기 A 강점·약점 요약
- 핵심 강점 3개
- 핵심 약점 3개
- 5단계 진출 시 우선 보강 항목 1~2개

---

### 분기 B
(동일 구조)

### 분기 C
(동일 구조)

---

## 비교 분석

### 축별 베스트
- Axis A: 분기 X
- Axis B: 분기 Y
- ...

### 컷오프 통과 분기
[X, Y] (Z개)

### 권장 선택 근거
1. 점수 종합 1위는 X (X.XX)
2. 사용자 컨셉의 게임 기둥 3개와 가장 부합하는 분기는 [Y/X]
3. 가장 검증 가설이 명확한 것은 [Z]
4. (해당 시) 약점 축이 보강 가능한 영역이라 진입 후 회복 가능

→ **분기 [X] 권장**

### 비권장 분기 처리
- 컷오프 미달 분기: 폐기 또는 향후 별 프로젝트로 분리
- 컷오프 통과했으나 비선택: workspace 에 보관 (재방문 가능)
```

## 사용자 의사결정 요청

리포트 작성 후 사용자에게:
1. 리포트 요약 표 + 권장 선택 + 근거 1~2줄 표시
2. 다음 질문:
   ```
   5단계 진출할 드래프트를 선택하세요 (A / B / C):
   ※ 권장: [X]
   ※ 권장과 다른 선택 시 사유를 한 줄 적어주세요.
   ```
3. 사용자 응답을 받아 `state.yaml` 의 `artifacts.selected_branch` 에 기록
4. 단계 완료 처리

## 톤
- 한국어 마크다운
- 점수는 정수 1~5. 종합점수만 소수점 둘째 자리.
- RAG 인용은 짧게 (한 문장 이내). 출처 파일명은 반드시 명시.
- 사용자에게 보고 시 표 형식 우선, 산문 최소화.
