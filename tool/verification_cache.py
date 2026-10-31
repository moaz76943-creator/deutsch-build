#!/usr/bin/env python3
"""Dependency-aware, fail-closed verification cache."""
from __future__ import annotations
import hashlib, json
from pathlib import Path
from typing import Iterable

def fingerprint(paths: Iterable[Path], *, config: dict, tool_version: str) -> str:
    h = hashlib.sha256()
    for path in sorted((Path(p) for p in paths), key=lambda p: p.as_posix()):
        h.update(path.as_posix().encode()); h.update(b'\0')
        h.update(path.read_bytes() if path.is_file() else b'<missing>'); h.update(b'\0')
    h.update(json.dumps(config, sort_keys=True, separators=(',', ':')).encode())
    h.update(b'\0'); h.update(tool_version.encode())
    return h.hexdigest()

def load(cache_path: Path) -> dict:
    try:
        value = json.loads(cache_path.read_text(encoding='utf-8'))
        return value if isinstance(value, dict) else {}
    except (OSError, ValueError, json.JSONDecodeError):
        return {}

def is_valid(entry: dict, current_fingerprint: str) -> bool:
    return isinstance(entry, dict) and entry.get('fingerprint') == current_fingerprint and entry.get('result', {}).get('status') == 'PASS'

def store(cache_path: Path, key: str, fingerprint_value: str, result: dict) -> None:
    data = load(cache_path)
    data[key] = {'fingerprint': fingerprint_value, 'result': result}
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    tmp = cache_path.with_suffix(cache_path.suffix + '.tmp')
    tmp.write_text(json.dumps(data, sort_keys=True, indent=2) + '\n', encoding='utf-8')
    tmp.replace(cache_path)
