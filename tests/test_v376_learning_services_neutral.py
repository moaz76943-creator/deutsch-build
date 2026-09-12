from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_shared_learning_services_use_learning_content():
    for rel in [
        'lib/models/learning_path.dart',
        'lib/services/learning_engine.dart',
        'lib/services/vocabulary_coach.dart',
        'lib/services/mastery_dashboard.dart',
    ]:
        src = read(rel)
        assert "import '../models/content.dart';" not in src
        assert 'ContentItem' not in src
    assert "import '../core/content_contract.dart';" in read('lib/services/learning_engine.dart')
    assert "import '../core/content_contract.dart';" in read('lib/services/vocabulary_coach.dart')
    assert "import '../core/content_contract.dart';" in read('lib/services/mastery_dashboard.dart')
    assert "import 'core/content_contract.dart';" not in read('lib/models/learning_path.dart')
