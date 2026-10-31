#!/usr/bin/env python3
"""Generate Markdown coverage metrics for lexical datasets."""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any, Iterable, Sequence

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DATASET_PATHS = (
    ROOT / "tools" / "data_generator" / "output",
    ROOT / "tools" / "data_generator" / "fixtures",
)
DEFAULT_OUTPUT_PATH = ROOT / "docs" / "dataset" / "LEXICON_COVERAGE.md"
_DIRECTION_SUFFIX = re.compile(r"\.(?:forward|reverse|[a-z]{2,3}_to_[a-z]{2,3})$", re.I)


def discover_dataset_files(paths: Iterable[Path | str]) -> list[Path]:
    found: dict[str, Path] = {}
    for raw in paths:
        path = Path(raw)
        candidates = [path] if path.is_file() else path.rglob("*.json") if path.is_dir() else []
        for candidate in candidates:
            if candidate.is_file() and candidate.suffix.lower() == ".json":
                found[str(candidate.resolve())] = candidate
    return [found[key] for key in sorted(found)]


def _entries(path: Path) -> list[dict[str, Any]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"{path}: dataset root must be an object")
    entries = payload.get("entries", [])
    if not isinstance(entries, list):
        raise ValueError(f"{path}: entries must be an array")
    return [item for item in entries if isinstance(item, dict)]


def _pair(entry: dict[str, Any]) -> str:
    identity = entry.get("pair_identity")
    if not isinstance(identity, dict):
        return "unknown"
    pair_id = identity.get("id")
    if isinstance(pair_id, str) and pair_id.strip():
        return pair_id.strip().lower()
    source, target = identity.get("source_language"), identity.get("target_language")
    if isinstance(source, str) and isinstance(target, str) and source.strip() and target.strip():
        return f"{source.strip().lower()}->{target.strip().lower()}"
    return "unknown"


def _concept(entry: dict[str, Any]) -> str:
    concept = entry.get("concept_id")
    if isinstance(concept, str) and concept.strip():
        return concept.strip()
    key = entry.get("canonical_key")
    if isinstance(key, str) and key.strip():
        return _DIRECTION_SUFFIX.sub("", key.strip())
    return json.dumps(entry, ensure_ascii=False, sort_keys=True)


def _record_key(entry: dict[str, Any], pair_id: str) -> str:
    identity = entry.get("pair_identity")
    if isinstance(identity, dict):
        record_id = identity.get("record_id")
        if isinstance(record_id, str) and record_id.strip():
            return f"{pair_id}|{record_id.strip()}"
    key = entry.get("canonical_key")
    if isinstance(key, str) and key.strip():
        return f"{pair_id}|{key.strip()}"
    return f"{pair_id}|{_concept(entry)}|{json.dumps(entry, ensure_ascii=False, sort_keys=True)}"


def _pos(entry: dict[str, Any]) -> str:
    value = entry.get("partOfSpeech", entry.get("part_of_speech", "other"))
    return value.strip().lower() if isinstance(value, str) and value.strip() else "other"


def _has_audio(entry: dict[str, Any]) -> bool:
    marker = entry.get("audioMarker", entry.get("audio_marker"))
    return isinstance(marker, dict) and all(
        isinstance(marker.get(side), str) and marker[side].strip() for side in ("source", "target")
    )


def collect_metrics(dataset_paths: Sequence[Path | str] | None = None) -> dict[str, Any]:
    files = discover_dataset_files(dataset_paths or DEFAULT_DATASET_PATHS)
    pairs: dict[str, dict[str, Any]] = {}
    seen: set[str] = set()
    for path in files:
        for entry in _entries(path):
            pair_id = _pair(entry)
            record_key = _record_key(entry, pair_id)
            if record_key in seen:
                continue
            seen.add(record_key)
            bucket = pairs.setdefault(
                pair_id,
                {"concepts": set(), "records": 0, "pos": Counter(), "audio": 0},
            )
            bucket["concepts"].add(_concept(entry))
            bucket["records"] += 1
            bucket["pos"][_pos(entry)] += 1
            bucket["audio"] += int(_has_audio(entry))

    result: dict[str, dict[str, Any]] = {}
    for pair_id in sorted(pairs):
        bucket = pairs[pair_id]
        records = bucket["records"]
        result[pair_id] = {
            "total_concepts": len(bucket["concepts"]),
            "directional_records": records,
            "pos_distribution": dict(sorted(bucket["pos"].items())),
            "audio_marked_records": bucket["audio"],
            "audio_marker_coverage_pct": round(bucket["audio"] / records * 100, 1) if records else 0.0,
        }
    return {"dataset_files": len(files), "pairs": result}


def _bar(percent: float, width: int = 10) -> str:
    filled = round(max(0.0, min(100.0, percent)) / 100 * width)
    return "█" * filled + "░" * (width - filled)


def render_dashboard(metrics: dict[str, Any]) -> str:
    lines = [
        "# Lexicon Coverage Dashboard",
        "",
        "Automatically generated from lexical datasets in `tools/data_generator/output/` and fixtures.",
        "",
        f"Dataset files scanned: **{metrics.get('dataset_files', 0)}**",
        "",
    ]
    pairs = metrics.get("pairs", {})
    if not pairs:
        return "\n".join(lines + ["No dataset records found.", ""])
    lines += [
        "| Language Pair | Total Concepts | Directional Records | POS Distribution | Audio Coverage | Progress |",
        "|---|---:|---:|---|---:|---|",
    ]
    for pair_id in sorted(pairs):
        pair = pairs[pair_id]
        pos = ", ".join(f"{name}: {count}" for name, count in pair["pos_distribution"].items()) or "—"
        coverage = float(pair["audio_marker_coverage_pct"])
        lines.append(
            f"| {pair_id.replace('->', '→')} | {pair['total_concepts']} | {pair['directional_records']} | "
            f"{pos} | {coverage:.1f}% | `{_bar(coverage)}` |"
        )
    return "\n".join(lines + [""])


def generate_dashboard(
    *, dataset_paths: Sequence[Path | str] | None = None, output_path: Path | str = DEFAULT_OUTPUT_PATH
) -> dict[str, Any]:
    metrics = collect_metrics(dataset_paths)
    output = Path(output_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_dashboard(metrics), encoding="utf-8")
    return metrics


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset-dir", action="append", dest="dataset_paths", type=Path)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH)
    args = parser.parse_args(argv)
    generate_dashboard(dataset_paths=args.dataset_paths, output_path=args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
