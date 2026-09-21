from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_verb_page_does_not_rebuild_full_catalog_maps_in_build():
    text = (ROOT / 'lib/ui/app.dart').read_text()
    start = text.index('class VerbPage')
    end = text.index('class ProgressPage')
    page = text[start:end]
    assert 'final byVerb=<String,List<VerbConjugation>>{}' not in page
    assert 'final byGroup=<String,List<String>>{}' not in page
    assert 'final VerbIndex verbIndex;' in text
    assert 'required this.verbIndex' in text
    assert re.search(r'final\s+catalog\s*=\s*widget\.verbIndex\s*;', page)


def test_verb_index_exposes_cached_group_and_infinitive_catalog():
    text = (ROOT / 'lib/services/verb_index.dart').read_text()
    assert 'groups' in text
    assert 'rowsFor' in text
    assert 'infinitives' in text
    assert 'LanguageTextNormalizer _textNormalizer' in text


def test_verb_catalog_index_is_built_once_and_not_per_widget_build():
    text = (ROOT / 'lib/services/verb_index.dart').read_text()
    assert 'verbConjugations' in text and 'v126VerbExpansion' in text and 'v128VerbExpansion' in text
    assert '_byGroup' in text
    assert '_infinitives' in text
