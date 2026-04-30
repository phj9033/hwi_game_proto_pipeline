---
title: Game Feel 명세 양식
collection: gdd-wisdom
axis: C
theory_id: game-feel-spec
keywords: [game-feel, juice, responsiveness, animation, hit-pause, screen-shake, weight, feedback, ms, frames]
applies_to: [creation, implementation]
related: [8section-gdd-standard, gdd-antipatterns]
last_updated: 2026-04-28
---

# Game Feel 명세 양식

> "느낌이 좋다" 는 측정 불가능. 모든 게임 느낌(feel)은 ms·frames·dB·픽셀 단위로 명세 가능하다.
> 명세되지 않은 feel 은 구현되지 않은 feel 이다.

## 핵심 원리

Game Feel (또는 game juice) 은 추상적 단어가 아니다. 다음 6개 차원으로 분해된다:

1. **입력 반응성** (Input Responsiveness) — ms 단위
2. **애니메이션 페이즈** (Animation Phases) — startup/active/recovery 프레임
3. **임팩트 모먼트** (Impact Moments) — hit pause, screen shake, freeze frame
4. **무게감 프로파일** (Weight Profile) — 가속/감속 곡선
5. **오디오 피드백** (Audio Feedback) — 트리거 → 재생 지연, 다이내믹스
6. **비주얼 주스** (Visual Juice) — 파티클, 화면 왜곡, 색 변화

각 차원은 GDD 의 **별도 섹션 "Game Feel 명세"** 에 정량 수치로 적는다.

---

## 1. 입력 반응성 (Input Responsiveness)

**측정 단위**: ms 또는 frames (60fps 기준 16.67ms = 1 frame)

### 명세 항목

```markdown
## Game Feel — 입력 반응성

| 입력 → 시각 피드백 | 목표 지연 | 절대 한계 | 60fps 기준 |
|---------------------|----------|----------|-----------|
| 클릭 → 캐치 이펙트 시작 | < 50ms | < 100ms | 3 frames |
| 클릭 → 사운드 재생 시작 | < 30ms | < 50ms | 2 frames |
| 키 입력 → 캐릭터 이동 시작 | < 16ms | < 33ms | 1 frame |
| 클릭 → UI 버튼 시각 변화 | < 16ms | < 33ms | 1 frame |
```

### 가이드라인

- **16ms (1 frame)**: 격투/액션 게임 수준. 사용자가 의식적으로 인지 못함.
- **33ms (2 frames)**: 캐주얼 액션. 약간의 지연 인지하지만 자연스러움.
- **50~100ms (3~6 frames)**: 슬로우 액션, 카드 게임. 의도적 천천히.
- **>100ms**: 거의 모든 액션 게임에서 느림으로 인지됨.

### 안티패턴

❌ "반응이 빠르다" — 정량 없음
❌ "60fps 에서 부드럽게" — 입력 반응성과 framerate 는 별개
❌ 한 시스템이 여러 입력에 다른 반응성을 갖는데 명시 안 함

---

## 2. 애니메이션 페이즈 (Animation Phases)

**구성**:

```
Startup (시작) → Active (효과 발동) → Recovery (마무리)
```

격투 게임에서 유래한 분해. 모든 액션 메카닉에 적용 가능.

### 명세 항목

```markdown
## Game Feel — 애니메이션 페이즈

### 액션: 캐치 시도 (클릭)
| 페이즈 | 프레임 | 시각 표현 | 게임플레이 영향 |
|--------|--------|----------|----------------|
| Startup | 0~2f (0~33ms) | 클릭 위치 확장 원 | 히트 판정 시작 |
| Active | 2~5f (33~83ms) | 캐치 이펙트 재생 | 히트 판정 (활성) |
| Recovery | 5~8f (83~133ms) | 페이드 아웃 | 다음 클릭 가능 |

총 입력 잠금: 8f (133ms)

### 액션: 점프 (캐릭터)
| Startup | 3f | 다리 모으는 모션 | 점프 캔슬 가능 |
| Active | 12f | 공중 부양 | 입력 무시 |
| Recovery | 5f | 착지 모션 | 5f 후 재점프 가능 |
```

### 페이즈 비율 가이드

- **공격적 액션** (격투, 슈팅): Startup 짧게 (1~3f), Active 명확히 (3~10f), Recovery 길게 (5~15f) — 위험 vs 보상
- **방어적 액션** (가드, 회피): Startup 거의 없음, Active 길게, Recovery 짧게
- **느긋한 액션** (RPG, 시뮬레이션): 모두 균등하거나 Startup 길게

### 안티패턴

❌ Recovery 없음 — 액션 후 즉시 다음 액션 가능 → 메카닉 깊이 사라짐
❌ Startup·Recovery 모두 길어서 액션이 둔해 보임
❌ 페이즈가 시각적으로 구분 안 됨 → 사용자가 타이밍 학습 불가

---

## 3. 임팩트 모먼트 (Impact Moments)

**도구**:
- **Hit Pause** (히트 프리즈): 0.05~0.15초간 시간 정지
- **Screen Shake** (화면 흔들림): amplitude·duration·frequency
- **Freeze Frame** (정지 프레임): 1~3 frame 동결

### 명세 양식

```markdown
## Game Feel — 임팩트 모먼트

### 일반 캐치 성공
- Hit Pause: 50ms (3 frames)
- Screen Shake: 없음
- Sound: SFX_catch_normal.wav, +0dB
- Particle: 작은 별 5개, 0.3초

### LEGENDARY 캐치 성공
- Hit Pause: 200ms (12 frames)
- Screen Shake: amplitude=8px, duration=400ms, frequency=30Hz
- Freeze Frame: 첫 1 frame
- Sound: SFX_catch_legendary.wav, +3dB, BGM duck -6dB for 800ms
- Particle: 황금 별 30개, 0.8초, 화면 전체 빛
- Slow Motion: 다음 1초간 0.5x speed
```

### 가이드라인

- **임팩트는 위계가 있어야**: 일반 < 우수 < 전설 — 명확한 차이.
- **과용 금지**: 모든 액션에 hit pause 넣으면 둔해짐. 핵심 모먼트만.
- **Hit Pause 를 너무 길게**: > 300ms 면 답답함.

---

## 4. 무게감 프로파일 (Weight Profile)

**측정**:
- 가속 (acceleration) — units/second²
- 감속 (deceleration / friction)
- 최고 속도 (max velocity)
- 정지까지 시간 (time-to-stop)

### 명세 양식

```markdown
## Game Feel — 무게감

### 캐릭터 이동
| 항목 | 값 | 단위 |
|------|----|----|
| 정지 → 최고속도 도달 시간 | 100ms (6f) | ms |
| 최고속도 | 600 | px/s |
| 가속 | 6000 | px/s² |
| 감속 (입력 끊김) | 12000 | px/s² (가속의 2배) |
| 정지까지 시간 | 50ms (3f) | ms |

→ 응답형 캐릭터 (메트로배니아 스타일)

### 카메라 따라가기
- 캐릭터 이동 시 카메라 lag: 200ms (smooth follow)
- 캐릭터 정지 시 카메라 정지 lag: 400ms (overshoot 방지)
```

### 무게감 ↔ 게임 톤

| 톤 | 무게감 |
|---|---|
| Twitchy (격투, 슈팅) | 가속·감속 모두 매우 빠름. 정지까지 < 50ms |
| Responsive (플랫포머) | 가속 빠름, 감속 빠름. 즉각적 |
| Heavy (메카, RPG) | 가속 느림, 감속 느림. 묵직함 |
| Floaty (우주, 수중) | 가속 느림, 감속 매우 느림. 둥둥 |

### 안티패턴

❌ "묵직한 느낌" — 가속·감속 수치 없음
❌ 가속 = 감속 — 응답성 떨어짐 (대개 감속 = 가속의 1.5~2배)
❌ 무게감과 톤 불일치 (격투 게임인데 가속 느림)

---

## 5. 오디오 피드백 (Audio Feedback)

### 명세 항목

```markdown
## Game Feel — 오디오

### 트리거별 오디오
| 트리거 | 사운드 | 지연 | 볼륨 | 다이내믹스 |
|--------|--------|------|------|----------|
| 클릭 (UI) | SFX_click.wav | 0ms | -3dB | 정적 |
| 캐치 성공 (일반) | SFX_catch.wav | 0ms | 0dB | BGM 변화 없음 |
| 캐치 성공 (전설) | SFX_legendary.wav | 0ms | +3dB | BGM duck -6dB, 800ms |
| 콤보 5 | SFX_combo5.wav | 0ms | +1dB | 정적 |
| 게임 종료 | SFX_round_end.wav | 0ms | 0dB | BGM fadeout 1s |

### BGM 레이어
- Layer 1: 베이스 (항상 재생)
- Layer 2: 멜로디 (콤보 ≥ 3 일 때 페이드인)
- Layer 3: 강화 (콤보 ≥ 7 일 때 페이드인)
```

### 가이드라인

- **트리거 → 재생 지연 < 30ms**: 더 길면 인과 감각 끊어짐.
- **다이내믹스 명시**: 단순 사운드 재생 외에 BGM duck, 다른 사운드 동작 영향.
- **볼륨 위계**: 일반 < 강조 — 모든 사운드 같은 볼륨이면 강조 효과 사라짐.

---

## 6. 비주얼 주스 (Visual Juice)

### 명세 항목

```markdown
## Game Feel — 비주얼 주스

### 일반 캐치
- Particle: 5개 별 입자, 0.3초, 청색
- Color flash: 없음
- UI feedback: 점수 +N 텍스트, 0.5초간 떠오름

### 전설 캐치
- Particle: 30개 별 입자, 0.8초, 황금색
- Color flash: 화면 전체 0.1초 황금 오버레이
- Screen distortion: 가벼운 chromatic aberration, 0.3초
- UI feedback: 점수 +N 텍스트, 1.5초간 떠오름 + 글로우

### 콤보 인디케이터 (5 이상)
- Pulse: 콤보 카운터 1.2배 스케일링, 0.2초 펄스
- Color shift: 흰색 → 황금색 그라데이션
```

### 가이드라인

- **반응 = 비례**: 작은 액션은 작은 반응, 큰 액션은 큰 반응.
- **누적 효과**: 콤보 등 누적 상태는 시각적으로 누적되어 보여야 함.
- **남용 금지**: 모든 클릭에 화면 왜곡 → 멀미.

---

## 통합 명세 양식 (8섹션 GDD 의 보조 섹션)

8섹션 GDD 외에 다음 보조 섹션을 추가할 것:

```markdown
## Game Feel 명세

### 입력 반응성
(표)

### 애니메이션 페이즈
(액션별 표)

### 임팩트 모먼트
(트리거별 명세)

### 무게감 프로파일
(이동/카메라/UI 별 수치)

### 오디오 피드백
(트리거별 표 + BGM 레이어)

### 비주얼 주스
(액션별 명세)
```

---

## 검증 체크리스트

- [ ] 6개 차원 모두 명세됨
- [ ] 모든 수치가 단위와 함께 (ms, frames, px, dB)
- [ ] 60fps 기준 frame 카운트 병기
- [ ] 위계 (일반 < 강조 < 전설) 가 차원마다 일관됨
- [ ] "느낌이 좋다" 류 정성 단어 없음
- [ ] AC (8섹션 중 8) 에 feel 관련 측정 가능 항목 포함
