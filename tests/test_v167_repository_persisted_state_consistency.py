from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')

assert 'LearnerState _withoutLegacyPairProgress(LearnerState state)' in REPO
assert 'if (!hasPairProgressAuthority) return state;' in REPO
assert 'learned: <String>{},' in REPO
assert 'review: <String>{},' in REPO
assert 'reviewCards: <String, ReviewCard>{},' in REPO
assert 'Future<void> save(LearnerState s)' in PERSIST
assert 'jsonEncode(_toJson(s))' in PERSIST

direct_save_body = REPO[
    REPO.index('Future<void> save(LearnerState s)'):
    REPO.index('Future<Set<String>> loadAndMigrateFavoriteVerbs()')
]
save_now_body = REPO[
    REPO.index('Future<void> _saveNow'):
    REPO.index('Future<void> _recordGamificationReview')
]

for body in (direct_save_body, save_now_body):
    assert 'final persisted = persistence.normalize(' in body
    assert '_withoutLegacyPairProgress(s),' in body
    assert 'await persistence.save(persisted);' in body
    assert '_cachedState = persisted;' in body
    assert body.index('_withoutLegacyPairProgress(s),') < body.index(
        'await persistence.save(persisted);'
    )
    assert body.index('await persistence.save(persisted);') < body.index(
        '_cachedState = persisted;'
    )
