from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_verb_page_does_not_create_shared_preferences_future_inside_build():
    text = (ROOT / 'lib/ui/app.dart').read_text()
    page = text[text.index('class VerbPage'):text.index('class ProgressPage')]
    build = page[page.index('Widget build'):]
    assert 'SharedPreferences.getInstance()' not in build


def test_verb_page_does_not_load_learner_state_inside_build():
    text = (ROOT / 'lib/ui/app.dart').read_text()
    page = text[text.index('class VerbPage'):text.index('class ProgressPage')]
    build = page[page.index('Widget build'):]
    assert 'repo.load()' not in build
    assert 'state = repo.load()' not in build


def test_verb_page_caches_storage_future_for_rebuilds():
    text = (ROOT / 'lib/ui/app.dart').read_text()
    page = text[text.index('class VerbPage'):text.index('class ProgressPage')]
    assert 'late final Future<LearnerRepository> _repoFuture;' in page
    assert re.search(r'PreferencesService\.instance\(\)\.then\s*\(\s*\(prefs\)\s*=>\s*LearnerRepository\s*\(', page)
    assert 'late final Future<LearnerState> _stateFuture;' in page
    assert re.search(r'_stateFuture\s*=\s*_repoFuture\.then\s*\(\s*\(repo\)\s*=>\s*repo\.load\(\)\s*\)\s*;', page)
