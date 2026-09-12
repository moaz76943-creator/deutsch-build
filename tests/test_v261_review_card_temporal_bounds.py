from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_review_card_last_reviewed_at_is_bounded_like_other_persisted_timestamps():
    source = (ROOT / 'lib/models/learner.dart').read_text()
    marker = "if (last != null && last.isAfter(now.add(const Duration(days: 1)))) last = now;"
    assert marker in source
    assert "if (last != null && last.isBefore(DateTime(2000))) last = now;" in source
