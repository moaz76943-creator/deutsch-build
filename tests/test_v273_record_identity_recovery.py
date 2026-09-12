from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_persistence_filters_attempts_with_empty_identity_after_normalization():
    block = PERSIST[PERSIST.index('LearnerState _normalizeForPersistence') : PERSIST.index('static Map<String, ReviewCard> _normalizeReviewCards')]
    assert '.where((a) => a.id.trim().isNotEmpty && a.itemId.trim().isNotEmpty)' in block


def test_persistence_filters_assessment_history_with_empty_identity_after_normalization():
    block = PERSIST[PERSIST.index('LearnerState _normalizeForPersistence') : PERSIST.index('static Map<String, ReviewCard> _normalizeReviewCards')]
    assert '.where((h) => h.id.trim().isNotEmpty)' in block
