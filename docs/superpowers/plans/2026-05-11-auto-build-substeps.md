# Auto-Build Substeps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Round 0 를 분수 substep 4개 (0.1~0.4) 의 자동 연쇄로 확장하여, 엔진 선택 후 산출물 4종 기반 1차 프로토 (AC1 검증 가능 + 픽셀 placeholder) 까지 자동 빌드.

**Architecture:** `auto-build-orchestrator.md` 가 substep 4개를 순차 실행 (각 substep = 1 commit + 1 ITERATION_LOG 항목). PIL 헬퍼 스크립트가 art-bible 슬롯 맵 → placeholder PNG + sibling prompt.md 생성. 기존 Round 1+ (roundN-patch.md) 는 변경 없음.

**Tech Stack:** Python 3 (pyyaml, Pillow), Bash (smoke test), Markdown (프롬프트·SKILL), pytest (Python 단위 테스트).

**Spec:** `docs/superpowers/specs/2026-05-11-auto-build-substeps-design.md`

---

## File Structure

### 신규 파일
- `prompts/prototype-build-loop/auto-build-orchestrator.md` — 4 substep 자동 연쇄 + 실패 옵션 제시
- `prompts/prototype-build-loop/round0.1-scaffold.md` — scaffold (기존 round0-scaffold.md 핵심 이전)
- `prompts/prototype-build-loop/round0.2-core-loop.md` — §B 코어 루프 1 cycle
- `prompts/prototype-build-loop/round0.3-systems-ac1.md` — AC1 필수 §C + 테스트 인프라
- `prompts/prototype-build-loop/round0.4-art-placeholders.md` — art-bible 슬롯 → placeholder + prompt.md
- `.claude/skills/prototype-build-loop/tools/gen_placeholders.py` — PIL 헬퍼
- `.claude/skills/prototype-build-loop/tools/test_gen_placeholders.py` — 단위 테스트

### 수정 파일
- `pipeline.yaml` — v0.4 → v0.5, round_variants 확장 (v0.1~v0.4 + 기존 v0/vN 호환)
- `.claude/skills/prototype-build-loop/SKILL.md` — §2 모드 / §3 트리거 / §6 절차 / §10 마이그레이션
- `.claude/skills/prototype-build-loop/engines/godot.md` — 에셋 로드 컨벤션 1줄
- `.claude/skills/prototype-build-loop/engines/unity.md` — 동일
- `prompts/06b-art-bible.md` — 슬롯 맵 테이블에 `category` / `palette_ref` 컬럼 강제
- `prompts/prototype-build-loop/round0-scaffold.md` — deprecated 헤더 표기
- `tests/build_loop_smoke.sh` — 신규 파일 체크 + v0.5 검증

---

## Task 1: pipeline.yaml v0.5 schema migration

**Files:**
- Modify: `pipeline.yaml` (version bump, round_variants 확장, changelog append, naming_rule)

- [ ] **Step 1: pipeline.yaml.version bump**

Edit `pipeline.yaml`:
```yaml
pipeline:
  version: "0.5"   # 0.4 → 0.5
```

- [ ] **Step 2: changelog 항목 append (changelog 목록 최상단)**

Edit `pipeline.yaml`, `changelog:` 목록 맨 위에:
```yaml
changelog:
  - version: "0.5"
    date: "2026-05-11"
    changes:
      - "auto-build substeps: Round 0 → Round 0.1~0.4 분수 substep 자동 연쇄"
      - "state_schema.resume_fields.build_state 에 current_substep, auto_build_status 추가 (옵션)"
      - "단계 6 iteration_log.schema.round_variants 에 v0.1~v0.4 신규 (기존 v0 은 backward compat 로 유지, 신규 프로젝트는 v0.1~v0.4 사용)"
      - "naming_rule 갱신: Round 0 의 substep 은 0.1~0.4 분수 허용. Round N≥1 은 정수 단조."
  - version: "0.4"
    ...
```

- [ ] **Step 3: round_variants 에 v0.1~v0.4 추가**

Edit `pipeline.yaml` 의 `steps[id=6].iteration_log.schema.round_variants` 항목 (현재 `v0`, `vN` 만 있음). `v0` 다음에 v0.1~v0.4 4개 추가, `v0` 은 deprecated 표기로 유지:

```yaml
round_variants:
  v0:                          # deprecated v0.5: 기존 프로젝트 backward compat. 신규는 v0.1~v0.4.
    description: "build/{engine}/ 스캐폴드 직후 1회 (deprecated, 신규는 v0.1)"
    fields:
      - "**엔진**: 선택된 엔진 + 버전"
      - "**세팅**: tech-spec §F·§G·§I 어느 만큼 스캐폴드되었나"
      - "**시드 컨텐츠**: 코어 루프 1 사이클 placeholder 동작 범위"
  v0.1:                        # v0.5~ : auto-build substep 1
    description: "엔진 init + tech-spec §F·§G 모듈/시그널/Resource 스캐폴드"
    fields:
      - "**엔진**: 선택된 엔진 + 버전"
      - "**모듈**: tech-spec §F 의 N 항목 스텁"
      - "**시그널·Resource**: §G 의 N 시그널, N Resource"
  v0.2:                        # v0.5~ : auto-build substep 2
    description: "SSOT §B 코어 메카닉 1 cycle 최소 구현"
    fields:
      - "**구현 §B**: 핵심 메카닉명"
      - "**1 cycle 흐름**: 입력 → 동작 → 결과"
      - "**하드코딩**: 추후 §C 시스템으로 빠질 값 목록"
  v0.3:                        # v0.5~ : auto-build substep 3 (stop 라인)
    description: "AC1 필수 §C 시스템 + 테스트 인프라 (실행 가능, pass/fail 무관)"
    fields:
      - "**구현 §C**: AC1 필수 시스템 N개"
      - "**AC1 테스트**: 테스트 함수명"
      - "**실행 결과**: 원문 1~3줄, pass/fail 명시"
      - "**다음 라운드 권고**: fail 인 경우 가설 진단 1줄"
  v0.4:                        # v0.5~ : auto-build substep 4
    description: "art-bible 슬롯 → PIL placeholder PNG + sibling prompt.md"
    fields:
      - "**슬롯 수**: N"
      - "**카테고리 분포**: creature N, character N, object N, ui N, effect N"
      - "**placeholder 규칙**: §6.2 표 따름"
      - "**프롬프트 파일 경로**: build/{engine}/art/{slot_id}.prompt.md"
  vN:
    ...  (기존 그대로)
```

- [ ] **Step 4: naming_rule 갱신**

같은 schema 블록의 `naming_rule` 라인:
```yaml
naming_rule: "Round 0 의 auto-build substep 은 0.1~0.4 분수 허용. Round N ≥ 1 은 정수 단조 증가. v3.1 같은 patch bump 는 같은 사이클 내 보강에만."
```

- [ ] **Step 5: state_schema.resume_fields.build_state 에 신규 필드 추가**

먼저 현재 `pipeline.yaml` 의 `state_schema.resume_fields.build_state` 블록을 Read 로 확인 (현재 약 96-100 라인 근방, `current_round` / `last_snapshot` / `last_round_at` / `system_keywords` 가 dict 또는 string 설명형으로 있음).

블록 형식이 **dict** 이면 — `current_round` 키 다음에 신규 2개 키 삽입:
```yaml
build_state:
  current_round: ...           # 기존
  current_substep: string?     # 신규 v0.5: "0.1"|"0.2"|"0.3"|"0.4"|null. 자동 빌드 진행 중일 때만 채워짐, 완료/실패 시 null
  auto_build_status: enum?     # 신규 v0.5: in_progress | completed | failed_at_<substep> | null. "completed" 는 프로젝트 lifetime 보존.
  last_snapshot: ...           # 기존
  last_round_at: ...           # 기존
  system_keywords: ...         # 기존
```

블록 형식이 **string 설명형** (예: `build_state: "current_round, last_snapshot, ..."`) 이면 — 문자열에 신규 2개 필드 추가하고 별도 주석 또는 sub-block 으로 의미 명시.

기존 필드 4개 (`current_round` / `last_snapshot` / `last_round_at` / `system_keywords`) 는 반드시 보존, 절대 삭제·재정렬 ✕.

- [ ] **Step 6: 검증 — YAML 파싱 + version 검사**

Run:
```bash
python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); assert d['pipeline']['version']=='0.5'; print('OK')"
python3 -c "import yaml; d=yaml.safe_load(open('pipeline.yaml')); rv=next(s for s in d['steps'] if s['id']==6)['iteration_log']['schema']['round_variants']; assert all(k in rv for k in ['v0','v0.1','v0.2','v0.3','v0.4','vN']); print('OK')"
```
Expected: `OK` 두 번.

- [ ] **Step 7: Commit**

```bash
git add pipeline.yaml
git commit -m "feat(pipeline): bump v0.4 → v0.5, add auto-build substep round_variants

- round_variants 에 v0.1~v0.4 추가 (기존 v0 은 deprecated 표기로 backward compat)
- state_schema.build_state 에 current_substep / auto_build_status 신규 (옵션)
- naming_rule 갱신 (Round 0 substep 0.1~0.4 분수 허용)"
```

---

## Task 2: gen_placeholders.py 헬퍼 + 단위 테스트 (TDD)

**Files:**
- Create: `.claude/skills/prototype-build-loop/tools/gen_placeholders.py`
- Create: `.claude/skills/prototype-build-loop/tools/test_gen_placeholders.py`
- Create: `.claude/skills/prototype-build-loop/tools/__init__.py` (필요 시)

- [ ] **Step 1: 환경 준비 — Pillow 설치 가능 여부 확인**

```bash
python3 -c "from PIL import Image, ImageDraw; print('OK')"
```
없으면: `pip install Pillow` (또는 가상환경 사용 — 현재 프로젝트의 Python 환경에 맞춰).

- [ ] **Step 2: 실패 테스트 작성 — 슬롯 맵 파싱**

Create `.claude/skills/prototype-build-loop/tools/test_gen_placeholders.py`:
```python
"""gen_placeholders.py 단위 테스트."""
import os
import tempfile
from pathlib import Path
import pytest

from gen_placeholders import parse_slot_map, generate_placeholder, generate_prompt_md, run

SAMPLE_ART_BIBLE = """\
# Art Bible

## §Z 에셋 슬롯 맵 (확장)

| slot_id | category | 해상도 | palette_ref | 포맷 | 통합 위치 | 설명 |
|---------|----------|-------|-------------|------|---------|------|
| fish_01 | creature | 32x32 | §X.2 (ocean) | PNG | scenes/fish.tscn | 작은 청록 물고기 |
| player  | character | 48x48 | §X.1 (warm) | PNG | scenes/player.tscn | 주인공 |
| hud_bg  | ui | 320x64 | §X.3 (neutral) | PNG | scenes/hud.tscn | 상단 HUD 배경 |
"""

def test_parse_slot_map_basic():
    slots = parse_slot_map(SAMPLE_ART_BIBLE)
    assert len(slots) == 3
    ids = [s["slot_id"] for s in slots]
    assert ids == ["fish_01", "player", "hud_bg"]

def test_parse_slot_map_fields():
    slots = parse_slot_map(SAMPLE_ART_BIBLE)
    fish = slots[0]
    assert fish["category"] == "creature"
    assert fish["size"] == "32x32"
    assert "ocean" in fish["palette_ref"]
    assert "물고기" in fish["description"]

def test_parse_slot_map_no_table_raises():
    with pytest.raises(ValueError, match="슬롯 맵"):
        parse_slot_map("# Art Bible\n\nNo table here.")
```

- [ ] **Step 3: 테스트 실행 — 실패 확인**

```bash
cd .claude/skills/prototype-build-loop/tools
python3 -m pytest test_gen_placeholders.py -v
```
Expected: ImportError / ModuleNotFoundError (gen_placeholders.py 부재).

- [ ] **Step 4: gen_placeholders.py — parse_slot_map 구현**

Create `.claude/skills/prototype-build-loop/tools/gen_placeholders.py`:
```python
"""art-bible 슬롯 맵 → placeholder PNG + sibling prompt.md.

사용:
  python3 gen_placeholders.py --art-bible <path> --out-dir <path>

각 슬롯마다 카테고리별 도형·색 규칙으로 PNG, sibling .prompt.md (frontmatter + 프롬프트
+ art-bible 인용 + 교체 가이드) 를 출력 디렉토리에 생성.
"""
from __future__ import annotations
import argparse
import hashlib
import re
import sys
from datetime import date
from pathlib import Path


CATEGORY_RULES = {
    "creature":  {"shape": "circle",    "palette_key": "primary"},
    "character": {"shape": "rect_tall", "palette_key": "accent"},
    "object":    {"shape": "rect",      "palette_key": "secondary"},
    "ui":        {"shape": "rect_round","palette_key": "neutral_gray"},
    "effect":    {"shape": "diamond",   "palette_key": "highlight"},
}

FALLBACK_COLOR = (128, 128, 128, 255)  # 회색 RGBA


def parse_slot_map(art_bible_md: str) -> list[dict]:
    """art-bible 본문에서 §Z 슬롯 맵 테이블 파싱.

    Returns: [{slot_id, category, size, palette_ref, description}, ...]
    Raises: ValueError — 슬롯 맵 테이블 미발견 시.
    """
    # 헤더 패턴: "## §Z" 또는 "## §Z 에셋 슬롯 맵" 변형 허용
    header_re = re.compile(r"^##\s+§Z[^\n]*$", re.MULTILINE)
    m = header_re.search(art_bible_md)
    if not m:
        raise ValueError("art-bible 에서 §Z 슬롯 맵 헤더를 찾지 못함")
    body = art_bible_md[m.end():]
    # 다음 ## 헤더 까지만
    next_h2 = re.search(r"^##\s+", body, re.MULTILINE)
    if next_h2:
        body = body[:next_h2.start()]
    # 테이블 행 추출 (헤더·구분선 제외)
    rows = []
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if not cells or len(cells) < 5:
            continue
        # 헤더 행 / 구분선 행 스킵
        if cells[0].lower() in ("slot_id", "---", "----"):
            continue
        if all(set(c) <= set("-: ") for c in cells):
            continue
        rows.append(cells)
    # 컬럼 매핑: slot_id | category | size(해상도) | palette_ref | 포맷 | 통합 위치 | 설명
    slots = []
    for cells in rows:
        # 최소 7 컬럼 가정, 부족 시 빈 문자열 채움
        cells = cells + [""] * (7 - len(cells))
        slots.append({
            "slot_id": cells[0],
            "category": cells[1],
            "size": cells[2],
            "palette_ref": cells[3],
            "format": cells[4],
            "integration": cells[5],
            "description": cells[6],
        })
    return slots
```

- [ ] **Step 5: 테스트 실행 — parse_slot_map 통과 확인**

```bash
python3 -m pytest test_gen_placeholders.py -v -k parse_slot_map
```
Expected: 3 tests PASS (basic, fields, no_table_raises).

- [ ] **Step 6: 실패 테스트 추가 — generate_placeholder**

Append to `test_gen_placeholders.py`:
```python
def test_generate_placeholder_creates_png(tmp_path):
    slot = {"slot_id": "fish_01", "category": "creature", "size": "32x32",
            "palette_ref": "", "description": "test"}
    out = generate_placeholder(slot, tmp_path)
    assert out.exists()
    assert out.suffix == ".png"
    from PIL import Image
    img = Image.open(out)
    assert img.size == (32, 32)
    assert img.mode == "RGBA"

def test_generate_placeholder_unknown_category_uses_fallback(tmp_path):
    slot = {"slot_id": "weird_01", "category": "unknown_cat", "size": "16x16",
            "palette_ref": "", "description": ""}
    out = generate_placeholder(slot, tmp_path)
    assert out.exists()
```

- [ ] **Step 7: 테스트 실행 — 실패 확인**

```bash
python3 -m pytest test_gen_placeholders.py -v -k generate_placeholder
```
Expected: AttributeError / NameError (generate_placeholder 부재).

- [ ] **Step 8: generate_placeholder 구현**

Append to `gen_placeholders.py`:
```python
def _hash_color(seed: str) -> tuple[int, int, int, int]:
    """팔레트 ref 가 해석 안 될 때 fallback — 슬롯 id 해시 기반 일관 색상."""
    h = hashlib.md5(seed.encode()).digest()
    return (h[0], h[1], h[2], 255)


def _parse_size(size_str: str) -> tuple[int, int]:
    """'32x32' → (32, 32). 파싱 실패 시 (64, 64)."""
    m = re.match(r"(\d+)\s*x\s*(\d+)", size_str)
    if not m:
        return (64, 64)
    return (int(m.group(1)), int(m.group(2)))


def generate_placeholder(slot: dict, out_dir: Path) -> Path:
    """단일 슬롯 → PNG. out_dir/{slot_id}.png 반환."""
    from PIL import Image, ImageDraw, ImageFont

    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    w, h = _parse_size(slot["size"])
    color = _hash_color(slot["slot_id"])

    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    rule = CATEGORY_RULES.get(slot["category"], CATEGORY_RULES["object"])
    shape = rule["shape"]
    pad = max(1, min(w, h) // 8)

    if shape == "circle":
        draw.ellipse([pad, pad, w - pad, h - pad], fill=color)
    elif shape == "rect_tall":
        draw.rectangle([w // 4, pad, 3 * w // 4, h - pad], fill=color)
    elif shape == "rect":
        draw.rectangle([pad, pad, w - pad, h - pad], fill=color)
    elif shape == "rect_round":
        draw.rounded_rectangle([pad, pad, w - pad, h - pad],
                               radius=min(w, h) // 6, fill=color)
    elif shape == "diamond":
        cx, cy = w // 2, h // 2
        draw.polygon([(cx, pad), (w - pad, cy), (cx, h - pad), (pad, cy)],
                     fill=color)
    else:
        draw.rectangle([pad, pad, w - pad, h - pad], fill=FALLBACK_COLOR)

    # 라벨 (슬롯이 충분히 클 때만)
    if w >= 32 and h >= 16:
        try:
            font = ImageFont.load_default()
            label = slot["slot_id"][:10]
            draw.text((2, h - 12), label, fill=(0, 0, 0, 255), font=font)
        except Exception:
            pass

    out_path = out_dir / f"{slot['slot_id']}.png"
    img.save(out_path, "PNG")
    return out_path
```

- [ ] **Step 9: 테스트 실행 — generate_placeholder 통과**

```bash
python3 -m pytest test_gen_placeholders.py -v -k generate_placeholder
```
Expected: 2 tests PASS.

- [ ] **Step 10: 실패 테스트 — generate_prompt_md**

Append to `test_gen_placeholders.py`:
```python
def test_generate_prompt_md(tmp_path):
    slot = {"slot_id": "fish_01", "category": "creature", "size": "32x32",
            "palette_ref": "§X.2 (ocean)", "description": "작은 청록 물고기"}
    out = generate_prompt_md(slot, tmp_path)
    assert out.exists()
    assert out.name == "fish_01.prompt.md"
    text = out.read_text()
    assert "slot_id: fish_01" in text
    assert "category: creature" in text
    assert "size: 32x32" in text
    assert "ocean" in text
    assert "교체 가이드" in text
    assert "fish_01.png" in text
```

- [ ] **Step 11: 실행 — 실패 확인**

```bash
python3 -m pytest test_gen_placeholders.py -v -k generate_prompt_md
```
Expected: NameError.

- [ ] **Step 12: generate_prompt_md 구현**

Append to `gen_placeholders.py`:
```python
PROMPT_TEMPLATE = """\
---
slot_id: {slot_id}
category: {category}
size: {size}
palette_ref: {palette_ref}
placeholder_generated_at: {today}
---

# 이미지 생성 프롬프트
{prompt_body}

# 컨텍스트 (art-bible 인용)
- §Z 슬롯 row: {description}
- palette_ref: {palette_ref}

# 교체 가이드
- 파일명: `{slot_id}.png` 동일하게 유지
- 사이즈: {size} (변경 시 코드에서 sprite size 조정 필요)
- 배경: 투명 PNG
- 동일 경로에 덮어쓰기. 이 prompt.md 파일은 그대로 유지 (history 역할)
"""


def _build_prompt_body(slot: dict) -> str:
    """슬롯 설명을 픽셀아트 프롬프트로 변환 (단순 템플릿)."""
    size = slot["size"]
    desc = slot["description"] or slot["slot_id"]
    category = slot["category"]
    style_hint = {
        "creature": "픽셀아트, 옆모습, 투명 배경, retro 게임 스타일",
        "character": "픽셀아트, 정면 또는 옆모습, 투명 배경, retro 게임 스타일",
        "object": "픽셀아트, 단일 오브젝트, 투명 배경",
        "ui": "픽셀아트 UI 엘리먼트, 깔끔한 라인",
        "effect": "픽셀아트 이펙트, 단순 도형, 투명 배경",
    }.get(category, "픽셀아트, 투명 배경")
    return f'"{size} {style_hint}. {desc}."'


def generate_prompt_md(slot: dict, out_dir: Path) -> Path:
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    body = PROMPT_TEMPLATE.format(
        slot_id=slot["slot_id"],
        category=slot["category"],
        size=slot["size"],
        palette_ref=slot.get("palette_ref", ""),
        today=date.today().isoformat(),
        prompt_body=_build_prompt_body(slot),
        description=slot.get("description", ""),
    )
    out_path = out_dir / f"{slot['slot_id']}.prompt.md"
    out_path.write_text(body, encoding="utf-8")
    return out_path
```

- [ ] **Step 13: 실행 — 모든 테스트 통과**

```bash
python3 -m pytest test_gen_placeholders.py -v
```
Expected: 6 tests PASS.

- [ ] **Step 14: 실패 테스트 — run() 통합 함수**

Append to `test_gen_placeholders.py`:
```python
def test_run_creates_all_slots(tmp_path):
    ab = tmp_path / "06-art-bible.md"
    ab.write_text(SAMPLE_ART_BIBLE)
    out = tmp_path / "art"
    summary = run(art_bible_path=ab, out_dir=out)
    assert summary["count"] == 3
    for sid in ("fish_01", "player", "hud_bg"):
        assert (out / f"{sid}.png").exists()
        assert (out / f"{sid}.prompt.md").exists()
    assert summary["categories"]["creature"] == 1
    assert summary["categories"]["character"] == 1
    assert summary["categories"]["ui"] == 1
```

- [ ] **Step 15: 실행 — 실패 확인 + 구현**

```bash
python3 -m pytest test_gen_placeholders.py -v -k test_run
```
Expected: NameError.

Append to `gen_placeholders.py`:
```python
def run(art_bible_path: Path, out_dir: Path) -> dict:
    """엔드 투 엔드: art-bible 파싱 → 슬롯별 PNG + prompt.md 생성. 요약 반환."""
    art_bible_path = Path(art_bible_path)
    out_dir = Path(out_dir)
    text = art_bible_path.read_text(encoding="utf-8")
    slots = parse_slot_map(text)
    counts = {}
    for slot in slots:
        generate_placeholder(slot, out_dir)
        generate_prompt_md(slot, out_dir)
        counts[slot["category"]] = counts.get(slot["category"], 0) + 1
    return {"count": len(slots), "categories": counts, "out_dir": str(out_dir)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--art-bible", required=True, type=Path)
    ap.add_argument("--out-dir", required=True, type=Path)
    args = ap.parse_args()
    summary = run(args.art_bible, args.out_dir)
    print(f"OK: {summary['count']} slots → {summary['out_dir']}")
    for cat, n in summary["categories"].items():
        print(f"  {cat}: {n}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 16: 전체 테스트 + CLI smoke**

```bash
python3 -m pytest test_gen_placeholders.py -v
```
Expected: 7 tests PASS.

CLI smoke (임시 art-bible 으로):
```bash
mkdir -p /tmp/ph_test
cat > /tmp/ph_test/ab.md <<'EOF'
## §Z 에셋 슬롯 맵 (확장)
| slot_id | category | 해상도 | palette_ref | 포맷 | 통합 위치 | 설명 |
|---------|----------|-------|-------------|------|---------|------|
| test_a | creature | 32x32 | x | PNG | y | 테스트 |
EOF
python3 gen_placeholders.py --art-bible /tmp/ph_test/ab.md --out-dir /tmp/ph_test/out
ls /tmp/ph_test/out/
```
Expected: `test_a.png  test_a.prompt.md`.

- [ ] **Step 17: Commit**

```bash
git add .claude/skills/prototype-build-loop/tools/gen_placeholders.py \
        .claude/skills/prototype-build-loop/tools/test_gen_placeholders.py
git commit -m "feat(build-loop): gen_placeholders.py — art-bible 슬롯 → PNG + prompt.md

- 카테고리 5종 도형·색 규칙 (creature/character/object/ui/effect)
- 슬롯 id 해시 fallback 색상
- sibling prompt.md (frontmatter + 프롬프트 + 교체 가이드)
- pytest 7 케이스"
```

---

## Task 3: 06b-art-bible.md prompt — 슬롯 맵 컬럼 확장

**Files:**
- Modify: `prompts/06b-art-bible.md`

- [ ] **Step 1: 현재 슬롯 맵 섹션 확인**

```bash
grep -n "슬롯\|category\|palette" /Users/ad03159868/concept-pipeline/prompts/06b-art-bible.md | head -20
```

- [ ] **Step 2: 슬롯 맵 테이블을 7-컬럼 신규 형식으로 교체**

기존 컬럼 (`슬롯 ID | 출처 | 해상도 | 포맷 | 통합 위치`) 을 다음 신규 7-컬럼 형식으로 교체 (spec §6.1, Task 2 parser 와 정렬):

```
| slot_id | category | 해상도 | palette_ref | 포맷 | 통합 위치 | 설명 |
```

**컬럼 변경 사항**:
- **추가**: `category` (필수 enum: `creature` / `character` / `object` / `ui` / `effect` — 자동 placeholder 도형·색 규칙 결정), `palette_ref` (필수: art-bible 의 §색상·팔레트 섹션 참조, 예 "§X.2 (ocean)")
- **제거**: `출처` 컬럼. 출처 정보는 슬롯 `설명` 컬럼 또는 (자동 생성 후) `art/{slot_id}.prompt.md` 의 컨텍스트 섹션으로 이전.
- **유지**: `해상도` / `포맷` / `통합 위치` / `설명` — 기존 의미 그대로.

- 컬럼 설명 1줄씩 추가 (06b-art-bible.md 안의 슬롯 맵 정의 문단에):
  - `category`: 필수 enum 5종. 자동 placeholder 생성 시 도형·색 매핑용.
  - `palette_ref`: 필수. 같은 art-bible 의 §팔레트 섹션 참조.

- [ ] **Step 3: 예시 행 1~2개 갱신 (있으면)**

기존 예시 테이블이 있으면 새 컬럼 채워 갱신.

- [ ] **Step 4: 검증 — grep 으로 신규 컬럼 명시 존재**

```bash
grep -q "category" /Users/ad03159868/concept-pipeline/prompts/06b-art-bible.md && echo OK
grep -q "palette_ref" /Users/ad03159868/concept-pipeline/prompts/06b-art-bible.md && echo OK
```
Expected: `OK OK`.

- [ ] **Step 5: Commit**

```bash
git add prompts/06b-art-bible.md
git commit -m "feat(art-bible): 슬롯 맵에 category / palette_ref 컬럼 강제

auto-build Round 0.4 의 placeholder 생성 입력으로 사용."
```

---

## Task 4: Round 0.1 scaffold prompt

**Files:**
- Create: `prompts/prototype-build-loop/round0.1-scaffold.md`

- [ ] **Step 1: 기존 round0-scaffold.md 의 절차 1~6 (전제·어댑터 로드·스캐폴드 생성·git init·메타 갱신) 을 0.1 범위로 재작성**

Create `prompts/prototype-build-loop/round0.1-scaffold.md`:
```markdown
# Round 0.1 — Scaffold (auto-build substep)

본 substep 은 `auto-build-orchestrator.md` 의 1번째 단계로 자동 호출된다.

## 입력
- 단계 7 통과 (`state.yaml.completed_steps` 에 id=7)
- `06-tech-spec.md` (§F 모듈, §G 시그널·Resource)
- `engines/{선택 엔진}.md` (어댑터)
- 사용자 선택: 엔진 (`godot` / `unity`)

## 출력
- `workspace/<slug>/build/{engine}/` 디렉토리 + scaffold (모듈·시그널·Resource·디렉토리 트리)
- `workspace/<slug>/build/engine.yaml`
- `workspace/<slug>/ITERATION_LOG.md` 에 v0.1 항목
- `workspace/<slug>/state.yaml.build_state.current_substep = "0.1"` (진행 중) → `null` (substep 0.4 완료 후)

## 절차

1. **전제 검증**
   - 단계 7 게이트 통과 OR 4종 산출물 존재
   - 누락 시 거부 + 안내

2. **어댑터 로드·검증**
   - `engines/{engine}.md` frontmatter 파싱
   - 7 필수 H2 헤더 검증 (smoke test 와 동일 패턴)
   - `required_tools` 의 명령이 실제 PATH 에 있는지 사용자에게 확인

3. **스캐폴드 계획 표시**
   - 생성될 디렉토리·파일 트리 미리보기 (한 화면 이내)
   - **자동 모드에선 사용자 확인 ✕** (orchestrator 가 이미 1회 받았으므로) — 단, 어댑터의 *프로젝트 init* 가 destructive (기존 디렉토리 덮어쓰기) 면 1회 확인

4. **스캐폴드 생성**
   - 어댑터의 *프로젝트 init 절차* 1~6 순차 실행
   - tech-spec §F 모듈 → 어댑터 *모듈 매핑* 규칙으로 빈 파일·시그니처
   - tech-spec §G 시그널 → 어댑터 *시그널 매핑* 으로 정의 파일
   - tech-spec §G Resource → 어댑터 *Resource 매핑* 으로 클래스
   - 디렉토리 트리 생성 (`scenes/`, `scripts/`, `resources/`, `data/`, `tests/`, `art/`)

5. **성공 기준 검증**
   - 어댑터의 `init_command` 실행 → exit 0 확인
   - 실패 시 orchestrator 에 failed_at="0.1" 반환

6. **git init + commit**
   - `cd build/{engine}/ && git init && git add . && git commit -m "Round 0.1: scaffold (engine={engine})"`

7. **메타 갱신**
   - `engine.yaml` 작성 (engine, version, project_path, initialized_at, adapter_file, adapter_checksum)
   - `state.yaml`:
     - `artifacts.engine = {engine}`
     - `artifacts.build_initialized = true`
     - `build_state.current_substep = "0.1"`
     - `build_state.auto_build_status = "in_progress"`
     - `build_state.system_keywords` (SSOT §C·§B 추출, 캐시)

8. **ITERATION_LOG append**
   ```
   ## v0.1 — Scaffold (YYYY-MM-DD)
   **엔진**: {engine} {version}
   **모듈**: tech-spec §F 의 N 항목 스텁
   **시그널·Resource**: §G 의 N 시그널, N Resource
   ```

9. **orchestrator 에 성공 반환** → 다음 substep (0.2) 진행
```

- [ ] **Step 2: 헤더·섹션 grep 확인**

```bash
grep -c "^## " /Users/ad03159868/concept-pipeline/prompts/prototype-build-loop/round0.1-scaffold.md
```
Expected: 2 (`## 입력`, `## 출력`, `## 절차` — 정확히 3, grep 명령 카운트 ≥ 3).

- [ ] **Step 3: Commit**

```bash
git add prompts/prototype-build-loop/round0.1-scaffold.md
git commit -m "feat(build-loop): Round 0.1 scaffold prompt — auto-build substep 1"
```

---

## Task 5: Round 0.2 core loop prompt

**Files:**
- Create: `prompts/prototype-build-loop/round0.2-core-loop.md`

- [ ] **Step 1: 본문 작성**

Create `prompts/prototype-build-loop/round0.2-core-loop.md`:
```markdown
# Round 0.2 — 코어 루프 (auto-build substep)

`auto-build-orchestrator.md` 의 2번째 단계. Round 0.1 (scaffold) 완료 직후 자동 호출.

## 입력
- `06-integrated-spec.md` §B 코어 메카닉
- `06-tech-spec.md` §F (코어 모듈) + §G (시그널)
- `engines/{engine}.md` 의 *코어 루프 매핑* 규칙
- 0.1 완료된 `build/{engine}/` 트리

## 출력
- §B 의 *입력 → 동작 → 결과 → 다음 사이클* 1 cycle 이 끊김 없이 굴러가는 최소 구현 (placeholder 데이터·hardcoded 값 OK)
- commit + ITERATION_LOG v0.2

## 절차

1. **§B 코어 메카닉 추출**
   - SSOT §B 본문 파싱 → 핵심 메카닉 1개 + 1 cycle 의 입력·동작·결과 식별
   - 어댑터 *코어 루프 매핑* 패턴 따름 (Godot: `_process` / `_input` / signal 흐름, Unity: Update / Event)

2. **scaffold 의 코어 모듈 파일에 최소 구현**
   - tech-spec §F 코어 모듈 (0.1 에서 빈 스텁으로 생성됨) → §B 흐름 채움
   - hardcoded 값 OK, 수치는 SSOT §B 명시 값 우선 (없으면 합리적 기본)
   - 신호 흐름: 입력 시그널 → 처리 모듈 → 결과 시그널 → 다음 사이클 트리거

3. **수동 트리거 또는 자동 진행 확인**
   - 코어 루프가 한 번 실행되어 입력 → 동작 → 결과 흐름이 통과되는지 확인 (예: 헤드리스 모드 1초 실행 후 stdout 에 1 cycle 로그)

4. **성공 기준**
   - 어댑터의 *코어 루프 smoke* 명령 (있으면) 실행 → 1 cycle 로그 출력
   - 없으면 정적 검사: 입력→동작→결과 3 지점 모두 코드 경로 존재 확인
   - 실패 시 orchestrator 에 failed_at="0.2" 반환

5. **commit**
   ```
   Round 0.2: core loop (§B {메카닉명})

   {진단 1줄}

   변경:
   - {파일 1}: {요약}
   - {파일 2}: {요약}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.2 — 코어 루프 (YYYY-MM-DD)
   **구현 §B**: {핵심 메카닉명}
   **1 cycle 흐름**: 입력({...}) → 동작({...}) → 결과({...})
   **하드코딩**: {추후 §C 로 빠질 값 목록}
   ```

7. **state.yaml 갱신**
   - `build_state.current_substep = "0.2"`

8. **orchestrator 에 성공 반환** → 0.3 진행
```

- [ ] **Step 2: Commit**

```bash
git add prompts/prototype-build-loop/round0.2-core-loop.md
git commit -m "feat(build-loop): Round 0.2 core loop prompt — auto-build substep 2"
```

---

## Task 6: Round 0.3 systems + AC1 prompt

**Files:**
- Create: `prompts/prototype-build-loop/round0.3-systems-ac1.md`

- [ ] **Step 1: 본문 작성**

Create `prompts/prototype-build-loop/round0.3-systems-ac1.md`:
```markdown
# Round 0.3 — §C 시스템 + AC1 (auto-build substep, stop 라인)

`auto-build-orchestrator.md` 의 3번째 단계. 자동 빌드의 **stop 라인** — AC §I 가설 1번이 *측정 가능한 인프라까지* 닿으면 substep 완료.

## 입력
- `06-integrated-spec.md` §I AC 1번 (가설·측정 방법)
- `06-integrated-spec.md` §C (시스템·메타) — AC1 측정에 필수인 1~2개만 선별
- `06-tech-spec.md` §I (AC ↔ §C 매핑, 명시되어 있으면)
- `engines/{engine}.md` *테스트 매트릭스 형식*
- 0.2 완료된 `build/{engine}/` 트리

## 출력
- AC1 측정에 필수인 §C 시스템 1~2개 구현
- AC1 테스트 함수 + 실행 인프라 (어댑터 *테스트 매트릭스 형식*)
- AC1 테스트 실행 → 결과 출력 (pass/fail 무관)
- commit + ITERATION_LOG v0.3

## 절차

1. **AC1 필수 §C 선별**
   - tech-spec §I 에 AC↔§C 매핑이 명시되어 있으면 그대로 사용
   - 없으면 LLM 추론: AC1 가설을 측정하는 데 필요한 최소 §C 시스템 1~2개
   - **선별 결과를 ITERATION_LOG v0.3 에 명시** (사용자가 추후 검토 가능)

2. **§C 시스템 구현**
   - tech-spec §F 의 해당 시스템 모듈 (0.1 에서 스텁) 에 최소 동작 구현
   - placeholder 데이터·hardcoded 값 OK

3. **AC1 테스트 함수 작성**
   - 어댑터의 *테스트 매트릭스 형식* 따름 (Godot: GUT 또는 native test, Unity: EditMode test)
   - AC1 의 측정 지점에 계측 (assert·로그)
   - 실행 인프라: `godot --headless --test ac1` 등

4. **테스트 실행 (결과 무관)**
   - 명령 실행 → stdout / 로그 파일에 결과 기록
   - pass/fail 무관, **실행되어 결과가 출력** 되면 OK
   - 실행 자체가 실패 (테스트 인프라 부재·컴파일 오류) → orchestrator 에 failed_at="0.3" 반환

5. **commit**
   ```
   Round 0.3: §C systems for AC1 + test scaffold

   {진단 1줄: 어떤 §C 가 선별되었나, AC1 테스트 결과 요약}

   변경:
   - {시스템 모듈 N개}
   - {테스트 함수 1개}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.3 — §C 시스템 + AC1 (YYYY-MM-DD)
   **구현 §C**: {AC1 필수 시스템 N개}
   **AC1 테스트**: {테스트 함수명}
   **실행 결과**: {원문 1~3줄, pass/fail 명시}
   **다음 라운드 권고**: {fail 인 경우 가설 진단 1줄, pass 면 "정상"}
   ```

7. **state.yaml 갱신**
   - `build_state.current_substep = "0.3"`

8. **orchestrator 에 성공 반환** → 0.4 진행
```

- [ ] **Step 2: Commit**

```bash
git add prompts/prototype-build-loop/round0.3-systems-ac1.md
git commit -m "feat(build-loop): Round 0.3 systems+AC1 prompt — auto-build stop 라인"
```

---

## Task 7: Round 0.4 art placeholder prompt

**Files:**
- Create: `prompts/prototype-build-loop/round0.4-art-placeholders.md`

- [ ] **Step 1: 본문 작성**

Create `prompts/prototype-build-loop/round0.4-art-placeholders.md`:
```markdown
# Round 0.4 — Art placeholder + 프롬프트 파일 (auto-build substep)

`auto-build-orchestrator.md` 의 4번째 (마지막) 단계.

## 입력
- `06-art-bible.md` (§Z 슬롯 맵 — slot_id / category / size / palette_ref / 설명)
- `engines/{engine}.md` 의 *에셋 로드 컨벤션*
- `.claude/skills/prototype-build-loop/tools/gen_placeholders.py`
- 0.3 완료된 `build/{engine}/` 트리

## 출력
- `build/{engine}/art/{slot_id}.png` (N개)
- `build/{engine}/art/{slot_id}.prompt.md` (N개)
- 코드에서 placeholder 경로 참조 연결 (어댑터 컨벤션)
- commit + ITERATION_LOG v0.4
- (조건부) art-bible 에 신규 컬럼 보강 + `06-changelog.md` 1줄

## 절차

1. **art-bible §Z 슬롯 맵 파싱**
   - `tools/gen_placeholders.py` 의 `parse_slot_map()` 호출
   - `category`·`palette_ref` 컬럼 부재 시 (구 형식 art-bible) → LLM 추론으로 보강, art-bible 의 슬롯 행에 두 컬럼 append, `06-changelog.md` 에 1줄:
     ```
     - YYYY-MM-DD v0.4 — art-bible 슬롯 맵 category/palette_ref 보강 (auto-build 호환성)
     ```

2. **placeholder 생성**
   - `python3 .claude/skills/prototype-build-loop/tools/gen_placeholders.py --art-bible workspace/<slug>/06-art-bible.md --out-dir workspace/<slug>/build/{engine}/art/`
   - 결과 요약 확인 (count, 카테고리 분포)

3. **코드 연결 — 어댑터 *에셋 로드 컨벤션* 적용**
   - 어댑터에 명시된 패턴 (예: Godot 의 `preload("res://art/{slot_id}.png")`) 으로 적어도 1개 슬롯이 scene/resource 에서 로드되도록 wiring
   - 0.1~0.3 에서 생성된 모듈·시그널·Resource 중 art 슬롯을 참조하는 곳에 경로 박음
   - 모든 슬롯 wiring 은 무리 — 코어 루프에 등장하는 슬롯 1~2개만 자동, 나머지는 미사용 자산으로 art/ 에 대기

4. **smoke 검증**
   - 어댑터의 init_command 재실행 → 빌드 OK 확인 (placeholder 경로 오류 ✕)
   - 실패 시 orchestrator 에 failed_at="0.4" 반환

5. **commit**
   ```
   Round 0.4: art placeholders + prompt files (N slots)

   {요약: 슬롯 N개, 카테고리 분포, wired 슬롯 N개}

   변경:
   - art/ (PNG N + prompt.md N)
   - {wiring 된 scene/resource 파일}
   ```

6. **ITERATION_LOG append**
   ```
   ## v0.4 — Art placeholder (YYYY-MM-DD)
   **슬롯 수**: N
   **카테고리 분포**: creature N, character N, object N, ui N, effect N
   **placeholder 규칙**: gen_placeholders.py 카테고리 매핑 (creature=circle/primary, character=rect_tall/accent, object=rect/secondary, ui=rect_round/neutral, effect=diamond/highlight)
   **프롬프트 파일 경로**: build/{engine}/art/{slot_id}.prompt.md
   **wired 슬롯**: {wiring 된 슬롯 id 목록}
   ```

7. **state.yaml 갱신 (auto-build 완료)**
   - `build_state.current_substep = null`
   - `build_state.auto_build_status = "completed"`
   - `build_state.current_round = 0` (substep 모두 완료, Round 0 으로 마감)

8. **orchestrator 에 최종 성공 반환** → 사용자에게 자동 빌드 완료 보고
```

- [ ] **Step 2: Commit**

```bash
git add prompts/prototype-build-loop/round0.4-art-placeholders.md
git commit -m "feat(build-loop): Round 0.4 art placeholders prompt — auto-build substep 4"
```

---

## Task 8: auto-build-orchestrator prompt

**Files:**
- Create: `prompts/prototype-build-loop/auto-build-orchestrator.md`

- [ ] **Step 1: 본문 작성**

Create `prompts/prototype-build-loop/auto-build-orchestrator.md`:
```markdown
# Auto-Build Orchestrator

`prototype-build-loop` 스킬의 Round 0 진입점. 사용자가 "프로토타입 시작" 트리거 시 호출되며, substep 0.1~0.4 를 자동 연쇄 실행한다.

## 입력
- 단계 7 통과 (`state.yaml.completed_steps` 에 id=7)
- 4종 산출물 (`06-integrated-spec.md` / `06-art-bible.md` / `06-tech-spec.md` / `06-changelog.md`)
- `state.yaml.build_state.current_round` 가 null/부재 (첫 진입)
- `build/` 비어있음

## 출력
- Round 0.1~0.4 모두 통과 → `build_state.auto_build_status = "completed"`, `current_round = 0`
- 중간 실패 → `build_state.auto_build_status = "failed_at_<substep>"`, 사용자에게 3 옵션 제시

## 절차

1. **진입 조건 검증**
   - 위 입력 모두 만족하는지 확인
   - 불충족 시:
     - 단계 7 미통과 → 거부 + 누락 산출물 안내
     - 이미 build/ 존재 + Round 1+ 진행 중 → "자동 빌드 ✕ (기존 프로젝트). 기존 roundN-patch 진입" 안내
     - 기존 build/ 비어있지 않지만 Round 0 도 아님 (이상 상태) → 사용자 확인 후 처리

2. **엔진 선택 질문 (1회)**
   - "Godot 4 / Unity 6 중 어느 엔진으로?"
   - 사용자 응답 → `engines/{engine}.md` 어댑터 존재 확인

3. **자동 빌드 시작 보고**
   - "Round 0.1~0.4 자동 빌드 시작. 약 N분 예상. 중간 실패 시에만 멈춤."
   - 진행 표시 (substep 마다 1줄)

4. **substep 순차 실행**

   각 substep 은 다음 패턴:
   ```
   for sub in [0.1, 0.2, 0.3, 0.4]:
     prompts/prototype-build-loop/round{sub}-*.md 본문 따라 진행
     성공 → commit + ITERATION_LOG append + state.yaml.current_substep 갱신, 다음 substep
     실패 → break, 실패 옵션 분기 (§5)
   ```

5. **실패 시 옵션 제시**

   ```
   Round 0.{X} 실패: {원인 1~3줄}

   상태:
   - 마지막 성공: 0.{Y} (commit hash: {hash})
   - 변경 (uncommitted): {파일 목록}
   - state.yaml: auto_build_status="failed_at_0.{X}"

   옵션:
   1. 재개 — 진단 1회 반영 후 0.{X} 재시도 (재시도 1회만)
   2. 수동 전환 — 자동 abort. Round 1+ 사용자 피드백 라운드 진입.
        (남은 substep 은 별도 슬래시 /cp-art-rebuild 등으로 회고 적용 가능)
   3. 롤백 — git reset --hard {지정 substep commit}. **commit 폐기 destructive — 명시 확인 필수**.

   선택?
   ```

   - 옵션 1: substep 본문에 실패 원인 진단 1줄 추가 + 재시도. 두 번째 실패 시 옵션 1 자동 비활성, 사용자에게 "옵션 2 또는 3 만" 안내.
   - 옵션 2: uncommitted 보존, `auto_build_status="aborted_at_0.{X}"`, 안내 후 종료. 사용자 다음 발화부터 Round 1+ 자동 감지.
   - 옵션 3: 사용자 확인 ("rollback 0.{Y} commit 까지 정말? Y/N") → Y 면 `git reset --hard`, N 면 취소.

6. **최종 보고 (성공 경로)**

   ```
   자동 빌드 완료 (Round 0.1~0.4).

   요약:
   - 엔진: {engine} {version}
   - 모듈: §F N 항목
   - 코어 루프: §B {메카닉} 1 cycle 동작
   - §C 시스템: {N개 — AC1 필수}
   - AC1 테스트: {결과 원문}
   - art placeholders: N 슬롯 ({카테고리 분포})

   다음:
   - build/{engine}/ 에서 직접 빌드·플레이 → 피드백 발화 시 자동 Round 1 진입
   - art 교체: art/{slot_id}.prompt.md 참고하여 PNG 만 덮어쓰기
   ```

7. **state.yaml 최종 상태**
   - `current_round = 0`, `current_substep = null`, `auto_build_status = "completed"`

## 에러 케이스 (orchestrator 레벨)

| 케이스 | 처리 |
|--------|------|
| 엔진 선택 후 어댑터 부재 | 에러 + `adapter-template.md` 복제 가이드 |
| substep 본문 prompt 파일 누락 | 에러 + 누락 파일 명시 (구현 누락) |
| 한 substep 안에서 두 번째 실패 | 옵션 1 자동 비활성, 옵션 2/3 만 제시 |
| 사용자 응답 없이 무한 대기 | 자동 진행 ✕ — 사용자 응답이 옵션 선택의 게이트 |
```

- [ ] **Step 2: Commit**

```bash
git add prompts/prototype-build-loop/auto-build-orchestrator.md
git commit -m "feat(build-loop): auto-build-orchestrator — Round 0.1~0.4 자동 연쇄 제어"
```

---

## Task 9: SKILL.md 업데이트

**Files:**
- Modify: `.claude/skills/prototype-build-loop/SKILL.md`

- [ ] **Step 1: §2 모드 갱신**

`SKILL.md` 의 `## 2. 모드` 섹션 안의 `- **Round 0 (1회)**: ...` 줄을 다음으로 교체:
```markdown
- **Round 0 (1회, 자동 빌드 substep 4개)**: 엔진 선택 후 `auto-build-orchestrator.md` 가 Round 0.1 (scaffold) → 0.2 (코어 루프 §B) → 0.3 (§C 시스템 + AC1) → 0.4 (art placeholder) 를 자동 연쇄. substep 마다 commit + ITERATION_LOG 항목. 중간 실패 시에만 사용자 개입.
```

- [ ] **Step 2: §3 트리거 표 갱신**

`SKILL.md` 의 `## 3. 트리거` 섹션 표의 Round 0 행을 다음으로 교체:
```markdown
| Round 0 (auto-build) | 명시: "프로토타입 시작" / "프로토타입 빌드" / `/prototype-start` — orchestrator 가 0.1~0.4 자동 연쇄 |
```

- [ ] **Step 3: §6 Round 0 절차 갱신**

`SKILL.md` 의 `## 6. Round 0 절차` 섹션 본문 전체를 다음으로 교체:
```markdown
## 6. Round 0 절차 (auto-build)

`prompts/prototype-build-loop/auto-build-orchestrator.md` 가 진입점. orchestrator 가 substep 0.1~0.4 를 순차 호출:

- **0.1**: `prompts/prototype-build-loop/round0.1-scaffold.md` — 엔진 init + §F·§G 스캐폴드
- **0.2**: `prompts/prototype-build-loop/round0.2-core-loop.md` — §B 코어 메카닉 1 cycle
- **0.3**: `prompts/prototype-build-loop/round0.3-systems-ac1.md` — AC1 필수 §C + 테스트 인프라 (stop 라인)
- **0.4**: `prompts/prototype-build-loop/round0.4-art-placeholders.md` — `tools/gen_placeholders.py` 호출

substep 마다 commit + ITERATION_LOG v0.{1..4} 항목. 실패 시 마지막 성공 substep 유지, 사용자에게 3 옵션 (재개·수동 전환·롤백) 제시. 자세한 절차는 `auto-build-orchestrator.md` 참조.

기존 `prompts/prototype-build-loop/round0-scaffold.md` 는 deprecated (backward compat 용 보존).
```

- [ ] **Step 4: §10 에러 케이스 표 갱신**

`SKILL.md` 의 `## 10. 에러 케이스` 표에 다음 행 추가 (기존 행 모두 유지):
```markdown
| auto-build substep 중 실패 | orchestrator 의 3 옵션 제시 (재개 1회 / 수동 전환 / 롤백). 자가 디버그 무한 루프 가드 (substep 당 자동 재시도 1회) |
| auto-build 진입 조건 불충족 (기존 build/ 존재) | "자동 빌드 ✕. 기존 roundN-patch 진입" 안내. |
| state.yaml v0.4 → v0.5 마이그레이션 | (1) `.archive/state-pre-migration-{timestamp}.yaml` 백업 → (2) `build_state.current_substep=null`, `build_state.auto_build_status=null` 기본값 추가 → (3) `notes` 에 `"schema migration 0.4 → 0.5 (auto-build substeps added)"` 1줄 → (4) `pipeline_version: "0.5"` 갱신. |
```

기존 v0.2.1→v0.3 마이그레이션 행은 그대로 유지.

- [ ] **Step 5: §11 호출 외부 자산 목록 갱신**

`SKILL.md` 의 `## 11. 호출되는 외부 자산` 섹션 목록에 신규 prompts 추가:
```markdown
- `engines/godot.md`, `engines/unity.md` — 엔진별 어댑터 데이터
- `prompts/prototype-build-loop/auto-build-orchestrator.md` — Round 0 진입점
- `prompts/prototype-build-loop/round0.1-scaffold.md` — substep 1
- `prompts/prototype-build-loop/round0.2-core-loop.md` — substep 2
- `prompts/prototype-build-loop/round0.3-systems-ac1.md` — substep 3
- `prompts/prototype-build-loop/round0.4-art-placeholders.md` — substep 4
- `prompts/prototype-build-loop/round0-scaffold.md` — deprecated (v0.4 이전 backward compat)
- `prompts/prototype-build-loop/roundN-patch.md` — Round N 본문
- `.claude/skills/prototype-build-loop/tools/gen_placeholders.py` — art placeholder 헬퍼
- `pipeline.yaml.steps[5].iteration_log.schema.round_variants` — 로그 스키마
```

- [ ] **Step 6: §12 spec 참조 갱신**

`SKILL.md` 의 `## 12. spec 참조` 섹션에 신규 spec 1줄 추가:
```markdown
## 12. spec 참조

설계 근거:
- `docs/superpowers/specs/2026-05-06-prototype-build-loop-design.md` — 본 스킬 도입 spec
- `docs/superpowers/specs/2026-05-11-auto-build-substeps-design.md` — Round 0 → 0.1~0.4 substep 확장 (v0.5)
```

- [ ] **Step 7: Commit**

```bash
git add .claude/skills/prototype-build-loop/SKILL.md
git commit -m "feat(build-loop): SKILL.md — auto-build substep 모드/트리거/절차 반영"
```

---

## Task 10: 엔진 어댑터 — 에셋 로드 컨벤션 1줄

**Files:**
- Modify: `.claude/skills/prototype-build-loop/engines/godot.md`
- Modify: `.claude/skills/prototype-build-loop/engines/unity.md`

- [ ] **Step 1: godot.md 에 *에셋 로드 컨벤션* 섹션 추가 (또는 기존 섹션에 1줄)**

현재 7 필수 H2 헤더 안에 "에셋 로드" 섹션이 있으면 1줄, 없으면 새 H3 추가. 추가 내용:

```markdown
### 에셋 로드 컨벤션
- Placeholder PNG 경로: `art/{slot_id}.png` (`build/{engine}/` 기준 상대)
- Godot 로드 패턴: `preload("res://art/{slot_id}.png")` 또는 `load(...)`
- 교체 시: 동일 파일명·동일 경로 → 코드 수정 ✕. sprite size 변경 시만 scene 의 sprite 크기 조정.
```

- [ ] **Step 2: unity.md 동일 추가**

```markdown
### 에셋 로드 컨벤션
- Placeholder PNG 경로: `Assets/art/{slot_id}.png`
- Unity 로드 패턴: `Resources.Load<Sprite>("art/{slot_id}")` 또는 직접 Sprite 참조
- 교체 시: 동일 파일명·동일 경로 → 코드 수정 ✕. sprite size 변경 시만 SpriteRenderer 의 size 조정.
```

- [ ] **Step 3: 7 H2 헤더 검증 — smoke test 재실행 (Task 12 와 연동)**

```bash
bash tests/build_loop_smoke.sh 2>&1 | grep -E "godot.md|unity.md" | head -10
```
Expected: 필수 H2 헤더 7개 검증 ✓ (신규 H3 는 무관).

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/prototype-build-loop/engines/godot.md \
        .claude/skills/prototype-build-loop/engines/unity.md
git commit -m "feat(engines): 에셋 로드 컨벤션 — art/{slot_id}.png 패턴 명시"
```

---

## Task 11: 기존 round0-scaffold.md deprecated 표기

**Files:**
- Modify: `prompts/prototype-build-loop/round0-scaffold.md`

- [ ] **Step 1: 파일 최상단에 deprecated 헤더 추가**

`prompts/prototype-build-loop/round0-scaffold.md` 의 첫 줄 (`# Round 0 — 초기 환경 스캐폴드 프롬프트`) 바로 위에 다음 추가:

```markdown
> **DEPRECATED (v0.5+)** — 본 파일은 v0.5 이전 backward compat 용. 신규 프로젝트는 `auto-build-orchestrator.md` → `round0.1-scaffold.md` ~ `round0.4-art-placeholders.md` 사용.
>
> Spec: `docs/superpowers/specs/2026-05-11-auto-build-substeps-design.md`

```

- [ ] **Step 2: Commit**

```bash
git add prompts/prototype-build-loop/round0-scaffold.md
git commit -m "docs(build-loop): mark round0-scaffold.md as deprecated (v0.5+)"
```

---

## Task 12: build_loop_smoke.sh — 신규 파일 + v0.5 검증

**Files:**
- Modify: `tests/build_loop_smoke.sh`

- [ ] **Step 1: 신규 파일 존재 체크 추가 (기존 항목 보존)**

`tests/build_loop_smoke.sh` 의 `[3] 신규 인프라 파일` 섹션은 `for f in ... ; do` 형식의 파일 목록. **기존 항목 (현재 약 9개) 은 그대로 두고**, 닫는 `;` 직전에 신규 7개를 append:

```bash
# 기존 목록 끝에 다음 7개 추가 (기존 항목 삭제·교체 ✕)
  "prompts/prototype-build-loop/auto-build-orchestrator.md" \
  "prompts/prototype-build-loop/round0.1-scaffold.md" \
  "prompts/prototype-build-loop/round0.2-core-loop.md" \
  "prompts/prototype-build-loop/round0.3-systems-ac1.md" \
  "prompts/prototype-build-loop/round0.4-art-placeholders.md" \
  ".claude/skills/prototype-build-loop/tools/gen_placeholders.py" \
  ".claude/skills/prototype-build-loop/tools/test_gen_placeholders.py" \
```

먼저 현재 파일을 Read 하여 기존 목록의 정확한 위치 (`for f in \` 시작점부터 `; do` 까지) 를 파악한 뒤 Edit 으로 마지막 항목 다음 줄에 위 7개 삽입.

- [ ] **Step 2: round_variants v0.1~v0.4 검증 추가**

`[1] pipeline.yaml v0.3+ schema` 섹션의 ROUND_VARIANTS 체크 다음에 추가:

```bash
ROUND_SUBSTEPS=$(python3 -c "
import yaml
d = yaml.safe_load(open('pipeline.yaml'))
step6 = next(s for s in d['steps'] if s['id'] == 6)
rv = step6.get('iteration_log', {}).get('schema', {}).get('round_variants', {})
expected = ['v0.1', 'v0.2', 'v0.3', 'v0.4']
missing = [k for k in expected if k not in rv]
print('OK' if not missing else 'MISS:' + ','.join(missing))
")
[[ "$ROUND_SUBSTEPS" == "OK" ]] && ok "round_variants v0.1~v0.4 모두 존재" || fail "$ROUND_SUBSTEPS"
```

- [ ] **Step 3: 신규 06b-art-bible.md 컬럼 검증 추가**

새 섹션 추가 (예: `[7] 06b-art-bible.md 슬롯 맵 컬럼 확장`):

```bash
echo ""
echo "[7] 06b-art-bible.md 슬롯 맵 확장 (v0.5)"
grep -q "category" prompts/06b-art-bible.md && ok "category 컬럼 명시" || fail "category 컬럼 미명시"
grep -q "palette_ref" prompts/06b-art-bible.md && ok "palette_ref 컬럼 명시" || fail "palette_ref 컬럼 미명시"
```

- [ ] **Step 4: gen_placeholders.py 단위 테스트 실행 추가 (옵션)**

새 섹션:
```bash
echo ""
echo "[8] gen_placeholders.py 단위 테스트"
if python3 -c "import PIL" 2>/dev/null; then
  if python3 -m pytest .claude/skills/prototype-build-loop/tools/test_gen_placeholders.py -q 2>&1 | tail -1 | grep -qE "passed"; then
    ok "gen_placeholders.py 테스트 통과"
  else
    fail "gen_placeholders.py 테스트 실패"
  fi
else
  warn "Pillow 미설치 — gen_placeholders.py 테스트 스킵"
fi
```

- [ ] **Step 5: smoke test 실행 → 전체 통과**

```bash
bash tests/build_loop_smoke.sh
```
Expected: 모든 체크 ✅, 종료 코드 0.

- [ ] **Step 6: Commit**

```bash
git add tests/build_loop_smoke.sh
git commit -m "test(smoke): build_loop_smoke v0.5 — 신규 파일·round_variants·art-bible 컬럼 검증"
```

---

## Task 13: pipeline_smoke.sh — 버전 0.5 호환 확인

**Files:**
- Modify: `tests/pipeline_smoke.sh` (변경 없을 수 있음, 통과만 확인)

- [ ] **Step 1: pipeline_smoke 실행**

```bash
bash tests/pipeline_smoke.sh
```
Expected: 모든 체크 통과. v0.5 가 v0.x 패턴에 매치되어 통과해야 함.

- [ ] **Step 2: 실패 시 패턴 수정**

만약 version 패턴이 0.4 까지만 허용하는 hardcode 가 있으면 수정. 없으면 skip.

- [ ] **Step 3: Commit (변경 있으면)**

```bash
git add tests/pipeline_smoke.sh
git commit -m "test(smoke): pipeline_smoke v0.5 호환"
```

---

## Task 14: 통합 검증 — 두 smoke test 모두 통과

- [ ] **Step 1: 두 smoke 실행**

```bash
bash tests/pipeline_smoke.sh && bash tests/build_loop_smoke.sh
```
Expected: 모두 종료 코드 0, 모든 체크 ✅.

- [ ] **Step 2: gen_placeholders.py 단위 테스트 재확인**

```bash
cd .claude/skills/prototype-build-loop/tools && python3 -m pytest -v
```
Expected: 7 tests PASS.

- [ ] **Step 3: 최종 git status / log 확인**

```bash
git status
git log --oneline | head -15
```
Expected: clean working tree, 12~14 신규 commit (Task 1~12 + 가능한 13).

---

## Optional Task 15: 06c-tech-spec.md AC↔§C 매핑 강제 (deferred)

> **결정 필요**: spec §12 미해결 항목. 본 plan 에 포함할지 별도 plan 으로 분리할지.

기본은 **별도 plan 분리** — 이번 plan 의 핵심은 auto-build substep 인프라. AC↔§C 매핑 정확도 개선은 별도 사이클 (LLM 추론 정확도 측정 후 결정).

만약 포함한다면:
- `prompts/06c-tech-spec.md` 의 §I 섹션에 `ac_systems_mapping:` 필드 강제
- 단계 7 게이트의 `cross_reference_check` 에 매핑 존재 검증 추가
- pipeline_smoke / build_loop_smoke 에 매핑 grep 추가

→ **결론**: 이번 plan 은 Task 14 까지로 완료. Task 15 는 별도 plan.

---

## Execution Order / Dependencies

```
Task 1 (pipeline.yaml v0.5)
  ↓
Task 2 (gen_placeholders.py) ─── 독립, Task 1 후 언제든
  ↓
Task 3 (06b-art-bible.md) ────── 독립, Task 1 후 언제든
  ↓
Task 4~7 (round 0.1~0.4 prompts) ── 서로 독립, 순서 무관
  ↓
Task 8 (orchestrator) ──────── Task 4~7 후 (참조함)
  ↓
Task 9 (SKILL.md) ─────────── Task 8 후 (참조함)
  ↓
Task 10 (engine adapters) ──── 독립
  ↓
Task 11 (deprecated 표기) ──── Task 9 후
  ↓
Task 12 (build_loop_smoke) ── 모든 신규 파일 후
  ↓
Task 13 (pipeline_smoke 확인)
  ↓
Task 14 (통합 검증)
```

병렬 실행 가능 그룹 (subagent-driven 시):
- Group A (Task 1 후): Task 2, Task 3, Task 4, Task 5, Task 6, Task 7, Task 10 동시
- Group B: Task 8 (Task 4~7 후)
- Group C: Task 9, Task 11 (Task 8 후)
- Group D: Task 12, Task 13 (모든 신규 파일 후)
- Group E: Task 14 (마지막)

---

## Verification — 전체 완료 확인

- [ ] `pipeline.yaml.version == "0.5"`
- [ ] `pipeline.yaml.steps[5].iteration_log.schema.round_variants` 에 v0.1~v0.4 모두 존재
- [ ] 신규 prompt 5개 존재 (orchestrator + 0.1~0.4)
- [ ] `tools/gen_placeholders.py` + 테스트 통과 (7 케이스)
- [ ] `06b-art-bible.md` 에 category·palette_ref 컬럼 강제
- [ ] `SKILL.md` 의 §2, §3, §6, §10, §11, §12 갱신
- [ ] `engines/godot.md`, `engines/unity.md` 에 에셋 로드 컨벤션
- [ ] `round0-scaffold.md` deprecated 표기
- [ ] `build_loop_smoke.sh` 통과 + `pipeline_smoke.sh` 통과
- [ ] 모든 변경 커밋됨, working tree clean
