from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_DEPS = ROOT / "lib/services/app_dependencies.dart"
MAIN = ROOT / "lib/main.dart"
APP = ROOT / "lib/ui_v35/app.dart"
LEARNING = ROOT / "lib/ui_v35/learning_pages.dart"
PROGRESS = ROOT / "lib/ui_v35/progress_pages.dart"


def test_app_dependencies_owns_explicit_content_corpus():
    text = APP_DEPS.read_text(encoding="utf-8")
    assert "import '../core/content_contract.dart';" in text
    assert "final List<T> corpus;" in text
    assert "required this.corpus" in text


def test_main_composes_content_once():
    text = MAIN.read_text(encoding="utf-8")
    assert "final activeLanguagePack = runtime.languagePack;" in text
    assert "final contentPack = activeLanguagePack.contentPack;" in text
    assert "final corpus = contentPack.items;" in text
    assert "contentPack.items.toList(growable: false)" not in text
    assert "corpus: corpus," in text


def test_v35_app_receives_corpus_without_content_engine_lookup():
    text = APP.read_text(encoding="utf-8")
    assert "ContentEngine.instance" not in text
    assert "widget.dependencies.corpus.length" in text


def test_v35_learning_pages_use_injected_corpus():
    text = LEARNING.read_text(encoding="utf-8")
    assert "ContentEngine.instance" not in text
    assert "final List<ContentItem> corpus;" in text


def test_v35_progress_pages_use_injected_corpus():
    text = PROGRESS.read_text(encoding="utf-8")
    assert "ContentEngine.instance" not in text
    assert "final List<ContentItem> corpus;" in text


def test_v35_ui_does_not_construct_search_or_verb_services():
    for path in (LEARNING, PROGRESS, APP):
        text = path.read_text(encoding="utf-8")
        assert "SearchIndex(" not in text
        assert "VerbIndex.instance" not in text
