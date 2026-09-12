from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.verification_cache import fingerprint, load, is_valid, store

def test_fingerprint_changes_when_source_changes(tmp_path):
    source = tmp_path / 'source.txt'; source.write_text('a')
    a = fingerprint([source], config={'mode':'fast'}, tool_version='1')
    source.write_text('b')
    b = fingerprint([source], config={'mode':'fast'}, tool_version='1')
    assert a != b

def test_config_and_tool_version_invalidate(tmp_path):
    source = tmp_path / 'source.txt'; source.write_text('a')
    base = fingerprint([source], config={'mode':'fast'}, tool_version='1')
    assert base != fingerprint([source], config={'mode':'release'}, tool_version='1')
    assert base != fingerprint([source], config={'mode':'fast'}, tool_version='2')

def test_corrupt_cache_is_a_miss(tmp_path):
    cache = tmp_path / 'cache.json'; cache.write_text('{bad')
    assert load(cache) == {}

def test_store_and_validate(tmp_path):
    cache = tmp_path / 'cache.json'
    store(cache, 'check', 'fp', {'status':'PASS'})
    data = load(cache)
    assert is_valid(data['check'], 'fp')
    assert not is_valid(data['check'], 'other')
