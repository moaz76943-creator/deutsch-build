from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "sync"
PRESENTATION = FEATURE / "presentation"
INFRA = FEATURE / "infrastructure"


def test_sync_feature_files_respect_strict_line_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_network_packages_are_confined_to_sync_infrastructure():
    for path in FEATURE.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        if "package:http/" in text or "dart:io" in text:
            assert INFRA in path.parents, path


def test_sync_presentation_uses_canonical_glass_tokens_without_network_imports():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    for token in ("AppGlassCard", "AppColors", "AppTypography"):
        assert token in text
    assert "package:http/" not in text
    assert "dart:io" not in text


def test_offline_queue_uses_resilient_local_storage_bucket():
    storage = (
        ROOT / "lib" / "core" / "infrastructure" / "storage" /
        "local_storage_repository.dart"
    ).read_text(encoding="utf-8")
    repo = (
        FEATURE / "data" / "local_sync_repository.dart"
    ).read_text(encoding="utf-8")
    assert "syncPendingMutations" in storage
    assert "StorageBucket.syncPendingMutations" in repo
    assert "LocalStorageRepository" in repo


def test_sync_has_no_default_endpoint_or_embedded_secret():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in FEATURE.rglob("*.dart")
    )
    assert "http://" not in text
    assert "https://" not in text
    assert "api_key" not in text.lower()
    assert "client_secret" not in text.lower()
