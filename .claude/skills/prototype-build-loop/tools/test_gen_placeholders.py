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
