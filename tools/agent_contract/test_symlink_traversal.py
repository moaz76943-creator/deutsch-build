import unittest
import os
import tempfile
import json
from tools.agent_contract.guard import main

class TestSymlinkTraversal(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "ledger.json")
        self.report_path = os.path.join(self.temp_dir.name, "report.json")
        with open(self.ledger_path, "w") as f:
            json.dump({}, f)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_symlink_traversal(self):
        # Create a real symlink pointing to lib
        os.makedirs("tools/agent_contract/symlink_test_dir", exist_ok=True)
        if not os.path.exists("tools/agent_contract/symlink_test_dir/symlink_to_lib"):
            os.symlink("../../../lib", "tools/agent_contract/symlink_test_dir/symlink_to_lib")

        # Test file inside symlink
        path_to_test = "tools/agent_contract/symlink_test_dir/symlink_to_lib/main.dart"

        res = main([
            "--task-id", "T1",
            "--base-sha", "abc",
            "--transition", "CLAIM",
            "--paths", path_to_test,
            "--ledger", self.ledger_path,
            "--report", self.report_path
        ])

        # Clean up symlink test dir
        import shutil
        shutil.rmtree("tools/agent_contract/symlink_test_dir")

        self.assertEqual(res, 1)

if __name__ == '__main__':
    unittest.main()
