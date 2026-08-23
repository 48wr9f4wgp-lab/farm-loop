#!/usr/bin/env python3
import hashlib
import json
import pathlib
import sys
from datetime import datetime, timezone

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
files = []
for path in sorted(p for p in root.rglob("*") if p.is_file()):
    data = path.read_bytes()
    files.append({
        "path": path.relative_to(root).as_posix(),
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
    })
print(json.dumps({
    "game": "Farm Loop",
    "version": "godot-0.3.2-mobile-ci",
    "godot": "4.7.2",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "files": files,
}, ensure_ascii=False, indent=2))
