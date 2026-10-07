from pathlib import Path
import shutil
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[2]

DYNAMIC = ROOT / "lib/core/l10n/dynamic_l10n_engine.dart"
MODELS = ROOT / "lib/core/l10n/l10n_models.dart"
EXPLAIN = ROOT / "lib/core/explain_why/deterministic_explain_why_engine.dart"
LIFE = ROOT / "lib/features/phase3_integration/life_feature_runtime.dart"
L10N_CONTRACT = ROOT / "lib/core/l10n/l10n_contract.dart"

CHANGED_PRODUCTION_FILES = (
    DYNAMIC,
    MODELS,
    EXPLAIN,
    LIFE,
    L10N_CONTRACT,
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _method_slice(source: str, start_marker: str, end_marker: str) -> str:
    start = source.index(start_marker)
    end = source.index(end_marker, start)
    return source[start:end]


def test_dynamic_l10n_public_resolution_api_is_explicitly_ui_only():
    source = _read(DYNAMIC)
    models = _read(MODELS)

    assert "String uiText(" in source
    assert "UiL10nResolvedText resolveUi(" in source
    assert "String text(" not in source
    assert "L10nResolvedText resolve(" not in source
    assert "findMessage(" not in source

    assert "final class UiL10nResolvedText" in models
    assert "final class L10nResolvedText" not in models


def test_learning_explanations_do_not_depend_on_ui_localization_runtime():
    source = _read(EXPLAIN)

    assert "../l10n/dynamic_l10n_engine.dart" not in source
    assert "../localization/localization_state.dart" not in source
    assert "DynamicL10nEngine" not in source
    assert "required L10nDictionary dictionary" in source
    assert "_dictionary.require(key)" in source
    assert "message.render(arguments: request.arguments)" in source


def test_directional_learning_literals_bypass_ui_dictionary_and_fallback():
    source = _read(LIFE)

    ui_method = _method_slice(
        source,
        "String resolveUiLiteral(",
        "String resolveDirectionalLiteral(",
    )
    directional_method = _method_slice(
        source,
        "String resolveDirectionalLiteral(",
        "bool isTargetLanguage(",
    )

    assert "_engine.uiText(key)" in ui_method
    assert "_ensureUiLiteral(" in ui_method

    assert "_engine." not in directional_method
    assert "_ensureUiLiteral(" not in directional_method
    assert "AppLocale.parse(languageCode);" in directional_method
    assert "return raw;" in directional_method


def test_l10n_contract_names_ui_fallback_explicitly():
    source = _read(L10N_CONTRACT)

    assert "engine.uiText(" in source
    assert "engine.resolveUi(" in source
    assert "engine.text(" not in source
    assert "engine.resolve(" not in source


def test_task7_behavior_contract_runs_when_dart_is_available():
    dart = shutil.which("dart")
    if dart is None:
        pytest.skip("Dart SDK is unavailable in this verification environment")

    contract = ROOT / "test/quality_gate/localization_boundary_behavior_test.dart"
    result = subprocess.run(
        [dart, "run", str(contract)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        timeout=60,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_task7_changed_production_files_respect_file_ceiling():
    for path in CHANGED_PRODUCTION_FILES:
        assert len(_read(path).splitlines()) <= 1000, path
