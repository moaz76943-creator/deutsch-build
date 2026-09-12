from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / '.github' / 'workflows' / 'build-apk.yml'


def _section(text: str, name: str) -> str:
    marker = f'      - name: {name}'
    start = text.index(marker)
    end = text.find('\n      - name:', start + 1)
    return text[start:] if end == -1 else text[start:end]


def test_signing_material_is_created_after_toolchain_setup():
    text = WORKFLOW.read_text(encoding='utf-8')
    signing_pos = text.index('      - name: Materialize release signing material')
    java_pos = text.index('      - name: Set up Java')
    gradle_pos = text.index('      - name: Set up Gradle')
    flutter_pos = text.index('      - name: Set up Flutter')
    build_pos = text.index('      - name: Build and verify release APK')
    assert java_pos < signing_pos < build_pos
    assert gradle_pos < signing_pos < build_pos
    assert flutter_pos < signing_pos < build_pos


def test_signing_material_is_private_and_never_uploaded_as_artifact():
    text = WORKFLOW.read_text(encoding='utf-8')
    signing = _section(text, 'Materialize release signing material')
    cleanup = _section(text, 'Remove CI-owned signing material')
    assert 'umask 077' in signing
    assert 'chmod 600 android/app/upload-keystore.jks' in signing
    assert 'if: always()' in cleanup
    artifact = _section(text, 'Upload private release artifact')
    assert 'upload-keystore.jks' not in artifact
