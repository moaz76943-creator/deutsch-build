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
        'vocabulary_view_mode': 'lib/services/ui_preferences.dart',
        'daily_study_time_minutes': 'lib/services/ui_preferences.dart',
        'pomodoro_timer_minutes': 'lib/services/ui_preferences.dart',
        'daily_new_cards_quota': 'lib/services/ui_preferences.dart',
        'daily_review_limit': 'lib/services/ui_preferences.dart',
        'offline_pack_registry_v1': 'lib/services/pack_manager_service.dart',
        'offline_active_pack_v1': 'lib/services/pack_manager_service.dart',
        'offline_manifest_revision_v1': 'lib/services/pack_manager_service.dart',
        'offline_manifest_acceptance_v2': 'lib/services/pack_manager_service.dart',
        'search_custom_word_notes_v1': 'lib/features/search/infrastructure/local_bookmarks_repository.dart',
        'app_learning_preferences_v1': 'lib/features/app_settings/data/preferences_settings_local_data_source.dart',
        'settings.theme_mode.v1': 'lib/core/settings/adaptive_theme_settings.dart',
        'settings.speech_rate.v1': 'lib/core/settings/speech_rate_settings.dart',
        'sys_memory_agent_v1': 'lib/services/preferences_service.dart',
    }
