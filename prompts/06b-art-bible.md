# 단계 6b — 아트 바이블 (시점 문서, 자동)

## 목적
SSOT(`06-integrated-spec.md`) 의 §E 비주얼·오디오 톤 + §G.1 어종 서사 + §D 화면 구성을
**아티스트·이미지 생성 도구가 즉시 사용 가능한 슬롯·프롬프트 형태**로 전개한다.

## 입력
- `workspace/<slug>/06-integrated-spec.md` (SSOT, 필수)
- `workspace/<slug>/05-detailed-gdd.md` (보조)
- (있으면) `workspace/<slug>/prototype/` 디렉토리 — 현재 placeholder 자산 위치 식별

## 산출물
`workspace/<slug>/06-art-bible.md`

## 작성 원칙
- **인용만, 복제 ✕**: 팔레트·톤 키워드·레퍼런스는 SSOT §E 를 *링크* (예: "→ 06-integrated-spec.md §E.색팔레트"). 본문에 다시 적지 않음.
- **시점 문서 = 슬롯 단위**: 각 에셋 1슬롯 = 1행. 행마다 *프롬프트·해상도·포맷·통합 위치* 4축 박힘.
- **외부 도구 중립**: Midjourney·DALL-E·SDXL·Nano Banana 어디든 먹을 수 있는 EN 프롬프트 (선택지 = 톤 키워드 합성 + 부정 프롬프트).
- **placeholder 호환**: 기존 placeholder 슬롯이 있으면 그 위치에 PNG 드롭만 하면 wiring 자동 — 호출처(`*.gd`/`*.tres`) 라인 명시.

## 필수 섹션 (5개)

### 1. 팔레트·레퍼런스 (인용)
- SSOT §E 색팔레트 5색 → 헤더 표 1개. 본문은 "→ 06-integrated-spec.md §E.색팔레트" 한 줄.
- SSOT §E 톤 키워드 7개·아트 레퍼런스 5종도 동일하게 *인용 1줄*.
- **추가 정보** (시점 문서에서만): 부정 프롬프트 (이 게임에 *없어야 할* 것) — "saturated colors", "anime", "chibi", "happy lighting", "cartoon outline" 등.

### 2. 에셋 슬롯 맵
프로젝트 자산을 **슬롯군** 으로 묶는다. 슬롯군당 표 1개:

| 슬롯 ID | 출처 (SSOT 인용) | 해상도 | 포맷 | 통합 위치 (파일·라인) |
|---|---|---|---|---|
| `fish_lock_silhouette_01` | §G.1 fs_silhouette_01 | 256×256 | PNG α | `species_icon.gd:make_for_species` |
| ... | ... | ... | ... | ... |

**필수 슬롯군**:
- 어종 (잠금/해제 2상태)
- 항해 그리드 칸 종류
- 항구 배 본체 (영구 업그레이드 단계별)
- 씬 배경 (메인 메뉴/항구/항해/낚시/결과)
- UI 칩 (미끼 카테고리·자원·등급 pip)
- EC·정점 모먼트 컷씬 (있는 경우)

### 3. 프롬프트 템플릿
슬롯군 단위 EN 프롬프트. **변수 슬롯** (`{species_lore}`, `{cell_kind}`) 표시.

```
[슬롯군: 어종 잠금 실루엣]
TEMPLATE:
  "Dark fog silhouette of {species_lore_keyword},
   monochrome ink-on-parchment style, hint of bioluminescence,
   centered subject, transparent background, 256x256,
   art style: Inscryption Act 1 + Sunless Sea + The Lighthouse 2019 film mood,
   palette: deep teal #1A2530 + warm gold accent #E8C58A,
   --no saturated colors, anime, chibi, cartoon outline"

VARIANTS (12 species, SSOT §G.1 인용):
  - fs_silhouette_01: species_lore_keyword="deep fog shadow"
  - fs_calm_02:       species_lore_keyword="ancient turtle of crystal"
  - ...
```

### 4. 외부 도구별 사용 가이드
- **Midjourney**: `--ar 1:1 --stylize 200 --no [부정 프롬프트]` 권장 파라미터
- **DALL-E 3**: 자연어 프롬프트 + "transparent background" 명시 (불완전, 후처리 필요)
- **SDXL/ComfyUI**: 권장 negative embedding · 권장 sampler · CFG 5~7
- **Nano Banana / Imagen**: 자연어 프롬프트, 부정 프롬프트는 명시적 단어로

### 5. 통합 워크플로우
1. 외부 도구로 슬롯 생성 → PNG 산출
2. `prototype/art/<slot_group>/<slot_id>.png` 경로에 드롭
3. 호출처(.gd / .tres) 가 자동으로 ImageTexture 로드 — 코드 변경 불필요 (placeholder 호환 슬롯의 경우)
4. 비호환 슬롯 = 슬롯 표 *통합 위치* 컬럼에 명시된 라인 직접 교체

## 작성 절차 (자동, 사용자 응답 ✕)
1. SSOT 읽기 — §E·§G·§D 추출
2. 5 섹션 순차 작성, 각 섹션 *인용 1줄 + 시점 정보* 만
3. 슬롯 맵 자동 생성 — `prototype/` 존재 시 grep 으로 placeholder 호출처 위치 회수
4. 자기 점검:
   - 모든 SSOT §G.1 어종이 슬롯에 등재되었는가?
   - 모든 §D 화면이 배경 슬롯에 등재되었는가?
   - 프롬프트 템플릿이 변수 슬롯을 명시적으로 노출하는가?
   - 부정 프롬프트가 SSOT §E *안티 키워드* 와 정합인가?

## 톤
- 한국어 본문 + 영어 프롬프트
- 슬롯 표·코드블록 우선, 산문 최소
- "이 표만 보고 외부 도구로 생성 가능한가?" 가 통과 기준
