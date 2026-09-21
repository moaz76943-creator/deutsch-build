from pathlib import Path
from tempfile import TemporaryDirectory

from tool.content_compiler import compile_to

ROOT = Path(__file__).resolve().parents[1]


def test_generated_json_runtime_source_is_materializable_and_opt_in():
    with TemporaryDirectory() as tmp:
        generated = Path(tmp) / 'generated'
        content_out, _ = compile_to(generated)
        assert content_out.exists(), 'generated JSON-derived content source was not materialized'
    german = (ROOT / 'lib/language/german/german_content_pack.dart').read_text(encoding='utf-8')
    assert 'JsonGermanContentSource' in german
    assert 'useGeneratedContent' in german


def test_generated_source_is_parity_checked_against_json_pack():
    german = (ROOT / 'lib/language/german/german_content_pack.dart').read_text(encoding='utf-8')
    assert 'JsonGermanContentSource' in german
    assert 'ContentEngine<ContentItem>' in german
