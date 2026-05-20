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

FALLBACK_COLOR = (128, 128, 128, 255)


def parse_slot_map(art_bible_md: str) -> list[dict]:
    """art-bible 본문에서 §Z 슬롯 맵 테이블 파싱.

    Returns: [{slot_id, category, size, palette_ref, format, integration, description}, ...]
    Raises: ValueError — 슬롯 맵 테이블 미발견 시.
    """
    header_re = re.compile(r"^##\s+(?:§Z|2\.)\s*[^\n]*에셋 슬롯|^##\s+§Z[^\n]*", re.MULTILINE)
    m = header_re.search(art_bible_md)
    if not m:
        # fallback: 첫 번째 slot_id 컬럼 테이블 위치 검색
        m2 = re.search(r"\|\s*slot_id\s*\|", art_bible_md)
        if not m2:
            raise ValueError("art-bible 에서 §Z 슬롯 맵 헤더를 찾지 못함")
        # m 대신 m2 위치에서 시작 (header 전체 본문)
        body = art_bible_md[m2.start():]
    else:
        body = art_bible_md[m.end():]
    next_h2 = re.search(r"^##\s+", body, re.MULTILINE)
    if next_h2:
        body = body[:next_h2.start()]
    rows = []
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if not cells or len(cells) < 5:
            continue
        if cells[0].lower() in ("slot_id", "---", "----"):
            continue
        if all(set(c) <= set("-: ") for c in cells):
            continue
        rows.append(cells)
    slots = []
    for cells in rows:
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


def _hash_color(seed: str) -> tuple[int, int, int, int]:
    h = hashlib.md5(seed.encode()).digest()
    return (h[0], h[1], h[2], 255)


def _parse_size(size_str: str) -> tuple[int, int]:
    m = re.match(r"(\d+)\s*x\s*(\d+)", size_str)
    if not m:
        return (64, 64)
    return (int(m.group(1)), int(m.group(2)))


def generate_placeholder(slot: dict, out_dir: Path) -> Path:
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


def run(art_bible_path: Path, out_dir: Path) -> dict:
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
