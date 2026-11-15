"""T70-adjacent guard: excluded languages must never ship as pack assets.

he.json (Hebrew, excluded) was found shipped as an empty stub under
assets/packs/ in 2026-11-15; it was removed in PR #1191. These contracts
pin the registry_sync.py guard so the class of violation cannot return
silently (assets/packs is not registry-synced).
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/polyglot/registry_sync.py"
PACKS = ROOT / "assets/packs"
EXCLUDED = {"he", "iw"}


def test_registry_check_exits_zero_on_clean_tree() -> None:
    result = subprocess.run(
        [sys.executable, str(TOOL), "--check"],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_no_excluded_language_pack_asset_exists() -> None:
    for path in PACKS.glob("*.json"):
        assert path.stem not in EXCLUDED, f"excluded pack asset present: {path.name}"
        payload = json.loads(path.read_text(encoding="utf-8"))
        assert payload.get("languageCode") not in EXCLUDED


def _load_registry_sync():
    import importlib.util

    spec = importlib.util.spec_from_file_location("registry_sync", TOOL)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_guard_reports_excluded_stem_and_code(tmp_path: Path, monkeypatch) -> None:
    rs = _load_registry_sync()
    monkeypatch.setattr(rs, "PACK_ASSETS_DIR", tmp_path)
    (tmp_path / "he.json").write_text(
        json.dumps({"languageCode": "he", "version": 1, "vocabulary": []}),
        encoding="utf-8",
    )
    (tmp_path / "iw.json").write_text(
        json.dumps({"languageCode": "de", "version": 1, "vocabulary": []}),
        encoding="utf-8",
    )
    problems = rs._check_pack_assets_are_policy_clean()
    assert any("he.json" in p for p in problems)
    assert any("iw.json" in p for p in problems)


def test_guard_accepts_clean_pack_dir(tmp_path: Path, monkeypatch) -> None:
    rs = _load_registry_sync()
    monkeypatch.setattr(rs, "PACK_ASSETS_DIR", tmp_path)
    (tmp_path / "de.json").write_text(
        json.dumps({"languageCode": "de", "version": 1, "vocabulary": []}),
        encoding="utf-8",
    )
    assert rs._check_pack_assets_are_policy_clean() == []
