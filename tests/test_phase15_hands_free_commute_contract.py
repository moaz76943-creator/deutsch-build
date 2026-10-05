from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase15_queue_reads_due_meaning_and_listening_facets_only():
    queue = read("lib/features/commute/commute_review_queue.dart")
    assert "ReviewFacetType.meaningRecall" in queue
    assert "ReviewFacetType.listening" in queue
    assert "!card.dueAt.isAfter(clock)" in queue
    assert "ReviewFacetType.pronunciation" not in queue


def test_phase15_playback_uses_phase10_runtime_and_required_sequence():
    service = read("lib/features/commute/hands_free_commute_service.dart")
    assert service.count("IAudioRuntime") >= 2
    assert "AudioVariant.word" in service
    assert "AudioVariant.sentence" in service
    term = service.index("review.item.sourceText")
    meaning = service.index("review.item.translationText")
    example = service.index("review.item.exampleText")
    assert term < meaning < example
    assert "_betweenSegments" in service


def test_phase15_logs_back_to_phase11_facet_scheduler():
    service = read("lib/features/commute/hands_free_commute_service.dart")
    assert "repository.recordFacet" in service
    assert "facetType: review.facetType" in service
    assert "variantKey: review.variantKey" in service
    assert "correct: known" in service


def test_phase15_runtime_failure_is_explicit_and_not_cloud_fallback():
    service = read("lib/features/commute/hands_free_commute_service.dart")
    page = read("lib/ui_v35/commute/hands_free_commute_page.dart")
    assert "audio_runtime_unavailable" in service
    assert "result.reason" in service
    assert "يتوقف التسلسل" in page
    assert "SpeechService" not in page + service
    assert "http://" not in page + service
    assert "https://" not in page + service


def test_phase15_commute_runtime_remains_isolated_from_phase3_root():
    deps = read("lib/services/app_dependencies.dart")
    main = read("lib/main.dart")
    profile = read("lib/language/arabic/arabic_speech_profile.dart")
    assert "sourceAudioRuntime" in deps
    assert "OfflineAudioRuntime" in main
    assert "sourceAudioRuntime: sourceAudioRuntime" not in main
    assert "ArabicSpeechProfile" not in main
    assert "languageCode => 'ar'" in profile


def test_phase15_ui_has_large_controls_and_bidi_safe_text():
    controls = read("lib/ui_v35/commute/commute_controls.dart")
    page = read("lib/ui_v35/commute/hands_free_commute_page.dart")
    assert "_controlHeight = 72" in controls
    assert "DirectionalText.forLanguage" in controls
    assert "BidiText" in controls
    for label in ("تشغيل", "إيقاف مؤقت", "أعرفها", "لا أعرفها"):
        assert label in controls
    assert "HandsFreeCommutePage" in page


def test_phase15_zero_new_dependency_surface_and_ui_gate():
    pubspec = read("pubspec.yaml")
    assert "just_audio:" not in pubspec
    assert "audio_service:" not in pubspec
    assert "record:" not in pubspec
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
