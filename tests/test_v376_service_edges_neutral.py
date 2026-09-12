from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_repository_and_profile_use_neutral_content_contract():
    repository = read('lib/services/repository.dart')
    profile = read('lib/services/word_profile_service.dart')
    assert "import '../core/content_contract.dart';" in repository
    assert "import '../core/content_contract.dart';" in profile
    assert 'ContentItem item' not in repository
    assert 'ContentItem item' not in profile


def test_quality_facade_is_not_used_by_shared_learning_services():
    for rel in [
        'lib/services/learning_engine.dart',
        'lib/services/vocabulary_coach.dart',
        'lib/services/mastery_dashboard.dart',
        'lib/services/word_profile_service.dart',
    ]:
        src = read(rel)
        assert 'ContentQuality.' not in src
        assert "import 'quality.dart'" not in src
        assert 'TextNormalizer.' not in src
        assert "import 'text_normalizer.dart'" not in src
