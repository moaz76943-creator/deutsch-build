#!/usr/bin/env python3
"""Write private, idempotent build settings without touching tracked Gradle files."""
import os
from pathlib import Path
import shutil
import sys

from release_signing import ROOT, write_properties


def main() -> None:
    flutter_root, sdk_root = map(Path, sys.argv[1:3])
    write_properties(ROOT / "android/local.properties", {
        "flutter.sdk": str(flutter_root.resolve()),
        "sdk.dir": str(sdk_root.resolve()),
    })
    workers = os.environ.get("LOCAL_BUILD_WORKERS", "1")
    if not workers.isdigit() or int(workers) < 1:
        raise SystemExit("LOCAL_BUILD_WORKERS must be a positive integer")
    config = {
        "org.gradle.workers.max": workers,
        "org.gradle.parallel": "false",
        "org.gradle.caching": "true",
        "org.gradle.daemon": "false",
        "org.gradle.jvmargs": os.environ.get("LOCAL_BUILD_JVMARGS", "-Xmx1536m -XX:MaxMetaspaceSize=512m -Dfile.encoding=UTF-8"),
    }
    if os.uname().machine in ("aarch64", "arm64"):
        aapt2 = shutil.which("aapt2")
        if not aapt2:
            raise SystemExit("ARM64 builds require native aapt2 (Termux package: aapt)")
        config["android.aapt2FromMavenOverride"] = aapt2
    gradle_home = Path(os.environ.get("GRADLE_USER_HOME", Path.home() / ".gradle"))
    write_properties(gradle_home / "gradle.properties", config)


if __name__ == "__main__":
    main()
