from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]


def test_reading_word_lookup_uses_search_index_not_full_catalog_scan():
    text = (ROOT / 'lib/ui_v35/progress_pages.dart').read_text()
    start = text.index('void _showWord')
    end = text.index('\n  }', start) + 4
    block = text[start:end]
    assert 'a1.where' not in block
    assert 'searchIndex.search' in block


def test_next_step_does_not_build_word_profiles_for_every_candidate():
    text = (ROOT / 'lib/ui_v35/progress_pages.dart').read_text()
    start = text.index('class _NextStepCard')
    end = text.index('class MistakeDashboardPage', start)
    block = text[start:end]
    assert 'WordProfileService.build(a, state, corpus: a1)' not in block
    assert 'LearningCore.weakestItemForSkill' in block


def test_learning_core_exposes_bounded_weakest_item_selection():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'static T? weakestItemForSkill<T extends LearningContent>' in text
    assert 'Mastery.forItemRows' in text
