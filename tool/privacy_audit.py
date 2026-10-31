#!/usr/bin/env python3
from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
import re

@dataclass(frozen=True)
class PrivacyReport:
    ok: bool
    errors: tuple[str, ...]
    local_storage_keys: tuple[str, ...]
    local_storage_owners: dict[str, str]
    direct_shared_preferences_imports: tuple[str, ...]
    sensitive_terms: tuple[str, ...]

_LOCAL_KEY_OWNERS = {
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
_ALLOWED_LOCAL_KEYS = set(_LOCAL_KEY_OWNERS)
_SENSITIVE = re.compile(r'(?i)(password|passwd|secret|api[_-]?key|access[_-]?token|refresh[_-]?token|authorization|cookie|session[_-]?token|email|phone|payment|card[_-]?number|billing)')
_STORAGE_RECEIVER = r'(?:_prefs|prefs|_preferences|preferences)'
_STORAGE_METHOD = r'(?:getString|getStringList|getBool|getInt|setString|setStringList|setBool|setInt|remove|readText|readTextList|writeText|writeTextList|deleteValue)'

def audit_project(root: Path) -> PrivacyReport:
    errors: list[str] = []
    keys: set[str] = set()
    direct_prefs: list[str] = []
    sensitive: list[str] = []
    key_files: dict[str, set[str]] = {key: set() for key in _ALLOWED_LOCAL_KEYS}
    lib = root / 'lib'
    dart_files = list(lib.rglob('*.dart')) if lib.exists() else []

    for path in dart_files:
        text = path.read_text(encoding='utf-8', errors='ignore')
        rel = str(path.relative_to(root))
        if 'package:shared_preferences/shared_preferences.dart' in text and rel != 'lib/services/preferences_service.dart':
            direct_prefs.append(rel)
        # Inventory literal keys and simple file-local const-backed keys.
        const_keys = dict(
            re.findall(
                r"(?:static\s+)?const(?:\s+[A-Za-z_][A-Za-z0-9_<>,?]*)?\s+"
                r"(\w+Key|key)\s*=\s*['\"]([^'\"]+)['\"]",
                text,
            )
        )
        if rel == 'lib/services/privacy_settings.dart':
            for name, value in re.findall(
                r"static\s+const(?:\s+[A-Za-z_][A-Za-z0-9_<>,?]*)?\s+"
                r"(\w+Key)\s*=\s*['\"]([^'\"]+)['\"]",
                text,
            ):
                const_keys[name] = value
        for match in re.finditer(
            rf"\b{_STORAGE_RECEIVER}\.{_STORAGE_METHOD}\(\s*['\"]([^'\"]+)['\"]",
            text,
        ):
            keys.add(match.group(1))
            key_files.setdefault(match.group(1), set()).add(rel)
        for match in re.finditer(
            rf"\b{_STORAGE_RECEIVER}\.{_STORAGE_METHOD}\(\s*(\w+Key|key)\s*[,)]",
            text,
        ):
            value = const_keys.get(match.group(1))
            if value:
                keys.add(value)
                key_files.setdefault(value, set()).add(rel)
        if rel == 'lib/services/privacy_settings.dart':
            for name in re.findall(r"LocalPrivacySettingsStore\.(\w+Key)", text):
                resolved = const_keys.get(name)
                if resolved:
                    keys.add(resolved)
                    key_files.setdefault(resolved, set()).add(rel)
        if rel == 'lib/services/repository.dart':
            for name in ('key', 'legacyFavoriteKey'):
                value = const_keys.get(name)
                if value:
                    keys.add(value)
                    key_files.setdefault(value, set()).add(rel)
        # The repository remains the canonical key owner; the persistence adapter receives these keys explicitly.
        if rel in {'lib/services/repository.dart', 'lib/services/preferences_service.dart'}:
            for match in _SENSITIVE.finditer(text):
                line = text[:match.start()].count('\n') + 1
                snippet = text.splitlines()[line-1].strip() if text.splitlines() else ''
                if '//' not in snippet and not snippet.startswith('*'):
                    sensitive.append(f'{rel}:{line}:{match.group(1)}')


    unexpected = sorted(keys - _ALLOWED_LOCAL_KEYS)
    if unexpected:
        errors.append(f'Unexpected local persistence keys: {unexpected}')
    for key, owner in _LOCAL_KEY_OWNERS.items():
        if key not in keys:
            errors.append(f'Declared local persistence key is missing from inventory: {key}')
            continue
        offenders = sorted(path for path in key_files.get(key, set()) if path != owner)
        if offenders:
            errors.append(f'Local persistence key {key!r} is referenced outside its owner {owner}: {offenders}')
    if direct_prefs:
        errors.append(f'Direct SharedPreferences access outside adapter: {sorted(direct_prefs)}')
    if sensitive:
        errors.append(f'Potential sensitive-data vocabulary in application source: {sensitive[:20]}')

    # Keep this gate explicit: the current app has no account/payment/session persistence boundary.
    repository = (lib / 'services' / 'repository.dart').read_text(encoding='utf-8', errors='ignore') if (lib / 'services' / 'repository.dart').exists() else ''
    if "static const key = 'v34_state'" not in repository:
        errors.append('LearnerRepository must retain the canonical local-state key.')
    if "verb_favorites_v1" in repository and "loadAndMigrateFavoriteVerbs" not in repository:
        errors.append('Legacy verb favorites must have an explicit repository migration boundary.')
    persistence = (lib / 'services' / 'learner_persistence.dart').read_text(encoding='utf-8', errors='ignore') if (lib / 'services' / 'learner_persistence.dart').exists() else ''
    if 'verb_favorites_v1' in repository and 'loadAndMigrateFavoriteVerbs' in repository and 'clearLocalData' not in persistence:
        errors.append('LearnerPersistence must own legacy favorite cleanup.')
    if 'clearLocalData()' not in repository:
        errors.append('Local data deletion boundary is missing.')

    owners = {key: owner for key, owner in _LOCAL_KEY_OWNERS.items() if key in keys}
    return PrivacyReport(not errors, tuple(errors), tuple(sorted(keys)), owners, tuple(sorted(direct_prefs)), tuple(sensitive))

if __name__ == '__main__':
    root = Path(__file__).resolve().parents[1]
    report = audit_project(root)
    if not report.ok:
        print('PRIVACY AUDIT: FAIL')
        for error in report.errors:
            print('ERROR:', error)
        raise SystemExit(1)
    print('PRIVACY AUDIT: PASS')
    print('Local persistence keys:', ', '.join(report.local_storage_keys) or 'none')
    print('Direct SharedPreferences imports outside adapter: 0')
    print('Sensitive persistence vocabulary: 0')
