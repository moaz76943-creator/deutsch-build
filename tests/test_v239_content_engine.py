from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_content_engine_adapter_exists_and_owns_runtime_source_boundary():
    path=ROOT/'lib/services/content_engine.dart'
    assert path.exists(), 'content_engine.dart missing'
    text=path.read_text(encoding='utf-8')
    assert 'abstract interface class ContentSource<T extends LearningContent>' in text
    assert 'ContentEngine<T extends LearningContent>' in text
    assert 'class ContentEngine' in text
    assert 'Iterable<T> get items' in text


def test_learning_core_consumes_content_through_explicit_boundary():
    text=(ROOT/'lib/core/learning_core.dart').read_text(encoding='utf-8')
    assert "../services/content_engine.dart" not in text
    assert 'ContentEngine.instance.items' not in text
    assert 'Iterable<T> corpus' in text
