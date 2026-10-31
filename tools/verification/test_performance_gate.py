import unittest
from pathlib import Path
import os
import subprocess
import shutil
import json
from unittest.mock import patch, MagicMock
from tools.verification.performance_gate import VerificationGate, compare_baselines

class TestPerformanceGate(unittest.TestCase):
    def setUp(self):
        self.root = Path(".")
        self.gate = VerificationGate(self.root)

    @patch('subprocess.run')
    def test_analyzer_failure_fails_gate(self, mock_run):
        mock_result = MagicMock()
        mock_result.returncode = 1
        mock_result.stdout = "Dart analyzer found build-blocking errors"
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        status, msg, metrics = self.gate.check_dart_errors()
        self.assertEqual(status, "FAIL")
        self.assertIn("Analyzer failed", msg)

    @patch('subprocess.run')
    def test_analyzer_success_passes_gate(self, mock_run):
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = "OK"
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        status, msg, metrics = self.gate.check_dart_errors()
        self.assertEqual(status, "PASS")
        self.assertIn("analyzer_duration_ms", metrics)

    def test_missing_sqlite_returns_blocked(self):
        temp_gate = VerificationGate(Path("/tmp/nonexistent"))
        status, msg, metrics = temp_gate.measure_sqlite_performance()
        self.assertEqual(status, "BLOCKED")

    def test_manifest_generation_includes_hash(self):
        self.gate.run_check("mock_check", lambda: ("PASS", "Ok", {"m1": 1.0}))
        out_path = Path("test_manifest.json")
        try:
            self.gate.generate_manifest(out_path)
            data = json.loads(out_path.read_text())
            self.assertIn("hash", data)
            self.assertEqual(data["overall_status"], "PASS")
            self.assertEqual(data["results"][0]["metrics"]["m1"], 1.0)
        finally:
            if out_path.exists():
                out_path.unlink()

    def test_baseline_comparison(self):
        pre = {
            "results": [
                {"component": "mock", "metrics": {"p95": 100}}
            ]
        }
        post = {
            "results": [
                {"component": "mock", "metrics": {"p95": 250}} # > 20% and > 100ms
            ]
        }
        reg = compare_baselines(pre, post)
        self.assertTrue(len(reg) > 0)

        post_ok = {
            "results": [
                {"component": "mock", "metrics": {"p95": 110}} # OK
            ]
        }
        reg_ok = compare_baselines(pre, post_ok)
        self.assertEqual(len(reg_ok), 0)

if __name__ == "__main__":
    unittest.main()
