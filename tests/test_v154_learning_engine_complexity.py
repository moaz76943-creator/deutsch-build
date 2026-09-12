from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENGINE = ROOT / 'lib/services/learning_engine.dart'
COACH = ROOT / 'lib/services/vocabulary_coach.dart'


def test_v154_learning_engine_precomputes_item_priority_before_sorting():
    text = ENGINE.read_text()
    assert 'final priorityById = <String, int>{' in text
    assert 'priorityById[candidate.id]' in text
    assert 'remaining.sort((a,b){' not in text
    assert text.count('remaining.sort((a,b)=>') == 1


def test_v154_learning_engine_does_not_rescan_attempts_inside_item_priority():
    text = ENGINE.read_text()
    assert 'final attemptsByItem = <String, List<Attempt>>{};' in text
    assert 'attemptsByItem[item.id]' in text
    assert 'state.attempts.where((x)=>x.itemId==item.id)' not in text
    assert 'a.where((x)=>!x.correct).length' in text


def test_v154_vocabulary_coach_uses_bounded_top_k_instead_of_full_sort():
    text = COACH.read_text()
    assert 'const maxRanked = 120;' in text
    assert 'ranked.length < maxRanked' in text
    assert 'ranked.sort' not in text
    assert '.where(ContentQuality.isLearnable).where' not in text
    assert 'limit.clamp(1, 120)' in text
