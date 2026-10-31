from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_word_profile_uses_injected_language_normalizer_and_neutral_fields():
    text = (ROOT / "lib/services/word_profile_service.dart").read_text()
    assert "LanguageTextNormalizer" in text
    assert "item.german" not in text
    assert "item.sentence" not in text
    assert "import 'text_normalizer.dart';" not in text


def test_reading_practice_uses_language_quality_and_neutral_fields():
    text = (ROOT / "lib/services/reading_practice.dart").read_text()
    assert "LanguageContentQuality" in text
    assert "x.german" not in text
    assert "x.sentence" not in text
    assert "import 'quality.dart';" not in text


def test_learning_engine_accepts_language_content_quality():
    text = (ROOT / "lib/services/learning_engine.dart").read_text()
    assert "LanguageContentQuality" in text
    assert "ContentQuality.issues" not in text
    assert "ContentQuality.isLearnable" not in text


def test_vocabulary_coach_accepts_language_content_quality():
    text = (ROOT / "lib/services/vocabulary_coach.dart").read_text()
    assert "LanguageContentQuality" in text
    assert "ContentQuality.isLearnable" not in text
    assert "item.german" not in text
