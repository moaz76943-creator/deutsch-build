from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
LEARNING = (ROOT / 'lib/services/learning_engine.dart').read_text()
MASTERY = (ROOT / 'lib/core/mastery.dart').read_text()
DASH = (ROOT / 'lib/services/mastery_dashboard.dart').read_text()
CONV = (ROOT / 'lib/services/conversation_engine.dart').read_text()


def test_learning_engine_declares_item_attempts_before_using_it():
    use = LEARNING.index('AdaptiveFocus.modeForRows')
    import re
    matches = list(re.finditer(r'final\s+itemAttempts\s*=', LEARNING))
    assert matches and matches[0].start() < use


def test_mastery_retention_uses_observed_success_rate():
    assert 'card.successRate' in MASTERY
    assert 'successRate' in MASTERY


def test_conversation_has_more_than_five_realistic_scenarios():
    GERMAN_STRATEGY=(ROOT/'lib/language/german/german_language_exercise_strategy.dart').read_text()
    assert (CONV + GERMAN_STRATEGY).count('ConversationScenario(') >= 8


def test_mastery_dashboard_keeps_corpus_explicit_for_content_reporting():
    assert 'required List<LearningContent> corpus' in DASH
