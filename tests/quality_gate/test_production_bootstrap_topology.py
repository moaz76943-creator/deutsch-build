"""Canonical production bootstrap topology contract."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
BOOT = ROOT / "lib/bootstrap/production_bootstrap.dart"
RUNTIME = ROOT / "lib/bootstrap/production_runtime.dart"


def test_bootstrap_preserves_render_first_phase3_topology():
    text = BOOT.read_text(encoding="utf-8")
    assert "WidgetsBinding.instance.addPostFrameCallback" in text
    assert "Phase3ProductionShell(" in text
    assert "LocalLearningRecoveryRuntimeHost(" in text
    assert "ProductionRuntimeCoordinator" in text
    assert "DeutschAppV35" not in text
    assert not re.search(r"\bDeutschApp\s*\(", text)
    assert len(text.splitlines()) < 1000


def test_runtime_module_owns_bounded_corpus_activation_and_memory_seed():
    text = RUNTIME.read_text(encoding="utf-8")
    assert "ActivePackRuntimeProvider(" in text
    assert "const initialWindowSize = 128;" in text
    assert "SystemAgentRuntime.start(" in text
    assert "SqlCipherPackDatabaseSecurity" in text
    assert "AndroidKeystorePackDatabaseKeyStore" in text
    assert len(text.splitlines()) < 1000


def test_legacy_top_level_ui_shells_are_not_reintroduced_into_production_root():
    combined = BOOT.read_text(encoding="utf-8") + RUNTIME.read_text(encoding="utf-8")
    assert "ui_v35/app.dart" not in combined
    assert "ui/app.dart" not in combined
