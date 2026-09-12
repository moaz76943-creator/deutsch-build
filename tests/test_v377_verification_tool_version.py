from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.verification_cache import fingerprint


def test_verification_fingerprint_uses_v379_tool_version(tmp_path):
    source = tmp_path / 'source.txt'
    source.write_text('stable')
    v379 = fingerprint([source], config={'check': 'x'}, tool_version='V379')
    old = fingerprint([source], config={'check': 'x'}, tool_version='V378')
    assert v379 != old
