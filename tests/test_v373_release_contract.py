from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v373_release_contract_declares_language_content_intelligence_boundary():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle


def test_v373_contract_is_in_language_layer():
    contract = (ROOT / 'lib/language/language_content_intelligence.dart').read_text(encoding='utf-8')
    german = (ROOT / 'lib/language/german/german_content_intelligence.dart').read_text(encoding='utf-8')
    assert 'abstract interface class LanguageContentIntelligence' in contract
    assert 'implements LanguageContentIntelligence' in german
    assert 'class ContentIntelligence' not in german
