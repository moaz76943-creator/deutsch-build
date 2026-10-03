from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "stories"


def test_story_feature_files_respect_line_limit():
    assert FEATURE.exists()
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_domain_contains_required_models_and_stays_flutter_free():
    domain = FEATURE / "domain"
    text = "\n".join(p.read_text(encoding="utf-8") for p in domain.rglob("*.dart"))
    for token in (
        "class StoryItem",
        "class StoryParagraph",
        "class StoryComprehensionQuestion",
        "abstract interface class StoryRepository",
    ):
        assert token in text
    assert "package:flutter/" not in text


def test_presentation_uses_glass_tokens_and_has_no_audio_plugins():
    presentation = FEATURE / "presentation"
    text = "\n".join(
        p.read_text(encoding="utf-8") for p in presentation.rglob("*.dart")
    )
    assert "AppGlassCard" in text
    assert "AppColors" in text
    assert "AppTypography" in text
    for banned in ("flutter_tts", "audioplayers", "speech_to_text", "just_audio"):
        assert banned not in text


def test_local_data_has_two_beginner_stories_and_questions():
    text = (FEATURE / "data" / "local_story_repository.dart").read_text(
        encoding="utf-8"
    )
    assert text.count("StoryItem(") >= 2
    assert "StoryLevel.a1" in text
    assert "StoryLevel.a2" in text
    assert text.count("StoryComprehensionQuestion(") >= 4


def test_reader_notifier_owns_word_reveal_translation_and_scoring():
    text = (FEATURE / "application" / "story_reader_notifier.dart").read_text(
        encoding="utf-8"
    )
    for token in (
        "toggleWordMeaning",
        "toggleParagraphTranslation",
        "answerQuestion",
        "comprehensionScorePercent",
    ):
        assert token in text
