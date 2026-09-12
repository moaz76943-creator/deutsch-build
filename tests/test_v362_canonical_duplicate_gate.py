import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_quality_gate import review_batch


def _write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')


def _item(content_id='w9001', german='lernen'):
    return {
        'id': content_id, 'german': german, 'arabic': 'يتعلم',
        'sentence': 'Ich lerne Deutsch.', 'sentenceAr': 'أنا أتعلم الألمانية.',
        'topic': 'تعلم', 'skill': 'recall', 'article': '', 'plural': '', 'accepted': [german]
    }


def _batch(item):
    return {'version': 1, 'languageCode': 'de', 'contentItems': [item], 'verbConjugations': [], 'audio': []}


def test_review_rejects_duplicate_german_inside_batch_after_normalization(tmp_path):
    source = tmp_path / 'batch.json'
    data = _batch(_item())
    data['contentItems'].append(_item('w9002', ' LERNEN '))
    _write(source, data)
    report = review_batch(source)
    assert report['status'] == 'FAIL'
    assert any('duplicate normalized german' in error for error in report['errors'])


def test_review_rejects_german_already_in_canonical_content(tmp_path):
    source = tmp_path / 'batch.json'
    canonical = tmp_path / 'content.json'
    _write(source, _batch(_item(german='Lernen')))
    _write(canonical, [_item('w1000', 'lernen')])
    report = review_batch(source, existing_content_path=canonical)
    assert report['status'] == 'FAIL'
    assert any('existing canonical german' in error for error in report['errors'])


def test_review_accepts_distinct_german_entries_against_canonical_content(tmp_path):
    source = tmp_path / 'batch.json'
    canonical = tmp_path / 'content.json'
    _write(source, _batch(_item(german='reisen')))
    _write(canonical, [_item('w1000', 'lernen')])
    report = review_batch(source, existing_content_path=canonical)
    assert report['status'] == 'PASS'


def test_review_does_not_mutate_canonical_content(tmp_path):
    source = tmp_path / 'batch.json'
    canonical = tmp_path / 'content.json'
    _write(source, _batch(_item(german='lernen')))
    _write(canonical, [_item('w1000', 'lernen')])
    before = canonical.read_bytes()
    review_batch(source, existing_content_path=canonical)
    assert canonical.read_bytes() == before
