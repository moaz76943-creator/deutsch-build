from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_android_secure_storage_platform_files_exist():
    assert (ROOT / "android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt").exists()
    assert (ROOT / "lib/services/android_secure_session_storage.dart").exists()


def test_android_implementation_uses_keystore_and_aead():
    text = read("android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt")
    assert "AndroidKeyStore" in text
    assert "KeyGenerator" in text
    assert "AES/GCM/NoPadding" in text
    assert "GCMParameterSpec" in text
    assert "Cipher" in text


def test_android_implementation_does_not_use_shared_preferences_for_credentials():
    text = read("android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt")
    assert "SharedPreferences" not in text
    assert "getSharedPreferences" not in text


def test_android_storage_restricts_file_and_excludes_backup():
    text = read("android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt")
    assert "filesDir" in text
    assert "renameTo" not in text
    assert "ATOMIC_MOVE" in text
    assert "REPLACE_EXISTING" in text
    backup = read("android/app/src/main/res/xml/backup_rules.xml")
    extraction = read("android/app/src/main/res/xml/data_extraction_rules.xml")
    assert 'domain="file"' in backup
    assert 'domain="file"' in extraction


def test_dart_adapter_maps_platform_failures_without_exposing_values():
    text = read("lib/services/android_secure_session_storage.dart")
    assert "MethodChannel" in text
    assert "SecureSessionStorageFailure" in text
    assert "SecureSessionCredentials" in text
    assert "getCurrentSession" not in text
    assert "SharedPreferences" not in text


def test_main_activity_registers_secure_storage_channel():
    text = read("android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt")
    assert "AndroidSecureSessionStorage.CHANNEL_NAME" in text
    assert "configureFlutterEngine" in text


def test_offline_production_root_does_not_activate_auth_storage():
    text = read("lib/main.dart")
    assert "AndroidSecureSessionStorage" not in text
    assert "AuthSessionController" not in text
    assert "BackendTransportFactory" not in text
