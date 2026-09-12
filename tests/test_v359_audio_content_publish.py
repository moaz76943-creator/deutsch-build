from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_ingestion import publish_batch


def _row(content_id: str, german='lernen'):
    return {
        'id': content_id, 'german': german, 'arabic': 'يتعلم',
        'sentence': 'Ich lerne Deutsch.', 'sentenceAr': 'أنا أتعلم الألمانية.',
        'topic': 'تعلم', 'skill': 'recall', 'article': '', 'plural': '',
        'accepted': [german],
    }


def _batch(path: Path, audio_name='new-1.mp3'):
    path.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [_row('new-1')],
        'verbConjugations': [],
        'audio': [{'contentId': 'new-1', 'pronunciation': audio_name}],
    }, ensure_ascii=False), encoding='utf-8')


def test_publish_batch_atomically_adds_content_and_audio(tmp_path):
    source = tmp_path / 'batch'
    source.mkdir()
    _batch(source / 'batch.json')
    (source / 'new-1.mp3').write_bytes(b'fake-audio')
    content = tmp_path / 'content_items.json'
    verbs = tmp_path / 'verb_conjugations.json'
    generated = tmp_path / 'generated'
    audio_manifest = tmp_path / 'audio_manifest.json'
    audio_root = tmp_path / 'audio'
    content.write_text(json.dumps([_row('old-1', 'arbeiten')], ensure_ascii=False), encoding='utf-8')
    verbs.write_text('[]', encoding='utf-8')
    audio_manifest.write_text(json.dumps({'version': 1, 'entries': []}), encoding='utf-8')

    result = publish_batch(source, content, verbs, generated, audio_manifest, audio_root)

    assert result == (2, 0, 1)
    assert [row['id'] for row in json.loads(content.read_text(encoding='utf-8'))] == ['old-1', 'new-1']
    assert json.loads(audio_manifest.read_text(encoding='utf-8'))['entries'][0]['contentId'] == 'new-1'
    assert (audio_root / 'new-1.mp3').read_bytes() == b'fake-audio'
    assert (generated / 'content_items_generated.dart').exists()


def test_publish_batch_rejects_missing_audio_without_mutating_anything(tmp_path):
    source = tmp_path / 'batch'
    source.mkdir()
    _batch(source / 'batch.json')
    content = tmp_path / 'content_items.json'
    verbs = tmp_path / 'verb_conjugations.json'
    generated = tmp_path / 'generated'
    audio_manifest = tmp_path / 'audio_manifest.json'
    audio_root = tmp_path / 'audio'
    content.write_text(json.dumps([_row('old-1', 'arbeiten')], ensure_ascii=False), encoding='utf-8')
    verbs.write_text('[]', encoding='utf-8')
    audio_manifest.write_text(json.dumps({'version': 1, 'entries': []}), encoding='utf-8')
    before = (content.read_bytes(), verbs.read_bytes(), audio_manifest.read_bytes())

    try:
        publish_batch(source, content, verbs, generated, audio_manifest, audio_root)
    except ValueError as exc:
        assert 'missing source audio asset' in str(exc)
    else:
        raise AssertionError('expected missing source audio rejection')

    assert (content.read_bytes(), verbs.read_bytes(), audio_manifest.read_bytes()) == before
    assert not audio_root.exists()
    assert not generated.exists()
