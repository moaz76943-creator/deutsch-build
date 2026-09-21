from pathlib import Path
import re

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
    assert 'required this.dependencies' in text
    assert 'LearningSession(repo:widget.repo,dependencies:widget.dependencies' in text
    assert 'VocabularyPage(repo:widget.repo,dependencies:widget.dependencies' in text


def test_legacy_verb_and_mastery_pages_receive_dependencies():
    text = SRC.read_text(encoding='utf-8')
    assert 'VerbPage(verbIndex:widget.dependencies.verbIndex)' in text
    assert 'final List<ContentItem> corpus;' in text
    assert 'required this.corpus' in text
    assert 'final LanguageContentIntelligence contentIntelligence;' in text
    assert 'required this.contentIntelligence' in text
    assert re.search(r'MasteryDashboard\.build\(\s*repo\.load\(\),\s*corpus:\s*corpus,\s*contentIntelligence:\s*contentIntelligence,?\s*\)', text)
