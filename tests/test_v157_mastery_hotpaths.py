from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MASTERY = ROOT / 'lib/core/mastery.dart'
DASH = ROOT / 'lib/services/mastery_dashboard.dart'


def test_for_item_rows_groups_attempts_by_skill_once():
    text = MASTERY.read_text(encoding='utf-8')
    assert 'final attemptsBySkill = <String, List<Attempt>>{};' in text
    assert '(attemptsBySkill[a.skill] ??= <Attempt>[]).add(a);' in text
    assert 'itemAttempts.where((a) => a.skill == skill).toList' not in text


def test_dashboard_uses_direct_retention_helper_without_rebuilding_mastery_evidence():
    text = DASH.read_text(encoding='utf-8')
    assert 'Mastery.retentionForCard' in text
    assert 'Mastery.forItem(item.id, const [], reviewCard: card' not in text


def test_dashboard_keeps_one_mastery_calculation_per_item():
    text = DASH.read_text(encoding='utf-8')
    assert text.count('Mastery.forItemRows(') == 1
