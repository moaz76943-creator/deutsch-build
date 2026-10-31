from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_vocabulary_surface_uses_canonical_adaptive_glass_and_audio_controls():
    source = read("lib/ui_v35/learning/vocabulary_page.dart")
    library = read("lib/ui_v35/learning_pages.dart")

    assert "../design_system/app_glass_card.dart" in library
    assert "../design_system/app_audio_button.dart" in library
    assert "../design_system/app_typography.dart" in library
    assert source.count("AppGlassCard(") >= 5
    assert source.count("AppAudioButton(") >= 3
    assert re.search(r"(?<![A-Za-z])Card\(", source) is None
    assert "Icons.volume_up" not in source
    assert "package:flutter_tts/" not in source
    assert "package:speech_to_text/" not in source


def test_vocabulary_surface_preserves_direction_and_article_semantics():
    source = read("lib/ui_v35/learning/vocabulary_page.dart")

    assert "languageCode: _targetLanguageCode" in source
    assert "languageCode: 'ar'" in source
    assert "case 'der':" in source and "0xFF2563EB" in source
    assert "case 'die':" in source and "0xFFDC2626" in source
    assert "case 'das':" in source and "0xFF16A34A" in source
    assert "AppTypography." in source


def test_vocabulary_learning_action_stays_on_canonical_repository_srs_path():
    source = read("lib/ui_v35/learning/vocabulary_page.dart")
    repository = read("lib/services/repository.dart")

    assert "_openLearningSession" in source
    assert "SingleItemSession(" in source
    assert "repo: widget.repo" in source
    assert "await widget.repo.record(" not in source
    assert "unifiedSrsScheduler.schedule(" not in source
    assert "await unifiedSrsScheduler.schedule(" in repository
