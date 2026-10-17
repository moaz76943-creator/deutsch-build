import unittest
import os
import json
import subprocess
from unittest.mock import patch, MagicMock

import tools.verification.zero_regression_gate as gate

class TestZeroRegressionGate(unittest.TestCase):

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_analyzer_failure_blocks_acceptance(self, mock_run):
        # 15. Add tests proving failures block acceptance.
        mock_run.return_value = (1, "error • Something is wrong", "")
        res = gate.run_dart_analyzer()
        self.assertEqual(res.status, gate.STATUS_FAIL)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_analyzer_pass(self, mock_run):
        mock_run.return_value = (0, "No issues found!", "")
        res = gate.run_dart_analyzer()
        self.assertEqual(res.status, gate.STATUS_PASS)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_missing_sqlite_tests_not_run(self, mock_run):
        # 12. Reject missing critical benchmarks as NOT_RUN or BLOCKED.
        mock_run.return_value = (1, "", "Could not find file")
        res = gate.run_sqlite_check()
        self.assertEqual(res.status, gate.STATUS_NOT_RUN)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_missing_benchmark_tests_not_run(self, mock_run):
        # 12. Reject missing critical benchmarks as NOT_RUN or BLOCKED.
        mock_run.return_value = (1, "", "Could not find file")
        res = gate.run_benchmark_check()
        self.assertEqual(res.status, gate.STATUS_NOT_RUN)

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
                     "benchmarks": {
                         "details": {
                             "p50_latency_ms": 30.0,
                             "peak_memory_mb": 50.0
                         }
                     }
                 }
             }, f)

        with open(c_file, "w") as f:
             json.dump({
                 "results": {
                     "benchmarks": {
                         "details": {
                             "p50_latency_ms": 35.0, # Regression > 10%
                             "peak_memory_mb": 50.0
                         }
                     }
                 }
             }, f)

        res = gate.compare_baselines(c_file, b_file)
        self.assertEqual(res.status, gate.STATUS_FAIL)

        if os.path.exists(b_file): os.remove(b_file)
        if os.path.exists(c_file): os.remove(c_file)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_benchmark_tolerances(self, mock_run):
        output = """
        ⏱️ زمن استرجاع L1 Cache لـ 100 عنصر: 25.0 ms
        ⏱️ زمن تفكيك الـ JSON لـ 50 مهمة: 120.0 ms
        """
        mock_run.return_value = (0, output, "")

        res = gate.run_benchmark_check(threshold_p50=20.0)
        self.assertEqual(res.status, gate.STATUS_FAIL)
        self.assertIn("exceeds tolerance", res.message)

        res_pass = gate.run_benchmark_check(threshold_p50=30.0)
        self.assertEqual(res_pass.status, gate.STATUS_PASS)

    @patch('tools.verification.zero_regression_gate.run_command')
    def test_startup_tests(self, mock_run):
        mock_run.return_value = (0, "output", "")
        res = gate.run_startup_tests()
        self.assertEqual(res.status, gate.STATUS_PASS)

        mock_run.return_value = (1, "output", "No such file or directory")
        res2 = gate.run_startup_tests()
        self.assertEqual(res2.status, gate.STATUS_NOT_RUN)

if __name__ == "__main__":
    unittest.main()
