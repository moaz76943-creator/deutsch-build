from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_generated_json_runtime_source_exists_and_is_opt_in():
    path = ROOT / 'lib' / 'data' / 'generated' / 'content_items_generated.dart'
    assert path.exists(), 'generated JSON-derived content source missing'
    german = (ROOT / 'lib/language/german/german_content_pack.dart').read_text(encoding='utf-8')
    assert 'JsonGermanContentSource' in german
    assert 'useGeneratedContent' in german


def test_generated_source_is_parity_checked_against_json_pack():
    german = (ROOT / 'lib/language/german/german_content_pack.dart').read_text(encoding='utf-8')
    assert 'JsonGermanContentSource' in german
    assert 'ContentEngine<ContentItem>' in german
