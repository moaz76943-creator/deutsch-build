#!/usr/bin/env python3
"""Run lexicon schema, cross-language matrix, and audio coverage checks."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

try:
    from tools.data_generator.matrix_builder import (
        MatrixValidationError,
        load_and_validate,
        text_direction_for_language,
    )
except ModuleNotFoundError:  # pragma: no cover - direct script execution fallback
    from matrix_builder import (  # type: ignore
        MatrixValidationError,
        load_and_validate,
        text_direction_for_language,
    )

HERE = Path(__file__).resolve().parent
PROJECT_ROOT = HERE.parents[1]
DEFAULT_SCHEMA_PATH = HERE / "schema.json"
DEFAULT_CORE_PATH = HERE / "fixtures" / "de_ar_a1_core.json"
DEFAULT_SKELETON_DIR = HERE / "output" / "matrix_skeletons"
DEFAULT_REPORT_PATH = PROJECT_ROOT / "reports" / "data_health_summary.json"


class PipelineValidationError(RuntimeError):
    """Raised after the health report records one or more invalid data files."""

    def __init__(self, message: str, report: Mapping[str, Any] | None = None):
        super().__init__(message)
        self.report = dict(report) if report is not None else None


class PipelineCoverageError(RuntimeError):
    """Raised when complete audio-marker coverage is below the requested floor."""

    def __init__(self, message: str, report: Mapping[str, Any] | None = None):
        super().__init__(message)
        self.report = dict(report) if report is not None else None


def _display_path(path: Path) -> str:
    try:
        return path.resolve().relative_to(PROJECT_ROOT.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def _skeleton_paths(skeleton_dir: Path) -> tuple[Path, ...]:
    if not skeleton_dir.exists():
        return ()
    if not skeleton_dir.is_dir():
        raise PipelineValidationError(f"matrix skeleton path is not a directory: {skeleton_dir}")
    return tuple(sorted(path for path in skeleton_dir.rglob("*.json") if path.is_file()))


def _complete_audio_marker(entry: Mapping[str, Any]) -> bool:
    marker = entry.get("audioMarker")
    if not isinstance(marker, Mapping):
        return False
    return all(isinstance(marker.get(side), str) and marker[side].strip() for side in ("source", "target"))


def _cross_language_metrics(entries: Iterable[Mapping[str, Any]], *, require_concept_id: bool) -> dict[str, int]:
    entries_list = list(entries)
    directed_pairs: set[str] = set()
    concept_ids: set[str] = set()
    concept_by_signature: dict[tuple[str, str, str, str], str] = {}
    record_count = 0

    for index, entry in enumerate(entries_list):
        record_count += 1
        pair = entry.get("pair_identity")
        if not isinstance(pair, Mapping):
            raise MatrixValidationError(f"entry[{index}].pair_identity must be an object")

        source = pair.get("source_language")
        target = pair.get("target_language")
        pair_id = pair.get("id")
        if not all(isinstance(value, str) and value for value in (source, target, pair_id)):
            raise MatrixValidationError(f"entry[{index}].pair_identity is malformed")
        if pair_id != f"{source}->{target}":
            raise MatrixValidationError(
                f"entry[{index}].pair_identity.id expected {source}->{target!s}, got {pair_id!r}"
            )
        if pair.get("source_direction") != text_direction_for_language(source):
            raise MatrixValidationError(f"entry[{index}] has invalid source language direction")
        if pair.get("target_direction") != text_direction_for_language(target):
            raise MatrixValidationError(f"entry[{index}] has invalid target language direction")
        directed_pairs.add(pair_id)

        concept_id = entry.get("concept_id")
        if require_concept_id and not (isinstance(concept_id, str) and concept_id.strip()):
            raise MatrixValidationError(f"entry[{index}].concept_id is required for matrix skeletons")
        if isinstance(concept_id, str) and concept_id.strip():
            concept_ids.add(concept_id)
            signature = (source, target, str(entry.get("source_text", "")), str(entry.get("target_text", "")))
            concept_by_signature[signature] = concept_id

    if require_concept_id:
        for index, entry in enumerate(entries_list):
            pair = entry["pair_identity"]
            signature = (
                pair["target_language"],
                pair["source_language"],
                str(entry.get("target_text", "")),
                str(entry.get("source_text", "")),
            )
            reverse_concept_id = concept_by_signature.get(signature)
            if reverse_concept_id is not None and reverse_concept_id != entry["concept_id"]:
                raise MatrixValidationError(
                    f"entry[{index}].concept_id does not match its reverse record"
                )

    return {
        "records": record_count,
        "directedPairs": len(directed_pairs),
        "conceptIds": len(concept_ids),
    }


def _write_report(report: Mapping[str, Any], report_path: Path) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def _process_candidates(
    candidates: Sequence[tuple[Path, bool]],
    schema_path: Path,
    files: list[dict[str, Any]],
    errors: list[dict[str, str]],
    valid_datasets: list[tuple[Path, Mapping[str, Any], bool]],
) -> None:
    """Process all candidate paths, validate them, and accumulate metrics."""
    for path, is_skeleton in candidates:
        item = {"path": _display_path(path), "kind": "matrix_skeleton" if is_skeleton else "core"}
        try:
            dataset = load_and_validate(path, schema_path=schema_path)
            metrics = _cross_language_metrics(dataset["entries"], require_concept_id=is_skeleton)
            item.update({"valid": True, "entries": metrics["records"]})
            files.append(item)
            valid_datasets.append((path, dataset, is_skeleton))
        except (OSError, ValueError, TypeError, KeyError) as exc:
            item.update({"valid": False, "entries": 0, "error": str(exc)})
            files.append(item)
            errors.append({"path": _display_path(path), "error": str(exc)})


def _compute_coverage_metrics(
    valid_datasets: list[tuple[Path, Mapping[str, Any], bool]],
) -> dict[str, Any]:
    """Compute overall coverage and cross-language metrics from valid datasets."""
    total_records = 0
    covered_records = 0
    matrix_records = 0
    matrix_pairs: set[str] = set()
    matrix_concepts: set[str] = set()

    for _path, dataset, is_skeleton in valid_datasets:
        for entry in dataset["entries"]:
            total_records += 1
            if _complete_audio_marker(entry):
                covered_records += 1
            if is_skeleton:
                matrix_records += 1
                pair = entry["pair_identity"]
                matrix_pairs.add(pair["id"])
                concept_id = entry.get("concept_id")
                if isinstance(concept_id, str) and concept_id.strip():
                    matrix_concepts.add(concept_id)

    coverage = round((covered_records / total_records * 100.0) if total_records else 0.0, 2)
    return {
        "total_records": total_records,
        "covered_records": covered_records,
        "matrix_records": matrix_records,
        "matrix_pairs": matrix_pairs,
        "matrix_concepts": matrix_concepts,
        "coverage": coverage,
    }


def _build_report(
    files: list[dict[str, Any]],
    errors: list[dict[str, str]],
    metrics: dict[str, Any],
    skeleton_paths: tuple[Path, ...],
    fail_under_coverage: float | None,
) -> dict[str, Any]:
    """Assemble the final report dictionary."""
    invalid_files = sum(1 for item in files if not item["valid"])
    return {
        "status": "unhealthy" if errors else "healthy",
        "schemaVersion": "1.0.0",
        "schemaValidation": {
            "filesChecked": len(files),
            "validFiles": len(files) - invalid_files,
            "invalidFiles": invalid_files,
            "files": files,
        },
        "crossLanguageExpansion": {
            "skeletonFiles": len(skeleton_paths),
            "records": metrics["matrix_records"],
            "directedPairs": len(metrics["matrix_pairs"]),
            "conceptIds": len(metrics["matrix_concepts"]),
        },
        "audioCoverage": {
            "totalRecords": metrics["total_records"],
            "coveredRecords": metrics["covered_records"],
            "missingRecords": metrics["total_records"] - metrics["covered_records"],
            "coveragePercent": metrics["coverage"],
            "requiredPercent": fail_under_coverage,
        },
        "errors": errors,
    }


def run_pipeline(
    *,
    core_path: str | Path = DEFAULT_CORE_PATH,
    skeleton_dir: str | Path = DEFAULT_SKELETON_DIR,
    schema_path: str | Path = DEFAULT_SCHEMA_PATH,
    report_path: str | Path = DEFAULT_REPORT_PATH,
    fail_under_coverage: float | None = None,
) -> dict[str, Any]:
    """Validate all available lexicon data and emit one deterministic health report."""
    core = Path(core_path)
    skeletons_root = Path(skeleton_dir)
    schema = Path(schema_path)
    report_file = Path(report_path)

    if fail_under_coverage is not None and not 0.0 <= fail_under_coverage <= 100.0:
        raise ValueError("fail_under_coverage must be between 0 and 100")

    errors: list[dict[str, str]] = []
    files: list[dict[str, Any]] = []
    valid_datasets: list[tuple[Path, Mapping[str, Any], bool]] = []

    try:
        skeleton_paths = _skeleton_paths(skeletons_root)
    except PipelineValidationError as exc:
        skeleton_paths = ()
        errors.append({"path": _display_path(skeletons_root), "error": str(exc)})

    candidates: Sequence[tuple[Path, bool]] = ((core, False),) + tuple(
        (path, True) for path in skeleton_paths
    )

    _process_candidates(candidates, schema, files, errors, valid_datasets)

    metrics = _compute_coverage_metrics(valid_datasets)
    coverage = metrics["coverage"]

    threshold_failed = fail_under_coverage is not None and coverage < fail_under_coverage
    if threshold_failed:
        errors.append(
            {
                "path": "audioCoverage",
                "error": f"coverage {coverage:.2f}% is below required {fail_under_coverage:.2f}%",
            }
        )

    report = _build_report(files, errors, metrics, skeleton_paths, fail_under_coverage)
    _write_report(report, report_file)

    invalid_files = report["schemaValidation"]["invalidFiles"]
    if invalid_files or any(error["path"] != "audioCoverage" for error in errors):
        raise PipelineValidationError(
            f"data pipeline validation failed with {len(errors)} error(s)", report
        )
    if threshold_failed:
        raise PipelineCoverageError(errors[-1]["error"], report)
    return report


def _summary(report: Mapping[str, Any]) -> dict[str, Any]:
    schema = report["schemaValidation"]
    matrix = report["crossLanguageExpansion"]
    audio = report["audioCoverage"]
    return {
        "status": report["status"],
        "filesChecked": schema["filesChecked"],
        "invalidFiles": schema["invalidFiles"],
        "skeletonFiles": matrix["skeletonFiles"],
        "audioCoveragePercent": audio["coveragePercent"],
        "errors": len(report["errors"]),
    }


def _coverage_percent(value: str) -> float:
    try:
        parsed = float(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("coverage must be a number") from exc
    if not 0.0 <= parsed <= 100.0:
        raise argparse.ArgumentTypeError("coverage must be between 0 and 100")
    return parsed


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate lexicon schemas, matrix skeletons, and audio-marker coverage"
    )
    parser.add_argument("--validate-all", action="store_true", help="run the complete validation pipeline")
    parser.add_argument("--summary", action="store_true", help="print a compact JSON health summary")
    parser.add_argument(
        "--fail-under-coverage",
        type=_coverage_percent,
        metavar="PERCENT",
        help="exit non-zero if complete audio-marker coverage is below PERCENT",
    )
    args = parser.parse_args(argv)

    try:
        report = run_pipeline(
            core_path=DEFAULT_CORE_PATH,
            skeleton_dir=DEFAULT_SKELETON_DIR,
            schema_path=DEFAULT_SCHEMA_PATH,
            report_path=DEFAULT_REPORT_PATH,
            fail_under_coverage=args.fail_under_coverage,
        )
        if args.summary:
            print(json.dumps(_summary(report), sort_keys=True))
        elif args.validate_all or not any((args.summary, args.fail_under_coverage is not None)):
            print(
                "VALID "
                f"files={report['schemaValidation']['filesChecked']} "
                f"coverage={report['audioCoverage']['coveragePercent']:.2f}%"
            )
        return 0
    except (PipelineValidationError, PipelineCoverageError) as exc:
        if args.summary and exc.report is not None:
            print(json.dumps(_summary(exc.report), sort_keys=True))
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
