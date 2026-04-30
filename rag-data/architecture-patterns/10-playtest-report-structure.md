---
title: Playtest Report 구조 패턴
collection: architecture-patterns
axis: E
theory_id: playtest-report-structure
keywords: [playtest, report, hypothesis-testing, observation, metric, qualitative, quantitative, sign-off, regression]
applies_to: [evaluation]
related: [test-evidence-matrix, prototype-code-standards, vertical-slice-scope]
last_updated: 2026-04-28
---

# Playtest Report 구조 패턴

> 플레이테스트 = *외부 시각으로* 게임을 본 결과. 디자이너의 머릿속이 아닌 *실제 플레이어*의 행동·반응이 진실.
> 자동화 못 잡는 결함의 90% 가 플레이테스트에서 발견.

## 핵심 원리

플레이테스트의 본질:
- **가설 검증**: "X 일 때 플레이어는 Y 한다" 의 실증
- **이탈 신호**: 디자이너가 못 본 막힘·혼란
- **예상 외 행동**: "이게 가능?" 또는 "이렇게 하다니?"

따라서 리포트는:
- 가설 명시 → 결과 측정 (정량 + 정성)
- 관찰 기록 (행동·발화)
- 명시적 결론 (PASS/PIVOT/KILL)

---

## 표준 11 섹션

```markdown
# Playtest Report — <게임/시스템명>

## 1. Metadata
## 2. Hypothesis (검증 가설)
## 3. Test Setup
## 4. Tester Profile
## 5. Quantitative Observations
## 6. Qualitative Observations
## 7. Hypothesis Verdict
## 8. Unexpected Findings
## 9. Pain Points
## 10. Conclusion (PROCEED / PIVOT / KILL)
## 11. Sign-off
```

---

## 1. Metadata

```markdown
## 1. Metadata
- **Date**: 2026-04-28
- **Build**: dev-2026-04-28-a1b2c3
- **Duration**: 45분
- **Mode**: Unguided / Semi-guided / Guided
- **Tester**: <이름 또는 익명 ID>
- **Observer**: <이름>
- **Recording**: 영상 / 오디오 / 메모 only
```

### Mode 정의

| Mode | 설명 | 가치 |
|------|------|------|
| **Unguided** | 디자이너 개입 없음. 관찰만. | 가장 가치 높음 (실제 플레이) |
| **Semi-guided** | 막히면 살짝 힌트 | 중간 (FTUE 검증에 적합) |
| **Guided** | 디자이너가 단계별 안내 | 낮음 (특정 시스템 검증에만) |

→ Vertical Slice 검증은 *Unguided* 의무.

---

## 2. Hypothesis (검증 가설)

```markdown
## 2. Hypothesis

### H-1: <명확한 진술>
- 측정 방법: ...
- 통과 기준: ...

### H-2: ...
```

각 가설:
- **명확한 진술**: "X 일 때 Y 한다" 형식
- **측정 가능**: 정량 또는 명확 boolean
- **통과 기준**: 사전 명시 (테스트 후 변경 금지)

예시:
```markdown
### H-1: 첫 30초 안에 첫 캐치 성공
- 측정 방법: 시간 기록
- 통과 기준: 5명 중 4명 이상 30초 내 첫 캐치

### H-2: LEGENDARY 등장 시 인지함
- 측정 방법: 발화 ("어! 이거 뭐야?") 또는 행동 (즉각 클릭)
- 통과 기준: 5명 중 4명 이상 인지

### H-3: 60초 라운드 후 "한 번 더" 의도
- 측정 방법: 자발적 다시 시작 vs 종료
- 통과 기준: 3명 이상 자발적 재시작
```

---

## 3. Test Setup

```markdown
## 3. Test Setup

### 환경
- 하드웨어: M1 Mac, 16GB
- 해상도: 1920×1080
- 입력: 마우스 + 키보드
- 헤드폰: Yes (사운드 평가 가능)

### 빌드
- Godot 4.6
- 빌드 ID: dev-2026-04-28-a1b2c3
- 변경 사항 (이전 빌드 대비): 난이도 곡선 +20%, LEGENDARY 가중치 0.05 → 0.07

### 사전 안내
- "이 게임을 30분 정도 자유롭게 플레이해주세요"
- "막히면 도와드릴게요. 단, 가능한 한 스스로 해보세요"
- "느낀 점·혼란스러운 점이 있으면 그때그때 말씀해주세요"
```

---

## 4. Tester Profile

```markdown
## 4. Tester Profile

### 데모그래픽
- 나이: 20대
- 게임 경험: 캐주얼 게이머 (모바일 위주)
- 본 장르 경험: 낮음 (낚시 게임 처음)

### Bartle 유형
- 자가 평가: Achiever 위주
- 관찰: 점수 도전 적극적

### 특이사항
- 빠른 손 작업 익숙
- 시각 처리 빠름
```

---

## 5. Quantitative Observations (정량 관찰)

```markdown
## 5. Quantitative Observations

### 주요 지표
| 지표 | 값 | 비교 |
|------|----|----|
| 첫 캐치 시점 | 12s | 목표 30s 내 ✓ |
| 평균 라운드 점수 | 8,500 | 예상 5,000~10,000 ✓ |
| LEGENDARY 캐치 횟수 (15분) | 3 | 가능 |
| 자발적 재시작 횟수 | 7 | 강한 재플레이 의도 ✓ |
| 일시정지 횟수 | 0 | 자연스러운 흐름 |
| 종료 시점 (자발) | 28분 | 목표 30분 근접 ✓ |

### 시간별 분포
- 0~5분: 적응 (낮은 점수, 실수 많음)
- 5~15분: 학습 (점수 증가, 콤보 시도)
- 15~25분: 마스터리 시도 (높은 점수)
- 25~28분: 종료 결정
```

---

## 6. Qualitative Observations (정성 관찰)

```markdown
## 6. Qualitative Observations

### 주요 발화
- 0:30 "어! 이게 뭐지?" (LEGENDARY 첫 등장)
- 2:15 "아 이거 콤보가 되네!" (콤보 5 도달)
- 8:00 "LEGENDARY 만 노리면 되겠다" (전략 형성)
- 15:30 "와 6개나 있어!" (난이도 정점 인지)
- 22:00 "한 번 더" (라운드 종료 후)
- 27:00 "재밌었어요" (자발적 종료 직전)

### 행동 패턴
- 클릭 빠름·정확 (반응 시간 적당)
- LEGENDARY 등장 시 항상 우선 클릭 (전략 형성됨)
- 일반 오브젝트 가끔 무시 (LEGENDARY 대기)
- 콤보 끊기면 작은 짜증 표현 (재미 신호)

### 감정 변화 (관찰자 평가)
- 0~3분: 호기심
- 3~10분: 학습·발견
- 10~20분: 몰입·도전
- 20~28분: 만족·여운
```

---

## 7. Hypothesis Verdict (가설 판정)

```markdown
## 7. Hypothesis Verdict

| 가설 | 결과 | 근거 |
|------|------|------|
| H-1: 첫 30초 캐치 | ✅ PASS | 12초 (기준 30초) |
| H-2: LEGENDARY 인지 | ✅ PASS | "어 이게 뭐지?" + 즉각 클릭 |
| H-3: 한 번 더 의도 | ✅ PASS | 7회 자발적 재시작 |

종합: 3/3 PASS
```

---

## 8. Unexpected Findings (예상 외 발견)

```markdown
## 8. Unexpected Findings

### 1. LEGENDARY 만 노리는 전략 형성 (8분 시점)
디자이너 의도: 모든 오브젝트가 의미 있음
실제: LEGENDARY 점수가 너무 압도적 → 일반 캐치 무시

→ 잠재적 *지배 전략* 위험. 차후 검증 필요.

### 2. "콤보" 라는 말 한 번도 안 함
디자이너 의도: 콤보 시스템 강조
실제: 점수 증가는 인지하지만 "콤보" 라는 메카닉으로 인지 안 함

→ UI 표시 부족 또는 명칭 미인지.

### 3. 화면 좌상단 보지 않음
디자이너 의도: 거기에 점수 표시
실제: 한 번도 안 봄. 점수는 결과 화면에서만 확인.

→ HUD 위치 재고 필요.
```

---

## 9. Pain Points (막힘 포인트)

```markdown
## 9. Pain Points

### 1. ESC 키 == 게임 일시정지 모름
- 발생 시점: 0:00
- 행동: ESC 시도 안 함 (메뉴 복귀 위해 우클릭 시도)
- 영향: 자연스러운 일시정지 못함

### 2. LEGENDARY 후 짧은 정적 (의아함)
- 발생 시점: 0:35 (첫 LEGENDARY 직후)
- 행동: 화면 흔들림 후 멈춘 듯 보임 → "어? 끝난 건가?"
- 실제: hit pause 200ms + slow motion 1초
- 영향: 게임 멈춘 줄 알고 클릭 멈춤
```

---

## 10. Conclusion

```markdown
## 10. Conclusion: PROCEED with adjustments

### 종합 판정
3/3 가설 통과. 코어 메카닉 검증됨.

### 다음 결정
- ✅ PROCEED — 메카닉 그대로 진행
- ⚠️ 단, 다음 조정 필요:
  1. LEGENDARY 보상 -20% (지배 전략 완화)
  2. HUD 위치 재고 (좌상 → 중하)
  3. 콤보 인디케이터 명시화 (텍스트 추가)
  4. ESC 일시정지 첫 등장 시 안내

### 다음 액션
- [ ] 위 4 조정 적용
- [ ] 5명 이상 추가 플레이테스트 (재검증)
- [ ] PROCEED 확정 시 Production 단계
```

### Verdict 종류

| Verdict | 의미 |
|---------|------|
| **PROCEED** | 가설 통과. 진행. |
| **PROCEED with adjustments** | 통과했으나 조정 필요 |
| **PIVOT** | 일부 가설 실패. 방향 수정. |
| **KILL** | 핵심 가설 실패. 폐기 또는 근본 재설계. |

---

## 11. Sign-off

```markdown
## 11. Sign-off

- **Designer**: <이름>, 동의 ✓
- **Producer / PM**: <이름>, 동의 ✓
- **Date Reviewed**: 2026-04-28

### 회람
- [x] 게임 디자이너
- [x] 프로듀서
- [ ] 아트 디렉터 (선택)
```

---

## 다중 세션 분석

여러 플레이테스트 (예: Vertical Slice 의 3 세션 의무) 시:

```markdown
## 종합 분석 (3 세션)

| 가설 | 세션 1 | 세션 2 | 세션 3 | 종합 |
|------|--------|--------|--------|------|
| H-1: 첫 30초 캐치 | ✅ 12s | ✅ 18s | ❌ 35s | ⚠️ 2/3 PASS |
| H-2: LEGENDARY 인지 | ✅ | ✅ | ✅ | ✅ 3/3 PASS |
| H-3: 한 번 더 | ✅ | ⚠️ 1회만 | ✅ | ⚠️ 2/3 PASS |

종합: 가설 1·3 은 일부 실패. PIVOT 검토.
```

→ 단일 세션은 *개별 발견*, 다중 세션은 *통계적 신뢰*.

---

## 안티패턴

### 1. 가설 사후 작성
플레이테스트 후 결과 보고 가설 작성 → 항상 PASS.

해결: 가설은 *사전*에 명시 + 통과 기준 사전 결정.

---

### 2. 정량만, 정성 누락
점수·시간만 기록. 발화·행동 누락.

해결: 두 차원 모두 의무. 발화·표정·신체 언어 기록.

---

### 3. Guided 만으로 Vertical Slice 검증
디자이너가 단계마다 안내 → 진짜 사용자 경험 못 봄.

해결: VS 는 Unguided 의무. 막혀도 30분 이상 관찰만.

---

### 4. 1 세션으로 결론
한 번 통과 → 완성으로 간주.

해결: 다중 세션 (VS 의무 3회 이상). 통계적 신뢰.

---

### 5. PROCEED/KILL 만, 중간 없음
"OK" 또는 "KILL" 이분법 → 미세 조정 기회 없음.

해결: PROCEED with adjustments, PIVOT 같은 중간 verdict.

---

## 본 파이프라인 적용

본 파이프라인은 단계 7 에서 *프로토타입 준비*까지. 실제 플레이테스트는 다음 워크플로우.

단계 6 통합 명세서에 다음 정보 포함:
- H. 프로토타입 가설 (3~7개) → 다음 워크플로우의 플레이테스트 기준
- I. 인수 기준 → 통과 기준

→ 본 패턴은 단계 7 후 *시작*. 결과는 다음 워크플로우의 입력.

---

## 검증 체크리스트

리포트 작성 시:
- [ ] 11 섹션 모두 존재
- [ ] 가설 사전 명시 + 통과 기준
- [ ] 정량·정성 모두 기록
- [ ] Mode 명시 (특히 Unguided 여부)
- [ ] Tester Profile 명시
- [ ] Pain Points + Unexpected 별도 식별
- [ ] Verdict 4 종 중 명확 선택
- [ ] Sign-off
- [ ] (다중 세션 시) 종합 분석
