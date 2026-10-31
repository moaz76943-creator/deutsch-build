from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.verification_cache import fingerprint


def test_v378_invalidates_v377_cache_version(tmp_path):
    source = tmp_path / 'source.txt'
    source.write_text('stable', encoding='utf-8')
    assert fingerprint([source], config={'check': 'x'}, tool_version='V379') != fingerprint(
        [source], config={'check': 'x'}, tool_version='V378'
    )


def test_verify_uses_v378_tool_version():
    source = (Path(__file__).resolve().parents[1] / 'tool/verify.py').read_text(encoding='utf-8')
    compiler = (Path(__file__).resolve().parents[1] / 'tool/content_compiler.py').read_text(encoding='utf-8')
    assert "tool_version='V383'" in source
    assert 'tool_version="V379"' in compiler
