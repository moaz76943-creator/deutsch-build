from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = (ROOT / 'lib/models/content.dart').read_text(encoding='utf-8')
LEARNER = (ROOT / 'lib/models/learner.dart').read_text(encoding='utf-8')
ASSESSMENT = (ROOT / 'lib/models/assessment.dart').read_text(encoding='utf-8')


def test_content_model_owns_only_static_learning_content():
    assert 'class Attempt' not in CONTENT
    assert 'class MasteryEvidence' not in CONTENT


def test_learner_model_owns_attempt_history_and_assessment_history():
    assert 'class Attempt' in LEARNER
    assert 'class AssessmentHistory' in LEARNER
    assert "import 'content.dart';" not in LEARNER
    assert "import 'assessment.dart';" not in LEARNER


def test_assessment_model_contains_runtime_assessment_types_only():
    assert 'class AssessmentQuestion' in ASSESSMENT
    assert 'class AssessmentResponse' in ASSESSMENT
    assert 'class AssessmentResult' in ASSESSMENT
    assert 'class AssessmentHistory' not in ASSESSMENT
