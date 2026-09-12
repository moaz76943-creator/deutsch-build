from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_content_aggregator_does_not_duplicate_part07():
    src = read('content/german/content_a1.dart')
    assert src.count('...a1Part07') == 1


def test_learning_core_does_not_eagerly_build_full_id_index():
    src = read('lib/core/learning_core.dart')
    assert 'static final Map<String, ContentItem> _index = {' not in src
    assert 'static Map<String, ContentItem>?' not in src
    assert 'ContentEngine.instance' not in src
    assert 'Iterable<T> corpus' in src


def test_verb_index_is_lazy_not_static_constructor_work():
    src = read('lib/services/verb_index.dart')
    assert 'static final VerbIndex instance = VerbIndex._();' not in src
    assert 'VerbIndex({required LanguageTextNormalizer textNormalizer})' in src
    assert 'LanguageTextNormalizer _textNormalizer' in src


def test_search_index_keeps_single_cached_instance_without_eager_map_at_import():
    src = read('lib/services/search_index.dart')
    legacy = read('lib/services/search_index_legacy.dart')
    assert 'static SearchIndex? _instance;' in legacy
    assert 'SearchIndex get instance' not in src
    assert 'GermanContentPack' in legacy
    assert 'final Map<String, _Entry<T>> _entryCache' in src


def test_learning_core_due_path_avoids_full_fresh_corpus_materialization():
    src = read('lib/core/learning_core.dart')
    assert 'final fresh = a1.where((x)=>!s.learned.contains(x.id) && ContentQuality.isLearnable(x)).toList();' not in src
    assert 'final focused = <T>[];' in src
    assert 'final fallback = <T>[];' in src
    assert '.take(30).toList(growable: false)' in src
    assert 'final focused = <T>[];' in src
    assert 'final fallback = <T>[];' in src
