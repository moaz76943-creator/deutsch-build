from pathlib import Path

from tool.v370_final_architecture_gate import scan_tree


def test_final_gate_reports_remaining_language_leaks():
    root = Path(__file__).resolve().parents[1]
    findings = scan_tree(root)
    assert all(f.file not in {"lib/core/content_quality.dart", "lib/core/text_normalizer.dart"} for f in findings)


def test_final_gate_ignores_language_adapter_code():
    root = Path(__file__).resolve().parents[1]
    findings = scan_tree(root)
    assert all(not f.file.startswith("lib/language/german/") for f in findings)
