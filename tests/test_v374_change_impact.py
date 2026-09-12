from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.change_impact import RiskLevel, analyze_changes

def test_content_change_selects_content_checks():
    report = analyze_changes(Path('.'), ['content/content_items.json'])
    assert report.risk is RiskLevel.LOW
    assert 'content' in report.affected_domains
    assert 'content_quality' in report.selected_checks
    assert 'compiler_parity' in report.selected_checks

def test_security_change_escalates_to_critical_security_checks():
    report = analyze_changes(Path('.'), ['lib/security/auth_service.dart'])
    assert report.risk is RiskLevel.CRITICAL
    assert 'security' in report.selected_checks

def test_unknown_change_fails_closed():
    report = analyze_changes(Path('.'), ['mystery/unknown.xyz'])
    assert report.uncertain is True
    assert report.risk is RiskLevel.HIGH
    assert 'full_regression' in report.selected_checks
