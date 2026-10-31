from tools.agents.lexicon_auditor_agent import (
    GERMAN_ARTICLE_COLOR_TOKENS,
    audit_entry,
)


def _entry():
    return {
        "lemma": "Bahnhof",
        "language": "de",
        "partOfSpeech": "noun",
        "usageBand": "alltag",
        "register": "neutral",
        "article": "der",
        "gender": "masculine",
        "articleColorToken": "germanArticle.der",
        "usageEvidence": [
            {"source": "Duden", "classification": "common"},
            {"source": "Goethe", "classification": "A1-A2"},
        ],
        "translation": {
            "targetLanguage": "ar",
            "text": "محطة القطار",
            "strategy": "contextual",
            "senseId": "railway.station",
        },
        "connotations": ["neutral"],
        "idioms": [],
    }


def test_common_contextual_entry_with_german_article_passes():
    report = audit_entry(_entry())
    assert report.is_valid
    assert GERMAN_ARTICLE_COLOR_TOKENS == {
        "der": "germanArticle.der",
        "die": "germanArticle.die",
        "das": "germanArticle.das",
    }


def test_rare_or_archaic_usage_is_rejected():
    entry = _entry()
    entry["usageBand"] = "rare"
    entry["register"] = "archaic"
    report = audit_entry(entry)
    codes = {issue.code for issue in report.errors}
    assert "usage.not_alltag" in codes
    assert "register.forbidden" in codes


def test_known_false_friend_is_rejected_for_english_target():
    entry = _entry()
    entry.update({"lemma": "bekommen", "partOfSpeech": "verb"})
    entry.pop("article")
    entry.pop("gender")
    entry.pop("articleColorToken")
    entry["translation"] = {
        "targetLanguage": "en",
        "text": "become",
        "strategy": "contextual",
        "senseId": "receive.obtain",
    }
    report = audit_entry(entry)
    assert "false_friend.detected" in {issue.code for issue in report.errors}


def test_german_articles_cannot_leak_into_other_language_rules():
    entry = _entry()
    entry["language"] = "ar"
    entry["translation"]["targetLanguage"] = "de"
    report = audit_entry(entry)
    assert "article.non_german" in {issue.code for issue in report.errors}


def test_article_gender_and_color_token_are_fixed():
    entry = _entry()
    entry["article"] = "die"
    report = audit_entry(entry)
    codes = {issue.code for issue in report.errors}
    assert "article.gender_mismatch" in codes
    assert "article.color_token_mismatch" in codes


def test_separable_verb_contract_is_structural_and_explicit():
    entry = _entry()
    entry.update(
        {
            "lemma": "aufstehen",
            "partOfSpeech": "verb",
            "separable": True,
            "separablePrefix": "auf",
            "stem": "stehen",
        }
    )
    entry.pop("article")
    entry.pop("gender")
    entry.pop("articleColorToken")
    entry["translation"] = {
        "targetLanguage": "ar",
        "text": "ينهض",
        "strategy": "contextual",
        "senseId": "rise.from_rest",
    }
    report = audit_entry(entry)
    assert report.is_valid


def test_idiom_requires_idiomatic_or_cultural_equivalent_strategy():
    entry = _entry()
    entry["idioms"] = [
        {
            "expression": "den Faden verlieren",
            "translation": "يفقد خيط الحديث",
            "strategy": "literal",
        }
    ]
    report = audit_entry(entry)
    assert "idiom.literal_forbidden" in {issue.code for issue in report.errors}


def test_sensitive_connotation_requires_review_and_usage_note():
    entry = _entry()
    entry["connotations"] = ["vulgar"]
    report = audit_entry(entry)
    assert "connotation.review_required" in {
        issue.code for issue in report.errors
    }
    entry["reviewStatus"] = "reviewed"
    entry["usageNote"] = (
        "Use only when explicitly teaching register and social context."
    )
    assert audit_entry(entry).is_valid
