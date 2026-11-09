import unittest
import os
import json
import subprocess
from pathlib import Path
from unittest.mock import patch, MagicMock

import tools.verification.zero_regression_gate as gate

class TestZeroRegressionGate(unittest.TestCase):

    def setUp(self):
        self.root = Path(".")

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_analyzer_failure_blocks_acceptance(self, mock_run):
        mock_run.return_value = (1, "error • Something is wrong", "")
        res = gate.run_dart_analyzer()
        self.assertEqual(res.status, gate.STATUS_FAIL)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_analyzer_pass(self, mock_run):
        mock_run.return_value = (0, "No issues found!", "")
        res = gate.run_dart_analyzer()
        self.assertEqual(res.status, gate.STATUS_PASS)

    @patch('pathlib.Path.rglob')
    def test_missing_sqlite_tests_not_run(self, mock_rglob):
        mock_rglob.return_value = iter([])
        res = gate.run_sqlite_check(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)

    @patch('pathlib.Path.rglob')
    def test_missing_benchmark_fts5_not_run(self, mock_rglob):
        mock_rglob.return_value = iter([])
        res = gate.run_benchmark_fts5(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)

    @patch('pathlib.Path.exists')
    def test_missing_memory_benchmark_blocked(self, mock_exists):
        mock_exists.return_value = False
        res = gate.run_benchmark_memory(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)

    @patch('pathlib.Path.exists')
    def test_missing_startup_tests_blocked(self, mock_exists):
        mock_exists.return_value = False
        res = gate.run_startup_tests(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)

    @patch('os.path.exists')
    @patch('pathlib.Path.exists')
    @patch('shutil.which')
    def test_missing_time_toolchain_blocks(self, mock_which, mock_path_exists, mock_os_exists):
        mock_path_exists.return_value = True
        def os_exists_side_effect(path):
            if path == "/usr/bin/time":
                return False
            return True
        mock_os_exists.side_effect = os_exists_side_effect
        mock_which.return_value = None
        res = gate.run_benchmark_memory(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)
        self.assertIn("Missing time toolchain", res.message)

    @patch('os.path.exists')
    @patch('pathlib.Path.exists')
    @patch('tools.verification.zero_regression_gate.run_command')
    def test_unparseable_metrics_blocks(self, mock_run, mock_path_exists, mock_os_exists):
        mock_path_exists.return_value = True
        mock_os_exists.return_value = True
        # memory mock
        mock_run.return_value = (0, "no metrics here", "")
        res = gate.run_benchmark_memory(self.root)
        self.assertEqual(res.status, gate.STATUS_BLOCKED)
        self.assertIn("Could not extract memory", res.message)

        # startup mock
        mock_run.return_value = (0, "no metrics here", "")
        res2 = gate.run_startup_tests(self.root)
        self.assertEqual(res2.status, gate.STATUS_BLOCKED)
        self.assertIn("Could not extract STARTUP_TIME", res2.message)

    def test_manifest_generation(self):
        results = {
            "dart_analyzer": gate.GateResult(gate.STATUS_PASS, "Passed"),
            "sqlite_integrity": gate.GateResult(gate.STATUS_PASS, "Passed"),
            "benchmarks": gate.GateResult(gate.STATUS_FAIL, "Failed"),
        }
        test_file = "test_manifest.json"
        overall = gate.generate_manifest(results, test_file)
        self.assertEqual(overall, gate.STATUS_FAIL)

        with open(test_file, 'r') as f:
            data = json.load(f)
            self.assertEqual(data["overall_status"], gate.STATUS_FAIL)
            self.assertEqual(data["results"]["benchmarks"]["status"], gate.STATUS_FAIL)
            self.assertIn("hash", data)

        if os.path.exists(test_file):
            os.remove(test_file)

    def test_baseline_comparison_missing(self):
        res = gate.compare_baselines("not_exist.json", "baseline_not_exist.json")
        self.assertEqual(res.status, gate.STATUS_NOT_RUN)

    def test_baseline_comparison_regression(self):
        b_file = "b.json"
        c_file = "c.json"

        with open(b_file, "w") as f:
             json.dump({
                 "results": {
                     "benchmark_memory": {
                         "details": {
                             "peak_memory_mb": 50.0
                         }
                     }
                 }
             }, f)

        with open(c_file, "w") as f:
             json.dump({
                 "results": {
                     "benchmark_memory": {
                         "details": {
                             "peak_memory_mb": 70.0 # Regression > 20%
                         }
                     }
                 }
             }, f)

        res = gate.compare_baselines(c_file, b_file)
        self.assertEqual(res.status, gate.STATUS_FAIL)
        self.assertIn("Regressions detected", res.message)

        if os.path.exists(b_file): os.remove(b_file)
        if os.path.exists(c_file): os.remove(c_file)

    @patch('os.path.exists')
    @patch('pathlib.Path.exists')
    @patch('tools.verification.zero_regression_gate.run_command')
    def test_benchmark_memory_fails_on_exceeding_limit(self, mock_run, mock_path_exists, mock_os_exists):
        mock_path_exists.return_value = True
        mock_os_exists.return_value = True
        mock_run.return_value = (0, "MEMORY_PEAK_MB: 300.0", "")
        res = gate.run_benchmark_memory(self.root, limit_mb=256.0)
        self.assertEqual(res.status, gate.STATUS_FAIL)
        self.assertIn("exceeds limit", res.message)

    @patch('pathlib.Path.exists')
    @patch('tools.verification.zero_regression_gate.run_command')
    def test_startup_tests_fails_on_exceeding_threshold(self, mock_run, mock_exists):
        mock_exists.return_value = True
        mock_run.return_value = (0, "STARTUP_TIME_MS: 2000.0", "")
        res = gate.run_startup_tests(self.root, threshold_ms=1500.0)
        self.assertEqual(res.status, gate.STATUS_FAIL)
        self.assertIn("exceeds threshold", res.message)

if __name__ == "__main__":
    unittest.main()
