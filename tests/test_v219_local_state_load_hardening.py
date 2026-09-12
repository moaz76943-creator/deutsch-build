from pathlib import Path
SRC = Path('lib/services/learner_persistence.dart').read_text()
def test_review_cards_are_bounded_and_keys_are_limited():
    assert 'cardsRaw.entries.take(maxCollectionItems)' in SRC
    assert 'id.length > 160' in SRC
def test_review_card_storage_key_must_match_payload_id():
    assert 'if (card.itemId == key) reviewCards[key] = card;' in SRC
