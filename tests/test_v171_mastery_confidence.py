from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
mastery=(ROOT/'lib/core/mastery.dart').read_text()
adaptive=(ROOT/'lib/services/adaptive_focus.dart').read_text()

def test_mastery_exposes_confidence_weighted_evidence():
    assert 'confidence' in mastery.lower()
    assert 'attempts' in mastery
    assert 'prior' in mastery.lower()

def test_adaptive_focus_precomputes_latest_by_dimension():
    assert 'latestByDimension' in adaptive
