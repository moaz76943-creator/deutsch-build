from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_language_pack_exposes_content_intelligence_contract():
    source = (ROOT / 'lib/language/language_pack.dart').read_text()
    assert 'LanguageContentIntelligence get contentIntelligence;' in source


def test_german_language_pack_owns_content_intelligence_implementation():
    source = (ROOT / 'lib/language/german/german_language_pack.dart').read_text()
    assert "german_content_intelligence.dart" in source
    assert 'LanguageContentIntelligence get contentIntelligence' in source
    assert 'GermanContentIntelligence()' in source


def test_content_intelligence_service_does_not_own_language_heuristics():
    source = (ROOT / 'lib/services/content_intelligence.dart').read_text()
    assert "import '../language/german/german_content_intelligence.dart';" not in source
    assert "import 'text_normalizer.dart';" not in source
    assert "topic.contains('المستوى a2')" not in source
    assert "endsWith('en')" not in source


def test_shared_learning_services_require_language_intelligence():
    learning = (ROOT / 'lib/services/learning_intelligence.dart').read_text()
    engine = (ROOT / 'lib/services/learning_engine.dart').read_text()
    dashboard = (ROOT / 'lib/services/mastery_dashboard.dart').read_text()
    assert 'required LanguageContentIntelligence contentIntelligence' in learning
    assert 'required LanguageContentIntelligence contentIntelligence' in engine
    assert 'required LanguageContentIntelligence contentIntelligence' in dashboard
    assert 'ContentIntelligence.profile' not in learning
    assert 'ContentIntelligence.profile' not in engine
    assert 'ContentIntelligence.cachedReport' not in dashboard
