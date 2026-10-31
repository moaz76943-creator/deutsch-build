from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase11_uses_one_active_scheduler_contract():
    repository = read("lib/services/repository.dart")
    progress = read("lib/services/progress_tracker_service.dart")
    scheduler = read("lib/core/srs_scheduler.dart")
    assert "UnifiedSrsScheduler" in scheduler
    assert "unifiedSrsScheduler.schedule" in repository
    assert "unifiedSrsScheduler.schedule" in progress
    assert "SpacedRepetitionService.calculateNextReview" not in progress


def test_phase11_preserves_legacy_meaning_key_and_lazy_facets():
    facets = read("lib/core/srs_facets.dart")
    learner = read("lib/models/learner.dart")
    assert "meaning_recall" in facets
    assert "if (facetType == ReviewFacetType.meaningRecall" in facets
    assert "String get storageKey" in learner
    assert "reviewCardForFacet" in learner


def test_phase11_sqlite_migration_is_additive_and_composite():
    progress = read("lib/services/progress_tracker_service.dart")
    assert "version: 3" in progress
    assert "conceptId" in progress
    assert "facetType" in progress
    assert "variantKey" in progress
    assert "idx_spaced_repetition_facet" in progress
    assert "meaning_recall" in progress


def test_phase11_does_not_duplicate_canonical_content_in_srs_rows():
    progress = read("lib/services/progress_tracker_service.dart")
    learner = read("lib/models/learner.dart")
    forbidden = ("german", "arabic", "sentenceAr", "audioPath")
    srs_section = progress[progress.index("_tableNameSpacedRepetition"):]
    for marker in forbidden:
        assert marker not in srs_section
    assert "canonical content" not in learner.lower()


def test_phase11_does_not_start_later_roadmap_features():
    paths = [
        "lib/core/srs_facets.dart",
        "lib/core/srs_scheduler.dart",
        "lib/services/progress_tracker_service.dart",
    ]
    text = "\n".join(read(path) for path in paths)
    assert "CommuteMode" not in text
    assert "PronunciationLab" not in text
    assert "AdaptivePlacement" not in text


def test_phase11_legacy_learning_surfaces_consume_meaning_facets_only():
    paths = [
        "lib/services/vocabulary_coach.dart",
        "lib/services/daily_plan.dart",
        "lib/core/learning_core.dart",
        "lib/services/learning_engine.dart",
        "lib/services/adaptive_teacher.dart",
        "lib/services/mastery_dashboard.dart",
        "lib/services/learning_intelligence.dart",
    ]
    text = "\n".join(read(path) for path in paths)
    assert "meaningReviewCards" in text
    assert "meaningAttempts" in text
