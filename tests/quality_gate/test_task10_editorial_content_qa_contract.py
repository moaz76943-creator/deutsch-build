from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PIPELINE = ROOT / "tool" / "editorial_content_review.py"
MANIFEST = ROOT / "tool" / "editorial_review" / "task10_manifest.json"
CORRECTIONS = ROOT / "content" / "german" / "editorial_corrections.jsonl"
COMPILER = ROOT / "tool" / "content_compiler.py"


def test_task10_pipeline_is_deterministic_and_complete():
    result = subprocess.run(
        [sys.executable, str(PIPELINE), "check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        timeout=120,
    )
    assert result.returncode == 0, result.stderr or result.stdout
    assert "TASK 10 EDITORIAL PIPELINE: PASS" in result.stdout
    assert "APPROVED: 690" in result.stdout
    assert "NEEDS_SPECIALIST_REVIEW: 490" in result.stdout
    assert "CORRECTIONS: 68" in result.stdout


def test_task10_manifest_and_batches_cover_all_candidates():
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert manifest["schema_version"] == 2
    assert manifest["queue_count"] == 1180
    assert manifest["canonical_corrections"] == 68
    assert manifest["allowed_statuses"] == [
        "APPROVED",
        "NEEDS_SPECIALIST_REVIEW",
    ]
    assert manifest["status_counts"] == {
        "APPROVED": 690,
        "NEEDS_SPECIALIST_REVIEW": 490,
    }
    rows = []
    for name in manifest["batches"]:
        lines = [
            line
            for line in (MANIFEST.parent / name).read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        assert 1 <= len(lines) <= 200
        rows.extend(json.loads(line) for line in lines)
    assert len(rows) == 1180
    assert {row["status"] for row in rows} == {
        "APPROVED",
        "NEEDS_SPECIALIST_REVIEW",
    }


def test_task10_correction_ledger_is_bounded_and_compiler_owned():
    rows = [
        json.loads(line)
        for line in CORRECTIONS.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    assert len(rows) == 68
    assert all(row["field"] == "sentence" for row in rows)
    assert all(row["rule"] == "REMOVE_DUPLICATED_GERMAN_ARTICLE" for row in rows)
    assert all(
        any(
            token in row["from"].casefold()
            for token in ("der der", "die die", "das das")
        )
        for row in rows
    )
    compiler = COMPILER.read_text(encoding="utf-8")
    assert "EDITORIAL_CORRECTIONS" in compiler
    assert "_apply_editorial_corrections" in compiler
    assert "_fingerprint_sources" in compiler


def test_task10_surfaces_respect_file_ceiling():
    paths = [PIPELINE, MANIFEST, CORRECTIONS, COMPILER]
    paths.extend(MANIFEST.parent.glob("task10_batch_*.jsonl"))
    for path in paths:
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
