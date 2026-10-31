from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_content_intelligence_consumes_language_neutral_content_contract():
    source = (ROOT / 'lib/language/german/german_content_intelligence.dart').read_text(encoding='utf-8')
    assert "../core/content_contract.dart" in source
    assert 'ContentItem' not in source
    assert 'LearningContent' in source
    assert '.sourceText' in source
    assert '.exampleText' in source
    assert '.exampleTranslationText' in source
    assert '.grammaticalMarker' in source
    assert '.pluralForm' in source
    assert '.acceptedForms' in source


def test_learning_intelligence_consumes_language_neutral_content_contract():
    source = (ROOT / 'lib/services/learning_intelligence.dart').read_text(encoding='utf-8')
    assert "../core/content_contract.dart" in source
    assert 'ContentItem' not in source
    assert 'LearningContent' in source


def test_shared_service_projection_has_no_german_field_accesses():
    for name in ('content_intelligence.dart',):
        source = (ROOT / 'lib/services' / name).read_text(encoding='utf-8')
        for field in ('german', 'arabic', 'sentenceAr', 'article', 'accepted'):
            assert not re.search(r'\.' + re.escape(field) + r'\b', source)
