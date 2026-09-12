from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "pytest.ini"


def test_pytest_defaults_to_live_tests_tree_only():
    assert CONFIG.is_file(), "pytest.ini must pin collection to the live tests tree"
    text = CONFIG.read_text(encoding="utf-8")
    assert "[pytest]" in text
    assert "testpaths = tests" in text
