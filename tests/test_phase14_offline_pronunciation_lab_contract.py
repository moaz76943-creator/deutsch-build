from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase14_uses_unified_offline_audio_runtime_not_legacy_tts():
    service = read(
        "lib/features/pronunciation/pronunciation_lab_service.dart"
    )
    page = read(
        "lib/ui_v35/pronunciation/offline_pronunciation_lab_page.dart"
    )
    assert "IAudioRuntime" in service
    assert "AudioVariant.pronunciation" in service
    assert "SpeechService" not in page
    assert "SafeTtsController" not in page
    assert "speech_to_text" not in page


def test_phase14_pronunciation_is_an_independent_facet():
    service = read(
        "lib/features/pronunciation/pronunciation_lab_service.dart"
    )
    engine = read(
        "lib/features/pronunciation/pronunciation_lab_engine.dart"
    )
    assert "ReviewFacetType.pronunciation" in service
    assert "contrast:" in service
    assert "attempt.facetType != ReviewFacetType.pronunciation" in engine
    assert "pronunciation" in read("lib/core/srs_facets.dart")


def test_phase14_has_local_android_signal_capture_and_no_network_scoring():
    native = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/"
        "AndroidPronunciationSignalProbe.kt"
    )
    evaluator = read(
        "lib/features/pronunciation/pronunciation_signal_evaluator.dart"
    )
    model = read(
        "lib/features/pronunciation/domain/pronunciation_models.dart"
    )
    assert "AudioRecord" in native
    assert "VOICE_RECOGNITION" in native
    assert "captureDurationMs" in native
    assert "zeroCrossingRate" in native
    assert "http://" not in native + evaluator
    assert "https://" not in native + evaluator
    assert "phonemeAccuracyAvailable => false" in model


def test_phase14_is_perception_first_and_tracks_core_german_contrasts():
    catalog = read(
        "lib/language/german/german_pronunciation_catalog.dart"
    )
    page = read(
        "lib/ui_v35/pronunciation/offline_pronunciation_lab_page.dart"
    )
    assert "fühlen" in catalog
    assert "füllen" in catalog
    assert "Staat" in catalog
    assert "Stadt" in catalog
    assert "schon" in catalog
    assert "schön" in catalog
    assert "ich_ach_fricative" in catalog
    assert "اسمع → ميّز → انطق" in page


def test_phase14_offline_lab_remains_available_but_not_phase3_composed():
    app = read("lib/ui_v35/app.dart")
    deps = read("lib/services/app_dependencies.dart")
    main = read("lib/main.dart")
    activity = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt"
    )
    assert "OfflinePronunciationLabPage" in app
    assert "SpeechPracticePage(repo: widget.repo)" not in app
    assert "pronunciationSignalProbe" in deps
    assert "AndroidPronunciationSignalProbe.CHANNEL_NAME" in activity
    assert "AndroidPronunciationSignalProbe" not in main


def test_phase14_ui_files_respect_modularity_gate():
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
