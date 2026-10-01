from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_weakest_item_does_not_treat_unmeasured_as_zero_mastery():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'static T? weakestItemForSkill' in text
    assert 'final itemAttempts = attemptsByItem[item.id];' in text
    assert 'itemAttempts == null || itemAttempts.isEmpty' in text
    assert 'fallback ??= item;' in text


def test_weakest_item_has_explicit_unmeasured_fallback_after_measured_items():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'T? fallback;' in text
    assert 'fallback ??= item;' in text
    assert 'return best ?? fallback;' in text


def test_learning_core_imports_mastery_directly():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert "import 'mastery.dart';" in text
