"""Static fail-closed contracts for the offline pack network policy and installer."""
from __future__ import annotations

from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/pack_downloader_service.dart"
EXTRACTOR = ROOT / "lib/core/security/secure_archive_extractor.dart"
TARGET_POLICY = ROOT / "lib/core/security/trusted_network_target.dart"


def test_downloader_rejects_untrusted_targets_before_requesting() -> None:
    source = SERVICE.read_text(encoding="utf-8")
    assert "TrustedNetworkTarget.requireTrusted" in source
    assert "_trustedTarget" in source
    assert "PackDownloadState.rejected" in source
    assert "return false;" in source


def test_downloader_enforces_canonical_host_allowlist() -> None:
    source = SERVICE.read_text(encoding="utf-8")
    assert "requireTrusted(parsed, allowedHosts: approvedPackHosts)" in source

    provider = ROOT / "lib/providers/active_language_provider.dart"
    provider_source = provider.read_text(encoding="utf-8")
    assert "languagePackManifestUrl" in provider_source
    # The manifest fetch must pin the same canonical origin as the pack fetch.
    assert provider_source.count("allowedHosts: const {'raw.githubusercontent.com'}") >= 2


def test_downloader_blocks_untrusted_hosts_and_plain_http() -> None:
    source = TARGET_POLICY.read_text(encoding="utf-8")
    assert "only https targets are permitted" in source
    assert "IP literals" in source
    assert "allowedHosts" in source
    assert "localhost" in source

    service = SERVICE.read_text(encoding="utf-8")
    assert "'raw.githubusercontent.com'" in service
    assert "'cdn.jsdelivr.net'" in service


def test_downloader_uses_bounded_timeouts_and_no_redirect_following() -> None:
    source = SERVICE.read_text(encoding="utf-8")
    assert "requestTimeout" in source
    assert "idleTimeout" in source
    assert "maxUncompressedPackBytes" in source
    assert "..followRedirects = false" in source
    assert ".timeout(requestTimeout)" in source
    assert ".timeout(idleTimeout)" in source


def test_downloader_has_no_unbounded_stream_ceiling() -> None:
    source = SERVICE.read_text(encoding="utf-8")
    assert "maxUncompressedPackBytes = " in source
    assert "64 * 1024 * 1024" in source


def test_archive_extractor_rejects_symlinks_and_duplicate_entries() -> None:
    source = EXTRACTOR.read_text(encoding="utf-8")
    assert "_symbolicLinkType" in source
    assert "isSymbolicLink" in source or "_symbolicLinkType" in source
    assert "Archive entry is an unsafe symbolic link" in source
    assert "Archive contains a duplicate entry" in source
    assert "microsecondsSinceEpoch" in source


def test_archive_extractor_keeps_bounded_limits() -> None:
    source = EXTRACTOR.read_text(encoding="utf-8")
    assert "defaultMaxExpandedTotalBytes" in source
    assert "defaultMaxSingleEntryBytes" in source
    assert "defaultMaxEntryCount" in source
    assert "defaultMaxExpansionRatio" in source

def test_downloader_rejects_malformed_caller_digest_before_io() -> None:
    source = SERVICE.read_text(encoding="utf-8")
    assert "_validManifestDigest" in source
    assert "r'^[a-fA-F0-9]{64}$'" in source
    # The gate must run before any network request is constructed.
    assert source.index("_validManifestDigest.hasMatch(expectedHash)") < source.index(
        "http.Request('GET', target)"
    )


def test_admission_gate_rejects_malformed_digest() -> None:
    admission = ROOT / "lib/core/storage/pack_admission_service.dart"
    source = admission.read_text(encoding="utf-8")
    assert "_safeDigest" in source
    assert "_safeDigest.hasMatch(expectedHash)" in source
    assert source.index("_safeDigest.hasMatch(expectedHash)") < source.index(
        "Isolate.run"
    )
