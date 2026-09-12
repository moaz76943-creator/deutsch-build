from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_json_runtime_switch_is_build_time_and_defaults_legacy():
    text = (ROOT / 'lib' / 'language' / 'german' / 'german_content_pack.dart').read_text(encoding='utf-8')
    assert "bool.fromEnvironment('DEUTSCH_JSON_CONTENT', defaultValue: false)" in text
    assert 'JsonGermanContentSource' in text
    assert 'LegacyGermanContentSource' in text
    assert 'ContentEngine<ContentItem>' in text
