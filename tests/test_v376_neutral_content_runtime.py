from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_content_engine_is_language_neutral():
    src = read('lib/services/content_engine.dart')
    assert "import '../../content/german/" not in src
    assert 'ContentSource<T extends LearningContent>' in src
    assert 'ContentEngine<T extends LearningContent>' in src
    assert 'ContentItem' not in src


def test_content_contract_does_not_describe_concrete_german_model():
    src = read('lib/core/content_contract.dart')
    assert 'ContentItem' not in src
