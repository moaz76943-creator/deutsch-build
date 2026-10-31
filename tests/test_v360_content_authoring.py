from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from content_authoring import prepare_authoring


def test_authoring_schema_compiles_simple_entries_into_reviewable_batch(tmp_path):
    source = tmp_path / 'authoring.json'
    output = tmp_path / 'batch.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'entries': [{
            'id': 'w9001',
            'word': 'lernen',
            'translation': 'يتعلم',
            'sentence': 'Ich lerne Deutsch.',
            'sentenceTranslation': 'أنا أتعلم الألمانية.',
            'topic': 'تعلم',
            'skill': 'recall',
            'article': '',
            'plural': '',
            'accepted': ['lernen'],
            'audio': {'pronunciation': 'w9001.mp3'},
        }],
        'verbs': [],
    }, ensure_ascii=False), encoding='utf-8')

    (tmp_path / 'content.json').write_text('[]', encoding='utf-8')
    (tmp_path / 'verbs.json').write_text('[]', encoding='utf-8')

    result = prepare_authoring(source, output, existing_content_path=tmp_path / 'content.json', existing_verb_path=tmp_path / 'verbs.json')

    assert result == (1, 0, 1)
    batch = json.loads(output.read_text(encoding='utf-8'))
    assert batch['contentItems'][0]['id'] == 'w9001'
    assert batch['contentItems'][0]['german'] == 'lernen'
    assert batch['contentItems'][0]['sentenceAr'] == 'أنا أتعلم الألمانية.'
    assert batch['audio'] == [{'contentId': 'w9001', 'pronunciation': 'w9001.mp3'}]


def test_authoring_rejects_duplicate_ids_before_writing_output(tmp_path):
    source = tmp_path / 'authoring.json'
    output = tmp_path / 'batch.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'entries': [
            {'id': 'w9001', 'word': 'eins', 'translation': 'واحد'},
            {'id': 'w9001', 'word': 'zwei', 'translation': 'اثنان'},
        ],
        'verbs': [],
    }, ensure_ascii=False), encoding='utf-8')
    (tmp_path / 'content.json').write_text('[]', encoding='utf-8')
    (tmp_path / 'verbs.json').write_text('[]', encoding='utf-8')

    try:
        prepare_authoring(source, output, existing_content_path=tmp_path / 'content.json', existing_verb_path=tmp_path / 'verbs.json')
    except ValueError as exc:
        assert 'duplicate authoring content id' in str(exc)
    else:
        raise AssertionError('expected duplicate authoring id rejection')
    assert not output.exists()


def test_authoring_rejects_unknown_fields_in_entry(tmp_path):
    source = tmp_path / 'authoring.json'
    output = tmp_path / 'batch.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'entries': [{'word': 'Hallo', 'translation': 'مرحبًا', 'unexpected': True}],
        'verbs': [],
    }, ensure_ascii=False), encoding='utf-8')
    (tmp_path / 'content.json').write_text('[]', encoding='utf-8')
    (tmp_path / 'verbs.json').write_text('[]', encoding='utf-8')

    try:
        prepare_authoring(source, output, existing_content_path=tmp_path / 'content.json', existing_verb_path=tmp_path / 'verbs.json')
    except ValueError as exc:
        assert 'unsupported authoring entry field' in str(exc)
    else:
        raise AssertionError('expected unknown field rejection')


def test_authoring_groups_verb_forms_without_repeating_header_data(tmp_path):
    source = tmp_path / 'authoring.json'
    output = tmp_path / 'batch.json'
    source.write_text(json.dumps({
        'version': 1, 'languageCode': 'de', 'entries': [],
        'verbs': [{
            'infinitive': 'sein', 'arabic': 'يكون', 'group': 'أساسية',
            'forms': [
                {'person': 'ich', 'personAr': 'أنا', 'form': 'bin', 'past': 'bin gewesen', 'pastArabic': 'كنتُ', 'example': 'Ich bin müde.', 'exampleAr': 'أنا متعب.', 'pastExample': 'Ich bin müde gewesen.', 'pastExampleAr': 'كنتُ متعبًا.'},
                {'person': 'du', 'personAr': 'أنت', 'form': 'bist'},
            ],
        }],
    }, ensure_ascii=False), encoding='utf-8')
    (tmp_path / 'content.json').write_text('[]', encoding='utf-8')
    (tmp_path / 'verbs.json').write_text('[]', encoding='utf-8')

    result = prepare_authoring(source, output, existing_content_path=tmp_path / 'content.json', existing_verb_path=tmp_path / 'verbs.json')

    assert result == (0, 2, 0)
    batch = json.loads(output.read_text(encoding='utf-8'))
    assert batch['verbConjugations'][0]['infinitive'] == 'sein'
    assert batch['verbConjugations'][1]['arabic'] == 'يكون'


def test_authoring_rejects_unsafe_audio_path(tmp_path):
    source = tmp_path / 'authoring.json'
    output = tmp_path / 'batch.json'
    source.write_text(json.dumps({
        'version': 1, 'languageCode': 'de',
        'entries': [{'id': 'w9001', 'word': 'Hallo', 'translation': 'مرحبًا', 'audio': {'pronunciation': '../secret.mp3'}}],
        'verbs': [],
    }, ensure_ascii=False), encoding='utf-8')
    (tmp_path / 'content.json').write_text('[]', encoding='utf-8')
    (tmp_path / 'verbs.json').write_text('[]', encoding='utf-8')

    try:
        prepare_authoring(source, output, existing_content_path=tmp_path / 'content.json', existing_verb_path=tmp_path / 'verbs.json')
    except ValueError as exc:
        assert 'safe and relative' in str(exc)
    else:
        raise AssertionError('expected unsafe audio path rejection')
    assert not output.exists()
