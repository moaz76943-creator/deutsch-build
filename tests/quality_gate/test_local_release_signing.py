"""Behavioral release setup checks with disposable real keys, never production keys."""
import base64
import importlib.util
import os
from pathlib import Path
import shutil
import secrets
import pty
import select
import time
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("release_signing", ROOT / "tool/release_signing.py")
signing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(signing)


@pytest.fixture(scope="module")
def test_password():
    return secrets.token_urlsafe(24)


@pytest.fixture(scope="module")
def test_key(tmp_path_factory, test_password):
    if not shutil.which("keytool"):
        pytest.skip("JDK keytool required for signing integration checks")
    path = tmp_path_factory.mktemp("test-keystore") / "test-only.jks"
    result = subprocess.run([
        "keytool", "-genkeypair", "-storetype", "JKS", "-keystore", str(path),
        "-alias", "release", "-storepass", test_password, "-keypass", test_password,
        "-keyalg", "RSA", "-keysize", "2048", "-validity", "2", "-dname", "CN=Disposable Test",
    ], capture_output=True, text=True, timeout=30)
    assert result.returncode == 0, result.stderr
    return path.read_bytes()


@pytest.fixture
def local_home(tmp_path, monkeypatch, test_password):
    home = tmp_path / "home with spaces"
    home.mkdir()
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("GRADLE_USER_HOME", str(home / ".gradle"))
    for name in signing.ALIASES:
        monkeypatch.delenv("ORG_GRADLE_PROJECT_" + name, raising=False)
        monkeypatch.delenv(signing.ALIASES[name][0], raising=False)
    monkeypatch.delenv("RELEASE_KEYSTORE_BASE64", raising=False)
    monkeypatch.delenv("RELEASE_KEYSTORE_BASE64_FILE", raising=False)
    monkeypatch.setenv("RELEASE_STORE_PASSWORD", test_password)
    monkeypatch.setenv("RELEASE_KEY_PASSWORD", test_password)
    monkeypatch.setenv("RELEASE_KEY_ALIAS", "release")
    return home


def install_key(home, payload):
    key = home / ".gradle/release-key.jks"
    key.parent.mkdir(parents=True, exist_ok=True)
    key.write_bytes(payload)
    return key


def test_existing_keystore_setup_is_idempotent_and_preserves_other_properties(local_home, test_key):
    key = install_key(local_home, test_key)
    props = key.parent / "gradle.properties"
    props.write_text("# Preserve the owner's custom settings\ncustom.flag=retain\norg.gradle.jvmargs=-Xmx1536m\n")
    result = signing.prepare(signing.resolve())
    assert result["releaseStoreFile"] == str(key)
    before = props.read_bytes()
    before_time = props.stat().st_mtime_ns
    signing.prepare(signing.resolve())
    assert props.read_bytes() == before
    assert props.stat().st_mtime_ns == before_time
    assert "# Preserve the owner's custom settings" in props.read_text()
    assert signing.properties(props)["custom.flag"] == "retain"
    assert key.read_bytes() == test_key
    assert props.stat().st_mode & 0o777 == 0o600
    assert key.stat().st_mode & 0o777 == 0o600


def test_setup_repairs_stale_worker_path(local_home, test_key):
    key = install_key(local_home, test_key)
    (key.parent / "gradle.properties").write_text("releaseStoreFile=/nonexistent/runner/upload.jks\n")
    result = signing.prepare(signing.resolve())
    assert result["releaseStoreFile"] == str(key)
    assert signing.resolve()["releaseStoreFile"] == str(key)


def test_setup_explicit_alias_inputs_repair_obsolete_profile(local_home, test_key, test_password):
    key = install_key(local_home, test_key)
    props = key.parent / "gradle.properties"
    props.write_text("releaseStorePassword=obsolete\nreleaseKeyPassword=obsolete\nreleaseKeyAlias=obsolete\ncustom.keep=yes\n")
    assert signing.resolve()["releaseKeyAlias"] == "obsolete"
    result = signing.prepare(signing.resolve())
    assert result["releaseStorePassword"] == test_password
    assert result["releaseKeyAlias"] == "release"
    assert signing.properties(props)["custom.keep"] == "yes"


def test_explicit_cloud_path_and_credentials_override_local_key(local_home, test_key, monkeypatch):
    install_key(local_home, test_key)
    explicit = local_home / "cloud.jks"
    explicit.write_bytes(test_key)
    monkeypatch.setenv("ORG_GRADLE_PROJECT_releaseStoreFile", str(explicit))
    monkeypatch.setenv("ORG_GRADLE_PROJECT_releaseKeyAlias", "other-alias")
    config = signing.resolve()
    assert config["releaseStoreFile"] == str(explicit)
    assert config["releaseKeyAlias"] == "other-alias"
    with pytest.raises(signing.SigningError, match="validation failed"):
        signing.prepare(config)


def test_base64_file_decode_is_atomic_and_accepts_wrapped_input(local_home, test_key, monkeypatch):
    encoded = local_home / "input.b64"
    value = base64.b64encode(test_key).decode()
    encoded.write_text("\n".join(value[i:i + 64] for i in range(0, len(value), 64)))
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64_FILE", str(encoded))
    config = signing.prepare(signing.resolve())
    assert Path(config["releaseStoreFile"]).read_bytes() == test_key
    signing.prepare(signing.resolve())
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64", "another-input")
    with pytest.raises(signing.SigningError, match="either"):
        signing.prepare(signing.resolve())


def test_base64_relative_explicit_path_uses_android_app_semantics(local_home, test_key, monkeypatch, tmp_path):
    project = tmp_path / 'project'
    project.mkdir()
    monkeypatch.setattr(signing, 'ROOT', project)
    monkeypatch.setenv('RELEASE_KEYSTORE_PATH', 'private/key.jks')
    monkeypatch.setenv('RELEASE_KEYSTORE_BASE64', base64.b64encode(test_key).decode())
    config = signing.prepare(signing.resolve(project))
    expected = project / 'android/app/private/key.jks'
    assert Path(config['releaseStoreFile']) == expected
    assert expected.read_bytes() == test_key


def test_invalid_decoded_key_does_not_create_a_release_keystore(local_home, monkeypatch):
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64", base64.b64encode(b"not a keystore").decode())
    with pytest.raises(signing.SigningError, match="validation failed"):
        signing.prepare(signing.resolve())
    assert not (local_home / ".gradle/release-key.jks").exists()
    assert not list((local_home / ".gradle").glob("tmp*"))


def test_different_base64_never_replaces_existing_signing_identity(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64", base64.b64encode(b"different").decode())
    with pytest.raises(signing.SigningError, match="refusing to replace"):
        signing.prepare(signing.resolve())
    assert key.read_bytes() == test_key


def test_wrong_password_never_changes_gradle_properties(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    props = key.parent / "gradle.properties"
    props.write_text("custom.flag=unchanged\n")
    before = props.read_bytes()
    monkeypatch.setenv("ORG_GRADLE_PROJECT_releaseKeyPassword", "wrong-secret")
    with pytest.raises(signing.SigningError, match="validation failed"):
        signing.prepare(signing.resolve())
    assert props.read_bytes() == before
    assert key.read_bytes() == test_key


def test_missing_key_is_actionable_and_no_key_is_generated(local_home):
    with pytest.raises(signing.SigningError, match="incomplete"):
        signing.prepare(signing.resolve())
    assert not (local_home / ".gradle").exists()


def test_existing_key_never_supplies_implicit_passwords(local_home, test_key, monkeypatch):
    install_key(local_home, test_key)
    monkeypatch.delenv("RELEASE_STORE_PASSWORD")
    monkeypatch.delenv("RELEASE_KEY_PASSWORD")
    config = signing.resolve()
    assert not config["releaseStorePassword"]
    assert not config["releaseKeyPassword"]


def test_properties_roundtrip_preserves_escaped_passwords_and_paths(tmp_path):
    path = tmp_path / "settings.properties"
    values = {"storeFile": "/home/space path/key.jks", "password": " pass=word:!#\\\nع🔑"}
    signing.write_properties(path, values)
    assert signing.properties(path) == values


def test_ephemeral_runner_setup_never_persists_credentials(local_home, test_key, monkeypatch):
    runner_temp = local_home / 'runner-temporary'
    destination = runner_temp / 'release.jks'
    props = local_home / '.gradle/gradle.properties'
    props.parent.mkdir(parents=True, exist_ok=True)
    props.write_text('custom.keep=yes\n')
    before = props.read_bytes()
    monkeypatch.setenv('RUNNER_TEMP', str(runner_temp))
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseStoreFile', str(destination))
    monkeypatch.setenv('RELEASE_KEYSTORE_BASE64', base64.b64encode(test_key).decode())
    config = signing.prepare(
        signing.resolve_ephemeral(),
        ephemeral=True,
    )
    assert Path(config['releaseStoreFile']).read_bytes() == test_key
    assert props.read_bytes() == before
    assert signing.properties(props) == {'custom.keep': 'yes'}


def test_ephemeral_resolution_ignores_durable_gradle_credentials(
    local_home, test_key, test_password, monkeypatch
):
    props = local_home / '.gradle/gradle.properties'
    props.parent.mkdir(parents=True, exist_ok=True)
    props.write_text(
        'releaseStorePassword=stale-secret\n'
        'releaseKeyAlias=stale-alias\n'
        'releaseKeyPassword=stale-secret\n'
    )
    runner_temp = local_home / 'runner'
    destination = runner_temp / 'release.jks'
    monkeypatch.setenv('RUNNER_TEMP', str(runner_temp))
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseStoreFile', str(destination))
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseStorePassword', test_password)
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseKeyAlias', 'release')
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseKeyPassword', test_password)
    config = signing.resolve_ephemeral()
    assert config['releaseStorePassword'] == test_password
    assert config['releaseKeyAlias'] == 'release'
    assert config['releaseKeyPassword'] == test_password


def test_worker_shell_ephemeral_forwards_flag_keeps_home_clean_and_preserves_identity(
    local_home, test_key, test_password, monkeypatch, tmp_path
):
    runner_temp = tmp_path / 'runner-temp'
    runner_temp.mkdir()
    destination = runner_temp / 'release.jks'
    props = local_home / '.gradle/gradle.properties'
    props.parent.mkdir(parents=True, exist_ok=True)
    props.write_text('custom.keep=yes\n')
    before = props.read_bytes()
    encoded = base64.b64encode(test_key).decode()

    source_key = tmp_path / 'source.jks'
    source_key.write_bytes(test_key)
    expected_fingerprint = signing.certificate_sha256({
        'releaseStoreFile': str(source_key),
        'releaseStorePassword': test_password,
        'releaseKeyAlias': 'release',
        'releaseKeyPassword': test_password,
    })

    env = {
        **os.environ,
        'ROOT': str(ROOT),
        'RUNNER_TEMP': str(runner_temp),
        'RELEASE_KEYSTORE_BASE64': encoded,
        'ORG_GRADLE_PROJECT_releaseStoreFile': str(destination),
        'ORG_GRADLE_PROJECT_releaseStorePassword': test_password,
        'ORG_GRADLE_PROJECT_releaseKeyAlias': 'release',
        'ORG_GRADLE_PROJECT_releaseKeyPassword': test_password,
    }
    proc = subprocess.run(
        [
            'bash',
            '-c',
            'set -Eeuo pipefail; source "$ROOT/scripts/release-signing.sh"; '
            'prepare_release_signing --ephemeral',
        ],
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )
    output = proc.stdout + proc.stderr
    assert proc.returncode == 0, output
    assert props.read_bytes() == before
    assert destination.read_bytes() == test_key
    assert test_password not in output
    assert encoded not in output
    assert signing.certificate_sha256({
        'releaseStoreFile': str(destination),
        'releaseStorePassword': test_password,
        'releaseKeyAlias': 'release',
        'releaseKeyPassword': test_password,
    }) == expected_fingerprint


def test_ephemeral_cli_refuses_home_fallback(local_home, test_key, monkeypatch, tmp_path):
    runner_temp = tmp_path / 'runner-temp'
    runner_temp.mkdir()
    monkeypatch.setenv('RUNNER_TEMP', str(runner_temp))
    monkeypatch.setenv('RELEASE_KEYSTORE_BASE64', base64.b64encode(test_key).decode())
    monkeypatch.delenv('ORG_GRADLE_PROJECT_releaseStoreFile', raising=False)
    monkeypatch.delenv('RELEASE_KEYSTORE_PATH', raising=False)
    proc = subprocess.run(
        ['python3', str(ROOT / 'tool/release_signing.py'), '--prepare', '--ephemeral'],
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert proc.returncode != 0
    assert 'explicit runner keystore path' in proc.stderr
    assert not (local_home / '.gradle/release-key.jks').exists()
    assert not (local_home / '.gradle/gradle.properties').exists()


def test_ephemeral_cli_rejects_keystore_outside_runner_temp(
    local_home, test_key, monkeypatch, tmp_path
):
    runner_temp = tmp_path / 'runner-temp'
    runner_temp.mkdir()
    outside = tmp_path / 'outside/release.jks'
    monkeypatch.setenv('RUNNER_TEMP', str(runner_temp))
    monkeypatch.setenv('ORG_GRADLE_PROJECT_releaseStoreFile', str(outside))
    monkeypatch.setenv('RELEASE_KEYSTORE_BASE64', base64.b64encode(test_key).decode())
    proc = subprocess.run(
        ['python3', str(ROOT / 'tool/release_signing.py'), '--prepare', '--ephemeral'],
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert proc.returncode != 0
    assert 'inside RUNNER_TEMP' in proc.stderr
    assert not outside.exists()


def test_interactive_setup_hides_input_and_reuses_existing_key(local_home, test_key, test_password, monkeypatch):
    key = install_key(local_home, test_key)
    for alias, _ in signing.ALIASES.values():
        monkeypatch.delenv(alias, raising=False)

    interactive_timeout = float(
        os.environ.get("LOCAL_SIGNING_INTERACTIVE_TEST_TIMEOUT", "30")
    )
    child_pid, master = pty.fork()
    if child_pid == 0:
        os.execlp(
            "bash",
            "bash",
            str(ROOT / "scripts/setup_local_signing.sh"),
        )

    output = b""
    prompts = [
        (b"releaseStorePassword", test_password),
        (b"releaseKeyAlias", "release"),
        (b"releaseKeyPassword", test_password),
    ]
    sent = 0
    status = None
    deadline = time.monotonic() + interactive_timeout
    try:
        while time.monotonic() < deadline:
            readable, _, _ = select.select([master], [], [], 0.2)
            if readable:
                try:
                    output += os.read(master, 8192)
                except OSError:
                    pass
            while sent < len(prompts) and prompts[sent][0] in output:
                os.write(master, (prompts[sent][1] + "\n").encode())
                sent += 1

            waited_pid, waited_status = os.waitpid(child_pid, os.WNOHANG)
            if waited_pid == child_pid:
                status = waited_status
                break

        if status is None:
            os.kill(child_pid, 9)
            _, status = os.waitpid(child_pid, 0)
            pytest.fail(
                "interactive signing setup timed out; PTY output="
                + output.decode(errors="replace")
            )
    finally:
        os.close(master)

    assert os.waitstatus_to_exitcode(status) == 0, output.decode(errors="replace")
    assert sent == 3
    assert test_password.encode() not in output
    assert key.read_bytes() == test_key
    signing.validate(signing.resolve())

def test_bash_setup_and_guard_use_existing_key_without_environment_credentials(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    # Signing-only preparation must not bootstrap/download Flutter inside Termux.
    monkeypatch.setenv("PREFIX", "/data/data/com.termux/files/usr")
    signing.write_properties(key.parent / "gradle.properties", signing.resolve())
    for alias, _ in signing.ALIASES.values():
        monkeypatch.delenv(alias, raising=False)
    setup = subprocess.run(["bash", "-x", str(ROOT / "scripts/local-release.sh"), "--setup-only"],
                           capture_output=True, text=True, timeout=30)
    assert setup.returncode == 0, setup.stdout + setup.stderr
    assert signing.resolve()["releaseStorePassword"] not in setup.stdout + setup.stderr
    guard = subprocess.run(["bash", str(ROOT / "scripts/signing_guard.sh")],
                           capture_output=True, text=True, timeout=30)
    assert guard.returncode == 0, guard.stdout + guard.stderr
    assert key.read_bytes() == test_key


def test_guard_accepts_java21_and_checks_conservative_disk_policy(tmp_path, monkeypatch):
    tools = tmp_path / "sdk/bin"
    tools.mkdir(parents=True)
    android = tmp_path / "android"
    (android / "platforms/android-36").mkdir(parents=True)
    (android / "build-tools/36.0.0").mkdir(parents=True)
    (android / "ndk/28.2.13676358").mkdir(parents=True)
    for name, output in {
        "flutter": "Flutter 3.44.9", "dart": "Dart SDK version: 3.12.2",
        "java": 'openjdk version "21.0.12"',
        "javac": "javac 21.0.12",
    }.items():
        path = tools / name
        path.write_text("#!/bin/sh\nprintf '%s\\n' '" + output + "'\n")
        path.chmod(0o755)
    disk_marker = tmp_path / "disk-called"
    df = tools / "df"
    df.write_text(f"#!/bin/sh\ntouch '{disk_marker}'\nprintf 'Filesystem 1024-blocks Used Available Capacity Mounted\nfs 4194304 0 2097152 0 /\n'\n")
    df.chmod(0o755)
    monkeypatch.setenv("PATH", str(tools) + os.pathsep + os.environ["PATH"])
    monkeypatch.setenv("ANDROID_SDK_ROOT", str(android))
    proc = subprocess.run(["bash", str(ROOT / "scripts/build_guard.sh")],
                          capture_output=True, text=True, timeout=30)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "Java 21 (validated)" in proc.stdout
    assert disk_marker.exists()
    assert "WARN" in proc.stdout


@pytest.mark.parametrize("mode", ["fallback", "properties", "cli", "environment", "key_properties"])
def test_real_gradle_signing_resolution_on_java21(local_home, test_key, test_password, tmp_path, mode):
    gradle = os.environ.get("LOCAL_SIGNING_GRADLE")
    if not gradle:
        pytest.skip("Set LOCAL_SIGNING_GRADLE to run the isolated real Gradle fixture")
    key = install_key(local_home, test_key)
    fixture = tmp_path / "gradle-fixture"
    fixture.mkdir()
    shutil.copy(ROOT / "android/release-signing.gradle", fixture)
    (fixture / "settings.gradle").write_text("rootProject.name = 'signing-fixture'\n")
    expected_alias = "release"
    arguments = []
    if mode == "properties":
        props = key.parent / "gradle.properties"
        signing.write_properties(props, {"releaseKeyAlias": "property-alias"})
        expected_alias = "property-alias"
    if mode == "cli":
        arguments = ["-PreleaseKeyAlias=cli-alias"]
        expected_alias = "cli-alias"
    if mode == "key_properties":
        signing.write_properties(fixture / "key.properties", {
            "storeFile": "~/" + str(key.relative_to(local_home)), "keyAlias": "file-alias",
        })
        expected_alias = "file-alias"
    (fixture / "build.gradle").write_text("""
apply from: 'release-signing.gradle'
tasks.register('verifySigning') {
    doLast {
        def config = resolveReleaseSigning()
        assert config.releaseStoreFile == System.getenv('EXPECTED_KEYSTORE')
        assert config.releaseStorePassword == System.getenv('EXPECTED_TEST_PASSWORD')
        assert config.releaseKeyAlias == System.getenv('EXPECTED_ALIAS')
        assert config.releaseKeyPassword == System.getenv('EXPECTED_TEST_PASSWORD')
        println 'SIGNING RESOLUTION PASS'
    }
}
""")
    env = {**os.environ, "EXPECTED_KEYSTORE": str(key), "EXPECTED_ALIAS": expected_alias, "EXPECTED_TEST_PASSWORD": test_password}
    if mode == "key_properties":
        env.pop("RELEASE_KEY_ALIAS", None)
    if mode == "environment":
        signing.write_properties(key.parent / "gradle.properties", {"releaseKeyAlias": "stale-alias"})
        env["ORG_GRADLE_PROJECT_releaseKeyAlias"] = "env-alias"
        env["EXPECTED_ALIAS"] = "env-alias"
    proc = subprocess.run([gradle, "--no-daemon", "--offline", "-p", str(fixture),
                           "verifySigning", *arguments], env=env, capture_output=True, text=True, timeout=120)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "SIGNING RESOLUTION PASS" in proc.stdout


def test_release_signing_cli_never_emits_credentials(local_home, test_key, test_password):
    install_key(local_home, test_key)
    proc = subprocess.run(["python3", str(ROOT / "tool/release_signing.py"), "--prepare"],
                          capture_output=True, text=True, timeout=30)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert test_password not in proc.stdout + proc.stderr
    assert "ORG_GRADLE_PROJECT_releaseStorePassword" not in proc.stdout + proc.stderr
    forbidden = subprocess.run(["python3", str(ROOT / "tool/release_signing.py"), "--exports"],
                               capture_output=True, text=True, timeout=30)
    assert forbidden.returncode != 0
    assert test_password not in forbidden.stdout + forbidden.stderr


def test_production_signing_sources_have_no_embedded_password_defaults(local_home, test_key, monkeypatch):
    install_key(local_home, test_key)
    for alias, _ in signing.ALIASES.values():
        monkeypatch.delenv(alias, raising=False)
    config = signing.resolve()
    assert config['releaseStorePassword'] == config['releaseKeyPassword'] == ''
    source = (ROOT / 'android/release-signing.gradle').read_text()
    assert 'releaseStorePassword: null' in source
    assert 'releaseKeyPassword: null' in source


def test_ephemeral_shell_check_never_falls_back_to_home_credentials(
    local_home, test_key, test_password, monkeypatch, tmp_path
):
    runner_temp = tmp_path / "runner-temp"
    runner_temp.mkdir()
    destination = runner_temp / "release.jks"
    destination.write_bytes(test_key)

    props = local_home / ".gradle/gradle.properties"
    props.parent.mkdir(parents=True, exist_ok=True)
    signing.write_properties(
        props,
        {
            "releaseStorePassword": test_password,
            "releaseKeyAlias": "release",
            "releaseKeyPassword": test_password,
        },
    )
    before = props.read_bytes()

    env = {
        **os.environ,
        "HOME": str(local_home),
        "GRADLE_USER_HOME": str(local_home / ".gradle"),
        "RUNNER_TEMP": str(runner_temp),
        "ORG_GRADLE_PROJECT_releaseStoreFile": str(destination),
    }
    for name in (
        "ORG_GRADLE_PROJECT_releaseStorePassword",
        "ORG_GRADLE_PROJECT_releaseKeyAlias",
        "ORG_GRADLE_PROJECT_releaseKeyPassword",
        "RELEASE_STORE_PASSWORD",
        "RELEASE_KEY_ALIAS",
        "RELEASE_KEY_PASSWORD",
    ):
        env.pop(name, None)

    proc = subprocess.run(
        [
            "bash",
            "-c",
            'set -Eeuo pipefail; source "$ROOT/scripts/release-signing.sh"; '
            "check_release_signing --ephemeral",
        ],
        env={**env, "ROOT": str(ROOT)},
        capture_output=True,
        text=True,
        timeout=30,
    )

    assert proc.returncode != 0
    assert "Release signing is incomplete" in proc.stderr
    assert props.read_bytes() == before
