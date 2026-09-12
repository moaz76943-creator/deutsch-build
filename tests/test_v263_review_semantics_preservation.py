from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_review_card_metadata_does_not_force_item_back_into_active_review_set():
    assert "review: legacyReview," in REPO
    assert "review: normalizedReview," in REPO
    assert "review: {...legacyReview, ...migratedCards.keys}" not in REPO
    assert "review: {...normalizedReview, ...normalizedCards.keys}.take(maxCollectionItems).toSet()," not in REPO


def test_review_ids_still_receive_missing_cards_during_normalization():
    assert 'for (final id in normalizedReview)' in REPO
    assert 'normalizedCards.putIfAbsent(id, () => ReviewCard(itemId: id, dueAt: now));' in REPO
