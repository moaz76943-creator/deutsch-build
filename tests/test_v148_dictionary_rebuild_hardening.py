from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/ui_v35/pages/core_pages.dart'
SERVICE = ROOT / 'lib/services/word_profile_service.dart'
SEARCH = ROOT / 'lib/services/search_index.dart'


def _source(path):
    return path.read_text(encoding='utf-8')


def test_dictionary_page_loads_state_once_and_caches_profiles():
    src = _source(CORE)
    block = src[src.index('class _SearchDictionaryState'):src.index('class _DictionaryWordCard')]
    assert 'late final LearnerState state = widget.repo.load();' in block
    assert 'Map<String, WordProfile<ContentItem>>' in block
    assert '_profiles[item.id]' in block
    assert 'Map<String, List<Attempt>>' in block
    assert 'itemAttempts:' in block


def test_dictionary_card_has_no_repository_load_or_corpus_scan():
    src = _source(CORE)
    block = src[src.index('class _DictionaryWordCard'):]
    assert 'repo.load()' not in block
    assert 'corpus: a1' not in block
    assert 'WordProfile<ContentItem> profile' in block


def test_word_profile_uses_indexes_and_pre_grouped_attempts():
    src = _source(SERVICE)
    assert 'required SearchIndex<T> searchIndex' in src
    assert 'required VerbIndex verbIndex' in src
    assert 'verbIndex.rowsFor' in src
    assert 'searchIndex.topicGroups' in src
    assert 'searchIndex.skillGroups' in src
    assert 'SearchIndex.instance' not in src
    assert 'VerbIndex.instance' not in src
    assert 'itemAttempts' in src
    assert 'Mastery.forItemRows' in src
    assert 'for (final v in verbConjugations)' not in src
    assert 'for (final x in corpus)' not in src


def test_search_index_exposes_lazy_skill_groups():
    src = _source(SEARCH)
    assert '_skillGroups' in src
    assert 'Map<String, List<T>> get skillGroups' in src
