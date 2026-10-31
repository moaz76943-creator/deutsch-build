import unittest
import sys
import os
sys.path.insert(0, os.path.abspath('.'))

from tools.maintenance.superseded_pr_pruner import audit_and_prune_duplicates

class TestSupersededPrPruner(unittest.TestCase):
    def test_pruner_module_exists_and_callable(self):
        self.assertTrue(callable(audit_and_prune_duplicates))

if __name__ == "__main__":
    unittest.main()
