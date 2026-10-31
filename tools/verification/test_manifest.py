import unittest
from pathlib import Path
import json

class TestManifestFormat(unittest.TestCase):
    def test_manifest_format(self):
        # We check if GateDecision formats to expected PASS/FAIL/BLOCKED/NOT_RUN strings
        from j095_gate import GateDecision
        self.assertEqual(GateDecision.PASS.value, "PASS")
        self.assertEqual(GateDecision.FAIL.value, "FAIL")
        self.assertEqual(GateDecision.BLOCKED.value, "BLOCKED")
        self.assertEqual(GateDecision.NOT_RUN.value, "NOT_RUN")

if __name__ == '__main__':
    unittest.main()
