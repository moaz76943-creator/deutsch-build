#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAX_LINES = 1000
GENERATED = ROOT / "lib" / "data" / "generated"


def read(path: str) -> str:
    target = ROOT / path
    return target.read_text(encoding="utf-8") if target.exists() else ""


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def main() -> int:
    errors: list[str] = []

    gradle = read("android/app/build.gradle")
    proguard = read("android/app/proguard-rules.pro")
    bootstrap_dart = read("lib/bootstrap/production_bootstrap.dart")
    reporter = read("lib/services/runtime_failure_reporter.dart")
    bundle_script = read("scripts/build-aab.sh")

    if "minifyEnabled true" not in gradle or "shrinkResources true" not in gradle:
        fail("Release R8/resource shrinking is not enabled.", errors)
    if "signingConfig signingConfigs.secureRelease" not in gradle:
        fail("Release is not bound to secureRelease signing.", errors)
    if "signingConfigs.debug" in gradle:
        fail("Release/debug signing fallback remains in Android Gradle.", errors)

    required_r8 = (
        "native <methods>",
        "net.sqlcipher.**",
        "net.zetetic.database.**",
        "AndroidRecordedAudioPlayer",
        "AndroidPronunciationSignalProbe",
        "AndroidPackDatabaseKeyStore",
        "AndroidSecureSessionStorage",
        "-assumenosideeffects class android.util.Log",
    )
    for token in required_r8:
        if token not in proguard:
            fail(f"R8 production rule missing: {token}", errors)

    if "NoopRuntimeFailureReporter" not in bootstrap_dart:
        fail("Unified release crash reporter boundary is not wired.", errors)
    if "if (!kReleaseMode)" not in bootstrap_dart:
        fail("FlutterError details are not release-gated.", errors)
    if "print(" in reporter or "debugPrint(" in reporter:
        fail("Crash reporter stub emits debug output.", errors)

    debug_call = re.compile(r"(?<![A-Za-z0-9_])(?:print|debugPrint)\s*\(")
    for path in sorted((ROOT / "lib").rglob("*.dart")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        match = debug_call.search(text)
        if match:
            fail(
                f"Production Dart debug output remains: {path.relative_to(ROOT)}",
                errors,
            )

    for path in sorted((ROOT / "lib").rglob("*.dart")):
        try:
            path.relative_to(GENERATED)
            continue
        except ValueError:
            pass
        lines = len(path.read_text(encoding="utf-8").splitlines())
        if lines > MAX_LINES:
            fail(
                f"Implementation file exceeds {MAX_LINES} lines: "
                f"{path.relative_to(ROOT)} ({lines})",
                errors,
            )

    if (
        ROOT
        / "lib/features/progress/domain/repositories/"
        "in_memory_learner_progress_repository.dart"
    ).exists():
        fail("Testing in-memory progress repository remains in production lib/.", errors)

    if "flutter build appbundle --release" not in bundle_script:
        fail("Production App Bundle build command is missing.", errors)
    if "--obfuscate" not in bundle_script or "--split-debug-info" not in bundle_script:
        fail("Production App Bundle Dart hardening is incomplete.", errors)
    if "jarsigner -verify -strict" not in bundle_script:
        fail("Production App Bundle signature verification is missing.", errors)

    ios_root = ROOT / "ios"
    if ios_root.exists():
        pbx = ios_root / "Runner.xcodeproj" / "project.pbxproj"
        if not pbx.exists():
            fail("iOS platform exists without Runner Xcode project.", errors)
        else:
            ios_text = pbx.read_text(encoding="utf-8", errors="ignore")
            if "CODE_SIGN_STYLE" not in ios_text:
                fail("iOS CODE_SIGN_STYLE is not configured.", errors)
            if "PRODUCT_BUNDLE_IDENTIFIER" not in ios_text:
                fail("iOS PRODUCT_BUNDLE_IDENTIFIER is not configured.", errors)
        ios_state = "PRESENT"
    else:
        ios_state = "NOT_APPLICABLE_NO_IOS_PLATFORM"

    if errors:
        print("PHASE17 PRODUCTION GATE: FAIL")
        for error in errors:
            print("ERROR:", error)
        return 1

    print("PHASE17 PRODUCTION GATE: PASS")
    print(f"IOS_SIGNING_STATE={ios_state}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
