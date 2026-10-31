from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')


def test_flutter_and_android_versions_stay_in_sync():
    pubspec = read('pubspec.yaml')
    gradle = read('android/app/build.gradle')
    pub = re.search(r'^version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)', pubspec, re.M)
    code = re.search(r'versionCode\s+(\d+)', gradle)
    name = re.search(r'versionName\s+"([^"]+)"', gradle)
    assert pub and code and name
    assert f'{pub.group(1)}.{pub.group(2)}.{pub.group(3)}' == name.group(1)
    assert int(pub.group(4)) == int(code.group(1))
