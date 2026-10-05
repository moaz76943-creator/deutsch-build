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
        'vocabulary_view_mode',
        'daily_study_time_minutes',
        'pomodoro_timer_minutes',
        'daily_new_cards_quota',
        'daily_review_limit',
        'offline_pack_registry_v1',
        'offline_active_pack_v1',
        'offline_manifest_revision_v1',
        'offline_manifest_acceptance_v2',
        'search_custom_word_notes_v1',
        'app_learning_preferences_v1',
        'settings.theme_mode.v1',
        'settings.speech_rate.v1',
        'sys_memory_agent_v1',
    }
