from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = (ROOT / 'install_flutter.sh').read_text()


def test_install_script_has_no_destructive_delete_or_move_commands():
    lines = SCRIPT.splitlines()
    active = [ln for ln in lines if not ln.lstrip().startswith('#')]
    assert not any('rm -rf' in ln for ln in active)
    assert not any('rm -f' in ln for ln in active)
    assert not any(' mv ' in f' {ln.strip()} ' for ln in active)


def test_install_script_does_not_replace_existing_toolchain_paths():
    assert 'if [[ -e "$FLUTTER_ROOT" ]]' in SCRIPT
    assert 'refusing to overwrite it' in SCRIPT
    assert 'if [[ -e "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]]' in SCRIPT
    assert 'preserved' in SCRIPT.lower() or 'preserving' in SCRIPT.lower()


def test_install_script_uses_copy_not_move_for_staging_and_never_deletes_staging():
    assert 'cp -a ' in SCRIPT or 'cp -R ' in SCRIPT
    assert 'mv "$staging/cmdline-tools"' not in SCRIPT
    assert 'rm -rf "$staging"' not in SCRIPT


def test_install_script_keeps_existing_gradle_properties_intact():
    assert 'mv "$tmp" "$gp"' not in SCRIPT
    assert 'cp "$tmp" "$gp"' not in SCRIPT
