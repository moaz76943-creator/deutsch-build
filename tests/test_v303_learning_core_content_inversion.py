import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/core/learning_core.dart'
LEARNING = ROOT / 'lib/ui_v35/learning_pages.dart'
LEARNING_PARTS = ROOT / 'lib/ui_v35/learning'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'

def learning_text():
    return LEARNING.read_text(encoding='utf-8') + '\n' + '\n'.join(
        path.read_text(encoding='utf-8')
        for path in sorted(LEARNING_PARTS.glob('*.dart'))
    )


def test_learning_core_has_no_runtime_dependency_on_content_engine_singleton():
    text = CORE.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert 'ContentEngine.instance' not in text


def test_content_dependent_learning_operations_receive_corpus_explicitly():
    text = CORE.read_text(encoding='utf-8')
    assert re.search(r'static\s+List<T>\s+due<T\s+extends\s+LearningContent>', text)
    assert re.search(r'static\s+T\?\s+weakestItemForSkill<T\s+extends\s+LearningContent>\(\s*LearnerState\s+s,\s*String\s+skill,\s*Iterable<T>\s+corpus', text)


def test_callers_pass_their_content_boundary_into_learning_core():
    learning = learning_text()
    progress = PROGRESS.read_text(encoding='utf-8')
    assert re.search(r'LearningCore\.weakestItemForSkill\(\s*state,\s*focusSkill,\s*corpus,\s*isLearnable:\s*contentQuality\.isLearnable,?\s*\)', progress, re.DOTALL)
    assert 'LearningCore.weakestSkill(s)' in learning  # skill-only operation stays corpus-free
