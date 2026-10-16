import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('create_private_build_log.sh')


class PrivateLogTests(unittest.TestCase):
    def invoke(self, home, mode='debug'):
        return subprocess.run(['bash', str(SCRIPT), mode], env={**os.environ, 'HOME': str(home)},
                              capture_output=True, text=True)

    def test_private_log_directory_and_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.invoke(tmp)
            self.assertEqual(result.returncode, 0, result.stderr)
            p = Path(result.stdout.strip())
            self.assertEqual(p.parent.stat().st_mode & 0o777, 0o700)
            self.assertEqual(p.stat().st_mode & 0o777, 0o600)
            self.assertTrue(p.is_file())

    def test_unique_files_on_repeated_build(self):
        with tempfile.TemporaryDirectory() as tmp:
            a, b = self.invoke(tmp), self.invoke(tmp)
            self.assertEqual((a.returncode, b.returncode), (0, 0))
            self.assertNotEqual(a.stdout, b.stdout)

    def test_refuses_symlink_log_directory(self):
        with tempfile.TemporaryDirectory() as tmp:
            home, target = Path(tmp) / 'home', Path(tmp) / 'target'
            home.mkdir()
            target.mkdir()
            (home / '.deutsch_bilarabi_logs').symlink_to(target)
            self.assertEqual(self.invoke(home).returncode, 10)
            self.assertEqual(list(target.iterdir()), [])

    def test_existing_public_directory_is_secured(self):
        with tempfile.TemporaryDirectory() as tmp:
            log_dir = Path(tmp) / '.deutsch_bilarabi_logs'
            log_dir.mkdir(mode=0o755)
            os.chmod(log_dir, 0o755)
            self.assertEqual(self.invoke(tmp, 'release').returncode, 0)
            self.assertEqual(log_dir.stat().st_mode & 0o777, 0o700)

    def test_invalid_mode_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(self.invoke(tmp, 'other').returncode, 10)
            self.assertFalse((Path(tmp) / '.deutsch_bilarabi_logs').exists())


if __name__ == '__main__':
    unittest.main()
