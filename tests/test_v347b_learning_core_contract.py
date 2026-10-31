import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/core/learning_core.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_learning_core_consumes_language_neutral_contract_not_content_model():
    text = CORE.read_text(encoding='utf-8')
    assert "import '../models/content.dart';" not in text
    assert "import 'content_contract.dart';" in text
    assert 'T extends LearningContent' in text
    assert 'ContentItem' not in text
    assert 'ContentQuality' not in text


def test_content_dependent_core_operations_accept_explicit_learnability_policy():
    text = CORE.read_text(encoding='utf-8')
    assert re.search(r'bool\s+Function\(T\s+item\)\s+isLearnable', text)
    assert re.search(r'static\s+List<T>\s+due<T\s+extends\s+LearningContent>\(', text)
    assert re.search(r'static\s+T\?\s+weakestItemForSkill<T\s+extends\s+LearningContent>\(', text)


def test_german_ui_keeps_german_quality_policy_outside_learning_core():
    text = PROGRESS.read_text(encoding='utf-8')
    assert re.search(r'LearningCore\.weakestItemForSkill\(\s*state,\s*focusSkill,\s*corpus', text)
    assert re.search(r'isLearnable:\s*contentQuality\.isLearnable', text)
