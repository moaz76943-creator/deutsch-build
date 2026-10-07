from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_android_clock_source_uses_monotonic_elapsed_realtime_without_permission():
    native = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/"
        "AndroidGamificationClockIntegritySource.kt"
    )
    manifest = read("android/app/src/main/AndroidManifest.xml")

    assert "SystemClock.elapsedRealtime()" in native
    assert "Settings.Global.BOOT_COUNT" in native
    assert "READ_PHONE_STATE" not in manifest
    assert "PACKAGE_USAGE_STATS" not in manifest


def test_main_wires_sqlite_gamification_with_android_clock_integrity():
    main = read("lib/main.dart")

    assert "SqliteGamificationRepository.open(" in main
    assert "AndroidGamificationClockIntegritySource()" in main
    assert "gamificationReviewSink: openedGamificationRepository" in main
    assert "gamificationRepository: openedGamificationRepository" in main
    assert "migrateLegacyProfileIfPristine(" in main


def test_quick_review_receipt_reads_canonical_gamification_streak():
    sink = read(
        "lib/features/daily_drill/data/universal_session_drill_review_sink.dart"
    )

    assert "GamificationRepository" in sink
    assert "_gamificationRepository.loadSnapshot()" in sink
    assert "currentStreak: gamification.profile.currentStreak" in sink
    assert "currentStreak: learner.streak" not in sink


def test_clock_integrity_is_persisted_in_sqlite_profile_and_events():
    store = read("lib/features/gamification/sqlite_gamification_repository.dart")

    assert "last_monotonic_elapsed_ms" in store
    assert "last_boot_count" in store
    assert "monotonic_elapsed_ms" in store
    assert "boot_count" in store
    assert "static const int schemaVersion = 4" in store
    assert "gamification_store_meta" in store
    assert "_bumpRevision" in store
