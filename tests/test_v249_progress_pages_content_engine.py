from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_progress_pages_uses_composed_corpus_boundary():
    text = TARGET.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert "import '../data/content_a1.dart';" not in text
    assert 'ContentEngine.instance.items' not in text
    assert re.search(
        r'LearningEngine\.buildPlan\(\s*(?:widget\.)?corpus\s*,',
        text,
        re.DOTALL,
    )
    assert 'LearningEngine.buildPlan(a1' not in text
    assert 'MistakeEngine.from(state.attempts,a1)' not in text
    assert 'RepairEngine.build(widget.mistake,a1)' not in text
    assert 'ReadingPractice.build(a1' not in text
    assert 'corpus: a1' not in text
