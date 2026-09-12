from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def read(p): return (ROOT/p).read_text(encoding='utf-8')

def test_learning_core_uses_explicit_content_boundary_and_fresh_selection_is_bounded():
    s=read('lib/core/learning_core.dart')
    assert 'static Map<String, ContentItem>? _index;' not in s
    assert 'ContentEngine.instance' not in s
    assert 'Iterable<T> corpus' in s
    assert 'final fresh = a1.where' not in s

def test_content_catalog_has_no_duplicate_part07():
    s=read('content/german/content_a1.dart')
    assert s.count('...a1Part07') == 1

def test_verb_index_initialization_is_lazy():
    s=read('lib/services/verb_index.dart')
    assert 'VerbIndex({required LanguageTextNormalizer textNormalizer})' in s
    assert 'LanguageTextNormalizer _textNormalizer' in s
    assert 'static final VerbIndex instance' not in s

def test_safe_tts_helpers_share_serialized_engine_gate():
    s=read('lib/services/tts_service.dart')
    assert 'Expando<_TtsGate>' in s
    assert 'gate.generation++' in s
    assert 'Future<void> safeSpeak' in s
