from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "lib/main.dart").read_text(encoding="utf-8")


def test_startup_renders_before_heavy_corpus_activation():
    main_body = MAIN[
        MAIN.index("Future<void> main() async"):
        MAIN.index("Future<_ActivatedPhase3App> _activateProduction")
    ]
    assert "runApp(const _RenderFirstBootstrapApp())" in main_body
    assert "_resolveActiveCorpusSession" not in main_body
    assert "fetchPage(" not in main_body


def test_activation_resolves_a_bounded_initial_indexed_window():
    assert "await _resolveActiveCorpusSession(prefs)" in MAIN
    assert "const initialWindowSize = 128;" in MAIN
    assert "repository.fetchPage(" in MAIN
    assert "limit: initialWindowSize" in MAIN
    assert "List<LearningContent>.unmodifiable(initialCorpus)" in MAIN


def test_startup_does_not_rematerialize_full_content_pack():
    assert "contentPack.items.toList(growable: false)" not in MAIN
    assert "ContentEngine.instance" not in MAIN
    assert "VerbIndex.instance" not in MAIN
