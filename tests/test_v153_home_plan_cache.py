from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'lib/ui_v35/app.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_v153_home_does_not_construct_all_tabs_on_every_build():
    text = APP.read_text()
    assert 'final tabs = [_homeTab(c), _learnTab(c), _practiceTab(c), _progressTab(c)];' not in text
    assert '_tabForIndex(c, tab)' in text


def test_v153_personal_path_card_is_stateful_and_plan_is_cached():
    text = PROGRESS.read_text()
    start = text.index('class _PersonalPathCard')
    end = text.index('class PersonalizedPathPage')
    card = text[start:end]
    assert 'extends StatefulWidget' in card
    assert 'late LearningPath _path;' in card
    assert 'LearningEngine.buildPlan(widget.corpus, _state, exerciseStrategy: widget.exerciseStrategy, contentQuality: widget.contentQuality, contentIntelligence: widget.contentIntelligence, dailyGoal: 8)' in card
    assert card.count('LearningEngine.buildPlan') == 1
    assert 'didUpdateWidget' in card


def test_v153_home_passes_state_revision_to_personal_path_card():
    text = APP.read_text()
    assert 'int _stateRevision = 0;' in text
    assert 'setState(() { state = widget.repo.load(); _stateRevision++; });' in text
    assert '_PersonalPathCard(repo: widget.repo, onDone: refresh, revision: _stateRevision, corpus: widget.dependencies.corpus' in text


def test_v153_learning_engine_groups_attempts_once_for_item_priority_and_history():
    text = (ROOT / 'lib/services/learning_engine.dart').read_text()
    assert 'final attemptsByItem = <String, List<Attempt>>{};' in text
    assert 'for (final attempt in state.attempts)' in text
    assert 'attemptsByItem[item.id]' in text
    assert 'state.attempts.where((x)=>x.itemId==item.id)' not in text
    assert 'state.attempts.any((a)=>a.itemId==item.id)' not in text
