from pathlib import Path
SRC=Path('lib/services/learner_persistence.dart').read_text()
def test_review_cards_are_normalized_before_persistence():
    assert '_normalizeReviewCard' in SRC and 'final card = _normalizeReviewCard(id, entry.value);' in SRC
def test_assessment_history_is_normalized_before_persistence():
    assert '_normalizeAssessmentHistory' in SRC and 'assessmentHistory:' in SRC and '.take(100)' in SRC
