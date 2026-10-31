from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_verb_index_depends_on_language_normalizer_not_legacy_facade():
    src = read('lib/services/verb_index.dart')
    pack = read('lib/language/german/german_content_pack.dart')
    assert "import '../language/language_text_normalizer.dart';" in src
    assert 'LanguageTextNormalizer textNormalizer' in src
    assert re.search(r'\bTextNormalizer\b', src) is None
    assert 'VerbIndex(textNormalizer:' in pack


def test_conversation_engine_uses_injected_language_normalizer():
    src = read('lib/services/conversation_engine.dart')
    assert "import '../language/language_text_normalizer.dart';" in src
    assert 'LanguageTextNormalizer textNormalizer' in src
    assert re.search(r'\bTextNormalizer\b', src) is None


def test_production_engine_uses_injected_language_normalizer():
    src = read('lib/services/production_engine.dart')
    assert "import '../language/language_text_normalizer.dart';" in src
    assert 'LanguageTextNormalizer textNormalizer' in src
    assert re.search(r'\bTextNormalizer\b', src) is None


def test_writing_analyzer_uses_injected_language_normalizer():
    src = read('lib/services/writing_analyzer.dart')
    ui = read('lib/ui_v35/conversation_pages.dart')
    assert "import '../language/language_text_normalizer.dart';" in src
    assert 'LanguageTextNormalizer textNormalizer' in src
    assert re.search(r'\bTextNormalizer\b', src) is None
    assert re.search(
        r'WritingAnalyzer\.analyze\(\s*t\s*,\s*textNormalizer:\s*widget\.textNormalizer\s*,?\s*\)',
        ui,
        re.DOTALL,
    )


def test_no_shared_normalization_consumer_imports_legacy_facade():
    consumers = [
        'lib/services/verb_index.dart',
        'lib/services/conversation_engine.dart',
        'lib/services/production_engine.dart',
        'lib/services/writing_analyzer.dart',
    ]
    for rel in consumers:
        assert "import 'text_normalizer.dart';" not in read(rel)
