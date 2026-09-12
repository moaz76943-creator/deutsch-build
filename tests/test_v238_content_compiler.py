from pathlib import Path
import json
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / 'tool' / 'content_compiler.py'
CONTENT = ROOT / 'content' / 'content_items.json'
VERBS = ROOT / 'content' / 'verb_conjugations.json'


def test_compiler_roundtrip_preserves_json_rows():
    with tempfile.TemporaryDirectory() as td:
        out_dir = Path(td)
        result = subprocess.run(
            [sys.executable, str(TOOL), 'compile', '--output-dir', str(out_dir)],
            cwd=ROOT, text=True, capture_output=True, check=False
        )
        assert result.returncode == 0, result.stderr
        result = subprocess.run(
            [sys.executable, str(TOOL), 'parity', '--output-dir', str(out_dir)],
            cwd=ROOT, text=True, capture_output=True, check=False
        )
        assert result.returncode == 0, result.stderr
        assert 'content_rows=14813' in result.stdout
        assert 'verb_rows=11718' in result.stdout


def test_compiler_is_deterministic_and_keeps_runtime_source_untouched():
    with tempfile.TemporaryDirectory() as td1, tempfile.TemporaryDirectory() as td2:
        for td in (td1, td2):
            result = subprocess.run(
                [sys.executable, str(TOOL), 'compile', '--output-dir', td],
                cwd=ROOT, text=True, capture_output=True, check=False
            )
            assert result.returncode == 0, result.stderr
        a = (Path(td1) / 'content_items_generated.dart').read_bytes()
        b = (Path(td2) / 'content_items_generated.dart').read_bytes()
        av = (Path(td1) / 'verb_conjugations_generated.dart').read_bytes()
        bv = (Path(td2) / 'verb_conjugations_generated.dart').read_bytes()
        assert a == b
        assert av == bv
        assert not (ROOT / 'lib' / 'data' / 'content_items_generated.dart').exists()
        assert not (ROOT / 'lib' / 'data' / 'verb_conjugations_generated.dart').exists()


def test_ci_invokes_content_compiler_parity_gate():
    build = (ROOT / '.github/workflows/build-apk.yml').read_text(encoding='utf-8')
    quality = (ROOT / '.github/workflows/quality.yml').read_text(encoding='utf-8')
    assert 'content_compiler.py' in build
    assert 'content_compiler.py' in quality

def test_ci_content_compiler_uses_runner_temp_without_forced_recursive_delete():
    for rel in ('.github/workflows/build-apk.yml', '.github/workflows/quality.yml'):
        text = (ROOT / rel).read_text(encoding='utf-8')
        assert 'mktemp -d' in text
        assert 'rm -rf "$RUNNER_TEMP/deutsch-content-generated"' not in text
