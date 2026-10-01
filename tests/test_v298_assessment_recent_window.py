from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'lib/services/assessment_engine.dart').read_text(encoding='utf-8')


def test_assessment_weak_skill_uses_same_recent_window_for_denominator():
    assert 'take(10).toList()' in SRC
    assert re.search(
        r'recent\.where\(\(x\)\s*=>\s*x\.correct\)\.length',
        SRC,
    )
    assert re.search(r'recentCorrect\s*/\s*recent\.length', SRC)
    assert re.search(r'final recent\s*=\s*a\.reversed\.take\(10\)', SRC)
