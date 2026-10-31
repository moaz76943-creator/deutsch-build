from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / 'tool' / 'content_ingestion.py'
MANIFEST = ROOT / 'content' / 'german' / 'content_manifest.json'
AUDIO = ROOT / 'content' / 'german' / 'audio_manifest.json'


def test_content_ingestion_emits_language_manifest_without_rewriting_catalog():
    assert TOOL.exists()
    assert MANIFEST.exists()
    before_content = (ROOT / 'content' / 'content_items.json').read_bytes()
    before_verbs = (ROOT / 'content' / 'verb_conjugations.json').read_bytes()

    result = subprocess.run(
        [sys.executable, str(TOOL), 'validate'],
        cwd=ROOT, text=True, capture_output=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    content = json.loads((ROOT / 'content' / 'content_items.json').read_text(encoding='utf-8'))
    verbs = json.loads((ROOT / 'content' / 'verb_conjugations.json').read_text(encoding='utf-8'))
    assert f'content_items={len(content)}' in result.stdout
    assert f'verb_conjugations={len(verbs)}' in result.stdout
    assert (ROOT / 'content' / 'content_items.json').read_bytes() == before_content
    assert (ROOT / 'content' / 'verb_conjugations.json').read_bytes() == before_verbs


def test_language_manifest_declares_editable_sources_and_audio_contract():
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    assert manifest['languageCode'] == 'de'
    assert manifest['contentItems'] == '../content_items.json'
    assert manifest['verbConjugations'] == '../verb_conjugations.json'
    assert manifest['audioManifest'] == 'audio_manifest.json'
    assert AUDIO.exists()
    audio = json.loads(AUDIO.read_text(encoding='utf-8'))
    assert audio == {'version': 1, 'entries': []}


def test_audio_manifest_contract_is_id_based_and_non_intrusive():
    audio = json.loads(AUDIO.read_text(encoding='utf-8'))
    assert set(audio) == {'version', 'entries'}
    assert isinstance(audio['entries'], list)
    for entry in audio['entries']:
        assert set(entry) <= {'contentId', 'word', 'sentence', 'pronunciation'}
        assert isinstance(entry.get('contentId'), str)
        assert entry['contentId']
        for key in set(entry) - {'contentId'}:
            assert isinstance(entry[key], str)
