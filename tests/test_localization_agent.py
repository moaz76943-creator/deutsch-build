import pytest

from tools.agents.localization_agent import (
    LocalizationAgentError,
    audit_arb,
    build_translation_template,
    synchronize_arb,
    text_direction_for,
)


def _base():
    return {
        "@@locale": "en",
        "welcome": "Welcome, {name}!",
        "@welcome": {
            "description": "Greeting shown inside a glass card",
            "placeholders": {"name": {"type": "String"}},
            "layout": {"maxWidthEm": 32},
        },
        "continueLabel": "Continue",
        "@continueLabel": {
            "description": "Primary action",
            "layout": {"maxWidthEm": 14},
        },
    }


def _arabic():
    return {
        "@@locale": "ar",
        "welcome": "أهلًا، {name}!",
        "@welcome": {
            "translationStrategy": "contextual",
            "reviewStatus": "reviewed",
            "layout": {"maxWidthEm": 32},
        },
        "continueLabel": "متابعة",
        "@continueLabel": {
            "translationStrategy": "cultural_equivalent",
            "reviewStatus": "reviewed",
            "layout": {"maxWidthEm": 14},
        },
    }


def test_direction_supports_rtl_and_ltr_without_german_pivot():
    assert text_direction_for("ar-JO") == "rtl"
    assert text_direction_for("fa") == "rtl"
    assert text_direction_for("de-DE") == "ltr"
    assert text_direction_for("en") == "ltr"


def test_contextual_reviewed_arb_passes_strict_audit():
    report = audit_arb(_base(), _arabic(), locale_code="ar")
    assert report.is_valid
    assert report.direction == "rtl"
    assert report.errors == ()


def test_literal_translation_strategy_is_rejected():
    target = _arabic()
    target["@continueLabel"]["translationStrategy"] = "literal"
    report = audit_arb(_base(), target, locale_code="ar")
    assert not report.is_valid
    assert "translation.literal_forbidden" in {
        issue.code for issue in report.errors
    }


def test_placeholder_drift_is_rejected():
    target = _arabic()
    target["welcome"] = "أهلًا!"
    report = audit_arb(_base(), target, locale_code="ar")
    assert "placeholder.mismatch" in {issue.code for issue in report.errors}


def test_glass_layout_width_budget_fails_closed_on_overflow_risk():
    target = _arabic()
    target["continueLabel"] = (
        "هذه عبارة طويلة جدًا لا يمكن أن تلائم بطاقة صغيرة بأمان"
    )
    target["@continueLabel"]["layout"] = {"maxWidthEm": 8}
    report = audit_arb(_base(), target, locale_code="ar")
    assert "layout.overflow_risk" in {issue.code for issue in report.errors}


def test_template_generation_never_copies_source_text_as_translation():
    template = build_translation_template(_base(), locale_code="de")
    assert template["@@locale"] == "de"
    assert template["welcome"] == ""
    assert template["@welcome"]["reviewStatus"] == "candidate"
    assert template["@welcome"]["translationStrategy"] == "contextual"


def test_synchronization_reorders_to_base_and_fails_on_missing_translation():
    target = _arabic()
    target["unused"] = "قديم"
    synchronized = synchronize_arb(_base(), target, locale_code="ar")
    assert list(k for k in synchronized if not k.startswith("@")) == [
        "welcome",
        "continueLabel",
    ]
    broken = _arabic()
    broken.pop("continueLabel")
    with pytest.raises(LocalizationAgentError, match="missing localization keys"):
        synchronize_arb(_base(), broken, locale_code="ar")
