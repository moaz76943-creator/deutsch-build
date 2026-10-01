from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_persistence_normalizes_updated_at_to_non_future_value():
    assert 'final now = DateTime.now();' in PERSIST
    assert 'var normalizedUpdatedAt = s.updatedAt.isBefore(now) ? now : s.updatedAt;' in PERSIST
    assert re.search(
        r'if\s*\(normalizedUpdatedAt\.isAfter\(now\.add\(const Duration\(days: 1\)\)\)\)\s*'
        r'normalizedUpdatedAt\s*=\s*now;',
        PERSIST,
        re.DOTALL,
    )


def test_persistence_does_not_move_updated_at_backward():
    assert 'updatedAt: normalizedUpdatedAt,' in PERSIST
    block = PERSIST[
        PERSIST.index('LearnerState _normalizeForPersistence'):
        PERSIST.index('static Map<String, ReviewCard> _normalizeReviewCards')
    ]
    assert 'var normalizedUpdatedAt = s.updatedAt.isBefore(now) ? now : s.updatedAt;' in block
