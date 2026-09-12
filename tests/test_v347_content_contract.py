from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / 'lib/core/content_contract.dart'
MODEL = ROOT / 'lib/models/content.dart'
SEARCH = ROOT / 'lib/services/search_index.dart'
DEPS = ROOT / 'lib/services/app_dependencies.dart'


def test_content_contract_and_legacy_model_bridge_exist():
    assert CONTRACT.exists()
    contract = CONTRACT.read_text(encoding='utf-8')
    model = MODEL.read_text(encoding='utf-8')
    for token in (
        'abstract interface class LearningContent',
        'String get id',
        'String get sourceText',
        'String get translationText',
        'String get exampleText',
        'String get exampleTranslationText',
        'String get topic',
        'String get skill',
        'String get grammaticalMarker',
        'String get pluralForm',
        'List<String> get acceptedForms',
    ):
        assert token in contract
    assert 'class ContentItem implements LearningContent' in model
    for token in (
        'String get sourceText => german',
        'String get translationText => arabic',
        'String get exampleText => sentence',
        'String get exampleTranslationText => sentenceAr',
        'String get grammaticalMarker => article',
        'String get pluralForm => plural',
        'List<String> get acceptedForms => accepted',
    ):
        assert token in model


def test_search_index_is_parameterized_over_language_neutral_content():
    text = SEARCH.read_text(encoding='utf-8')
    assert "import '../core/content_contract.dart';" in text
    assert 'class SearchIndex<T extends LearningContent>' in text
    assert 'SearchResult<T>' in text
    for token in ('_germanExact', '_arabicExact', 'item.german', 'item.arabic', 'item.sentenceAr', 'item.plural\b'):
        import re
        assert re.search(token, text) is None
    assert 'SearchIndex<T> searchIndex;' in DEPS.read_text(encoding='utf-8')
