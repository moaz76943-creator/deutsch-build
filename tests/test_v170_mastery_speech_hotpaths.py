from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_mastery_dashboard_iterates_active_state_ids_not_full_corpus():
    src = read('lib/services/mastery_dashboard.dart')
    assert 'final activeItemIds = <String>{' in src
    assert 'for (final attempt in state.meaningAttempts)' in src
    assert '...state.meaningReviewCards.map((card) => card.itemId)' in src
    assert 'for (final item in items)' not in src


def test_adaptive_focus_accepts_pre_grouped_rows():
    src = read('lib/services/adaptive_focus.dart')
    assert 'dimensionForRows' in src
    assert 'modeForRows' in src
    assert re.search(
        r'dimensionForItem\(\s*String itemId\s*,\s*List<Attempt> attempts',
        src,
        re.DOTALL,
    )


def test_speech_locale_is_configurable_not_hardcoded():
    src = read('lib/services/speech_service.dart')
    assert 'final String localeId;' in src
    assert 'SpeechService({this.localeId' in src
    assert 'localeId: localeId' in src


def test_learning_engine_uses_grouped_attempts_for_adaptive_focus():
    src = read('lib/services/learning_engine.dart')
    assert 'AdaptiveFocus.modeForRows' in src
