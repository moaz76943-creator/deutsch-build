import pathlib
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from verify_locked_dependencies import verify


def pub(main='example: ^2.3.0', dev=''):
    return f'name: offline\ndependencies:\n  flutter:\n    sdk: flutter\n  {main}\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n' + (f'  {dev}\n' if dev else '') + 'flutter:\n  uses-material-design: true\n'


def lock(name='example', version='2.4.1', kind='direct main'):
    return f'packages:\n  {name}:\n    dependency: "{kind}"\n    description:\n      name: {name}\n    source: hosted\n    version: "{version}"\nsdks:\n  dart: ">=3.0.0 <4.0.0"\n'


class LockTests(unittest.TestCase):
    def test_valid_caret(self):
        self.assertEqual(verify(pub(), lock()), [])

    def test_outside_bounded_range(self):
        self.assertIn('outside', verify(pub('example: ">=2.3.0 <2.4.0"'), lock())[0])

    def test_incorrect_direct_classification(self):
        self.assertIn('expected direct main', verify(pub(), lock(kind='direct dev'))[0])

    def test_missing_package(self):
        self.assertIn('missing from pubspec.lock', verify(pub(), lock(name='other'))[0])

    def test_exact_version(self):
        self.assertEqual(verify(pub('example: 0.5.42'), lock(version='0.5.42')), [])
        self.assertIn('outside', verify(pub('example: 0.5.42'), lock(version='0.5.41'))[0])

    def test_zero_major_caret(self):
        self.assertIn('outside', verify(pub('example: ^0.5.42'), lock(version='0.6.0'))[0])

    def test_missing_lock_cli_fails_closed(self):
        with tempfile.TemporaryDirectory() as folder:
            p = pathlib.Path(folder)
            (p / 'pubspec.yaml').write_text(pub())
            proc = subprocess.run([sys.executable, str(pathlib.Path(__file__).with_name('verify_locked_dependencies.py')),
                                  '--pubspec', str(p / 'pubspec.yaml'), '--lock', str(p / 'absent.lock')],
                                  capture_output=True, text=True)
            self.assertEqual(proc.returncode, 11)
            self.assertIn('DEPENDENCY_LOCK_ERROR', proc.stdout)

    def test_dev_dependency_kind(self):
        self.assertEqual(
            verify(pub('example: ^2.3.0', 'devtool: any'),
                   lock() .replace('sdks:', '  devtool:\n    dependency: "direct dev"\n    source: hosted\n    version: "1.2.3"\nsdks:')), [])

    def test_unknown_constraint_fails_closed(self):
        self.assertIn('unsupported', verify(pub('example: ~2.0'), lock())[0])

    def test_duplicate_declared_dependency_fails_closed(self):
        from verify_locked_dependencies import declared_dependencies
        with self.assertRaises(ValueError):
            declared_dependencies(pub('example: ^2.3.0', 'example: ^2.3.0'))

    def test_relevant_known_mismatch(self):
        self.assertTrue(verify(pub('sqflite_common_ffi: ">=2.3.0 <2.4.0"'), lock(name='sqflite_common_ffi', version='2.4.3', kind='direct dev')))


if __name__ == '__main__':
    unittest.main()
