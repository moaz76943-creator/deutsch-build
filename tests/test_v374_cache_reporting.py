from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.verify import VerificationReport

def test_verification_report_exposes_cached_checks():
    report = VerificationReport([], 'LOW', [], [], [], [], 'NOT RUN', 'NOT RUN', 'NOT RUN', [], ['content_quality'])
    assert report.cached == ['content_quality']
