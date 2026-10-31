from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CI = (ROOT / '.github/workflows/build-apk.yml').read_text(encoding='utf-8')

assert 'Verify immutable Gradle wrapper' in CI
assert 'python3 tool/gradle_wrapper_integrity.py' in CI
assert 'gradle wrapper --gradle-version "$GRADLE_VERSION"' not in CI
assert './scripts/build.sh release' in CI
