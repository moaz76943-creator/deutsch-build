from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

PRESENTATION = (
    "lib/features/app_settings/presentation/app_settings_screen.dart",
    "lib/features/app_settings/presentation/widgets/glass_action_row.dart",
    "lib/features/app_settings/presentation/widgets/glass_slider_tile.dart",
    "lib/ui_v35/account_auth_page.dart",
)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def presentation_source() -> str:
    return "\n".join(read(path) for path in PRESENTATION)


def test_settings_and_profile_surfaces_use_canonical_glass_only():
    source = presentation_source()

    assert source.count("AppGlassCard(") >= 8
    assert re.search(r"(?<![A-Za-z])Card\(", source) is None
    for path in PRESENTATION:
        assert len(read(path).splitlines()) < 1000, path


def test_settings_and_profile_use_cairo_and_explicit_rtl_boundaries():
    source = presentation_source()

    assert source.count("AppDirectionalText(") >= 30
    assert source.count("AppTypography.") >= 30
    assert "TextDirection.rtl" in read(
        "lib/features/app_settings/presentation/app_settings_screen.dart"
    )
    assert "TextDirection.rtl" in read("lib/ui_v35/account_auth_page.dart")
    assert "languageCode: 'ar'" in source
    assert "fontFamily: 'Inter'" not in source
    assert "fontFamily: 'Tajawal'" not in source


def test_storage_management_remains_local_and_reuses_existing_repository():
    settings = read(
        "lib/features/app_settings/presentation/app_settings_screen.dart"
    )
    notifier = read(
        "lib/features/app_settings/application/settings_notifier.dart"
    )
    repository = read(
        "lib/features/app_settings/data/local_settings_repository.dart"
    )
    local_source = read(
        "lib/features/app_settings/data/preferences_settings_local_data_source.dart"
    )

    assert "notifier.clearCache()" in settings
    assert "notifier.resetLearningProgress(" in settings
    assert "_repository.clearCache()" in notifier
    assert "LocalSettingsRepository" in repository
    assert "PreferencesSettingsLocalDataSource" in local_source
    assert "PreferencesService" in local_source

    combined = settings + repository + local_source
    assert "http://" not in combined
    assert "https://" not in combined
    assert "package:http/" not in combined
    assert "dart:io" not in combined


def test_profile_presentation_does_not_own_transport_or_credentials():
    profile = read("lib/ui_v35/account_auth_page.dart")

    assert "AuthSessionController" in profile
    assert "http://" not in profile
    assert "https://" not in profile
    assert "package:http/" not in profile
    assert "dart:io" not in profile
    assert "password" not in profile.lower()


def test_settings_profile_pr_does_not_require_android_permissions():
    source = presentation_source()

    assert "android.permission." not in source
