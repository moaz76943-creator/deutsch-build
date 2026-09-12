from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))
from privacy_audit import audit_project  # noqa: E402


def test_privacy_audit_resolves_const_backed_persistence_keys():
    report = audit_project(ROOT)
    assert report.ok, report.errors
    assert set(report.local_storage_keys) == {
        'v34_state',
        'verb_favorites_v1',
        'privacy_cloud_ai_v1',
        'privacy_speech_v1',
    }
