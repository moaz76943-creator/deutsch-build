#!/usr/bin/env python3
"""Ed25519 signing for offline pack catalog manifests."""

from __future__ import annotations

import base64
import re
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Mapping

try:
    from tools.language_pack_artifacts import canonical_json_bytes
except ModuleNotFoundError:
    from language_pack_artifacts import canonical_json_bytes

SIGNATURE_ALGORITHM = "Ed25519"
SIGNED_MANIFEST_SCHEMA_VERSION = 2
_KEY_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$")


class PackManifestSigningError(ValueError):
    """Raised when the signed catalog cannot be produced safely."""


def sign_catalog(
    *,
    packs: list[Mapping[str, Any]],
    manifest_revision: int,
    private_key_path: str | Path,
    key_id: str,
) -> dict[str, Any]:
    clean_key_id = key_id.strip()
    if not _KEY_ID_RE.fullmatch(clean_key_id):
        raise PackManifestSigningError("manifest key id is malformed")
    if manifest_revision <= 0:
        raise PackManifestSigningError("manifest revision must be positive")
    key_path = Path(private_key_path)
    if not key_path.is_file():
        raise PackManifestSigningError("manifest signing key file does not exist")

    payload: dict[str, Any] = {
        "schemaVersion": SIGNED_MANIFEST_SCHEMA_VERSION,
        "manifestRevision": manifest_revision,
        "algorithm": SIGNATURE_ALGORITHM,
        "keyId": clean_key_id,
        "packs": [dict(item) for item in packs],
    }
    message = canonical_json_bytes(payload)
    try:
        with tempfile.NamedTemporaryFile() as message_file:
            message_file.write(message)
            message_file.flush()
            result = subprocess.run(
                [
                    "openssl",
                    "pkeyutl",
                    "-sign",
                    "-rawin",
                    "-inkey",
                    str(key_path),
                    "-in",
                    message_file.name,
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
    except OSError as exc:
        raise PackManifestSigningError(
            "OpenSSL is required for Ed25519 catalog signing"
        ) from exc
    if result.returncode != 0:
        raise PackManifestSigningError(
            "Ed25519 catalog signing failed; private key was not accepted"
        )
    if len(result.stdout) != 64:
        raise PackManifestSigningError(
            "Ed25519 catalog signer returned an invalid signature length"
        )
    signed = dict(payload)
    signed["signature"] = base64.b64encode(result.stdout).decode("ascii")
    return signed
