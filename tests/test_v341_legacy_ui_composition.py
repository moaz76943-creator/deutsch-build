import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'lib/ui/app.dart'


def test_legacy_ui_uses_explicit_composition_dependencies():
    text = SRC.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert "import '../services/verb_index.dart';" not in text
    assert 'import \'../services/app_dependencies.dart\';' in text
    assert 'AppDependencies<ContentItem> dependencies;' in text
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text


def test_legacy_learning_and_vocabulary_pages_receive_corpus():
    text = SRC.read_text(encoding='utf-8')
    assert re.search(r'required\s+this\.dependencies', text)
    assert re.search(r'LearningSession\(\s*repo:\s*widget\.repo,\s*dependencies:\s*widget\.dependencies', text)
    assert re.search(r'VocabularyPage\(\s*repo:\s*widget\.repo,\s*dependencies:\s*widget\.dependencies', text)


def test_legacy_verb_and_mastery_pages_receive_dependencies():
    text = SRC.read_text(encoding='utf-8')
    assert re.search(r'VerbPage\(\s*verbIndex:\s*widget\.dependencies\.verbIndex', text)
    assert re.search(r'final\s+List<ContentItem>\s+corpus;', text)
    assert re.search(r'required\s+this\.corpus', text)
    assert 'final LanguageContentIntelligence contentIntelligence;' in text
    assert 'required this.contentIntelligence' in text
    assert re.search(r'MasteryDashboard\.build\(\s*repo\.load\(\),\s*corpus:\s*corpus,\s*contentIntelligence:\s*contentIntelligence,?\s*\)', text)
