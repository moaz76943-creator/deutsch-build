from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def _normalization_block():
    return PERSIST[
        PERSIST.index('LearnerState _normalizeForPersistence'):
        PERSIST.index('static Map<String, ReviewCard> _normalizeReviewCards')
    ]


def test_persistence_filters_attempts_with_empty_identity_after_normalization():
    block = _normalization_block()
    assert re.search(
        r'\.where\(\s*\(a\)\s*=>\s*a\.id\.trim\(\)\.isNotEmpty\s*&&\s*'
        r'a\.itemId\.trim\(\)\.isNotEmpty\s*,?\s*\)',
        block,
        re.DOTALL,
    )


def test_persistence_filters_assessment_history_with_empty_identity_after_normalization():
    block = _normalization_block()
    assert re.search(
        r'\.where\(\(h\)\s*=>\s*h\.id\.trim\(\)\.isNotEmpty\)',
        block,
    )
