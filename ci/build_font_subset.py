#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

TEXT_EXTENSIONS = {".gd", ".json", ".tscn", ".godot", ".md", ".txt"}
SKIP_DIRS = {".git", ".godot", "build"}
BASE_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz !?+×¥￥・｜／（）()[]：:→←✓,.%#&@_-"


def collect_chars(root: Path) -> str:
    chars = set(BASE_CHARS)
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        chars.update(ch for ch in text if ord(ch) >= 0x20 and ch not in "\r\n\t")
    return "".join(sorted(chars))


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: build_font_subset.py INPUT_FONT OUTPUT_FONT PROJECT_ROOT", file=sys.stderr)
        return 2

    input_font = Path(sys.argv[1]).resolve()
    output_font = Path(sys.argv[2]).resolve()
    root = Path(sys.argv[3]).resolve()
    if not input_font.is_file():
        print(f"missing input font: {input_font}", file=sys.stderr)
        return 3

    output_font.parent.mkdir(parents=True, exist_ok=True)
    charset_path = output_font.with_suffix(output_font.suffix + ".chars.txt")
    charset = collect_chars(root)
    charset_path.write_text(charset, encoding="utf-8")

    cmd = [
        "pyftsubset",
        str(input_font),
        f"--text-file={charset_path}",
        "--flavor=woff2",
        "--layout-features=*",
        "--glyph-names",
        "--symbol-cmap",
        f"--output-file={output_font}",
    ]
    subprocess.run(cmd, check=True)
    size = output_font.stat().st_size
    print(f"Japanese UI font subset: {len(charset)} chars / {size} bytes")
    if size <= 0 or size > 1_500_000:
        print("font subset size outside expected bounds", file=sys.stderr)
        return 4
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
