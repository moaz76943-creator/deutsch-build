from pathlib import Path

import pytest

from tools.zero_drift_check import DriftViolation, run_zero_drift


def _repo(tmp_path: Path) -> Path:
    (tmp_path / "docs" / "architecture").mkdir(parents=True)
    (tmp_path / "lib" / "ui_v35").mkdir(parents=True)
    (tmp_path / "lib" / "features" / "session").mkdir(parents=True)
    (tmp_path / "scripts").mkdir(parents=True)
    (tmp_path / "tools" / "automation").mkdir(parents=True)

    decisions = []
    for index in range(1, 8):
        decisions.append(
            f"""## ADR-{index:03d} — Decision {index}

### Context and motivation
Context.

### Accepted decision
Decision.

### Rejected alternatives
Alternative rejected.
"""
        )
    (tmp_path / "docs" / "architecture" / "DECISION_LOG.md").write_text(
        "# Decision Log\n\n"
        "<!-- BEGIN POST_MERGE_SYNC -->\n"
        "- Last synced main SHA: `0000000000000000000000000000000000000000`\n"
        "<!-- END POST_MERGE_SYNC -->\n\n"
        + "\n".join(decisions),
        encoding="utf-8",
    )
    (tmp_path / "docs" / "architecture" / "PROJECT_VISION_AND_RULES.md").write_text(
        "Shared Core + Language Intelligence + Directed Pair Intelligence\n"
        "USER_LANGUAGE SOURCE_LANGUAGE TARGET_LANGUAGE\n"
        "A → B is not equivalent to B → A\n"
        "LearnerRepository.record / recordFacet\n"
        "exact PR head\n",
        encoding="utf-8",
    )
    (tmp_path / "docs" / "architecture" / "BANNED_PATTERNS.md").write_text(
        "## 2. Patch-over-root-cause engineering\n",
        encoding="utf-8",
    )
    (tmp_path / "lib" / "features" / "session" / "universal_session_orchestrator.dart").write_text(
        "class UniversalSessionOrchestrator { LearnerRepository repository; }",
        encoding="utf-8",
    )
    (tmp_path / "scripts" / "local_quality_gate.sh").write_text(
        "python3 tool/weakness_gate.py\n"
        "python3 tools/zero_drift_check.py --repo-root \"$ROOT\"\n",
        encoding="utf-8",
    )
    (tmp_path / "tools" / "automation" / "runtime.py").write_text("def main(): pass\n", encoding="utf-8")
    (tmp_path / "tools" / "automation" / "run_pipeline.py").write_text(
        'self.runtime = self.automation_dir / "runtime.py"\n',
        encoding="utf-8",
    )
    (tmp_path / "lib" / "ui_v35" / "screen.dart").write_text("class Screen {}\n", encoding="utf-8")
    return tmp_path


def test_zero_drift_accepts_canonical_contract(tmp_path):
    report = run_zero_drift(_repo(tmp_path))
    assert report["status"] == "PASS"
    assert report["decision_count"] == 7


def test_zero_drift_rejects_missing_decision_structure(tmp_path):
    root = _repo(tmp_path)
    ledger = root / "docs" / "architecture" / "DECISION_LOG.md"
    ledger.write_text(ledger.read_text().replace("### Rejected alternatives\nAlternative rejected.\n", "", 1))

    with pytest.raises(DriftViolation, match="Rejected alternatives"):
        run_zero_drift(root)


def test_zero_drift_rejects_ui_file_at_1000_lines(tmp_path):
    root = _repo(tmp_path)
    (root / "lib" / "ui_v35" / "screen.dart").write_text("\n".join("x" for _ in range(1000)))

    with pytest.raises(DriftViolation, match="1000-line"):
        run_zero_drift(root)


def test_zero_drift_rejects_direct_audio_plugin_import_in_presentation(tmp_path):
    root = _repo(tmp_path)
    (root / "lib" / "ui_v35" / "screen.dart").write_text(
        "import 'package:flutter_tts/flutter_tts.dart';\n"
    )

    with pytest.raises(DriftViolation, match="audio plugin"):
        run_zero_drift(root)


def test_zero_drift_requires_canonical_runtime_wiring(tmp_path):
    root = _repo(tmp_path)
    (root / "tools" / "automation" / "run_pipeline.py").write_text("pass\n", encoding="utf-8")

    with pytest.raises(DriftViolation, match="canonical runtime"):
        run_zero_drift(root)
