import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_quality_gate import review_batch


def _write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')


def _base():
    return {
        'version': 1, 'languageCode': 'de',
        'contentItems': [{
            'id': 'w9001', 'german': 'lernen', 'arabic': 'يتعلم',
            'sentence': 'Ich lerne Deutsch.', 'sentenceAr': 'أنا أتعلم الألمانية.',
            'topic': 'تعلم', 'skill': 'recall', 'article': '', 'plural': '', 'accepted': ['lernen']
        }],
        'verbConjugations': [], 'audio': []
    }


def test_review_accepts_complete_content_batch(tmp_path):
    source = tmp_path / 'batch.json'
    _write(source, _base())
    report = review_batch(source)
    assert report['status'] == 'PASS'
    assert report['errors'] == []


def test_review_rejects_missing_translation(tmp_path):
    source = tmp_path / 'batch.json'
    data = _base()
    data['contentItems'][0]['arabic'] = ''
    _write(source, data)
    report = review_batch(source)
    assert report['status'] == 'FAIL'
    assert any('arabic' in error for error in report['errors'])


def test_review_rejects_sentence_without_translation(tmp_path):
    source = tmp_path / 'batch.json'
    data = _base()
    data['contentItems'][0]['sentenceAr'] = ''
    _write(source, data)
    report = review_batch(source)
    assert report['status'] == 'FAIL'
    assert any('sentenceAr' in error for error in report['errors'])


def test_review_rejects_audio_reference_without_matching_content(tmp_path):
    source = tmp_path / 'batch.json'
    data = _base()
    data['audio'] = [{'contentId': 'w404', 'pronunciation': 'w404.mp3'}]
    _write(source, data)
    report = review_batch(source)
    assert report['status'] == 'FAIL'
    assert any('audio contentId' in error for error in report['errors'])


def test_review_is_report_only_and_does_not_mutate_source(tmp_path):
    source = tmp_path / 'batch.json'
    _write(source, _base())
    before = source.read_bytes()
    review_batch(source)
    assert source.read_bytes() == before


def test_publish_path_uses_quality_gate_before_mutation(tmp_path):
    from content_ingestion import publish_batch
    source = tmp_path / 'batch'; source.mkdir()
    data = _base()
    data['contentItems'][0]['arabic'] = ''
    _write(source / 'batch.json', data)
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'
    audio_manifest = tmp_path / 'audio_manifest.json'; generated = tmp_path / 'generated'; audio_root = tmp_path / 'audio'
    content.write_text('[]', encoding='utf-8'); verbs.write_text('[]', encoding='utf-8')
    audio_manifest.write_text('{"version":1,"entries":[]}', encoding='utf-8')
    try:
        publish_batch(source, content, verbs, generated, audio_manifest, audio_root)
    except ValueError as exc:
        assert 'content quality gate' in str(exc)
    else:
        raise AssertionError('expected quality gate rejection')
    assert content.read_text(encoding='utf-8') == '[]'
