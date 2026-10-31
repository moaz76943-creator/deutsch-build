import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock
from j095_gate import VerificationGate, GateDecision

class TestRealGate(unittest.TestCase):
    @patch('j095_gate.VerificationGate.run_dart_analysis')
    @patch('j095_gate.VerificationGate.check_sqlite_schema')
    @patch('j095_gate.VerificationGate.check_sqlite_integrity')
    @patch('j095_gate.VerificationGate.check_sqlite_content_hash')
    @patch('j095_gate.VerificationGate.benchmark_fts5')
    @patch('j095_gate.VerificationGate.benchmark_memory')
    @patch('j095_gate.VerificationGate.benchmark_startup_normal')
    @patch('j095_gate.VerificationGate.benchmark_startup_safe')
    def test_gate_rejects_negative_regression(
            self,
            mock_startup_safe, mock_startup_normal, mock_memory, mock_fts5,
            mock_content_hash, mock_integrity, mock_schema, mock_dart_analysis):

        mock_dart_analysis.return_value = GateDecision.FAIL
        mock_schema.return_value = GateDecision.PASS
        mock_integrity.return_value = GateDecision.PASS
        mock_content_hash.return_value = GateDecision.PASS
        mock_fts5.return_value = GateDecision.PASS
        mock_memory.return_value = GateDecision.PASS
        mock_startup_normal.return_value = GateDecision.PASS
        mock_startup_safe.return_value = GateDecision.PASS

        gate = VerificationGate(Path("."))
        result = gate.evaluate()
        self.assertEqual(result, GateDecision.FAIL.value)

if __name__ == '__main__':
    unittest.main()
