from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "prepositions_arena"
PRESENTATION = FEATURE / "presentation"
DOMAIN = FEATURE / "domain"


def test_prepositions_arena_files_stay_below_strict_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_domain_owns_case_logic_without_flutter_ui_imports():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in DOMAIN.rglob("*.dart")
    )
    assert "PrepositionCaseRules" in text
    assert "GermanGrammaticalCase" in text
    assert "package:flutter/material.dart" not in text


def test_presentation_uses_canonical_glass_and_article_colors():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    for token in (
        "AppGlassCard",
        "AppColors",
        "AppTypography",
        "AppColors.articleDer",
        "AppColors.articleDie",
        "AppColors.articleDas",
    ):
        assert token in text


def test_drag_drop_card_is_interactive_and_has_no_grammar_table():
    text = (
        PRESENTATION / "widgets" / "drag_drop_case_card_widget.dart"
    ).read_text(encoding="utf-8")
    assert "Draggable<String>" in text
    assert "DragTarget<String>" in text
    assert "PrepositionCaseRules" not in text


def test_repository_contains_only_a1_a2_bank_contract():
    text = (
        FEATURE / "data" / "local_prepositions_repository.dart"
    ).read_text(encoding="utf-8")
    assert "LocalPrepositionsRepository" in text
    assert "'A1'" in text
    assert "'A2'" in text
    assert "'B1'" not in text
