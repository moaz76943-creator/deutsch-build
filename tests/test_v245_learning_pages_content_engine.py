from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_learning_pages_uses_composed_corpus_instead_of_direct_content_dependency():
    root = ROOT / 'lib/ui_v35/learning_pages.dart'
    text = root.read_text(encoding='utf-8') + '\n' + '\n'.join(
        path.read_text(encoding='utf-8')
        for path in sorted((ROOT / 'lib/ui_v35/learning').glob('*.dart'))
    )
    assert "import '../data/content_a1.dart';" not in text
    assert "import '../services/content_engine.dart';" not in text
    assert 'final corpus = widget.corpus;' in text
    assert 'LearningEngine.buildPlan(a1' not in text
    assert 'AssessmentEngine.build(a1' not in text
