"""Isolated shell tests for the production build helpers (no network/Flutter)."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parent / 'common.sh'


class BuildReliabilityTests(unittest.TestCase):
    def shell(self, statement, *, env=None):
        return subprocess.run(['bash', '-c', f'source "{SCRIPT}"; {statement}'],
                              capture_output=True, text=True, env=env)

    def test_fatal_codes_and_legacy_compatibility(self):
        for code in (10, 11, 12, 15, 16):
            result = self.shell(f'fatal {code} classified')
            self.assertEqual(code, result.returncode)
            self.assertIn('classified', result.stderr)
        self.assertEqual(self.shell('fatal previous_call').returncode, 1)

    def test_dependency_success_and_mandatory_locked_command(self):
        with tempfile.TemporaryDirectory() as directory:
            exe = Path(directory) / 'flutter'
            exe.write_text('#!/bin/sh\n[ "$*" = "pub get --enforce-lockfile" ] || exit 17\nexit 0\n')
            exe.chmod(0o700)
            env = {**os.environ, 'PATH': f'{directory}:{os.environ["PATH"]}'}
            self.assertEqual(self.shell('with_retry flutter pub get --enforce-lockfile', env=env).returncode, 0)

    def test_deterministic_failure_is_not_retried_and_secrets_are_hidden(self):
        with tempfile.TemporaryDirectory() as directory:
            counter = Path(directory) / 'counter'
            exe = Path(directory) / 'flutter'
            exe.write_text(f'#!/bin/sh\necho x >> "{counter}"\necho "storePassword=secret-key --pass secret-value" >&2\nexit 25\n')
            exe.chmod(0o700)
            env = {**os.environ, 'PATH': f'{directory}:{os.environ["PATH"]}'}
            result = self.shell('with_retry flutter pub get --enforce-lockfile', env=env)
            self.assertEqual(result.returncode, 25)
            self.assertEqual(counter.read_text().count('x'), 1)
            self.assertNotIn('secret-key', result.stderr + result.stdout)
            self.assertNotIn('secret-value', result.stderr + result.stdout)

    def test_transient_failure_has_bounded_retries_and_original_error_code(self):
        with tempfile.TemporaryDirectory() as directory:
            counter = Path(directory) / 'counter'
            exe = Path(directory) / 'flutter'
            exe.write_text(f'#!/bin/sh\necho x >> "{counter}"\necho "temporary failure storePassword=secret-key" >&2\nexit 23\n')
            exe.chmod(0o700)
            (Path(directory) / 'sleep').write_text('#!/bin/sh\nexit 0\n')
            (Path(directory) / 'sleep').chmod(0o700)
            env = {**os.environ, 'PATH': f'{directory}:{os.environ["PATH"]}'}
            result = self.shell('with_retry flutter pub get --enforce-lockfile', env=env)
            self.assertEqual(result.returncode, 23)
            self.assertEqual(counter.read_text().count('x'), 3)
            self.assertNotIn('secret-key', result.stdout + result.stderr)

    def test_interrupted_resolution_cleans_private_temp_log(self):
        with tempfile.TemporaryDirectory() as directory:
            exe = Path(directory) / 'flutter'
            exe.write_text('#!/bin/sh\necho "storePassword=hidden" >&2\nkill -TERM "$PPID"\nexit 0\n')
            exe.chmod(0o700)
            env = {**os.environ, 'TMPDIR': directory,
                   'PATH': f'{directory}:{os.environ["PATH"]}'}
            result = self.shell('with_retry flutter pub get --enforce-lockfile', env=env)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(sorted(p.name for p in Path(directory).iterdir()), ['flutter'])

    def test_transient_then_success(self):
        with tempfile.TemporaryDirectory() as directory:
            counter = Path(directory) / 'counter'
            exe = Path(directory) / 'flutter'
            exe.write_text(f'#!/bin/sh\necho x >> "{counter}"\nif [ "$(wc -l < "{counter}")" -eq 1 ]; then\n  echo "network error" >&2\n  exit 41\nfi\nexit 0\n')
            exe.chmod(0o700)
            (Path(directory) / 'sleep').write_text('#!/bin/sh\nexit 0\n')
            (Path(directory) / 'sleep').chmod(0o700)
            env = {**os.environ, 'PATH': f'{directory}:{os.environ["PATH"]}'}
            result = self.shell('with_retry flutter pub get --enforce-lockfile', env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(counter.read_text().count('x'), 2)


if __name__ == '__main__':
    unittest.main()
