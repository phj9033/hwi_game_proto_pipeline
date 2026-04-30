---
title: 프로토타입 코드 표준 (Relaxed)
collection: architecture-patterns
axis: E
theory_id: prototype-code-standards
keywords: [prototype, throwaway, hypothesis-validation, relaxed-standards, README, hardcoding-allowed, no-migration, isolation]
applies_to: [implementation]
related: [high-risk-system-identification, vertical-slice-scope]
last_updated: 2026-04-28
---

# 프로토타입 코드 표준 (Relaxed)

> 프로토타입은 *학습용 throwaway 코드*. 표준은 의도적으로 완화한다.
> 목표는 production 품질이 아니라 가설 검증.

## 적용 범위

```
paths: prototypes/**
```

본 표준은 `prototypes/` 디렉토리 안의 코드에만 적용. `src/` 의 production 코드는 정식 표준 (8섹션 GDD, ADR, Control Manifest 등) 적용.

---

## 핵심 원리

프로토타입의 본질:
- **빠른 반복** > 코드 품질
- **가설 검증** > 재사용성
- **학습** > 미래 보존

이를 위해 production 표준의 *대부분을 의도적으로 위반* 허용. 다만 *프로토타입 격리* 와 *학습 기록* 만은 필수.

---

## 허용 (production 에서는 금지인 것들)

### 코드 품질
- ✅ 하드코딩된 값 (data-driven config 불필요)
- ✅ 매직 넘버
- ✅ 최소·zero doc comments
- ✅ 복사·붙여넣기 코드 (DRY 무시)
- ✅ 디버그 출력 그대로 두기
- ✅ TODO·FIXME 누적

### 아키텍처
- ✅ 단순 아키텍처 (DI 불필요)
- ✅ Singleton, 글로벌 상태
- ✅ 의존성 양방향 무시
- ✅ 레이어링 위반
- ✅ 직접 참조 (시그널 패턴 안 써도 됨)

### 자산
- ✅ Placeholder 아트·사운드
- ✅ Free 에셋팩 그대로
- ✅ 색상 단순 사각형

### 빠르고-더러운 솔루션
- ✅ if/else 폭주
- ✅ 100줄 함수
- ✅ 글로벌 변수 ABCDEF

---

## 필수 (절대 양보 금지)

### 1. 격리 — 자기 디렉토리

각 프로토타입은 자기 서브디렉토리:

```
prototypes/
├── core-fishing-minigame/
│   ├── project.godot 또는 동등
│   ├── *.gd / *.cs / *.cpp
│   └── README.md
├── difficulty-curve-test/
│   ├── ...
│   └── README.md
└── ...
```

**금지**: 두 프로토타입이 코드 공유하지 말 것. 격리가 깨지면 이미 production 의 시작.

---

### 2. README.md — 가설 + 결과 기록

각 프로토타입은 `README.md` 필수:

```markdown
# 프로토타입: <이름>

## 가설 (Hypothesis)
검증하려는 것 1~3 개:
- H-1: <명확한 진술> — 측정 방법 — 통과 기준
- H-2: ...

## 실행 방법
1. <엔진> 으로 [경로/파일] 임포트
2. F5 또는 [실행 키]
3. ...

## 자동 측정
- 측정 항목 1: 수치
- 측정 항목 2: 수치

## 수동 측정 필요
- 항목 1: 어떻게 평가할 것인가
- 항목 2: ...

## 현재 상태
in-progress | concluded

## 결과 (Findings) — 결론 시점에 채움
- H-1: ✅/❌ + 근거
- H-2: ✅/❌ + 근거

## 결론·다음 단계
- PROCEED → production 으로 (어떤 부분 채택)
- PIVOT → 수치/방향 조정
- KILL → 폐기 + 다른 가설로 시작
```

**금지**:
- README 없는 프로토타입
- README 가 outdated (코드 변경됐는데 README 미반영)
- 결과 기록 없이 폐기

---

### 3. Production 코드 보호

다음 절대 금지:

- ❌ Production 코드 (`src/`) 가 `prototypes/` 를 import 또는 참조
- ❌ 프로토타입이 `src/` 외부 파일 수정
- ❌ 프로토타입이 배포·shipping 빌드에 포함

```bash
# CI 검증 예시
grep -r "from prototypes" src/    # 결과 있으면 빌드 fail
grep -r "import prototypes" src/  # 결과 있으면 빌드 fail
```

---

## 성공 시 — 마이그레이션 금지

프로토타입이 가설 검증 통과해서 production 진입할 때:

```
❌ 프로토타입 코드 그대로 src/ 로 이동
❌ 프로토타입 코드를 점진적으로 정리해서 production 화
✅ 프로토타입은 *그대로 두고*, production 에서 *처음부터 재작성*
```

**왜?**
- 프로토타입은 표준 위반 누적. 정리 비용 > 재작성 비용.
- 재작성 시점에 production GDD·ADR 작성. 설계가 깨끗해짐.
- 프로토타입 코드는 *참고용*. 결정의 근거.

### 마이그레이션 절차

```
1. 프로토타입 README 의 결과·결론 기록 완성
2. 결과를 정식 GDD 의 Acceptance Criteria 로 변환
3. ADR 작성 (프로토타입에서 검증된 결정 사항)
4. Control Manifest 갱신
5. Production 코드 작성 (8섹션 GDD 따름, 표준 적용)
6. 프로토타입은 prototypes/ 에 그대로 보존 (참고용)
```

---

## 프로토타입 라이프사이클

```
[Created]
   │ (코드 작성, 가설 정의)
   ↓
[In Progress]
   │ (반복 실험, 결과 측정)
   ↓
[Concluded]
   │ (README 결과·결론 기록)
   ├──→ [Migrated]   (production 으로 재작성, 프로토타입은 보존)
   ├──→ [Pivoted]    (다른 가설로 새 프로토타입)
   └──→ [Archived]   (학습 끝, 더 안 씀, 그대로 보존)
```

**절대 안 함**:
- 프로토타입 *삭제* (학습 기록 손실)
- 프로토타입 코드를 production 에 *직접 머지*

---

## 정리 (Cleanup)

Concluded 프로토타입 처리:

1. **결과 캡쳐**: README 의 Findings·결론 완성
2. **유지**: 디렉토리 그대로 보존. 향후 의사결정의 근거.
3. **갱신 금지**: Concluded 후에는 코드 수정 금지. 결과의 일관성 보호.
4. **확장 금지**: "약간만 더 다듬어서..." → 절대 안 됨. 새 프로토타입 또는 production.

> 프로토타입을 점진적으로 production 으로 만드는 *유혹* 이 가장 흔한 실패 패턴.
> 한 번 Concluded 하면 코드는 죽은 것으로 간주.

---

## 안티패턴

### 1. README 없는 프로토타입
"빨리 만들고 싶어서" 가설·결과 기록 누락.
→ 6개월 후 코드만 남고 *왜 만들었는지* 모름.

해결: README 가 코드보다 먼저. 가설 없이 시작하지 말 것.

---

### 2. 프로토타입 → production 점진적 마이그레이션
"이 부분만 정리하면 쓸 만함" → 누적 → production 의 절반이 프로토타입 코드.
→ 표준 위반이 production 에 영구 잔존.

해결: 마이그레이션 = 재작성. 코드 한 줄도 옮기지 말 것.

---

### 3. 다중 프로토타입 코드 공유
A 프로토타입의 helper 를 B 가 import.
→ 격리 깨짐. 한 곳 변경 시 다른 곳 깨짐.

해결: 각 프로토타입 자기완결. 복사가 차라리 OK.

---

### 4. 프로토타입에 표준 적용
"좋은 습관 들이려고 8섹션 GDD 작성" → 일주일 소요.
→ 프로토타입의 본질 (빠른 반복) 상실.

해결: 표준은 production 만. 프로토타입은 README + 코드 끝.

---

### 5. Concluded 후 코드 수정
"결론 났는데 더 나은 아이디어 있어서..."
→ 옛 결론이 적용된 README 와 새 코드 불일치.

해결: 새 가설이면 새 디렉토리. 옛 프로토타입은 그대로.

---

## 본 파이프라인과의 관계

본 파이프라인 (concept-pipeline) 은 단계 7 에서 끝남 — *프로토타입 준비 완료*. 즉, 통합 명세서를 만들어 *프로토타입 제작자에게 전달*.

프로토타입 단계 자체는 본 파이프라인 외부:
- 입력: 본 파이프라인의 산출 `06-integrated-spec.md`
- 본 표준 적용: prototypes/<이름>/ 안에서
- 출력: README.md 의 Findings·결론

→ 본 표준은 *다음 워크플로우 (프로토타입→본 게임 빌드업)* 의 시작점.

---

## 검증 체크리스트

프로토타입 시작 시:

- [ ] `prototypes/<이름>/` 디렉토리 생성됨
- [ ] README.md 의 가설 (H-1, H-2, ...) 명시됨
- [ ] 측정 방법 + 통과 기준 명시됨
- [ ] `src/` 와 격리 확인 (의존 없음)

프로토타입 진행 중:
- [ ] README 가 코드와 동기화됨
- [ ] 측정 결과 누적 기록

프로토타입 종료 시:
- [ ] Findings 모든 가설별로 기록됨
- [ ] 결론 (PROCEED/PIVOT/KILL) 명시
- [ ] PROCEED 인 경우: production 재작성 절차 합의
- [ ] 코드 수정 종료 (이후 read-only)
