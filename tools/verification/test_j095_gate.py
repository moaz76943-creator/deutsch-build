import unittest
import tempfile
import json
from pathlib import Path
from unittest.mock import patch, MagicMock

import j095_gate
from j095_gate import VerificationGate, GateDecision

class TestJ095Gate(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.repo_root = Path(self.temp_dir.name)
        (self.repo_root / "lib" / "data").mkdir(parents=True)
        (self.repo_root / "tools" / "verification").mkdir(parents=True)
        self.gate = VerificationGate(self.repo_root)

    def tearDown(self):
        self.temp_dir.cleanup()

    @patch('subprocess.run')
    def test_run_dart_analysis_pass(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0)
        self.assertEqual(self.gate.run_dart_analysis(), GateDecision.PASS)

    @patch('subprocess.run')
    def test_run_dart_analysis_fail(self, mock_run):
        mock_run.return_value = MagicMock(returncode=1, stderr="Error")
        self.assertEqual(self.gate.run_dart_analysis(), GateDecision.FAIL)

    def test_check_sqlite_schema_blocked(self):
        self.assertEqual(self.gate.check_sqlite_schema(), GateDecision.BLOCKED)

    def test_evaluate_all_pass(self):
        self.gate.run_dart_analysis = MagicMock(return_value=GateDecision.PASS)
        self.gate.check_sqlite_schema = MagicMock(return_value=GateDecision.PASS)
        self.gate.check_sqlite_integrity = MagicMock(return_value=GateDecision.PASS)
        self.gate.check_sqlite_content_hash = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_fts5 = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_memory = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_startup_normal = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_startup_safe = MagicMock(return_value=GateDecision.PASS)

        result = self.gate.evaluate()
        self.assertEqual(result, GateDecision.PASS.value)

        with open(self.gate.manifest_path, "r") as f:
            manifest = json.load(f)
            self.assertEqual(manifest["overall_decision"], GateDecision.PASS.value)

    def test_evaluate_with_failure(self):
        self.gate.run_dart_analysis = MagicMock(return_value=GateDecision.FAIL)
        self.gate.check_sqlite_schema = MagicMock(return_value=GateDecision.PASS)
        self.gate.check_sqlite_integrity = MagicMock(return_value=GateDecision.PASS)
        self.gate.check_sqlite_content_hash = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_fts5 = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_memory = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_startup_normal = MagicMock(return_value=GateDecision.PASS)
        self.gate.benchmark_startup_safe = MagicMock(return_value=GateDecision.PASS)

        result = self.gate.evaluate()
        self.assertEqual(result, GateDecision.FAIL.value)

        with open(self.gate.manifest_path, "r") as f:
            manifest = json.load(f)
            self.assertEqual(manifest["overall_decision"], GateDecision.FAIL.value)

if __name__ == '__main__':
    unittest.main()
