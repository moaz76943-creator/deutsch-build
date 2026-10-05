from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"


def test_phase3_root_does_not_construct_legacy_search_graph():
    text = MAIN.read_text(encoding="utf-8")
    assert "SearchIndex(" not in text
    assert "SearchIndex.instance" not in text
    assert "VerbIndex.instance" not in text
    assert "AppDependencies<ContentItem>(" not in text


def test_phase3_root_uses_indexed_corpus_authority():
    text = MAIN.read_text(encoding="utf-8")
    assert "ActivePackRuntimeProvider(" in text
    assert "resolution.corpusRepository" in text
    assert "QuickReviewBindings.fromIndexedSrsCorpus" in text
    assert "ExplainerBindings.fromIndexedSrsCorpus" in text


def test_production_shell_receives_bounded_corpus_directly():
    text = MAIN.read_text(encoding="utf-8")
    assert "Phase3ProductionShell(" in text
    assert "corpus: widget.corpus" in text
    assert "const initialWindowSize = 128;" in text
