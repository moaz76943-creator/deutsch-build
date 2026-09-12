from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK_CONTRACT = ROOT / 'lib/language/language_pack.dart'
GERMAN_PACK = ROOT / 'lib/language/german/german_language_pack.dart'
DEPS = ROOT / 'lib/services/app_dependencies.dart'
MAIN = ROOT / 'lib/main.dart'


def test_language_pack_contract_and_german_implementation_exist():
    assert PACK_CONTRACT.exists()
    assert GERMAN_PACK.exists()
    contract = PACK_CONTRACT.read_text(encoding='utf-8')
    german = GERMAN_PACK.read_text(encoding='utf-8')
    for token in (
        'abstract interface class LanguagePack',
        'String get languageCode',
        'String get displayName',
        'String get targetLocale',
        'String get sourceLocale',
    ):
        assert token in contract
    assert 'class GermanLanguagePack implements LanguagePack' in german


def test_german_language_pack_contains_only_language_configuration():
    text = GERMAN_PACK.read_text(encoding='utf-8')
    forbidden = (
        'LearnerState', 'Subscription', 'Authentication', 'SecureStorage',
        'AccessToken', 'password', 'secret', 'ContentItem',
    )
    assert all(token not in text for token in forbidden)
    for value in ('de', 'German', 'de-DE', 'ar'):
        assert value in text


def test_app_dependencies_accepts_selected_language_pack():
    text = DEPS.read_text(encoding='utf-8')
    assert "import '../language/language_pack.dart';" in text
    assert 'required this.languagePack' in text
    assert 'final LanguagePack languagePack;' in text


def test_main_selects_german_pack_at_composition_root():
    text = MAIN.read_text(encoding='utf-8')
    assert "import 'language/german/german_language_pack.dart';" in text
    assert 'final languagePack = const GermanLanguagePack();' in text
    assert 'languagePack: languagePack,' in text


def test_v348_build_identity_was_advanced_by_v349():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
