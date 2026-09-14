#!/usr/bin/env python3
import base64
import hashlib
import sys
from pathlib import Path

EXPECTED_SHA256 = "d2fe2508fb5e28c5e4b3ae6cfb16162e86b63239ceaae92928c3587fd3b56be1"


def read_payload(source: Path) -> str:
    prefix = source.name.removesuffix(".png.b64")
    parts = sorted(source.parent.glob(f"{prefix}.part*"))
    if parts:
        payload = "".join(part.read_text(encoding="utf-8") for part in parts)
        print(f"assembled app icon payload from {len(parts)} chunks")
        return "".join(payload.split())
    return "".join(source.read_text(encoding="utf-8").split())


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: materialize_app_icon.py <input.b64> <output.png>")

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    payload = read_payload(source)
    raw = base64.b64decode(payload, validate=True)
    digest = hashlib.sha256(raw).hexdigest()
    if digest != EXPECTED_SHA256:
        raise SystemExit(f"app icon checksum mismatch: {digest}")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(raw)
    if len(raw) < 1024:
        raise SystemExit("app icon output is unexpectedly small")

    print(f"materialized {output} ({len(raw)} bytes, sha256={digest})")


if __name__ == "__main__":
    main()
