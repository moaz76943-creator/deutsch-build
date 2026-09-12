from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/core/learning_core.dart'
LEARNING = ROOT / 'lib/ui_v35/learning_pages.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_learning_core_has_no_runtime_dependency_on_content_engine_singleton():
    text = CORE.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert 'ContentEngine.instance' not in text


def test_content_dependent_learning_operations_receive_corpus_explicitly():
    text = CORE.read_text(encoding='utf-8')
    assert 'static List<T> due<T extends LearningContent>' in text
    assert 'static T? weakestItemForSkill<T extends LearningContent>(LearnerState s, String skill, Iterable<T> corpus' in text


def test_callers_pass_their_content_boundary_into_learning_core():
    learning = LEARNING.read_text(encoding='utf-8')
    progress = PROGRESS.read_text(encoding='utf-8')
    assert 'LearningCore.weakestItemForSkill(state, focusSkill, corpus, isLearnable: contentQuality.isLearnable)' in progress
    assert 'LearningCore.weakestSkill(s)' in learning  # skill-only operation stays corpus-free
