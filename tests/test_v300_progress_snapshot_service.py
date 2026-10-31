from pathlib import Path
import subprocess, sys

ROOT = Path(__file__).resolve().parents[1]


def run_pytest_nodepy():
    pass


def test_progress_snapshot_calculation_has_service_owner():
    service = ROOT / "lib/services/progress_snapshot_service.dart"
    model = ROOT / "lib/models/progress_snapshot.dart"
    assert service.exists(), "ProgressSnapshot calculations must be owned by a service"
    text = model.read_text(encoding="utf-8")
    assert "models/learner.dart" not in text
    assert "models/assessment.dart" not in text
    assert "factory ProgressSnapshot.from" not in text


def test_progress_snapshot_service_preserves_existing_calculation_contract():
    service = ROOT / "lib/services/progress_snapshot_service.dart"
    text = service.read_text(encoding="utf-8") if service.exists() else ""
    for token in ["ProgressSnapshot", "Attempt", "AssessmentHistory", "_weightSum", "_level"]:
        assert token in text
