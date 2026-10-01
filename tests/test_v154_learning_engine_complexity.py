from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ENGINE = ROOT / 'lib/services/learning_engine.dart'
COACH = ROOT / 'lib/services/vocabulary_coach.dart'


def test_v154_learning_engine_precomputes_item_priority_before_selection():
    text = ENGINE.read_text()
    priority = text.index('final priorityById = <String, int>{')
    loop = text.index('while (selected.length < goal', priority)
    helper = text.index('static int _itemPriority', loop)
    assert priority < loop < helper
    assert '_itemPriority(item, attemptsByItem, weak)' in text[priority:loop]
    assert '_itemPriority(' not in text[loop:helper]


def test_v154_learning_engine_does_not_rescan_attempts_inside_item_priority():
    text = ENGINE.read_text()
    assert 'final attemptsByItem = <String, List<Attempt>>{};' in text
    assert 'attemptsByItem[item.id]' in text
    assert 'state.attempts.where((x)=>x.itemId==item.id)' not in text
    assert re.search(r'a\.where\(\(x\)\s*=>\s*!x\.correct\)\.length', text)


def test_v154_vocabulary_coach_uses_bounded_top_k_instead_of_full_sort():
    text = COACH.read_text()
    assert 'const maxRanked = 120;' in text
    assert 'ranked.length < maxRanked' in text
    assert 'ranked.sort' not in text
    assert '.where(ContentQuality.isLearnable).where' not in text
    assert 'limit.clamp(1, 120)' in text
