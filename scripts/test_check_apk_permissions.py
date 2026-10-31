"""Run the real Android permission gate using deterministic aapt mock output."""
import pathlib
import subprocess
import unittest

SCRIPT = pathlib.Path(__file__).with_name('check_apk_permissions.sh')


def check(mode, permissions):
    return subprocess.run(['bash', str(SCRIPT), mode], input=permissions,
                          text=True, capture_output=True)


class PermissionPolicyTests(unittest.TestCase):
    def test_permissionless_release(self):
        self.assertEqual(check('release', "package: com.deutschbilarabi.app\n").returncode, 0)

    def test_release_rejects_record_audio(self):
        out = check('release', "package: app\nuses-permission: name='android.permission.RECORD_AUDIO'\n")
        self.assertEqual(out.returncode, 16)

    def test_release_rejects_internet(self):
        out = check('release', "uses-permission: name='android.permission.INTERNET'\n")
        self.assertEqual(out.returncode, 16)

    def test_release_rejects_unlisted_permission(self):
        out = check('release', "uses-permission: name='android.permission.READ_CONTACTS'\n")
        self.assertEqual(out.returncode, 16)

    def test_release_rejects_sdk23_permissions(self):
        out = check('release', "uses-permission-sdk-23: name='android.permission.CAMERA'\n")
        self.assertEqual(out.returncode, 16)

    def test_debug_is_not_treated_as_release(self):
        self.assertEqual(check('debug', "uses-permission: name='android.permission.INTERNET'\n").returncode, 0)

    def test_invalid_mode_fails(self):
        self.assertEqual(check('other', '').returncode, 16)

    def test_no_sensitive_details_in_error(self):
        out = check('release', "uses-permission: name='android.permission.SECRET_VALUE'\n")
        self.assertNotIn('SECRET_VALUE', out.stderr)


if __name__ == '__main__':
    unittest.main()
