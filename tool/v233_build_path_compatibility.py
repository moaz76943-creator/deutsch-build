#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: Path) -> str:
    return path.read_text(encoding='utf-8')


def parse_lock(text: str):
    vals = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise ValueError(f'Invalid toolchain.lock line: {line}')
        k, v = line.split('=', 1)
        vals[k] = v
    return vals


def check() -> list[str]:
    errors: list[str] = []
    lock_path = ROOT / 'toolchain.lock'
    install = ROOT / 'install_flutter.sh'
    build = ROOT / 'build_deutsch.sh'
    scripts_build = ROOT / 'scripts' / 'build.sh'
    guard = ROOT / 'scripts' / 'build_guard.sh'
    workflow = ROOT / '.github' / 'workflows' / 'build-apk.yml'
    quality = ROOT / '.github' / 'workflows' / 'quality.yml'
    common = ROOT / 'scripts' / 'common.sh'
    termux_docs = ROOT / 'docs' / 'V173_TERMUX_TOOLCHAIN.md'

    for path in (lock_path, install, build, scripts_build, guard, common, workflow, quality, termux_docs):
        if not path.exists():
            errors.append(f'missing required build-path file: {path.relative_to(ROOT)}')

    lock = parse_lock(read(lock_path))
    required = {
        'FLUTTER_VERSION', 'DART_VERSION', 'JAVA_MAJOR', 'GRADLE_VERSION',
        'AGP_VERSION', 'KOTLIN_VERSION', 'ANDROID_COMPILE_SDK',
        'ANDROID_TARGET_SDK', 'ANDROID_MIN_SDK', 'ANDROID_BUILD_TOOLS_VERSION',
        'APK_ABI', 'CMDLINE_TOOLS_VERSION', 'GRADLE_WRAPPER_JAR_SHA256',
        'GRADLE_DISTRIBUTION_SHA256',
    }
    missing = sorted(required - lock.keys())
    if missing:
        errors.append('toolchain.lock missing keys: ' + ', '.join(missing))

    install_text = read(install)
    build_text = read(build)
    scripts_text = read(scripts_build)
    guard_text = read(guard)
    common_text = read(common)
    termux_docs_text = read(termux_docs)
    workflow_text = read(workflow)
    quality_text = read(quality)

    # Termux installer owns environment setup; build scripts remain host-neutral.
    if 'pkg install -y dart' in install_text:
        errors.append('Termux installer must not install standalone dart package')
    if 'sudo' in install_text:
        errors.append('Termux installer must not require sudo')
    if 'rm -rf "$HOME/flutter"' in install_text or 'rm -rf "$ANDROID_HOME"' in install_text:
        errors.append('Termux installer contains destructive SDK removal')

    # The regular build path must not invoke Termux-only binaries or paths.
    if 'pkg ' in build_text or '/data/data/com.termux' in build_text:
        errors.append('build_deutsch.sh leaked Termux-only commands/paths')
    if 'pkg ' in scripts_text or '/data/data/com.termux' in scripts_text:
        errors.append('scripts/build.sh leaked Termux-only commands/paths')

    # All supported paths must read the single toolchain lock.
    if 'TOOLCHAIN_FILE="$ROOT/toolchain.lock"' not in common_text or 'load_toolchain()' not in common_text:
        errors.append('scripts/common.sh does not provide the canonical toolchain loader')
    for name, text in [('install_flutter.sh', install_text), ('build_deutsch.sh', build_text),
                       ('scripts/common.sh', common_text)]:
        if 'toolchain.lock' not in text:
            errors.append(f'{name} does not reference toolchain.lock')
    if 'source "$ROOT/scripts/common.sh"' not in guard_text or 'load_toolchain' not in guard_text:
        errors.append('build_guard.sh does not use the canonical toolchain loader')

    # GitHub must consume lock-derived versions, never hardcode a conflicting toolchain.
    for pattern, label in [
        (r'flutter-version:\s*["\']?3\.', 'hardcoded Flutter version in workflow'),
        (r'java-version:\s*["\']?2[0-9]', 'hardcoded Java version in workflow'),
        (r'gradle-version:\s*["\']?8\.', 'hardcoded Gradle version in workflow'),
    ]:
        if re.search(pattern, workflow_text):
            errors.append(label)
        if re.search(pattern, quality_text):
            errors.append(label + ' (quality workflow)')

    # Documentation must not advertise a conflicting Flutter toolchain.
    if lock.get('FLUTTER_VERSION') and f"Flutter target: {lock['FLUTTER_VERSION']}" not in termux_docs_text:
        errors.append('Termux toolchain documentation disagrees with toolchain.lock')
    # The release build itself is preserved; this gate must not replace the build command.
    if 'flutter build apk --release' not in scripts_text:
        errors.append('release APK build command is missing')
    if 'flutter build apk --debug' not in scripts_text:
        errors.append('debug APK build command is missing')
    if 'flutter pub get --enforce-lockfile' not in scripts_text:
        errors.append('lockfile enforcement is missing from build path')

    return errors


if __name__ == '__main__':
    errs = check()
    if errs:
        print('V233 BUILD PATH COMPATIBILITY: FAIL')
        for err in errs:
            print(' - ' + err)
        sys.exit(1)
    print('V233 BUILD PATH COMPATIBILITY: PASS')
