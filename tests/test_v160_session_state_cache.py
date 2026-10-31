from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'lib/ui_v35/learning_pages.dart'
PARTS=ROOT/'lib/ui_v35/learning'

def text():
    chunks=[P.read_text(encoding='utf-8')]
    chunks.extend(path.read_text(encoding='utf-8') for path in sorted(PARTS.glob('*.dart')))
    return '\n'.join(chunks)

def test_core_session_keeps_one_session_state_snapshot():
    s=text()
    assert 'late LearnerState sessionState;' in s
    assert 'sessionState = widget.repo.load();' in s
    assert '_fallbackMode(pos, sessionState)' in s
    assert '_fallbackMode(0, sessionState)' in s
    assert 'widget.repo.load()) : _modeForPlanItem' not in s

def test_smart_assessment_keeps_state_for_question_build_and_history():
    s=text()
    assert 'late LearnerState assessmentState;' in s
    assert 'assessmentState = widget.repo.load();' in s
    assert re.search(
        r'AssessmentEngine\.build\(\s*corpus\s*,\s*assessmentState\s*,',
        s,
        re.DOTALL,
    )
    assert 'final corpus = widget.corpus;' in s
    assert 'history: assessmentState.assessmentHistory' in s
