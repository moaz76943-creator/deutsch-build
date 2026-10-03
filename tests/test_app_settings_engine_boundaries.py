from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "app_settings"


def test_app_settings_files_respect_modularity_cap():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_presentation_has_no_storage_or_platform_plugin_imports():
    forbidden = (
        "shared_preferences",
        "PreferencesService",
        "LearnerRepository",
        "flutter_tts",
        "sqflite",
        "MethodChannel",
    )
    for path in (FEATURE / "presentation").rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        for token in forbidden:
            assert token not in text, f"{path}: forbidden presentation token {token}"


def test_settings_surface_uses_canonical_glass_design_system():
    screen = (
        FEATURE / "presentation" / "app_settings_screen.dart"
    ).read_text(encoding="utf-8")
    slider = (
        FEATURE / "presentation" / "widgets" / "glass_slider_tile.dart"
    ).read_text(encoding="utf-8")
    action = (
        FEATURE / "presentation" / "widgets" / "glass_action_row.dart"
    ).read_text(encoding="utf-8")

    assert "AppGlassCard" in screen
    assert "AppGlassCard" in slider
    assert "AppGlassCard" in action
    assert "AppColors." in screen
    assert "AppTypography." in screen


def test_settings_persistence_stays_behind_preferences_adapter():
    source = (
        FEATURE / "data" / "preferences_settings_local_data_source.dart"
    ).read_text(encoding="utf-8")
    presentation = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (FEATURE / "presentation").rglob("*.dart")
    )

    assert "PreferencesService" in source
    assert "app_learning_preferences_v1" in source
    assert "shared_preferences" not in source
    assert "PreferencesService" not in presentation


def test_progress_reset_delegates_to_canonical_repository():
    resetter = (
        FEATURE / "data" / "canonical_learning_progress_resetter.dart"
    ).read_text(encoding="utf-8")

    assert "LearnerRepository" in resetter
    assert "_repository.clearLocalData()" in resetter


def test_runtime_applies_text_scale_and_speech_rate_provider():
    app = (ROOT / "lib" / "ui_v35" / "app.dart").read_text(encoding="utf-8")
    audio = (
        ROOT / "lib" / "features" / "audio" / "offline_audio_runtime.dart"
    ).read_text(encoding="utf-8")

    assert "_PreferenceTextScaler(media.textScaler, scale)" in app
    assert "settingsController.preferences.textScaleFactor" in app
    assert "speechRateProvider" in audio
    assert "_resolveSpeechRate(request)" in audio


def test_settings_preserve_accessibility_and_preference_aware_vocabulary_audio():
    screen = (
        FEATURE / "presentation" / "app_settings_screen.dart"
    ).read_text(encoding="utf-8")
    app = (ROOT / "lib" / "ui_v35" / "app.dart").read_text(encoding="utf-8")
    vocabulary = (
        ROOT / "lib" / "ui_v35" / "learning" / "vocabulary_page.dart"
    ).read_text(encoding="utf-8")

    assert "cognitiveAccessibilityEnabled" in screen
    assert "onCognitiveAccessibilityChanged" in screen
    assert "neuroSettings.setEnabled" in app
    assert "audioRuntime.play" in vocabulary
    assert "AudioRequest(" in vocabulary
    assert "SafeTtsController" not in vocabulary
