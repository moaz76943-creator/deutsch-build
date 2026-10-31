from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.verify import VerificationReport, _cache_scope
from tool.verification_cache import fingerprint


def test_cache_scope_includes_transitive_affected_files(tmp_path):
    changed = ['lib/core/contract.dart']
    affected = ['lib/core/contract.dart', 'lib/services/consumer.dart']
    contract = tmp_path / 'lib/core/contract.dart'
    consumer = tmp_path / 'lib/services/consumer.dart'
    contract.parent.mkdir(parents=True)
    consumer.parent.mkdir(parents=True)
    contract.write_text('v1')
    consumer.write_text('v1')
    first = fingerprint(_cache_scope(tmp_path, changed, affected), config={'check':'x'}, tool_version='V377')
    consumer.write_text('v2')
    second = fingerprint(_cache_scope(tmp_path, changed, affected), config={'check':'x'}, tool_version='V377')
    assert first != second


def test_verification_report_can_expose_affected_files():
    report = VerificationReport([], 'LOW', [], [], [], [], 'NOT RUN', 'NOT RUN', 'NOT RUN', [], [], ['lib/a.dart'])
    assert report.affected_files == ['lib/a.dart']
