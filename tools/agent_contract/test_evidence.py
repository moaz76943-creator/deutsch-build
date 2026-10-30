import unittest
from tools.agent_contract.guard import check_overlapping_claims, paths_overlap
import time

class TestOverlap(unittest.TestCase):
    def test_paths_overlap(self):
        self.assertTrue(paths_overlap("tools/agent_contract/guard.py", "tools/agent_contract/guard.py"))
        self.assertTrue(paths_overlap("tools/agent_contract/guard.py", "tools/agent_contract/"))
        self.assertTrue(paths_overlap("tools/agent_contract/", "tools/agent_contract/guard.py"))
        self.assertFalse(paths_overlap("lib/main.dart", "tools/agent_contract/guard.py"))

    def test_owner_evidence(self):
        now = time.time()
        ledger = {
            "T1": {"state": "CLAIM", "timestamp": now - 4000, "paths": ["AGENTS.md"]}
        }
        overlap, msg = check_overlapping_claims(ledger, "T2", ["AGENTS.md"], now)
        self.assertFalse(overlap)
        self.assertEqual(ledger["T1"]["state"], "BLOCKED")
        self.assertIn("Original owner: T1", ledger["T1"]["recovery_evidence"])

if __name__ == '__main__':
    unittest.main()
