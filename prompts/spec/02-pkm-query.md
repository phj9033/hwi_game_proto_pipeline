# PKM 쿼리 + 관련성 점수화

> spec-pipeline Step 2. G1 통과한 `inference.yaml` 로부터 PKM 검색 쿼리를 자동 생성하고, 결과를 점수화해 G2 게이트 표시 후보를 만든다.

## 역할
1. inference 의 각 차원에서 5~7개 PKM 쿼리 자동 생성
2. pkm-recall 스킬을 쿼리당 1회씩 순차 호출
3. 결과 통합·중복 제거 후 각 항목을 0~5 점으로 자체 점수화
4. 점수 ≥ 3 인 항목을 최대 8개까지 G2 게이트용 리스트로 반환

## 쿼리 자동 생성

inference 에서 다음 7개를 만든다 (메카닉이 3개 미만이면 그만큼 줄어듦):

```
1. "{genre} 게임 디자인 결정"
2. "{core_mechanics[0].name} 시스템 패턴"
3. "{core_mechanics[1].name} 시스템 패턴"
4. "{core_mechanics[2].name} 시스템 패턴" (3개 이상일 때만)
5. "{tone_mood[0]} {tone_mood[1]} 아트 디렉션"
6. "{comparable_titles[0].title} 분석"
7. "{comparable_titles[1].title} 분석"
```

각 쿼리를 별도로 pkm-recall 호출. 결과는 동일 `id`/`source` 기준으로 중복 제거.

## 점수화 루브릭 (각 항목 0~5)

각 PKM 항목의 본문을 보고 다음 3축의 합으로 점수 (각 0~2, 마지막 +1 보너스):

- **직접성 (0~2)**: 항목이 inference 의 특정 차원을 직접 언급하면 2, 인접 개념이면 1, 무관해 보이면 0
- **재사용 가능성 (0~2)**: 항목이 결정/패턴/스니펫처럼 구체적 가이드 형태면 2, 추상적 통찰이면 1, 메타 정보면 0
- **신선도 보너스 (+1)**: 항목 일자가 1년 이내면 +1

총 0~5점. **3점 이상**만 G2 후보로 표시.

## 출력

`workspace/<slug>/pkm-recall.md` — 다음 구조:

```markdown
# PKM Recall

생성일: <ISO>
쿼리 수: N
원시 항목 수: M

## CANDIDATES (점수 ≥ 3, 최대 8개)

### [1] score=4.5 source=<source> title=<title>
why-match: "<쿼리 X> 와 직접 매치"
excerpt: "<200자 내외>"

### [2] ...

## DISCARDED (점수 < 3, 카운트만)
- N items below threshold

## ADOPTED  (G2 통과 후 호출측이 채움)
(빈 섹션 — 사용자 채택 후 호출측이 본문 복사해 채움)
```

## 폴백
- pkm-recall 미설치/호출 실패 → 빈 파일 + `# SKIPPED: pkm-recall unavailable` 헤더만. 호출측이 G2 건너뜀.
- 모든 쿼리 0결과 또는 모두 점수 < 3 → `## CANDIDATES` 섹션 비움. 호출측이 G2 자동 통과.
