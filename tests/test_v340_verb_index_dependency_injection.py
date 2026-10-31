import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERB = ROOT / 'lib/ui_v35/verb_pages.dart'
APP = ROOT / 'lib/ui_v35/app.dart'
DEPS = ROOT / 'lib/services/app_dependencies.dart'


def test_verb_pages_use_explicit_verb_index():
    text = VERB.read_text(encoding='utf-8')
    assert "VerbIndex.instance" not in text
    assert "final VerbIndex verbIndex;" in text
    assert "final VerbIndex verbIndex;" in text[text.index('class VerbFavoritesPage'):]


def test_app_composes_verb_index_into_verb_page():
    text = APP.read_text(encoding='utf-8')
    assert re.search(r'VerbConjugationPage\(\s*repo:\s*widget\.repo,\s*verbIndex:\s*widget\.dependencies\.verbIndex,?\s*\)', text)


def test_app_dependencies_remains_the_verb_composition_boundary():
    text = DEPS.read_text(encoding='utf-8')
    assert "final VerbIndex verbIndex;" in text
