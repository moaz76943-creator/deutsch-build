from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'lib/ui/app.dart'


def test_legacy_ui_learning_and_vocabulary_use_content_engine_boundary():
    text = APP.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert "import '../services/app_dependencies.dart';" in text
    assert "import '../data/content_a1.dart';" not in text
    compact = ''.join(text.split())
    assert 'content=widget.dependencies.corpus;' in compact
    assert 'content.length' in compact
    assert 'content[x].id' in compact
    assert 'ContentItemgetitem=>content[order[i%order.length]];' in compact
    assert 'itemCount:content.length' in compact
    assert 'finalitem=content[i];' in compact
