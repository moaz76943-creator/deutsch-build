from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'lib/ui_v35/app.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_v153_home_does_not_construct_all_tabs_on_every_build():
    text = APP.read_text()
    assert 'final tabs = [_homeTab(c), _learnTab(c), _practiceTab(c), _progressTab(c)];' not in text
    assert '_tabForIndex(c, tab)' in text


def test_v153_personal_path_card_is_stateful_and_plan_is_cached():
    text = PROGRESS.read_text()
    start = text.index('class PersonalPathCard')
    end = text.index('class PersonalizedPathPage')
    card = text[start:end]
    assert 'extends StatefulWidget' in card
    assert 'late LearningPath _path;' in card
    assert re.search(
        r'LearningEngine\.buildPlan\(\s*widget\.corpus\s*,\s*_state\s*,.*?'
        r'exerciseStrategy:\s*widget\.exerciseStrategy\s*,.*?'
        r'contentQuality:\s*widget\.contentQuality\s*,.*?'
        r'contentIntelligence:\s*widget\.contentIntelligence\s*,.*?'
        r'dailyGoal:\s*8\s*,?\s*\)',
        card,
        re.DOTALL,
    )
    assert card.count('LearningEngine.buildPlan') == 1
    assert 'didUpdateWidget' in card


def test_v153_home_passes_state_revision_to_personal_path_card():
    text = APP.read_text()
    assert 'int _stateRevision = 0;' in text
    assert re.search(
        r'setState\(\(\)\s*\{\s*state\s*=\s*widget\.repo\.load\(\);\s*_stateRevision\+\+;\s*\}\);',
        text,
        re.DOTALL,
    )
    assert re.search(
        r'PersonalPathCard\(\s*repo:\s*widget\.repo\s*,\s*onDone:\s*refresh\s*,\s*'
        r'revision:\s*_stateRevision\s*,\s*corpus:\s*widget\.dependencies\.corpus',
        text,
        re.DOTALL,
    )


def test_v153_learning_engine_groups_attempts_once_for_item_priority_and_history():
    text = (ROOT / 'lib/services/learning_engine.dart').read_text()
    assert 'final attemptsByItem = <String, List<Attempt>>{};' in text
    assert 'for (final attempt in state.attempts)' in text
    assert 'attemptsByItem[item.id]' in text
    assert 'state.attempts.where((x)=>x.itemId==item.id)' not in text
    assert 'state.attempts.any((a)=>a.itemId==item.id)' not in text
