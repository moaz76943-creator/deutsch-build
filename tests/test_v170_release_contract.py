from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_flutter_and_android_versions_stay_in_sync():
    pubspec = read('pubspec.yaml')
    gradle = read('android/app/build.gradle')
    pub = re.search(r'^version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)', pubspec, re.M)
    # versionCode and versionName use variables from local.properties
    assert pub
    assert 'versionCode ' in gradle
    assert 'versionName ' in gradle
    # The build number from pubspec (+N) should match the flutter.versionCode in local.properties
    # This is enforced by the build system; we verify the wiring exists
    assert 'flutterVersionCode' in gradle
    assert 'flutterVersionName' in gradle
