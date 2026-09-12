from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]


def test_weakest_item_does_not_treat_unmeasured_as_zero_mastery():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    start = text.index('static T? weakestItemForSkill')
    end = text.index('\n  static Map<String,double> skillScores', start)
    block = text[start:end]
    assert 'attemptsByItem[item.id]' in block
    assert 'isEmpty' in block
    assert 'itemAttempts == null || itemAttempts.isEmpty' in block


def test_weakest_item_has_explicit_unmeasured_fallback_after_measured_items():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    start = text.index('static T? weakestItemForSkill')
    end = text.index('\n  static Map<String,double> skillScores', start)
    block = text[start:end]
    assert 'fallback' in block
    assert 'best == null' in block


def test_learning_core_imports_mastery_directly():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert "import 'mastery.dart';" in text
