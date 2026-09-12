from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LI = ROOT / 'lib/services/learning_intelligence.dart'
ENGINE = ROOT / 'lib/services/learning_engine.dart'


def text(path):
    return path.read_text(encoding='utf-8')


def test_rank_session_precomputes_attempts_by_item_for_decisions():
    s = text(LI)
    assert 'attemptsByItem' in s
    assert 'state.attempts.where((a) => a.itemId == item.id)' not in s
    assert 'attemptsByItem[item.id]' in s


def test_rank_session_does_not_build_unbounded_decision_list_before_limit():
    s = text(LI)
    assert 'ranked.length' in s
    assert 'ranked.add(decision)' in s or 'ranked.add(' in s
    assert 'limit.clamp(1, 100)' in s


def test_learning_engine_does_not_recompute_intelligence_for_all_coached_items():
    s = text(ENGINE)
    assert 'LearningIntelligence.rankSession' in s
    assert 'limit: remaining.length' not in s
