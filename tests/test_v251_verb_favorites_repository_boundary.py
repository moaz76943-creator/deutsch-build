from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REPO=(ROOT/'lib/services/repository.dart').read_text(); PERSIST=(ROOT/'lib/services/learner_persistence.dart').read_text(); PAGE=(ROOT/'lib/ui_v35/verb_pages.dart').read_text()
def test_repository_owns_legacy_key_and_delegates_migration_and_cleanup():
    assert "static const legacyFavoriteKey = 'verb_favorites_v1';" in REPO
    assert 'persistence.loadAndMigrateFavoriteVerbs(load())' in REPO
    assert 'persistence.clearLocalData()' in REPO
    assert 'getStringList(legacyFavoriteKey)' in PERSIST
    assert 'remove(legacyFavoriteKey)' in PERSIST
def test_verb_page_does_not_own_shared_preferences_or_legacy_favorite_key():
    assert 'package:shared_preferences/shared_preferences.dart' not in PAGE and 'PreferencesService' not in PAGE and 'verb_favorites_v1' not in PAGE
