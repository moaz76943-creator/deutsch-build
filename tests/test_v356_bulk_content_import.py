from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / 'tool' / 'content_ingestion.py'


def run_import(source: Path, output: Path):
    return subprocess.run(
        [sys.executable, str(TOOL), 'prepare-batch', '--source', str(source), '--output', str(output)],
        cwd=ROOT, text=True, capture_output=True, check=False,
    )


def test_prepare_batch_creates_reviewable_bulk_import_without_touching_catalog(tmp_path):
    source = tmp_path / 'batch.json'
    output = tmp_path / 'review.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [{
            'id': 'new-0001', 'german': 'lernen', 'arabic': 'يتعلم',
            'sentence': 'Ich lerne Deutsch.', 'sentenceAr': 'أنا أتعلم الألمانية.',
            'topic': 'تعلم', 'skill': 'recall', 'accepted': ['lernen'],
            'article': '', 'plural': '',
        }],
        'verbConjugations': [],
        'audio': [{'contentId': 'new-0001', 'pronunciation': 'audio/de/new-0001.mp3'}],
    }, ensure_ascii=False), encoding='utf-8')
    before = (ROOT / 'content' / 'content_items.json').read_bytes()

    result = run_import(source, output)

    assert result.returncode == 0, result.stderr
    assert 'batch_content_items=1' in result.stdout
    assert 'batch_audio_entries=1' in result.stdout
    assert output.exists()
    assert (ROOT / 'content' / 'content_items.json').read_bytes() == before
    prepared = json.loads(output.read_text(encoding='utf-8'))
    assert prepared['languageCode'] == 'de'
    assert prepared['contentItems'][0]['id'] == 'new-0001'
    assert prepared['audio'][0]['contentId'] == 'new-0001'


def test_prepare_batch_rejects_duplicate_existing_content_ids(tmp_path):
    source = tmp_path / 'batch.json'
    output = tmp_path / 'review.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [{
            'id': 'w0001', 'german': 'Hallo', 'arabic': 'مرحبًا',
            'sentence': 'Hallo!', 'sentenceAr': 'مرحبًا!',
            'topic': 'التحية', 'skill': 'recall', 'accepted': ['Hallo'],
            'article': '', 'plural': '',
        }],
        'verbConjugations': [],
        'audio': [],
    }, ensure_ascii=False), encoding='utf-8')

    result = run_import(source, output)

    assert result.returncode != 0
    assert 'duplicate existing content id' in result.stderr
    assert not output.exists()


def test_prepare_batch_rejects_duplicate_existing_verb_rows(tmp_path):
    source = tmp_path / 'batch.json'
    output = tmp_path / 'review.json'
    source.write_text(json.dumps({
        'version': 1,
        'languageCode': 'de',
        'contentItems': [],
        'verbConjugations': [{
            'infinitive': 'sein', 'arabic': 'يكون', 'group': '1. الأفعال الأساسية',
            'person': 'ich', 'personAr': 'أنا', 'form': 'bin', 'past': 'bin gewesen',
            'pastArabic': 'كنتُ', 'example': 'Ich bin müde.', 'exampleAr': 'أنا متعب.',
            'pastExample': 'Ich bin müde gewesen.', 'pastExampleAr': 'كنتُ متعب.',
        }],
        'audio': [],
    }, ensure_ascii=False), encoding='utf-8')

    result = run_import(source, output)

    assert result.returncode != 0
    assert 'duplicate existing verb row' in result.stderr
    assert not output.exists()
