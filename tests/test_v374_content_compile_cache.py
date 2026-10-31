from pathlib import Path
import sys, time
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.content_compiler import compile_to

def test_compile_cache_reuses_unchanged_outputs(tmp_path):
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'
    content.write_text('[{"id":"1","german":"a","arabic":"b","sentence":"c","sentenceAr":"d","topic":"e","skill":"f","article":"g","plural":"h","accepted":[]}]')
    verbs.write_text('[]')
    out = tmp_path / 'out'; cache = tmp_path / 'cache.json'
    compile_to(out, content, verbs, cache_path=cache)
    target = out / 'content_items_generated.dart'; before = target.stat().st_mtime_ns
    time.sleep(0.001)
    compile_to(out, content, verbs, cache_path=cache)
    assert target.stat().st_mtime_ns == before

def test_compile_cache_invalidates_on_source_change(tmp_path):
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'
    content.write_text('[{"id":"1","german":"a","arabic":"b","sentence":"c","sentenceAr":"d","topic":"e","skill":"f","article":"g","plural":"h","accepted":[]}]')
    verbs.write_text('[]'); out=tmp_path/'out'; cache=tmp_path/'cache.json'
    compile_to(out, content, verbs, cache_path=cache)
    content.write_text(content.read_text().replace('"a"','"aa"'))
    compile_to(out, content, verbs, cache_path=cache)
    assert 'aa' in (out/'content_items_chunk_000.dart').read_text()
