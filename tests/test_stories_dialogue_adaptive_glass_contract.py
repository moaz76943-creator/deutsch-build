from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

SURFACES = (
    "lib/features/stories/presentation/stories_catalog_screen.dart",
    "lib/features/stories/presentation/story_reader_screen.dart",
    "lib/features/dialogues/presentation/dialogue_chat_view.dart",
)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def surface_source() -> str:
    return "\n".join(read(path) for path in SURFACES)


def test_story_and_dialogue_surfaces_use_canonical_glass_only():
    source = surface_source()

    assert source.count("AppGlassCard(") >= 8
    assert re.search(r"(?<![A-Za-z])Card\(", source) is None
    for path in SURFACES:
        assert len(read(path).splitlines()) < 1000, path


def test_story_and_dialogue_audio_uses_canonical_button_and_runtime_boundary():
    source = surface_source()
    story_reader = read("lib/features/stories/presentation/story_reader_screen.dart")
    story_data = read("lib/features/stories/data/story_audio_runtime_adapter.dart")
    story_port = read("lib/features/stories/domain/story_audio_port.dart")
    dialogue = read("lib/features/dialogues/presentation/dialogue_chat_view.dart")
    dialogue_data = read("lib/features/dialogues/data/dialogue_repository.dart")

    assert source.count("AppAudioButton(") >= 3
    assert "StoryAudioPort" in story_reader
    assert "IAudioRuntime" not in story_reader
    assert "AudioRequest" not in story_reader
    assert "StoryAudioPort" in story_port
    assert "IAudioRuntime" in story_data
    assert "AudioRequest(" in story_data
    assert "DialogueAudioPort" in dialogue
    assert "DialogueAudioRuntimeAdapter" in dialogue_data
    assert "IAudioRuntime" in dialogue_data

    forbidden = (
        "package:flutter_tts/",
        "package:speech_to_text/",
        "package:audioplayers/",
        "package:just_audio/",
        "FlutterTts(",
        "SpeechToText(",
        "AudioPlayer(",
    )
    for token in forbidden:
        assert token not in source


def test_story_and_dialogue_copy_uses_cairo_and_explicit_language_direction():
    source = surface_source()

    assert source.count("AppDirectionalText(") >= 18
    assert source.count("AppTypography.") >= 24
    assert "languageCode: 'ar'" in source
    assert "languageCode: 'de'" in source
    assert "TextDirection.rtl" in source
    assert "fontFamily: 'Inter'" not in source
    assert "fontFamily: 'Tajawal'" not in source


def test_story_reader_reuses_existing_notifier_and_keeps_content_offline():
    story_reader = read("lib/features/stories/presentation/story_reader_screen.dart")
    notifier = read("lib/features/stories/application/story_reader_notifier.dart")
    data = read("lib/features/stories/data/local_story_repository.dart")
    source = surface_source()

    assert "StoryReaderNotifier" in story_reader
    assert "toggleWordMeaning" in notifier
    assert "toggleParagraphTranslation" in notifier
    assert "answerQuestion" in notifier
    assert "LocalStoryRepository" in data
    assert "http://" not in source
    assert "https://" not in source


def test_this_surface_does_not_add_android_permission_usage():
    source = surface_source()

    assert "android.permission." not in source
