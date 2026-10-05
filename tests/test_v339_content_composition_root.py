from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"


def test_production_root_uses_indexed_pack_runtime_as_content_authority():
    text = MAIN.read_text(encoding="utf-8")
    assert "ActivePackRuntimeProvider(" in text
    assert "final repository = resolution.corpusRepository;" in text
    assert "repository.fetchPage(" in text
    assert "resolvedCorpusSession.initialCorpus" in text
    assert "ContentEngine.instance" not in text
    assert "VerbIndex.instance" not in text


def test_initial_corpus_is_bounded_and_immutable():
    text = MAIN.read_text(encoding="utf-8")
    assert "const initialWindowSize = 128;" in text
    assert "limit: initialWindowSize" in text
    assert "List<LearningContent>.unmodifiable(initialCorpus)" in text


def test_production_shell_receives_corpus_explicitly():
    text = MAIN.read_text(encoding="utf-8")
    assert "Phase3ProductionShell(" in text
    assert "corpus: widget.corpus" in text
    assert "final List<LearningContent> corpus;" in text
