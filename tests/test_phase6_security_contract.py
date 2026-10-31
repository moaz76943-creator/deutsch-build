from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_runtime_manifest_is_ed25519_fail_closed():
    manifest = read("lib/services/pack_manifest.dart")
    manager = read("lib/services/pack_manager_service.dart")
    assert "supportedSchemaVersion = 2" in manifest
    assert "Ed25519PackManifestVerifier" in manifest
    assert "RejectingPackManifestVerifier" in manifest
    assert "verifyAndParse(rawJson)" in manager
    assert "manifestAcceptanceKey" in manager


def test_signed_descriptor_binds_sqlite_hash_and_install_admission():
    manifest = read("lib/services/pack_manifest.dart")
    manager = read("lib/services/pack_manager_service.dart")
    assert "contentSha256" in manifest
    assert "_assertDescriptorAdmitted" in manager
    assert "Content SQLite SHA-256 verification failed." in manager


def test_factory_cli_has_external_private_key_signing_only():
    factory = read("tools/language_pack_factory.py")
    signer = read("tools/pack_manifest_signing.py")
    assert "--signing-key" in factory
    assert "--key-id" in factory
    assert "openssl" in signer
    assert "PRIVATE KEY" not in signer


def test_phase6_does_not_implement_database_encryption_yet():
    manifest = read("lib/services/pack_manifest.dart").lower()
    manager = read("lib/services/pack_manager_service.dart").lower()
    forbidden = "sql" + "cipher"
    assert forbidden not in manifest
    assert forbidden not in manager
