from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUALITY_DIR = ROOT / "tests/quality_gate"


def _active_python_contracts() -> tuple[Path, ...]:
    contracts = set(QUALITY_DIR.glob("test_*.py"))
    contracts.update(ROOT.glob("tests/test_*_adaptive_glass_contract.py"))
    return tuple(sorted(contracts))


def test_active_contracts_do_not_pin_lib_main_source_text():
    offenders = []
    for path in _active_python_contracts():
        if path == Path(__file__).resolve():
            continue
        if "main.dart" in path.read_text(encoding="utf-8"):
            offenders.append(str(path.relative_to(ROOT)))
    assert offenders == [], (
        "Active quality contracts must verify behavior or semantic boundaries, "
        f"not lib/main.dart source wording: {offenders}"
    )
