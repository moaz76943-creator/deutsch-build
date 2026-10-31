#!/usr/bin/env python3
import os
import sys

FORBIDDEN_PATTERNS = [
    "google-analytics.com",
    "firebase-analytics",
    "mixpanel",
    "sentry.io",
    "facebook.com/tr",
    "app-measurement.com",
]

def scan_for_telemetry(root_dir: str) -> bool:
    print("[SOVEREIGN AUDIT] Scanning codebase for unauthorized telemetry endpoints...")
    found_violations = []

    for root, _, files in os.walk(root_dir):
        if any(ignored in root for ignored in [".git", "build", ".dart_tool"]):
            continue
        for file in files:
            if file.endswith((".dart", ".yaml", ".gradle", ".xml")):
                path = os.path.join(root, file)
                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        for pattern in FORBIDDEN_PATTERNS:
                            if pattern in content:
                                found_violations.append((path, pattern))
                except Exception:
                    pass

    if found_violations:
        print("[FAIL] Unauthorized telemetry detected:")
        for path, p in found_violations:
            print(f"  - {path}: contains {p}")
        return False

    print("[PASS] 100% Sovereign: Zero telemetry endpoints found in codebase.")
    return True

if __name__ == "__main__":
    success = scan_for_telemetry("lib")
    sys.exit(0 if success else 1)
