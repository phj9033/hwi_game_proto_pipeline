---
title: 비주얼·오디오 바이블 작성 패턴
collection: gdd-wisdom
axis: A
theory_id: visual-audio-bible
keywords: [art-bible, sound-bible, visual-style, audio-style, color-palette, mood, reference, BGM, SFX, asset-spec]
applies_to: [creation]
related: [game-feel-spec, pillar-antipillar]
last_updated: 2026-04-28
---

# 비주얼·오디오 바이블

> 게임의 *시각적·청각적 정체성*을 한 문서로 정의.
> 모든 자산 (이미지·사운드·BGM) 이 이 바이블을 기준으로 만들어짐 → 일관성 보장.

## 핵심 원리

자산은 흩어지기 쉽다. 한 사람이 만들어도 그날의 기분에 따라 다른 톤. 여러 사람이면 더 심함.

바이블은:
- **언어 통일**: 같은 단어로 같은 톤 가리킴
- **참조 묶음**: 모범 자산·금지 자산을 한 곳에
- **결정 근거**: "왜 이 색·이 사운드?" 답

---

## Art Bible (아트 바이블)

### 필수 섹션

```markdown
# Art Bible — <게임명>

## Visual Identity (비주얼 정체성)
한 줄 요약: "이 게임의 비주얼은 _______ 하다."

예: "낮은 채도의 픽셀 아트 + 따뜻한 황색 조명 + 아늑함"

## Style Keywords (스타일 키워드, 5~10개)
- 픽셀 아트 (16-bit)
- 손그림 느낌
- 낮은 채도
- 따뜻한 황색
- 미니멀 UI
- 부드러운 가장자리
- 빈티지 아날로그
- 코지 (cozy)

## Reference Games / Works (참조 작품 3~5개)
| 게임 | 차용 | 차이 |
|------|------|------|
| Stardew Valley | 픽셀 아트 + 따뜻함 | 더 어두운 채도 |
| Spiritfarer | 손그림 톤 + 감성 | 픽셀화된 라인 |
| Disco Elysium | 색조 모순 + 무드 | 우리는 단순화 |

## Color Palette (색팔레트)
주 색 5~7개 + 보조 5~7개:

### Primary
- 따뜻한 황색: #F4C95D (배경·강조)
- 깊은 갈색: #4A3526 (텍스트·라인)
- 베이지: #E8D5A8 (UI 베이스)
- 연한 청록: #6BA292 (캐치 성공 강조)
- 흐릿한 적색: #C2654E (위험·LEGENDARY)

### Secondary
- 회색조 5단계: #2D2418 ~ #D4C9B5 (그림자·중간 톤)

→ 절대 안 쓰는 색: 순수 검정 (#000), 형광색

## Lighting (조명)
- 메인 조명: 따뜻한 황색 (해질녘)
- 그림자: 부드러움, 30% 투명도
- 글로우: LEGENDARY 캐치 시만 (다른 곳엔 글로우 금지)

## Character Design (캐릭터 디자인)
- 비례: 4-head (스테레오타입 픽셀 비례)
- 라인: 1px 어두운 갈색 외곽선
- 표정: 단순 (눈 = 점, 입 = 선) - 픽셀 한계 활용
- 애니메이션: 4 프레임 idle, 8 프레임 액션

## Environment (환경)
- 시점: Top-down 45도
- 디테일: 중간 (소품 50% 보임)
- 깊이: 2.5D 효과 (그림자 + 약간의 perspective)

## UI Aesthetic (UI 미학)
- 경계선: 픽셀 직선 + 살짝 둥근 코너
- 폰트: 픽셀 폰트 (예: Determination Mono)
- 폰트 크기 위계: 16px (본문) / 20px (강조) / 32px (제목)
- 배경: 반투명 베이지

## Animation Principles (애니메이션 원칙)
- 12 fps (의도적 낮은 frame rate, 영화적)
- Anticipation (앞 동작) 강조
- Squash & stretch 절제 (캐주얼 게임이라)

## Anti-Style (피하는 것)
- ❌ 형광색 (게임 톤과 충돌)
- ❌ 매끄러운 그라데이션 (픽셀 아트 정체성과 충돌)
- ❌ 사실적 라이팅 (분위기 깨짐)
- ❌ 3D 모델 (아트 정체성 외)

## Asset Specs (자산 명세)
모든 자산은 다음 표준을 따름:
- 캔버스: 64×64px (오브젝트), 320×180px (UI), 1920×1080px (배경)
- 색: 위 팔레트만 사용
- 형식: PNG (sprite), .ase (Aseprite 소스)
- 명명: snake_case (예: object_fish_legendary.png)
```

---

## Sound Bible (사운드 바이블)

### 필수 섹션

```markdown
# Sound Bible — <게임명>

## Audio Identity (오디오 정체성)
한 줄 요약: "이 게임의 사운드는 _______ 하다."

예: "따뜻한 어쿠스틱 + 가벼운 8-bit 효과 + 60s 라운지 무드"

## Mood Keywords (무드 키워드 5~10개)
- 따뜻함 (warmth)
- 안락함 (cozy)
- 가벼운 향수 (light nostalgia)
- 8-bit 텍스처 (chiptune accents)
- 어쿠스틱 (acoustic)
- 미니멀
- 비흥분 (non-energetic — 캐주얼이라)

## Reference Tracks / Works (참조 음원 3~5개)
| 작품 | 차용 | 차이 |
|------|------|------|
| Stardew Valley OST | 따뜻함·일상감 | 우리는 더 미니멀 |
| Animal Crossing K.K. | 어쿠스틱 무드 | 우리는 BGM 단순화 |
| Coffee Talk | 라운지 텍스처 | 우리는 픽셀 사운드 가미 |

## BGM (배경 음악)

### Mood Mapping (무드 매핑)
| 게임 상태 | BGM 무드 | BPM | 길이 |
|---------|---------|-----|------|
| 메인 메뉴 | 평화·기대 | 70 | 90s 루프 |
| 일반 라운드 | 가벼운 텐션·진행 | 90 | 90s 루프 |
| 라운드 정점 | 흥분·긴장 | 120 | 30s 부스트 |
| 결과 화면 | 만족·여운 | 80 | 60s 루프 |

### Layered BGM
- Layer 1 (베이스): 항상 재생, 어쿠스틱 기타
- Layer 2 (멜로디): 라운드 시작 시 페이드인
- Layer 3 (강화): 콤보 ≥ 5 일 때 페이드인 (8-bit 신스 추가)

### 작곡 가이드
- 주 악기: 어쿠스틱 기타, 우쿨렐레, 8-bit 신스, 라이트 드럼
- 절대 안 쓰는 악기: 일렉 기타 디스토션, 헤비 베이스, 풀 오케스트라
- 키: 메이저 키 (밝은 무드)
- 박자: 4/4 또는 3/4

## SFX (효과음)

### Categories (카테고리)
| 카테고리 | 예시 | 톤 |
|---------|------|---|
| UI Click | 메뉴 버튼 | 짧음, 부드러운 8-bit |
| Catch Success (일반) | 캐치 성공 | 가벼움, 즉각 |
| Catch Success (전설) | LEGENDARY 캐치 | 길고 풍성, 황금빛 톤 |
| Catch Fail | 실패 | 깊이 낮은 단음, 짧음 |
| Spawn | 오브젝트 등장 | 부드러운 등장 |
| Combo | 콤보 갱신 | 단계별 다른 톤 (5/10/20) |

### Volume Hierarchy (볼륨 위계)
- 일반 SFX: 0 dB (기준)
- 강조 SFX (LEGENDARY): +3 dB
- UI SFX: -3 dB (배경)
- 음성: -2 dB (시간 사용)

### Dynamics (다이내믹스)
- BGM Duck: LEGENDARY 캐치 시 -6 dB for 800ms
- BGM Fadeout: 결과 화면 진입 시 1초

## Voice (음성)

게임에 음성 있음 ? Yes / No

Yes 인 경우:
- 톤: 따뜻한, 친근한
- 언어: 한국어 (1차), 영어 (2차)
- 스타일: 친구처럼 (격식 X)
- 자막: 항상 사용 가능 (접근성)

No 인 경우:
- "음성 없음" 명시
- 대신 텍스트 기반 캐릭터 표현

## Anti-Mood (피하는 무드)
- ❌ 격렬한 록 (게임 톤과 충돌)
- ❌ 슬픈 단조 (게임은 코지 톤)
- ❌ 무거운 영화적 (캐주얼 분위기와 충돌)
- ❌ 광고적 (Disney 스타일 등 과장된 happiness)

## Asset Specs (자산 명세)
- BGM: WAV 또는 OGG, 44.1kHz, 16-bit
- SFX: WAV, 44.1kHz, 16-bit, 모노 또는 스테레오
- 명명: snake_case (예: bgm_main_menu.ogg, sfx_catch_legendary.wav)
- 길이: BGM 60~120s 루프, SFX < 2초

## Mixing (믹싱)
- 마스터: -3 LUFS (게임 표준)
- BGM: -18 LUFS (배경)
- SFX: -12 LUFS (전경)
- 음성: -6 LUFS (가장 명확)
```

---

## 활용

### 단계 1 (컨셉)
- 비주얼·오디오 정체성 1줄 (3~5개 무드 키워드)
- 참조 작품 식별 (각 1~3개)

### 단계 6 (통합 명세)
- E. 비주얼·오디오 톤 섹션에 바이블 핵심 (1~2 페이지) 첨부
- 풀 바이블은 별 문서 (`design/art/art-bible.md`, `design/audio/sound-bible.md`)

---

## 안티패턴

### 1. 바이블 없이 자산 제작 시작
"일단 만들고 통일은 나중에" → 5종 자산 제작 후 톤 안 맞음 발견 → 재작업.

해결: 컨셉 단계부터 정체성 1줄. 단계 6 에서 바이블 완성. 자산 제작은 그 후.

### 2. 참조 작품 없음
"우리만의 스타일" 강조 → 너무 추상적 → 모든 자산이 다 다름.

해결: 참조 3~5개. 차용 + 차이 명시.

### 3. Anti-Style / Anti-Mood 누락
"하면 좋은 것" 만 적고 "안 하는 것" 누락 → 유혹 상황에서 일관성 깨짐.

해결: Anti 섹션 의무. 3개 이상.

### 4. 색팔레트 무한
"필요한 색은 다 사용" → 결과적으로 통일감 없음.

해결: 5~7 주 색 + 5~7 보조. 그 외 사용 시 ADR 통한 명시적 결정.

### 5. 사운드 무드 단일
모든 BGM 이 같은 무드 → 게임 상태 변화 못 느낌.

해결: 게임 상태별 무드 매핑 (메뉴·일반·정점·결과 등).

---

## 검증 체크리스트

### Art Bible
- [ ] Visual Identity 1줄
- [ ] Style Keywords 5~10개
- [ ] Reference Games / Works 3~5개 (차용 + 차이)
- [ ] Color Palette (주 5~7 + 보조 5~7, 16진수)
- [ ] Lighting 명세
- [ ] Character / Environment / UI 각 가이드
- [ ] Animation Principles
- [ ] Anti-Style 3개 이상
- [ ] Asset Specs (캔버스·색·형식·명명)

### Sound Bible
- [ ] Audio Identity 1줄
- [ ] Mood Keywords 5~10개
- [ ] Reference Tracks 3~5개
- [ ] BGM Mood Mapping (게임 상태별)
- [ ] BGM Layered 구조 (해당 시)
- [ ] SFX Categories + 톤
- [ ] Volume Hierarchy
- [ ] Dynamics (Duck, Fadeout)
- [ ] Voice 사용 여부
- [ ] Anti-Mood 3개 이상
- [ ] Mixing 표준 (LUFS)
