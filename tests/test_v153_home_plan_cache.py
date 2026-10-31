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


def test_v153_home_refreshes_dynamic_state_and_gamification_snapshot():
    text = APP.read_text()
    refresh = text[text.index('  void refresh()'):text.index('  Widget _tabForIndex')]
    assert 'state = widget.repo.load();' in refresh
    assert 'widget.dependencies.gamificationRepository.loadSnapshot()' in refresh

    home = text[text.index('  Widget _homeTab'):text.index('  Widget _learnTab')]
    assert 'ProgressSnapshotService.build(' in home
    assert 'final streak = profile.currentStreak;' in home
    assert 'final xp = profile.totalXp;' in home
    assert 'state.streak' not in home
    assert 'state.xp' not in home
    assert 'masteredWords: state.learned.length' in home
    assert 'totalWords: widget.dependencies.corpus.length' in home


def test_v153_learning_engine_groups_attempts_once_for_item_priority_and_history():
    text = (ROOT / 'lib/services/learning_engine.dart').read_text()
    assert 'final attemptsByItem = <String, List<Attempt>>{};' in text
    assert 'for (final attempt in meaningAttempts)' in text
    assert 'attemptsByItem[item.id]' in text
    assert 'state.attempts.where((x)=>x.itemId==item.id)' not in text
    assert 'state.attempts.any((a)=>a.itemId==item.id)' not in text
