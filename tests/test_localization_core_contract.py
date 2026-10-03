from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [
    "lib/core/localization/locale_direction_provider.dart",
    "lib/core/localization/locale_provider.dart",
    "lib/core/localization/localization_state.dart",
    "lib/core/localization/german_article_style.dart",
    "lib/core/localization/localization.dart",
]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def test_localization_core_is_platform_neutral_and_below_file_ceiling():
    for rel in FILES:
        text = read(rel)
        assert "package:flutter" not in text
        assert len(text.splitlines()) < 1000


def test_locale_direction_provider_has_explicit_rtl_language_set():
    text = read("lib/core/localization/locale_direction_provider.dart")
    assert "AppTextDirection" in text
    for code in ("'ar'", "'fa'", "'he'", "'ur'", "'ps'"):
        assert code in text


def test_user_source_target_locales_are_separate_contract_fields():
    text = read("lib/core/localization/localization_state.dart")
    assert "userLocale" in text
    assert "sourceLocale" in text
    assert "targetLocale" in text
    assert "switchUserLocale" in text
    assert "switchLearningPair" in text


def test_german_article_palette_is_fixed_and_language_isolated():
    text = read("lib/core/localization/german_article_style.dart")
    for article in ("der", "die", "das"):
        assert article in text
    assert "0xFF1976D2" in text
    assert "0xFFD32F2F" in text
    assert "0xFF388E3C" in text
    assert "German article styling is only valid for German" in text
