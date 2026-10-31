from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]; SRC=(ROOT/'lib/services/learner_persistence.dart').read_text(); CARD=(ROOT/'lib/models/learner.dart').read_text()
def test_state_input_has_outer_size_guard_before_json_decode():
    assert 'raw.length > 4 * 1024 * 1024' in SRC and 'jsonDecode(raw)' in SRC
    assert SRC.index('raw.length > 4 * 1024 * 1024') < SRC.index('jsonDecode(raw)')
def test_attempts_and_history_have_hard_limits_during_load():
    assert 'attemptsRaw.take(maxAttempts)' in SRC and 'historyRaw.take(100)' in SRC
def test_string_collections_are_bounded_and_normalized():
    assert 'whereType<String>()' in SRC and 'x.length <= 160' in SRC and '.take(maxCollectionItems)' in SRC
def test_review_cards_reject_mismatched_storage_and_payload_ids():
    assert 'maxReviewStorageKeyLength = 1024' in SRC and 'card.storageKey == key' in SRC
def test_review_card_numeric_fields_are_bounded():
    assert "_boundInt(_int(j['repetitions']), 0, 1000)" in CARD
def test_persistence_refuses_oversized_serialized_state():
    assert 'utf8.encode(payload)' in SRC and 'encodedPayloadBytes.length > maxPayloadBytes' in SRC
    assert 'LearnerPersistenceFailureCode.payloadTooLarge' in SRC
def test_corrupt_nested_records_are_isolated_instead_of_aborting_all_state():
    assert 'try {' in SRC and 'catch (_) {}' in SRC
