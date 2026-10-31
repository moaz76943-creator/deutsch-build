from pathlib import Path
ROOT=Path(__file__).parents[1]
MEM=(ROOT/'lib/core/memory.dart').read_text()
SRS=(ROOT/'lib/core/srs.dart').read_text()
MIST=(ROOT/'lib/services/mistake_engine.dart').read_text()

def test_memory_snapshot_uses_single_pass():
    body=MEM.split('factory MemorySnapshot.from',1)[1]
    assert 'list.where' not in body
    assert 'list.map' not in body
    assert 'for (final c in cards)' in body or 'for(final c in cards)' in body

def test_memory_rank_uses_bounded_top_selection_without_full_due_sort():
    body=MEM.split('static List<ReviewCard> rank',1)[1].split('static double priority',1)[0]
    assert 'due.sort' not in body
    assert 'boundedLimit' in body

def test_srs_has_bounded_safe_inputs_and_no_unbounded_schedule_index():
    assert 'r = repetitions < 0 ? 0' in SRS
    assert 'schedule.length - 1' in SRS
    assert 'clamp(0.0, 1.0)' in SRS

def test_mistake_recent_failure_rate_is_single_pass():
    body=MIST.split('static double _recentFailureRate',1)[1].split('static String _diagnosis',1)[0]
    assert '.where(' not in body
    assert '.toList()' not in body
    assert 'total' in body and 'failures' in body
