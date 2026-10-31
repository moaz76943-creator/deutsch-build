#!/usr/bin/env python3
"""Fail-closed architecture decision ledger verifier.

The checker turns durable architecture decisions into executable invariants.
It performs local static checks only: no network access, CI polling, provider
calls, secrets, or paid services are required.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Iterable, Sequence

REQUIRED_DECISIONS = tuple(f"ADR-{index:03d}" for index in range(1, 8))
DECISION_HEADING = re.compile(r"^## (ADR-\d{3})\s+—\s+.+$", re.MULTILINE)
REQUIRED_SECTIONS = (
    "### Context and motivation",
    "### Accepted decision",
    "### Rejected alternatives",
)
UI_ROOTS = ("lib/ui", "lib/ui_v35")
AUDIO_PLUGIN_IMPORTS = (
    "package:flutter_tts/",
    "package:speech_to_text/",
)


class DriftViolation(ValueError):
    """Raised when repository state contradicts a recorded architecture decision."""


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise DriftViolation(message)


def _read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        raise DriftViolation(f"cannot read required file {path}: {exc}") from exc


def _decision_blocks(ledger: str) -> dict[str, str]:
    matches = list(DECISION_HEADING.finditer(ledger))
    _require(matches, "DECISION_LOG.md contains no ADR decisions")
    blocks: dict[str, str] = {}
    for index, match in enumerate(matches):
        decision_id = match.group(1)
        _require(decision_id not in blocks, f"duplicate decision id: {decision_id}")
        end = matches[index + 1].start() if index + 1 < len(matches) else len(ledger)
        blocks[decision_id] = ledger[match.start():end]
    return blocks


def _check_ledger(root: Path) -> int:
    ledger_path = root / "docs" / "architecture" / "DECISION_LOG.md"
    ledger = _read(ledger_path)
    blocks = _decision_blocks(ledger)

    for decision_id in REQUIRED_DECISIONS:
        _require(decision_id in blocks, f"missing required architecture decision: {decision_id}")
        block = blocks[decision_id]
        for section in REQUIRED_SECTIONS:
            _require(
                section in block,
                f"{decision_id} missing required section: {section.removeprefix('### ')}",
            )

    _require(
        "<!-- BEGIN POST_MERGE_SYNC -->" in ledger
        and "<!-- END POST_MERGE_SYNC -->" in ledger,
        "DECISION_LOG.md missing managed post-merge sync block",
    )
    return len(blocks)


def _iter_ui_files(root: Path) -> Iterable[Path]:
    for relative_root in UI_ROOTS:
        ui_root = root / relative_root
        if ui_root.is_dir():
            yield from sorted(ui_root.rglob("*.dart"))


def _check_presentation_boundaries(root: Path) -> None:
    for path in _iter_ui_files(root):
        text = _read(path)
        line_count = len(text.splitlines())
        _require(
            line_count < 1000,
            f"1000-line presentation ceiling violated: {path.relative_to(root)} ({line_count})",
        )
        for forbidden in AUDIO_PLUGIN_IMPORTS:
            _require(
                forbidden not in text,
                f"direct audio plugin import in presentation: {path.relative_to(root)} ({forbidden})",
            )


def _check_multilingual_contract(root: Path, vision: str) -> None:
    for token in (
        "Shared Core + Language Intelligence + Directed Pair Intelligence",
        "USER_LANGUAGE",
        "SOURCE_LANGUAGE",
        "TARGET_LANGUAGE",
        "A → B",
    ):
        _require(token in vision, f"multilingual architecture contract drifted: missing {token!r}")


def _check_adaptive_learning(root: Path, vision: str) -> None:
    orchestrator_path = root / "lib" / "features" / "session" / "universal_session_orchestrator.dart"
    orchestrator = _read(orchestrator_path)
    _require(
        "UniversalSessionOrchestrator" in orchestrator and "LearnerRepository" in orchestrator,
        "adaptive-learning orchestrator no longer owns the canonical LearnerRepository boundary",
    )
    _require(
        "LearnerRepository.record" in vision and "recordFacet" in vision,
        "adaptive error-bank/SRS persistence contract drifted from architecture policy",
    )


def _check_root_cause_and_gate(root: Path, vision: str) -> None:
    banned = _read(root / "docs" / "architecture" / "BANNED_PATTERNS.md")
    gate = _read(root / "scripts" / "local_quality_gate.sh")
    _require("Patch-over-root-cause engineering" in banned, "root-cause policy missing from BANNED_PATTERNS")
    _require("tool/weakness_gate.py" in gate, "canonical quality gate no longer invokes weakness_gate")
    _require(
        'python3 tools/zero_drift_check.py --repo-root "$ROOT"' in gate,
        "canonical quality gate no longer invokes Zero Drift Check",
    )
    _require("exact PR head" in vision, "exact-head integration contract drifted from architecture policy")


def _check_canonical_automation_runtime(root: Path) -> None:
    runtime = root / "tools" / "automation" / "runtime.py"
    run_pipeline = root / "tools" / "automation" / "run_pipeline.py"
    _require(runtime.is_file(), "canonical runtime missing: tools/automation/runtime.py")
    pipeline = _read(run_pipeline)
    _require(
        'self.runtime = self.automation_dir / "runtime.py"' in pipeline,
        "pipeline is not wired to the canonical runtime",
    )


def run_zero_drift(repo_root: str | Path) -> dict[str, Any]:
    root = Path(repo_root).resolve()
    decision_count = _check_ledger(root)
    vision = _read(root / "docs" / "architecture" / "PROJECT_VISION_AND_RULES.md")

    _check_multilingual_contract(root, vision)
    _check_presentation_boundaries(root)
    _check_adaptive_learning(root, vision)
    _check_root_cause_and_gate(root, vision)
    _check_canonical_automation_runtime(root)

    return {
        "status": "PASS",
        "decision_count": decision_count,
        "presentation_file_limit": "<1000",
        "presentation_audio_plugins": "isolated",
        "adaptive_learning_path": "canonical",
        "root_cause_policy": "enforced",
        "automation_runtime": "canonical",
        "network_calls": 0,
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Verify living architecture decisions against repository state")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        report = run_zero_drift(args.repo_root)
    except DriftViolation as exc:
        print(json.dumps({"status": "FAIL", "error": str(exc)}, ensure_ascii=False, sort_keys=True))
        return 1
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
