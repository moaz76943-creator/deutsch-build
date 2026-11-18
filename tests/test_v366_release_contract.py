from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v366_release_contract_declares_language_normalization_boundary():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    pack = (ROOT / 'lib/language/language_pack.dart').read_text(encoding='utf-8')
    german_pack = (ROOT / 'lib/language/german/german_language_pack.dart').read_text(encoding='utf-8')
    docs = (ROOT / 'docs/V366_LANGUAGE_NORMALIZATION_CONTRACT.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert "versionName " in gradle
    assert 'LanguageTextNormalizer get textNormalizer;' in pack
    assert 'GermanTextNormalizer' in german_pack
    assert 'language-agnostic' in docs
