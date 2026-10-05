from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
MAIN_MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
RELEASE_MANIFEST = ROOT / "android/app/src/release/AndroidManifest.xml"
ANDROID_NS = "http://schemas.android.com/apk/res/android"
ANDROID_NAME = f"{{{ANDROID_NS}}}name"
ANDROID_CLEARTEXT = f"{{{ANDROID_NS}}}usesCleartextTraffic"

FORBIDDEN_NETWORK_PERMISSIONS = {
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.CHANGE_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.CHANGE_WIFI_STATE",
}


def _manifest_root(path: Path) -> ET.Element:
    return ET.parse(path).getroot()


def _release_manifest_paths() -> tuple[Path, ...]:
    paths = [MAIN_MANIFEST]
    if RELEASE_MANIFEST.exists():
        paths.append(RELEASE_MANIFEST)
    return tuple(paths)


def _declared_permissions(path: Path) -> set[str]:
    return {
        node.attrib[ANDROID_NAME]
        for node in _manifest_root(path).findall("uses-permission")
        if ANDROID_NAME in node.attrib
    }


def test_offline_first_release_declares_no_network_permissions():
    for manifest in _release_manifest_paths():
        declared = _declared_permissions(manifest)
        unexpected = declared & FORBIDDEN_NETWORK_PERMISSIONS
        assert not unexpected, (
            f"{manifest.relative_to(ROOT)} declares forbidden network permissions: "
            f"{sorted(unexpected)}"
        )


def test_pronunciation_microphone_permission_remains_explicit():
    assert "android.permission.RECORD_AUDIO" in _declared_permissions(MAIN_MANIFEST)


def test_cleartext_traffic_is_disabled_semantically():
    application = _manifest_root(MAIN_MANIFEST).find("application")
    assert application is not None
    assert application.attrib.get(ANDROID_CLEARTEXT) == "false"
