import base64
import subprocess

import pytest

from tools.language_pack_artifacts import canonical_json_bytes
from tools.language_pack_factory import PackFactoryValidationError, write_catalog
from tools.pack_manifest_signing import sign_catalog


def _write_keys(tmp_path):
    private_key = tmp_path / "test-ed25519-private.pem"
    public_key = tmp_path / "test-ed25519-public.pem"
    generated = subprocess.run(
        ["openssl", "genpkey", "-algorithm", "ED25519", "-out", str(private_key)],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert generated.returncode == 0, generated.stderr.decode(errors="replace")
    derived = subprocess.run(
        ["openssl", "pkey", "-in", str(private_key), "-pubout", "-out", str(public_key)],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert derived.returncode == 0, derived.stderr.decode(errors="replace")
    return private_key, public_key

def _descriptor():
    return {
        "id": "de-core",
        "languageCode": "de",
        "displayName": "Deutsch Core",
        "version": "1.0.0",
        "contractVersion": "1.0.0",
        "bundleFormat": "json-gzip-v1",
        "archiveUrl": "https://packs.example.test/de-core.pack.gz",
        "sha256": "a" * 64,
        "contentSha256": "b" * 64,
        "archiveSizeBytes": 12,
        "installedSizeBytes": 8,
    }


def test_sign_catalog_is_deterministic_and_openssl_verifiable(tmp_path):
    private_key, public_key = _write_keys(tmp_path)
    first = sign_catalog(
        packs=[_descriptor()],
        manifest_revision=12,
        private_key_path=private_key,
        key_id="test-rfc8032",
    )
    second = sign_catalog(
        packs=[_descriptor()],
        manifest_revision=12,
        private_key_path=private_key,
        key_id="test-rfc8032",
    )
    assert first == second
    assert first["schemaVersion"] == 2
    assert first["algorithm"] == "Ed25519"
    assert first["keyId"] == "test-rfc8032"

    unsigned = dict(first)
    signature = base64.b64decode(unsigned.pop("signature"))
    signature_path = tmp_path / "signature.bin"
    signature_path.write_bytes(signature)
    message_path = tmp_path / "manifest-message.json"
    message_path.write_bytes(canonical_json_bytes(unsigned))
    result = subprocess.run(
        [
            "openssl",
            "pkeyutl",
            "-verify",
            "-pubin",
            "-inkey",
            str(public_key),
            "-rawin",
            "-sigfile",
            str(signature_path),
            "-in",
            str(message_path),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0


def test_write_catalog_requires_signature_by_default(tmp_path):
    with pytest.raises(PackFactoryValidationError, match="signing key"):
        write_catalog(
            [_descriptor()],
            tmp_path / "catalog.json",
            manifest_revision=1,
        )
