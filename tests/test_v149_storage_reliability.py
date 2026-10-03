from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
TEXT=(ROOT/'lib/services/repository.dart').read_text()
PERSIST=(ROOT/'lib/services/learner_persistence.dart').read_text()
def test_enqueue_returns_real_operation_future_and_queue_recovers():
    assert 'final next = _writeQueue.then((_) => action());' in TEXT
    assert '_writeQueue = next.then<void>((_) {}).catchError((_) {});' in TEXT
    assert 'return next;' in TEXT
def test_storage_limit_error_is_not_swallowed_by_repository_queue():
    assert re.search(
        r'LearnerPersistenceFailure\(\s*LearnerPersistenceFailureCode\.payloadTooLarge\s*,?\s*\)',
        PERSIST,
        re.DOTALL,
    )
    assert '_writeQueue = next.then<void>((_) {}).catchError((_) {});' in TEXT
def test_every_mutating_operation_still_uses_serialized_enqueue():
    methods = (
        'save',
        'clearLocalData',
        'recordAssessment',
        'recordWritingMistake',
        'toggleFavoriteVerb',
        'record',
        'recordConversationAttempt',
    )
    for method in methods:
        assert re.search(
            rf'Future<[^>]+>\s+{method}\b.*?'
            rf'=>\s*_enqueue(?:<[^>]+>)?\s*\(',
            TEXT,
            re.DOTALL,
        ), method
