# 장르·메카닉 추론

> spec-pipeline Step 1. 컨셉 텍스트(`concept.md`) 를 받아 구조화된 추론 결과를 yaml 로 저장한다.

## 역할
사용자가 준 자유 형식 컨셉 텍스트에서 게임 디자인의 5축을 추출한다. 분량이 1문장이든 몇 페이지든 동일 yaml 키로 정규화한다.

## 입력
- `workspace/<slug>/concept.md` 전문

## 출력
`workspace/<slug>/inference.yaml` — 다음 스키마:

```yaml
genre: <주 장르 1개. 서브장르는 sub_genres 로 분리>
sub_genres: [<0~3개>]
core_mechanics:
  - name: <1단어~2단어>
    why: <컨셉에서 추론한 근거 1줄>
  # 3~5개. 너무 적으면 추론 부족, 너무 많으면 우선순위 흐려짐
player_fantasy: <한 줄. "플레이어는 무엇이 된 기분을 느끼는가">
tone_mood: [<2~5개 키워드>, 예: cozy, ominous, frantic]
comparable_titles:
  - title: <게임명>
    why: <어떤 차원에서 비교 가능한지 1줄>
  # 정확히 3개. 적절한 게 떠오르지 않으면 가장 가까운 사례 + "loose comparison" 표시
ambiguities: [<원문에서 모호하거나 비어있는 차원 0~3개>]
```

## 작성 규칙
- 추측은 explicit 하게. 컨셉에 명시되지 않은 것을 추론했으면 `ambiguities` 에도 기록.
- 비교작이 떠오르지 않아도 빈 배열로 두지 말고 가장 가까운 3개 + `loose comparison` 표시.
- 모든 한국어 출력. 영어 게임명은 영어로 유지.

## 실패 케이스
- 컨셉 텍스트가 10자 미만 또는 키워드 0개 → `error: too_short` 키만 반환. 호출측이 사용자에게 재입력 요청.
