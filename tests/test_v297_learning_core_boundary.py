from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = (ROOT / 'lib/core/learning_core.dart').read_text(encoding='utf-8')


def test_learning_core_does_not_depend_on_repository_layer():
    assert "import '../services/repository.dart';" not in CORE
    assert 'LearnerRepository' not in CORE
