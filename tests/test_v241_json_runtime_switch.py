from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_json_runtime_switch_is_build_time_and_defaults_legacy():
    text = (ROOT / 'lib' / 'language' / 'german' / 'german_content_pack.dart').read_text(encoding='utf-8')
    assert re.search(
        r"bool\.fromEnvironment\(\s*'DEUTSCH_JSON_CONTENT'\s*,\s*defaultValue:\s*false\s*,?\s*\)",
        text,
        re.DOTALL,
    )
    assert 'JsonGermanContentSource' in text
    assert 'LegacyGermanContentSource' in text
    assert 'ContentEngine<ContentItem>' in text
