#!/usr/bin/env python3
"""Static Data Safety / privacy contract audit for Deutsch بالعربي.

Checks AndroidManifest.xml against the public privacy policy invariants:
- RECORD_AUDIO is declared (required for on-device pronunciation).
- Network permissions are removed via tools:node="remove".
- Storage / media permissions are removed.
- allowBackup=false and networkSecurityConfig present.
- No cleartext traffic.

Exits 0 on pass, 1 on failure. Suitable for CI before Play upload.
"""
import pathlib
import sys
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "android" / "app" / "src" / "main" / "AndroidManifest.xml"

REQUIRED = {"android.permission.RECORD_AUDIO"}
FORBIDDEN_DECLARED = {
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.CHANGE_NETWORK_STATE",
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.READ_EXTERNAL_STORAGE",
    "android.permission.MANAGE_EXTERNAL_STORAGE",
    "android.permission.READ_MEDIA_IMAGES",
    "android.permission.READ_MEDIA_VIDEO",
    "android.permission.READ_MEDIA_AUDIO",
}

def main() -> int:
    if not MANIFEST.exists():
        print(f"FAIL: Manifest not found at {MANIFEST}")
        return 1

    tree = ET.parse(MANIFEST)
    root = tree.getroot()
    ns = {"android": "http://schemas.android.com/apk/res/android",
          "tools": "http://schemas.android.com/tools"}

    declared = set()
    removed = set()
    for perm in root.findall("uses-permission", ns):
        name = perm.get("{http://schemas.android.com/apk/res/android}name")
        node = perm.get("{http://schemas.android.com/tools}node")
        if name:
            if node == "remove":
                removed.add(name)
            else:
                declared.add(name)

    failures = []

    for req in REQUIRED:
        if req not in declared:
            failures.append(f"Missing required permission: {req}")

    for bad in FORBIDDEN_DECLARED:
        if bad in declared and bad not in removed:
            failures.append(f"Forbidden permission still declared (not removed): {bad}")

    app = root.find("application", ns)
    if app is None:
        failures.append("No <application> element")
    else:
        if app.get("{http://schemas.android.com/apk/res/android}allowBackup") != "false":
            failures.append("allowBackup must be false")
        if app.get("{http://schemas.android.com/apk/res/android}usesCleartextTraffic") != "false":
            failures.append("usesCleartextTraffic must be false")
        if not app.get("{http://schemas.android.com/apk/res/android}networkSecurityConfig"):
            failures.append("networkSecurityConfig missing")

    if failures:
        print("DATA SAFETY AUDIT: FAIL")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("DATA SAFETY AUDIT: PASS")
    print(f"  Required present: {sorted(REQUIRED & declared)}")
    print(f"  Explicitly removed: {len(removed)} network/storage permissions")
    return 0

if __name__ == "__main__":
    sys.exit(main())
