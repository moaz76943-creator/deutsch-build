from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.change_impact import analyze_changes
from tool.verify import build_plan

def test_fast_plan_keeps_unaffected_checks_explicitly_skipped():
    report = analyze_changes(Path('.'), ['lib/ui_v35/foo.dart'])
    plan = build_plan(report)
    assert any(c.name == 'security' and c.skipped for c in plan)
