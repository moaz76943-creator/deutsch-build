from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase7_uses_isolated_sqlcipher_for_active_pack_only():
    pubspec = read("pubspec.yaml")
    security = read("lib/services/pack_database_security.dart")
    assert "sqflite_sqlcipher: ^3.4.1" in pubspec
    assert "sqlcipher_export('encrypted')" in security
    assert "PRAGMA cipher_integrity_check" in security
    assert "_plainSqliteHeader" in security
    assert "sqlcipher_flutter_libs" not in pubspec


def test_phase7_key_is_random_and_wrapped_by_android_keystore():
    native = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/"
        "AndroidPackDatabaseKeyStore.kt"
    )
    lower = native.lower()
    assert "AndroidKeyStore" in native
    assert "SecureRandom" in native
    assert "AES/GCM/NoPadding" in native
    assert "context.filesDir" in native
    assert "setKeySize(256)" in native
    assert "deviceid" not in lower
    assert "android_id" not in lower


def test_pack_install_encrypts_before_registration_and_runtime_requires_key():
    manager = read("lib/services/pack_manager_service.dart")
    provider = read("lib/services/active_pack_runtime_provider.dart")
    assert "encryptPlaintextInPlace" in manager
    assert manager.index("encryptPlaintextInPlace") < manager.index(
        "final installed = InstalledLanguagePack"
    )
    assert "databaseEncrypted: true" in manager
    assert "pack_database_unencrypted" in provider
    assert "pack_database_key_missing" in provider
    assert "_databaseOpener.openReadOnly" in provider


def test_sqlcipher_release_shrinker_and_user_accessible_notice_exist():
    proguard = read("android/app/proguard-rules.pro")
    settings = read("lib/ui_v35/account_pages.dart")
    licenses = read("lib/services/open_source_license_registry.dart")
    assert "net.zetetic.database" in proguard
    assert "showLicensePage" in settings
    assert "ZETETIC LLC" in licenses
    assert "SQLCipher Community Edition" in licenses


def test_phase7_does_not_start_phase8_global_sqlite_rewrite():
    grammar = read("lib/services/grammar_hub_service.dart")
    assert "sqflite_sqlcipher" not in grammar
