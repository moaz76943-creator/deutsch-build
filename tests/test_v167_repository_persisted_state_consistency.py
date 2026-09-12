from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')

assert 'final persisted = persistence.normalize(s);' in REPO
assert 'await persistence.save(persisted);' in REPO
assert '_cachedState = persisted;' in REPO
assert 'Future<void> save(LearnerState s)' in PERSIST
assert 'jsonEncode(_toJson(s))' in PERSIST

save_body = REPO[REPO.index('Future<void> _saveNow'):REPO.index('Future<void> record({')]
assert save_body.index('await persistence.save(persisted);') < save_body.index('_cachedState = persisted;')
