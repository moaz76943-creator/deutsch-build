import pytest

from tools.agents.localization_agent import (
    LocalizationAgentError,
    audit_arb,
    icu_argument_names,
    synchronize_arb,
)
from tools.agents.lexicon_auditor_agent import audit_entry


def _base():
    return {
        "@@locale": "en",
        "items": "{count, plural, one {One item} other {{count} items}}",
        "@items": {
            "description": "item count",
            "placeholders": {"count": {"type": "int"}},
            "layout": {"maxWidthEm": 40},
        },
    }


def _arabic():
    return {
        "@@locale": "ar",
        "items": "{count, plural, one {عنصر واحد} other {{count} عناصر}}",
        "@items": {
            "translationStrategy": "contextual",
            "reviewStatus": "reviewed",
        },
    }


def test_icu_plural_branch_text_is_not_treated_as_placeholder():
    assert icu_argument_names(_base()["items"]) == {"count"}
    assert icu_argument_names(_arabic()["items"]) == {"count"}
    assert audit_arb(_base(), _arabic()).is_valid


def test_sync_rejects_declared_locale_mismatch_before_relabeling():
    with pytest.raises(
        LocalizationAgentError,
        match="target locale mismatch",
    ):
        synchronize_arb(
            _base(),
            _arabic(),
            locale_code="de",
        )


def test_sync_preserves_canonical_metadata_over_stale_target_metadata():
    target = _arabic()
    target["@items"]["placeholders"] = {
        "count": {"type": "String"}
    }
    target["@items"]["layout"] = {"maxWidthEm": 999}

    synced = synchronize_arb(
        _base(),
        target,
        locale_code="ar",
    )

    assert synced["@items"]["placeholders"] == {
        "count": {"type": "int"}
    }
    assert synced["@items"]["layout"] == {"maxWidthEm": 40}


def _canonical_entry(classification="common"):
    return {
        "id": "noun.bahnhof",
        "surface": "Bahnhof",
        "partOfSpeech": "noun",
        "direction": "ltr",
        "fields": {
            "canonical": {
                "senseId": "railway.station",
                "register": "neutral",
                "cefr": "A1",
                "semanticTags": ["travel"],
                "noun": {
                    "gender": "masculine",
                    "plural": "Bahnhöfe",
                    "declensionClass": "strong",
                    "caseForms": {
                        "nominativeSingular": "Bahnhof",
                        "accusativeSingular": "Bahnhof",
                        "dativeSingular": "Bahnhof",
                        "genitiveSingular": "Bahnhofs",
                    },
                },
            },
            "lexiconAudit": {
                "usageBand": "alltag",
                "usageEvidence": [
                    {
                        "source": "Duden",
                        "classification": classification,
                    }
                ],
                "translation": {
                    "targetLanguage": "ar",
                    "text": "محطة القطار",
                    "strategy": "contextual",
                    "senseId": "railway.station",
                },
                "connotations": ["neutral"],
                "idioms": [],
            },
        },
    }


def test_canonical_shared_core_lexicon_shape_is_consumed_directly():
    report = audit_entry(
        _canonical_entry(),
        language_code="de",
    )
    assert report.is_valid, report.errors


def test_trusted_dictionary_marked_rare_does_not_certify_alltag():
    report = audit_entry(
        _canonical_entry("rare"),
        language_code="de",
    )
    assert "usage.authority_required" in {
        issue.code for issue in report.errors
    }
