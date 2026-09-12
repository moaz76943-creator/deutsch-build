from pathlib import Path

SRC = Path('lib/ui_v35/app.dart').read_text()


def test_v35_home_uses_composed_corpus_for_corpus_count():
    assert "import '../data/content_a1.dart';" not in SRC
    assert "import '../services/content_engine.dart';" not in SRC
    assert "widget.dependencies.corpus.length" in SRC
    assert "${state.learned.length}/${a1.length}" not in SRC
