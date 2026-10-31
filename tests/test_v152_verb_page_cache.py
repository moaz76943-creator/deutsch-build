from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAGE = ROOT / 'lib/ui_v35/verb_pages.dart'
INDEX = ROOT / 'lib/services/verb_index.dart'


def test_v152_page_uses_cached_verb_groups_and_not_full_rebuild():
    text = PAGE.read_text()
    assert 'widget.verbIndex.groups' in text
    assert 'for(final v in verbConjugations){(groups[v.group]??=[]).add(v);}' not in text
    assert 'for(final v in verbConjugations)v.infinitive' not in text


def test_v152_favorites_use_index_rows_instead_of_full_corpus_filter():
    text = PAGE.read_text()
    assert 'verbIndex.rowsFor' in text
    assert 'all.where((v)=>favorites.contains(v.infinitive))' not in text


def test_v152_verb_index_groups_are_cached():
    text = INDEX.read_text()
    assert 'late final Map<String, List<String>> _groups' in text
    assert 'get groups => _groups;' in text
    assert 'return _byGroup.map(' not in text


def test_v152_favorites_use_repository_storage_boundary():
    text = PAGE.read_text()
    assert 'required this.repo' in text
    assert 'widget.repo.loadAndMigrateFavoriteVerbs()' in text
    assert 'widget.repo.toggleFavoriteVerb(infinitive)' in text
    assert 'PreferencesService' not in text



def test_v152_non_root_page_parts_do_not_redeclare_root_widget():
    for name in ('progress_pages.dart','conversation_pages.dart','learning_pages.dart','account_pages.dart','verb_pages.dart'):
        text = (ROOT / 'lib/ui_v35' / name).read_text()
        assert 'class DeutschAppV35 extends StatefulWidget' not in text


def test_v152_verb_state_owns_tts_dispose():
    text = PAGE.read_text()
    state_start = text.index('class _VerbConjugationPageState')
    favorites_start = text.index('class VerbFavoritesPage')
    state = text[state_start:favorites_start]
    assert re.search(
        r'void dispose\(\)\s*\{\s*_tts\.dispose\(\);\s*super\.dispose\(\);\s*\}',
        state,
        re.DOTALL,
    )
    assert text.count('_tts.dispose();') == 1
