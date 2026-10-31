from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_mastery_dashboard_requires_explicit_corpus():
    text = (ROOT / 'lib/services/mastery_dashboard.dart').read_text(encoding='utf-8')
    assert "import '../data/content_a1.dart';" not in text
    assert "import 'content_engine.dart';" not in text
    assert 'required List<LearningContent> corpus' in text
    assert 'final items = corpus;' in text
