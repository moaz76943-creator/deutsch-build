from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_ingestion import apply_batch


def _row(content_id: str):
    return {
        'id': content_id, 'german': 'lernen', 'arabic': 'يتعلم',
        'sentence': 'Ich lerne Deutsch.', 'sentenceAr': 'أنا أتعلم الألمانية.',
        'topic': 'تعلم', 'skill': 'recall', 'article': '', 'plural': '',
        'accepted': ['lernen'],
    }


def test_apply_batch_merges_sources_and_compiles_generated_content(tmp_path):
    content = tmp_path / 'content_items.json'
    verbs = tmp_path / 'verb_conjugations.json'
    generated = tmp_path / 'generated'
    audio = tmp_path / 'audio_manifest.json'
    content.write_text(json.dumps([_row('old-1')], ensure_ascii=False), encoding='utf-8')
    verbs.write_text('[]', encoding='utf-8')
    audio.write_text(json.dumps({'version': 1, 'entries': []}), encoding='utf-8')
    batch = tmp_path / 'review.json'
    batch.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [_row('new-1')],
        'verbConjugations': [],
        'audio': [{'contentId': 'new-1', 'pronunciation': 'audio/de/new-1.mp3'}],
    }, ensure_ascii=False), encoding='utf-8')

    result = apply_batch(batch, content, verbs, generated, audio)

    assert result == (2, 0, 1)
    merged = json.loads(content.read_text(encoding='utf-8'))
    assert [row['id'] for row in merged] == ['old-1', 'new-1']
    assert json.loads(verbs.read_text(encoding='utf-8')) == []
    assert (generated / 'content_items_generated.dart').exists()
    assert (generated / 'verb_conjugations_generated.dart').exists()


def test_apply_batch_rejects_non_reviewable_batch_without_mutating_sources(tmp_path):
    content = tmp_path / 'content_items.json'
    verbs = tmp_path / 'verb_conjugations.json'
    generated = tmp_path / 'generated'
    content.write_text(json.dumps([_row('old-1')], ensure_ascii=False), encoding='utf-8')
    verbs.write_text('[]', encoding='utf-8')
    batch = tmp_path / 'review.json'
    batch.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [_row('old-1')],
        'verbConjugations': [],
        'audio': [],
    }, ensure_ascii=False), encoding='utf-8')
    before_content = content.read_bytes()
    before_verbs = verbs.read_bytes()

    try:
        apply_batch(batch, content, verbs, generated)
    except ValueError as exc:
        assert 'duplicate existing content id' in str(exc)
    else:
        raise AssertionError('expected duplicate batch rejection')

    assert content.read_bytes() == before_content
    assert verbs.read_bytes() == before_verbs
    assert not generated.exists()
