from pathlib import Path
import sys, time
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.content_compiler import compile_to, CHUNK_SIZE


def _row(i: int) -> str:
    return '{"id":"%s","german":"g%s","arabic":"a","sentence":"s","sentenceAr":"sa","topic":"t","skill":"k","article":"der","plural":"p","accepted":[]}' % (i, i)


def test_incremental_compile_rewrites_only_changed_content_chunk(tmp_path):
    content = tmp_path / 'content.json'
    verbs = tmp_path / 'verbs.json'
    rows = [_row(i) for i in range(CHUNK_SIZE + 2)]
    content.write_text('[' + ','.join(rows) + ']')
    verbs.write_text('[]')
    out = tmp_path / 'out'
    cache = tmp_path / 'cache.json'

    compile_to(out, content, verbs, cache_path=cache)
    first = out / 'content_items_chunk_000.dart'
    second = out / 'content_items_chunk_001.dart'
    first_before, second_before = first.stat().st_mtime_ns, second.stat().st_mtime_ns

    time.sleep(0.01)
    rows[10] = _row(10).replace('g10', 'changed')
    content.write_text('[' + ','.join(rows) + ']')
    compile_to(out, content, verbs, cache_path=cache)

    assert first.stat().st_mtime_ns > first_before
    assert second.stat().st_mtime_ns == second_before
    assert 'changed' in first.read_text()
    assert 'g400' in second.read_text()


def test_incremental_compile_does_not_rewrite_aggregators_when_only_chunk_changes(tmp_path):
    content = tmp_path / 'content.json'
    verbs = tmp_path / 'verbs.json'
    rows = [_row(i) for i in range(CHUNK_SIZE + 2)]
    content.write_text('[' + ','.join(rows) + ']')
    verbs.write_text('[]')
    out = tmp_path / 'out'
    cache = tmp_path / 'cache.json'
    compile_to(out, content, verbs, cache_path=cache)
    aggregate = out / 'content_items_generated.dart'
    before = aggregate.stat().st_mtime_ns
    time.sleep(0.01)
    rows[10] = _row(10).replace('g10', 'changed-again')
    content.write_text('[' + ','.join(rows) + ']')
    compile_to(out, content, verbs, cache_path=cache)
    assert aggregate.stat().st_mtime_ns == before
