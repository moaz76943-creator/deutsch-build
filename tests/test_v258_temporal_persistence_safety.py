from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/learner_persistence.dart').read_text()
LEARNER = (ROOT / 'lib/models/assessment.dart').read_text()
LEARNER = (ROOT / 'lib/models/learner.dart').read_text()


def test_assessment_history_future_timestamp_is_bounded_before_persistence_and_use():
    assert 'safeAt' in LEARNER
    assert "j['at']" in LEARNER
    assert "DateTime.tryParse" in LEARNER
    assert "now.add(const Duration(days: 1))" in LEARNER
    assert 'at:safeAt' in LEARNER


def test_assessment_history_persistence_normalizer_keeps_temporal_normalization_boundary():
    assert '_normalizeAssessmentHistory' in REPO
    assert 'assessmentHistory: s.assessmentHistory.take(100).map(_normalizeAssessmentHistory).where((h) => h.id.trim().isNotEmpty).toList()' in REPO


def test_review_card_persistence_reuses_model_temporal_normalization():
    assert '_normalizeReviewCard' in REPO
    assert 'var due = DateTime.tryParse' in LEARNER
    assert 'due.isAfter(now.add(const Duration(days: 3650)))' in LEARNER
    assert 'final normalizedCards = _normalizeReviewCards(s.reviewCards);' in REPO
