from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_persistence_reconciles_missing_review_cards_without_changing_review_semantics():
    assert 'final normalizedCards = _normalizeReviewCards(s.reviewCards);' in REPO
    assert 'final normalizedReview = _boundedStringSet(s.review);' in REPO
    assert 'for (final id in normalizedReview)' in REPO
    assert 'normalizedCards.putIfAbsent(id, () => ReviewCard(itemId: id, dueAt: now));' in REPO
    assert 'review: normalizedReview,' in REPO


def test_existing_review_card_metadata_does_not_force_inactive_review_ids_back_into_review():
    assert 'review: normalizedReview,' in REPO
    assert 'review: {...normalizedReview, ...normalizedCards.keys}.take(maxCollectionItems).toSet(),' not in REPO
