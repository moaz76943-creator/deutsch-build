#!/usr/bin/env python3
"""Write private, idempotent build settings without touching tracked Gradle files."""
import os
from pathlib import Path
import shutil
import shlex
import sys

from release_signing import ROOT, write_properties


def native_aapt2(prefix: str) -> str:
    native = Path(prefix) / "bin/aapt2"
    selected = str(native) if os.access(native, os.X_OK) else shutil.which("aapt2")
    if not selected:
        raise SystemExit("ARM64 builds require native aapt2 (Termux package: aapt)")
    with open(selected, "rb") as binary:
        header = binary.read(20)
    # Portable launchers are allowed; ELF executables must target ARM64.
    if header.startswith(b"\x7fELF") and (
        len(header) < 20 or header[4:6] != b"\x02\x01"
        or int.from_bytes(header[18:20], "little") != 183
    ):
        raise SystemExit("aapt2 is not ARM64; install native Termux tools with pkg install aapt")
    return selected


def main() -> None:
    flutter_root, sdk_root = map(Path, sys.argv[1:3])
    write_properties(ROOT / "android/local.properties", {
        "flutter.sdk": str(flutter_root.resolve()),
        "sdk.dir": str(sdk_root.resolve()),
    })
    workers = os.environ.get("LOCAL_BUILD_WORKERS", "1")
    if not workers.isdigit() or int(workers) < 1:
        raise SystemExit("LOCAL_BUILD_WORKERS must be a positive integer")
    # Host settings remain intact: resource overrides apply only to this Termux process.
    prefix = os.environ.get("PREFIX", "")
    termux = prefix.startswith("/data/data/") and prefix.endswith("/files/usr")
    if not termux:
        return
    if os.uname().machine not in ("aarch64", "arm64"):
        raise SystemExit("The phone build entrypoint requires ARM64 Termux")
    flags = [
        f"-Dorg.gradle.workers.max={workers}", "-Dorg.gradle.parallel=false",
        "-Dorg.gradle.caching=true", "-Dorg.gradle.daemon=false",
        "-Dorg.gradle.jvmargs=" + os.environ.get("LOCAL_BUILD_JVMARGS", "-Xmx1024m -XX:MaxMetaspaceSize=384m -Dfile.encoding=UTF-8"),
        "-Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process",
    ]
    flags.append("-Dorg.gradle.project.android.aapt2FromMavenOverride=" + native_aapt2(prefix))
    opts = os.environ.get("GRADLE_OPTS", "") + " " + " ".join(shlex.quote(flag) for flag in flags)
    print("export GRADLE_OPTS=" + shlex.quote(opts.strip()))


if __name__ == "__main__":
    main()
