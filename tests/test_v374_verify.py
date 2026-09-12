from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.change_impact import analyze_changes
from tool.verify import build_plan, CheckSpec

def test_content_plan_contains_targeted_and_content_checks():
    report = analyze_changes(Path('.'), ['content/content_items.json'])
    names = [c.name for c in build_plan(report) if not c.skipped]
    assert 'content_quality' in names
    assert 'compiler_parity' in names
    assert 'full_regression' not in names

def test_uncertain_plan_escalates_to_full_regression():
    report = analyze_changes(Path('.'), ['unknown/file.xyz'])
    names = [c.name for c in build_plan(report) if not c.skipped]
    assert 'full_regression' in names

def test_skipped_checks_are_explicit():
    report = analyze_changes(Path('.'), ['content/content_items.json'])
    plan = build_plan(report)
    assert 'security' in {c.name for c in plan if c.skipped}
