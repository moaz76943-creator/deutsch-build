from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CI = (ROOT / '.github/workflows/build-apk.yml').read_text(encoding='utf-8')
GUARD = (ROOT / 'scripts/build_guard.sh').read_text(encoding='utf-8')
LOCK = (ROOT / 'toolchain.lock').read_text(encoding='utf-8')

assert 'python3 tool/gradle_wrapper_integrity.py' in CI
assert 'python3 "$ROOT/tool/gradle_wrapper_integrity.py"' in GUARD
assert 'GRADLE_WRAPPER_JAR_SHA256=' in LOCK
assert r'distributionUrl=https\://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip' in CI or 'distributionUrl=https\\://services.gradle.org/distributions/gradle-' in (ROOT / 'android/gradle/wrapper/gradle-wrapper.properties').read_text()
