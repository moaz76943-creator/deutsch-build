from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_ingestion import validate_audio_assets


def test_audio_assets_require_existing_files_and_reference_known_content(tmp_path):
    content = tmp_path / 'content.json'
    audio_manifest = tmp_path / 'audio_manifest.json'
    audio_root = tmp_path / 'audio'
    audio_root.mkdir()
    content.write_text(json.dumps([{'id': 'de-1'}]), encoding='utf-8')
    (audio_root / 'de-1.mp3').write_bytes(b'fake-audio')
    audio_manifest.write_text(json.dumps({
        'version': 1,
        'entries': [{'contentId': 'de-1', 'pronunciation': 'de-1.mp3'}]
    }), encoding='utf-8')

    assert validate_audio_assets(audio_manifest, audio_root, content) == (1, 1)


def test_audio_assets_reject_missing_file_and_orphan_file(tmp_path):
    content = tmp_path / 'content.json'
    audio_manifest = tmp_path / 'audio_manifest.json'
    audio_root = tmp_path / 'audio'
    audio_root.mkdir()
    content.write_text(json.dumps([{'id': 'de-1'}]), encoding='utf-8')
    (audio_root / 'orphan.mp3').write_bytes(b'orphan')
    audio_manifest.write_text(json.dumps({
        'version': 1,
        'entries': [{'contentId': 'de-1', 'pronunciation': 'missing.mp3'}]
    }), encoding='utf-8')

    try:
        validate_audio_assets(audio_manifest, audio_root, content)
    except ValueError as exc:
        assert 'missing audio asset' in str(exc)
    else:
        raise AssertionError('expected missing audio asset rejection')


def test_audio_validation_cli_accepts_empty_current_audio_catalog():
    import subprocess
    result = subprocess.run(
        [sys.executable, str(ROOT / 'tool' / 'content_ingestion.py'), 'validate-audio'],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0
    assert 'audio_validation=PASS' in result.stdout


def test_audio_assets_ignore_non_audio_documentation_files(tmp_path):
    content = tmp_path / 'content.json'
    audio_manifest = tmp_path / 'audio_manifest.json'
    audio_root = tmp_path / 'audio'
    audio_root.mkdir()
    content.write_text(json.dumps([]), encoding='utf-8')
    (audio_root / 'README.md').write_text('documentation', encoding='utf-8')
    audio_manifest.write_text(json.dumps({'version': 1, 'entries': []}), encoding='utf-8')

    assert validate_audio_assets(audio_manifest, audio_root, content) == (0, 0)
