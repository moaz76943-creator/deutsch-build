from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
MAIN = ROOT / "lib/main.dart"


def test_modern_ui_does_not_construct_app_wide_dependencies():
    offenders = []
    app_wide = (
        "ContentEngine(",
        "BackendTransportFactory.",
        "ActivePackRuntimeProvider(",
    )
    for path in (LIB / "ui_v35").rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        for token in app_wide:
            if token in text:
                offenders.append((str(path.relative_to(ROOT)), token))
    assert offenders == []


def test_main_is_the_pack_and_phase3_composition_root():
    text = MAIN.read_text(encoding="utf-8")
    assert "const activeLanguagePack = GermanLanguagePack();" in text
    assert "ActivePackRuntimeProvider(" in text
    assert "await _resolveActiveCorpusSession(prefs)" in text
    assert "OfflineAudioRuntime(" in text
    assert "QuickReviewBindings.fromIndexedSrsCorpus" in text
    assert "ExplainerBindings.fromIndexedSrsCorpus" in text
    assert "Phase3ProductionShell(" in text
    assert "AppDependencies<ContentItem>(" not in text
    assert "SearchIndex(" not in text


def test_legacy_ui_has_no_global_content_or_verb_lookup():
    text = (LIB / "ui/app.dart").read_text(encoding="utf-8")
    assert "ContentEngine.instance" not in text
    assert "VerbIndex.instance" not in text
