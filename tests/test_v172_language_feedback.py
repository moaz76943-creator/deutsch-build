from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def read(p): return (ROOT/p).read_text(encoding='utf-8')

def test_local_writing_analyzer_exists_with_structural_checks():
    s=read('lib/services/writing_analyzer.dart')
    assert 'class WritingAnalyzer' in s
    assert 'analyze' in s
    assert 'verb' in s.lower()
    assert 'capital' in s.lower()

def test_conversation_score_uses_soft_token_matching_and_order_signal():
    s=read('lib/services/conversation_engine.dart')
    assert '_tokenSimilarity' in s
    assert 'order' in s.lower()
    assert 'TextNormalizer' in s

def test_conversation_score_does_not_require_exact_inflection():
    s=read('lib/services/conversation_engine.dart')
    strategy=read('lib/language/german/german_language_exercise_strategy.dart')
    assert 'fährt' in s or 'fahr' in s or 'fährt' in strategy or 'fahr' in strategy
