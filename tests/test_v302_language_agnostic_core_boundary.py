from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/core/learning_core.dart'
DEPTH = ROOT / 'lib/services/content_depth.dart'
UI = ROOT / 'lib/ui_v35/learning_pages.dart'


def test_learning_core_does_not_own_language_specific_word_depth_content():
    text = CORE.read_text(encoding='utf-8')
    assert 'class WordDepth' not in text
    assert 'const depth = <String, WordDepth>' not in text
    assert 'WordDepth depthFor' not in text


def test_language_specific_depth_lives_outside_core_and_is_consumed_from_its_boundary():
    assert DEPTH.exists(), 'content depth boundary should exist'
    depth_text = DEPTH.read_text(encoding='utf-8')
    assert 'class WordDepth' in depth_text
    assert 'WordDepth depthFor' in depth_text
    ui_text = UI.read_text(encoding='utf-8')
    assert "import '../services/content_depth.dart';" in ui_text
