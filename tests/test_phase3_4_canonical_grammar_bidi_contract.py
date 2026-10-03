from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_production_grammar_route_uses_repository_backed_sqlite_ui():
    app = read("lib/ui_v35/app.dart")
    assert "import 'grammar/grammar_hub_page.dart';" in app
    assert "GrammarHubPage(" in app
    assert "dependencies: widget.dependencies" in app
    assert "import 'pages/grammar_hub_page.dart';" not in app


def test_grammar_service_has_no_independent_hardcoded_seed_logic():
    service = read("lib/services/grammar_hub_service.dart")
    assert "CanonicalGrammarCompiler" in service
    assert "_seedInitialData" not in service
    assert "CREATE TABLE grammar_topics" not in service


def test_legacy_grammar_data_is_only_a_bridge_to_canonical_catalog():
    bridge = read("lib/data/grammar_topics.dart")
    assert "CanonicalGrammarCatalog.allTopics" in bridge
    assert "GrammarTopic(" not in bridge


def test_bidi_primitives_are_modular_and_language_direction_is_explicit():
    directional = read("lib/core/text/directional_text.dart")
    boundary = read("lib/core/text/bidi_boundary.dart")
    assert "DirectionalText.german" in directional
    assert "AppTextDirection.ltr" in directional
    assert "DirectionalText.arabic" in directional
    assert "AppTextDirection.rtl" in directional
    assert "\\u2066" in boundary
    assert "\\u2067" in boundary
    assert "\\u2069" in boundary
