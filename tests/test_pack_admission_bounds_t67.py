"""Static fail-closed contracts for T66/T67: pack admission bounds.

Covers file-size bounds, per-table and total row-count bounds, bounded
query waiting, and the decompression-ratio ceiling constant. The Dart suite
is not executed locally (no Flutter SDK); these contracts pin the admission
gate's source so the bounds cannot be silently removed.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADMISSION = ROOT / "lib/core/storage/pack_admission_service.dart"


def _src() -> str:
    return ADMISSION.read_text(encoding="utf-8")


def test_pack_size_bound_is_declared_and_enforced() -> None:
    src = _src()
    assert "static const int maxPackBytes" in src
    assert "256 * 1024 * 1024" in src
    assert "length > maxPackBytes" in src
    assert "Pack exceeds maximum size bound" in src


def test_admission_queries_are_time_bounded_with_busy_timeout() -> None:
    src = _src()
    assert "PRAGMA busy_timeout" in src
    assert "busyTimeoutMs" in src
    # The pragma is issued on the admission connection before any scan.
    assert src.index("PRAGMA busy_timeout") < src.index("integrity_check")


def test_per_table_row_count_bounds_are_enforced_fail_closed() -> None:
    src = _src()
    assert "boundedTables" in src
    for table in (
        "concepts",
        "lexicon",
        "senses",
        "translations",
        "examples",
        "lexical_relations",
        "grammar",
    ):
        assert f"'{table}'" in src
    assert "SELECT COUNT(*) AS n FROM $table" in src
    assert "count > maxTableRows" in src
    assert "Table exceeds row-count bound" in src


def test_total_row_count_bound_is_enforced_fail_closed() -> None:
    src = _src()
    assert "maxTotalRows" in src
    assert "totalRows > maxTotalRows" in src
    assert "Pack exceeds total row-count bound" in src


def test_row_count_tables_are_compile_time_allowlist_not_caller_input() -> None:
    src = _src()
    assert "static const List<String> boundedTables" in src
    # No interpolation of variables into the table name other than the
    # allowlisted loop variable.
    assert "FROM $table" in src
    assert "FROM $languageCode" not in src


def test_decompression_ratio_ceiling_is_declared() -> None:
    src = _src()
    assert "maxDecompressionRatio" in src
    assert "100.0" in src


def test_oversize_pack_is_quarantined_before_hash_or_install() -> None:
    src = _src()
    # The size gate runs before hashing/atomic install so an oversized
    # payload can never reach the replace path.
    assert src.index("length > maxPackBytes") < src.index("Isolate.run")
    assert src.index("length > maxPackBytes") < src.index(
        "installDatabaseAtomically"
    )


def test_metadata_and_schema_validation_still_precede_activation() -> None:
    src = _src()
    # T66 core: schema verification runs before the atomic installer is called.
    assert src.index("_verifySqliteIntegrity") < src.index(
        "installDatabaseAtomically"
    )
    assert "verifyUniversalSchema" in src
    # Metadata language identity is enforced by the shared verifier.
    db_service = (ROOT / "lib/services/database_service.dart").read_text(
        encoding="utf-8"
    )
    assert "metadata['mapping_version']" in db_service
    assert "metadata['language_code']" in db_service
