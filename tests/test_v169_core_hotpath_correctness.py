from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_mistake_engine_indexes_content_once():
    src = read('lib/services/mistake_engine.dart')
    assert 'final contentById = <String, LearningContent>{' in src
    assert 'for (final item in content) item.id: item,' in src
    assert 'content.cast<ContentItem?>().firstWhere' not in src
    assert 'contentById[entry.key]' in src


def test_learning_engine_uses_content_index_for_repeated_lookup():
    src = read('lib/services/learning_engine.dart')
    assert 'final eligibleById = <String, LearningContent>{' in src
    assert 'for (final item in eligible) item.id: item,' in src
    assert '_find(eligible, id)' not in src
    assert 'eligibleById[id]' in src


def test_learning_intelligence_removes_redundant_sort():
    src = read('lib/services/learning_intelligence.dart')
    assert src.count('ranked.sort((a, b) => b.priority.compareTo(a.priority));') == 2


def test_ai_gateway_preserves_base_path_prefix():
    src = read('lib/services/ai_gateway.dart')
    assert 'baseUri.path.endsWith' in src
    assert "resolve('v1/review')" in src
    assert "resolve('v1/conversation')" in src
    assert "resolve('/v1/review')" not in src
    assert "resolve('/v1/conversation')" not in src
