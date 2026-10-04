from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase10_composition_root_owns_unified_audio_runtime():
    main = read("lib/main.dart")
    deps = read("lib/services/app_dependencies.dart")
    assert "OfflineAudioRuntime(" in main
    assert "activeLanguagePack.speechProfile" in main
    assert "AndroidRecordedAudioPlayer()" in main
    assert "audioRuntime: audioRuntime" in main
    assert "IAudioRuntime audioRuntime" in deps


def test_phase10_uses_current_declared_audio_dependencies_and_offline_assets():
    pubspec = read("pubspec.yaml")
    assert "flutter_tts: ^4.2.5" in pubspec
    assert "audioplayers: ^6.8.1" in pubspec
    assert "just_audio:" not in pubspec
    assert "content/german/audio_manifest.json" in pubspec
    assert "content/german/audio/" in pubspec

    runtime = read("lib/features/audio/offline_audio_runtime.dart")
    assert "IAudioRuntime" in runtime
    assert "recordedPlayer.playAsset" in runtime
    assert "package:audioplayers/" not in runtime


def test_phase10_android_declares_tts_discovery_and_local_player_bridge():
    manifest = read("android/app/src/main/AndroidManifest.xml")
    activity = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt"
    )
    player = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/"
        "AndroidRecordedAudioPlayer.kt"
    )
    assert "android.intent.action.TTS_SERVICE" in manifest
    assert "AndroidRecordedAudioPlayer.CHANNEL_NAME" in activity
    assert "MediaPlayer" in player
    assert "getLookupKeyForAsset" in player
    assert "http" not in player.lower()
    assert "android.permission.INTERNET" not in manifest


def test_phase10_recorded_audio_is_manifest_driven_not_path_guessed():
    catalog = read("lib/features/audio/data/audio_manifest_catalog.dart")
    legacy = read(
        "lib/features/audio/domain/resolvers/audio_path_resolver.dart"
    )
    runtime = read("lib/features/audio/offline_audio_runtime.dart")
    assert "recordedAssetFor" in catalog
    assert "recordedPlayer.playAsset" in runtime
    assert "AudioPathResolver" not in runtime
    assert "_baseAssetPath" in legacy


def test_phase10_keeps_ui_files_under_limit():
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_v11_hybrid_pronunciation_uses_existing_offline_runtime():
    service = read("lib/features/audio/hybrid_pronunciation_service.dart")
    runtime = read("lib/features/audio/offline_audio_runtime.dart")
    tts = read("lib/core/infrastructure/audio/flutter_tts_audio_engine.dart")
    lab = read("lib/features/pronunciation/pronunciation_lab_service.dart")

    assert "IAudioRuntime" in service
    assert "AudioVariant.pronunciation" in service
    assert "recordedPlayer.playAsset" in runtime
    assert "ttsEngine.probe" in runtime
    assert "_isStrictlyOfflineVoice" in tts
    assert "HybridPronunciationService" in lab
