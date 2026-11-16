import os
import subprocess
import unittest

class TestBuildSystem(unittest.TestCase):
    def test_fatal_default_exit_code(self):
        script = 'source scripts/common.sh; fatal "Test failure"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn(b'[ERROR] Test failure', result.stderr)

    def test_fatal_custom_exit_code(self):
        script = 'source scripts/common.sh; fatal $ERR_ENV "Test failure"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 10)
        self.assertIn(b'[ERROR] Test failure', result.stderr)

    def test_fatal_compile_exit_code(self):
        script = 'source scripts/common.sh; fatal --code "$ERR_COMP" "Test compile"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 12)
        self.assertIn(b'[ERROR] Test compile', result.stderr)

    def test_fatal_signing_exit_code(self):
        script = 'source scripts/common.sh; fatal --code "$ERR_SIGN" "Test signing"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 13)
        self.assertIn(b'[ERROR] Test signing', result.stderr)

    def test_fatal_dependency_exit_code(self):
        script = 'source scripts/common.sh; fatal --code "$ERR_DEP" "Test dependency"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 11)
        self.assertIn(b'[ERROR] Test dependency', result.stderr)

    def test_fatal_artifact_exit_code(self):
        script = 'source scripts/common.sh; fatal 16 "Test artifact"'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 16)
        self.assertIn(b'[ERROR] Test artifact', result.stderr)

    def test_with_retry_success(self):
        script = 'source scripts/common.sh; with_retry true'
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 0)

    def test_with_retry_failure(self):
        script = 'source scripts/common.sh; with_retry false'
        # with_retry has sleep 2, 4. So this takes around 6 seconds.
        result = subprocess.run(['bash', '-c', script], capture_output=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn(b'', result.stderr)

if __name__ == '__main__':
    unittest.main()
