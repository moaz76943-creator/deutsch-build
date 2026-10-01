from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from privacy_audit import audit_project  # noqa: E402


def test_each_local_persistence_key_has_a_single_declared_owner():
    report = audit_project(ROOT)
    assert report.ok, report.errors
    assert report.local_storage_owners == {
        'v34_state': 'lib/services/repository.dart',
        'verb_favorites_v1': 'lib/services/repository.dart',
        'privacy_cloud_ai_v1': 'lib/services/privacy_settings.dart',
        'privacy_speech_v1': 'lib/services/privacy_settings.dart',
            'vocabulary_view_mode': 'lib/ui_v35/learning_pages.dart',
    }
