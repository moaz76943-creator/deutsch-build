from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
ALLOWED = {
    'services/repository.dart',
    'services/learner_persistence.dart',
    'services/preferences_service.dart',
    'services/privacy_settings.dart',
    'services/neuro_accessibility_service.dart',
    'services/neuro_accessibility_settings.dart',
    'services/ui_preferences.dart',
    'main.dart',
    'ui_v35/learning_pages.dart',
}
PERSISTENCE_MARKERS = (
    'getString(', 'getStringList(', 'getBool(',
    'prefs.getString(', 'prefs.getStringList(', 'prefs.getBool(',
    'prefs.setString(', 'prefs.setStringList(', 'prefs.setBool(', 'prefs.remove(',
)


def test_shared_preferences_access_stays_behind_known_local_boundaries():
    offenders = []
    for path in LIB.rglob('*.dart'):
        rel = path.relative_to(LIB).as_posix()
        if rel in ALLOWED:
            continue
        text = path.read_text(encoding='utf-8')
        if 'SharedPreferences' in text or any(marker in text for marker in PERSISTENCE_MARKERS):
            offenders.append(rel)
    assert offenders == [], f'Unexpected local persistence access outside approved boundaries: {offenders}'


def test_learner_state_persistence_contract_has_single_owner():
    repository = (LIB / 'services/repository.dart').read_text(encoding='utf-8')
    assert "static const key = 'v34_state';" in repository
    persistence = (LIB / 'services/learner_persistence.dart').read_text(encoding='utf-8')
    for field in ('learned', 'review', 'favoriteVerbs', 'reviewCards', 'attempts', 'assessmentHistory'):
        assert f"'{field}'" in persistence
