from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK_CONTRACT = ROOT / "lib/language/language_pack.dart"
GERMAN_PACK = ROOT / "lib/language/german/german_language_pack.dart"
DEPS = ROOT / "lib/services/app_dependencies.dart"
MAIN = ROOT / "lib/main.dart"


def test_language_pack_contract_and_german_implementation_exist():
    contract = PACK_CONTRACT.read_text(encoding="utf-8")
    german = GERMAN_PACK.read_text(encoding="utf-8")
    for token in (
        "abstract interface class LanguagePack",
        "String get languageCode",
        "String get displayName",
        "String get targetLocale",
        "String get sourceLocale",
    ):
        assert token in contract
    assert "class GermanLanguagePack implements LanguagePack" in german


def test_german_language_pack_contains_only_language_configuration():
    text = GERMAN_PACK.read_text(encoding="utf-8")
    forbidden = (
        "LearnerState", "Subscription", "Authentication", "SecureStorage",
        "AccessToken", "password", "secret", "ContentItem",
    )
    assert all(token not in text for token in forbidden)
    for value in ("de", "German", "de-DE", "ar"):
        assert value in text


def test_legacy_app_dependencies_still_accept_selected_language_pack():
    text = DEPS.read_text(encoding="utf-8")
    assert "import '../language/language_pack.dart';" in text
    assert "required this.languagePack" in text
    assert "final LanguagePack languagePack;" in text


def test_production_root_selects_german_pack_without_global_singletons():
    text = MAIN.read_text(encoding="utf-8")
    assert "import 'language/german/german_language_pack.dart';" in text
    assert "const activeLanguagePack = GermanLanguagePack();" in text
    assert "activeLanguagePack.speechProfile" in text
    assert "activeLanguagePack.languageCode" in text
    assert "activeLanguagePack.sourceLocale" in text
    assert "ContentEngine.instance" not in text
    assert "VerbIndex.instance" not in text


def test_build_identity_is_explicit():
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    gradle = (ROOT / "android/app/build.gradle").read_text(encoding="utf-8")
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert 'versionName "' in gradle
