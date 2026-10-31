from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_review_card_last_reviewed_at_is_bounded_like_other_persisted_timestamps():
    source = (ROOT / 'lib/models/learner.dart').read_text()
    assert re.search(
        r'if\s*\(last != null\s*&&\s*last\.isAfter\(now\.add\(const Duration\(days: 1\)\)\)\)\s*'
        r'last\s*=\s*now;',
        source,
        re.DOTALL,
    )
    assert re.search(
        r'if\s*\(last != null\s*&&\s*last\.isBefore\(DateTime\(2000\)\)\)\s*'
        r'last\s*=\s*now;',
        source,
        re.DOTALL,
    )
