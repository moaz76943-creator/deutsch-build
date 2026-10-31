import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_diff import preview_batch


def _write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False), encoding='utf-8')


def _item(content_id='w2', german='reisen'):
    return {
        'id': content_id, 'german': german, 'arabic': 'يسافر', 'sentence': 'Ich reise.',
        'sentenceAr': 'أنا أسافر.', 'topic': 'سفر', 'skill': 'recall', 'article': '',
        'plural': '', 'accepted': [german]
    }


def _verb(infinitive='reisen', person='ich', form='reise'):
    return {
        'infinitive': infinitive, 'arabic': 'يسافر', 'group': 'regular', 'person': person,
        'personAr': 'أنا', 'form': form, 'past': '', 'pastArabic': '', 'example': '',
        'exampleAr': '', 'pastExample': '', 'pastExampleAr': ''
    }


def _audio(content_id='w2'):
    return {'contentId': content_id, 'pronunciation': 'w2.mp3'}


def _batch():
    return {'version': 1, 'languageCode': 'de', 'contentItems': [_item()],
            'verbConjugations': [_verb()], 'audio': [_audio()]}


def test_preview_reports_all_planned_additions_without_mutating_sources(tmp_path):
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'; audio = tmp_path / 'audio.json'; batch = tmp_path / 'batch.json'
    _write(content, [_item('w1', 'lernen')]); _write(verbs, []); _write(audio, {'version': 1, 'entries': []}); _write(batch, _batch())
    before = (content.read_bytes(), verbs.read_bytes(), audio.read_bytes())

    report = preview_batch(batch, content_path=content, verb_path=verbs, audio_manifest_path=audio)

    assert report['status'] == 'PASS'
    assert report['summary'] == {'content_added': 1, 'verbs_added': 1, 'audio_added': 1, 'conflicts': 0}
    assert report['content']['added'][0]['id'] == 'w2'
    assert report['verbs']['added'][0]['infinitive'] == 'reisen'
    assert report['audio']['added'][0]['contentId'] == 'w2'
    assert (content.read_bytes(), verbs.read_bytes(), audio.read_bytes()) == before


def test_preview_surfaces_existing_id_and_verb_and_audio_conflicts(tmp_path):
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'; audio = tmp_path / 'audio.json'; batch = tmp_path / 'batch.json'
    _write(content, [_item('w2', 'lernen')]); _write(verbs, [_verb()]); _write(audio, {'version': 1, 'entries': [_audio()]}); _write(batch, _batch())

    report = preview_batch(batch, content_path=content, verb_path=verbs, audio_manifest_path=audio)

    assert report['status'] == 'FAIL'
    assert report['summary']['conflicts'] == 3
    assert any(x['code'] == 'content_id_exists' for x in report['conflicts'])
    assert any(x['code'] == 'verb_row_exists' for x in report['conflicts'])
    assert any(x['code'] == 'audio_content_id_exists' for x in report['conflicts'])


def test_preview_is_read_only_when_batch_has_schema_error(tmp_path):
    content = tmp_path / 'content.json'; verbs = tmp_path / 'verbs.json'; audio = tmp_path / 'audio.json'; batch = tmp_path / 'batch.json'
    _write(content, [_item('w1', 'lernen')]); _write(verbs, []); _write(audio, {'version': 1, 'entries': []})
    invalid = _batch(); invalid['contentItems'][0]['arabic'] = 7; _write(batch, invalid)

    report = preview_batch(batch, content_path=content, verb_path=verbs, audio_manifest_path=audio)

    assert report['status'] == 'FAIL'
    assert report['summary']['conflicts'] >= 1
    assert any(x['code'] == 'schema' for x in report['conflicts'])
