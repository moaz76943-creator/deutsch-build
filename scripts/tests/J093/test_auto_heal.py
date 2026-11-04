import unittest
import os
import json
import tempfile
import shutil
from unittest.mock import patch, MagicMock
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
import auto_heal

class TestAutoHeal(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.attempts_file = os.path.join(self.test_dir, ".auto_heal_attempts.json")
        self.failures_file = os.path.join(self.test_dir, ".auto_heal_failures.json")
        self.ledger_path = os.path.join(self.test_dir, ".scope_guard_ledger.json")
        self.failures_ledger_path = os.path.join(self.test_dir, ".auto_heal_failures.json")
        self.plan_path = os.path.join(self.test_dir, "plan.json")
        self.target_file = os.path.join(self.test_dir, "target.dart")
        self.attempts_file = os.path.join(self.test_dir, ".auto_heal_attempts.json")
        self.failures_file = os.path.join(self.test_dir, ".auto_heal_failures.json")

        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\n")

        if os.path.exists(".auto_heal_attempts.json"):
            os.remove(".auto_heal_attempts.json")

        self.plan_data = {
            "plan_id": "J093-TEST",
            "signature": "valid",
            "base_sha": "a" * 40,
            "allowed_paths": [self.target_file],
            "operations": [
                {
                    "type": "repair_import",
                    "path": self.target_file,
                    "old_import": "bad_path",
                    "new_import": "good_path"
                }
            ]
        }

        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)
        self.git_head = patch('auto_heal.subprocess.check_output', return_value=b"a" * 40)
        self.git_head.start()
        self.addCleanup(self.git_head.stop)

    def tearDown(self):
        shutil.rmtree(self.test_dir)

    def test_dry_run(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.dry_run()

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_success(self, mock_gate, mock_ownership):
        mock_gate.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("good_path", content)

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_failure_rollback(self, mock_gate, mock_ownership):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("bad_path", content)

    def test_blocked_if_gate_missing(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)

        with patch('os.path.exists', side_effect=lambda p: False if p == "scripts/verify_contracts.py" else True):
            self.assertFalse(executor._run_gate())

    def test_unauthorized_plan(self):
        del self.plan_data["signature"]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        with self.assertRaises(Exception) as context:
            auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        self.assertIn("Missing signature", str(context.exception))

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.subprocess.check_call')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_commit(self, mock_gate, mock_check_call, mock_ownership):
        mock_gate.return_value = True
        mock_ownership.return_value = True
        self.plan_data["commit"] = True
        self.plan_data["branch"] = "test-branch"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        calls = mock_check_call.call_args_list
        self.assertEqual(calls[0][0][0], ["git", "checkout", "-b", "test-branch"])
        self.assertEqual(calls[1][0][0], ["git", "add", self.target_file])
        self.assertEqual(calls[2][0][0], ["git", "commit", "-m", "Fix(J093-TEST): Auto-heal repair"])

    def test_scope_guard_collision(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        if os.path.exists(self.failures_file):
            os.remove(self.failures_file)

        with self.assertRaises(SystemExit):
            executor.execute()

        self.assertTrue(os.path.exists(self.failures_file))
        with open(self.failures_file, 'r') as f:
            failures = json.load(f)
        self.assertTrue(any(f["plan_id"] == "J093-TEST" for f in failures))

    def test_regenerate_artifact_atomic(self):
        self.plan_data["operations"] = [
            {
                "type": "regenerate_artifact",
                "path": self.target_file,
                "content": "new_content"
            }
        ]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)

        # we can't easily intercept os.replace without mocking but we can verify it doesn't fail
        # and creates the target file.
        executor._apply_operation(self.plan_data["operations"][0])

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertEqual(content, "new_content")

    def test_scope_guard_collision(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

    @patch('auto_heal.AutoHealExecutor._run_gate')
    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    def test_bounded_attempts(self, mock_ownership, mock_gate):
        mock_ownership.return_value = True
        mock_gate.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        for _ in range(3):
            executor.execute()

        with self.assertRaises(SystemExit):
            executor.execute()

        if os.path.exists(".auto_heal_attempts.json"):
            os.remove(".auto_heal_attempts.json")

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_bounded_attempts_enforced(self, mock_gate):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

        # Simulate max failures
        for _ in range(3):
            with self.assertRaises(SystemExit):
                executor.execute()

        # The next execute should fail immediately due to bounded attempts
        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception) as context:
                executor.execute()

    def test_bounded_attempts(self):
        # Initial execution
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        with patch('auto_heal.AutoHealExecutor._run_gate', return_value=False):
            with self.assertRaises(SystemExit):
                executor.execute()

        with open(self.attempts_file, 'r') as f:
            attempts = json.load(f)
        self.assertEqual(attempts["J093-TEST"], 1)

        with open(self.failures_file, 'r') as f:
            failures = json.load(f)
        self.assertIn("J093-TEST", failures)
        self.assertEqual(len(failures["J093-TEST"]), 1)

        # Simulate reaching the constitutional maximum (two attempts)
        attempts["J093-TEST"] = 2
        with open(self.attempts_file, 'w') as f:
            json.dump(attempts, f)

        # 3rd attempt should fail before executing
        executor2 = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor2.guard.ledger_path = self.ledger_path

        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception):
                executor2.execute()

        with open(self.failures_file, 'r') as f:
            failures2 = json.load(f)

        self.assertIn("maximum attempts", str(failures2["J093-TEST"][-1]))


    def test_rejects_wildcard_base_sha(self):
        self.plan_data["base_sha"] = "any"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)
        with self.assertRaisesRegex(ValueError, "Invalid base_sha"):
            auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)

    def test_base_sha_mismatch_fails_closed(self):
        self.plan_data["base_sha"] = "a" * 40
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        with patch('auto_heal.subprocess.check_output', return_value=b"b" * 40):
            with self.assertRaisesRegex(ValueError, "BASE_SHA mismatch"):
                executor._verify_base_sha()

    def test_base_sha_unavailable_fails_closed(self):
        self.plan_data["base_sha"] = "a" * 40
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        with patch('auto_heal.subprocess.check_output', side_effect=FileNotFoundError("git unavailable")):
            with self.assertRaisesRegex(RuntimeError, "Cannot verify git HEAD"):
                executor._verify_base_sha()

    def test_missing_fts_builder_does_not_modify_artifact(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        with open(self.target_file, 'rb') as f:
            before = f.read()
        real_isfile = os.path.isfile
        with patch('auto_heal.os.path.isfile',
                   side_effect=lambda path: False if path == "tools/language_pack_sqlite.py" else real_isfile(path)):
            with self.assertRaisesRegex(FileNotFoundError, "FTS5 builder"):
                executor._apply_operation({"type": "rebuild_fts5", "path": self.target_file})
        with open(self.target_file, 'rb') as f:
            self.assertEqual(before, f.read())

    @patch('auto_heal.AutoHealExecutor._run_gate', return_value=False)
    def test_failed_verification_rolls_back_when_failure_log_unwritable(self, mock_gate):
        unavailable = os.path.join(self.test_dir, "nonexistent_parent", "failures.json")
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, unavailable)
        executor.guard.ledger_path = self.ledger_path
        with self.assertRaises(SystemExit):
            executor.execute()
        with open(self.target_file) as f:
            self.assertEqual(f.read(), "import 'bad_path';\\n".replace('\\n', '\n'))
        with open(self.ledger_path) as f:
            ledger = json.load(f)
        self.assertEqual(ledger["leases"][self.target_file]["status"], "CANCELLED")

    def test_backup_slot_never_escapes_backup_directory(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        escaped = executor._backup_slot('../../outside/critical.txt')
        normal = executor._backup_slot('/tmp/legitimate.txt')
        root = os.path.realpath(executor.backup_dir)
        self.assertEqual(os.path.commonpath([root, os.path.realpath(escaped)]), root)
        self.assertEqual(os.path.commonpath([root, os.path.realpath(normal)]), root)
        self.assertNotEqual(escaped, normal)

    def test_corrupt_scope_ledger_blocks_claim_and_status_update(self):
        guard = auto_heal.ScopeGuard(self.ledger_path)
        with open(self.ledger_path, 'w') as stream:
            stream.write('{"leases":')
        with self.assertRaisesRegex(ValueError, "Scope ledger corrupted"):
            guard.claim("agent_A", [self.target_file])
        with self.assertRaisesRegex(ValueError, "Scope ledger corrupted"):
            guard.update_status("agent_A", [self.target_file], "COMPLETE")
        with open(self.ledger_path) as stream:
            self.assertEqual(stream.read(), '{"leases":')

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_backup_failure_releases_claimed_lease(self, mock_gate):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path
        with patch('auto_heal.shutil.copy2', side_effect=OSError("unreadable source")):
            with self.assertRaises(SystemExit):
                executor.execute()
        mock_gate.assert_not_called()
        with open(self.target_file) as stream:
            self.assertIn("bad_path", stream.read())
        with open(self.ledger_path) as stream:
            ledger = json.load(stream)
        self.assertEqual(ledger["leases"][self.target_file]["status"], "CANCELLED")

    def test_corrupt_attempt_history_fails_closed_without_mutation(self):
        with open(self.attempts_file, 'w') as f:
            f.write('{"J093-TEST": 2')
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path
        with patch('auto_heal.AutoHealExecutor._run_gate', return_value=True):
            with self.assertRaises(SystemExit):
                executor.execute()
        with open(self.target_file) as f:
            self.assertIn("bad_path", f.read())
        with open(self.attempts_file) as f:
            self.assertEqual(f.read(), '{"J093-TEST": 2')

    @patch('auto_heal.AutoHealExecutor._run_gate', return_value=True)
    def test_atomic_regeneration_preserves_foreign_tmp_sibling(self, mock_gate):
        artifact_path = os.path.join(self.test_dir, "artifact.txt")
        sibling = artifact_path + ".tmp"
        with open(sibling, 'w') as f:
            f.write("unrelated task's data")
        self.plan_data["allowed_paths"].append(artifact_path)
        self.plan_data["operations"].append({
            "type": "regenerate_artifact",
            "path": artifact_path,
            "content": "new generated bytes"
        })
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path
        executor.execute()
        with open(artifact_path) as f:
            self.assertEqual(f.read(), "new generated bytes")
        with open(sibling) as f:
            self.assertEqual(f.read(), "unrelated task's data")

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_atomic_artifact_regeneration(self, mock_gate):
        mock_gate.return_value = True
        artifact_path = os.path.join(self.test_dir, "test_artifact.txt")
        self.plan_data["allowed_paths"].append(artifact_path)
        self.plan_data["operations"].append({
            "type": "regenerate_artifact",
            "path": artifact_path,
            "content": "new_artifact_content"
        })
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path, self.attempts_file, self.failures_file)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        with open(artifact_path, 'r') as f:
            content = f.read()

        self.assertEqual(content, "new_artifact_content")
        self.assertFalse(os.path.exists(artifact_path + ".tmp"))

if __name__ == '__main__':
    unittest.main()
