from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase16_xp_reward_is_owned_by_unified_srs_scheduler():
    scheduler = read("lib/core/srs_scheduler.dart")
    repository = read("lib/services/repository.dart")
    assert "xpRewardForReview" in scheduler
    assert "unifiedSrsScheduler.xpRewardForReview" in repository
    assert "ReviewTransactionEnvelope(" in repository
    assert "persistReviewEnvelope(" in repository
    assert "GamificationReviewEvent" in repository


def test_phase16_gamification_is_local_sqlite_and_idempotent():
    store = read(
        "lib/features/gamification/sqlite_gamification_repository.dart"
    )
    assert "CREATE TABLE gamification_profile" in store
    assert "CREATE TABLE gamification_review_events" in store
    assert "CREATE TABLE gamification_badges" in store
    assert "event_id TEXT PRIMARY KEY" in store
    assert "duplicate.isNotEmpty" in store
    assert "http://" not in store
    assert "https://" not in store


def test_phase16_clock_manipulation_fails_closed():
    engine = read("lib/features/gamification/gamification_engine.dart")
    assert "_backwardClockTolerance" in engine
    assert "backwardClock" in engine
    assert "localDayRegression" in engine
    assert "awardedXp: 0" in engine
    assert "clockAnomalyDetected: true" in engine
    assert "timezoneOffsetMinutes.clamp(-840, 840)" in engine


def test_phase16_dashboard_is_bidi_safe_and_uses_sqlite_repository():
    page = read(
        "lib/ui_v35/gamification/gamification_dashboard_page.dart"
    )
    sections = read(
        "lib/ui_v35/gamification/gamification_dashboard_sections.dart"
    )
    app = read("lib/ui_v35/app.dart")
    assert "GamificationRepository" in page
    assert "loadSnapshot" in page
    assert "Directionality" in page
    assert "BidiText" in sections
    assert "DirectionalText.forLanguage" in sections
    assert "GamificationDashboardPage" in app


def test_phase16_clear_local_data_clears_gamification_sqlite():
    repository = read("lib/services/repository.dart")
    store = read(
        "lib/features/gamification/sqlite_gamification_repository.dart"
    )
    assert "gamificationReviewSink.clearGamification()" in repository
    assert "DELETE" not in store.upper() or "delete(" in store
    assert "await txn.delete('gamification_review_events')" in store
    assert "await txn.delete('gamification_badges')" in store


def test_phase16_zero_new_dependencies_and_file_size_gate():
    pubspec = read("pubspec.yaml")
    assert "sqflite: ^2.4.2+1" in pubspec
    assert "timezone: ^0.11.1" in pubspec
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
      assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
    for path in (ROOT / "lib/features/gamification").rglob("*.dart"):
      assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
