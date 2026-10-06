"""Behavioral release setup checks with disposable real keys, never production keys."""
import base64
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess

import pytest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("release_signing", ROOT / "tool/release_signing.py")
signing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(signing)

TEST_STORE_PASSWORD = "disposable-store-pass"
TEST_KEY_PASSWORD = "disposable-key-pass"
TEST_ALIAS = "release"


@pytest.fixture(scope="module")
def test_key(tmp_path_factory):
    if not shutil.which("keytool"):
        pytest.skip("JDK keytool required for signing integration checks")
    path = tmp_path_factory.mktemp("test-keystore") / "test-only.jks"
    result = subprocess.run([
        "keytool", "-genkeypair", "-storetype", "JKS", "-keystore", str(path),
        "-alias", TEST_ALIAS, "-storepass", TEST_STORE_PASSWORD, "-keypass", TEST_KEY_PASSWORD,
        "-keyalg", "RSA", "-keysize", "2048", "-validity", "2", "-dname", "CN=Disposable Test",
    ], capture_output=True, text=True, timeout=30)
    assert result.returncode == 0, result.stderr
    return path.read_bytes()


@pytest.fixture
def local_home(tmp_path, monkeypatch):
    home = tmp_path / "home with spaces"
    home.mkdir()
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("GRADLE_USER_HOME", str(home / ".gradle"))
    for name in signing.ALIASES:
        monkeypatch.delenv("ORG_GRADLE_PROJECT_" + name, raising=False)
        monkeypatch.delenv(signing.ALIASES[name][0], raising=False)
    monkeypatch.delenv("RELEASE_KEYSTORE_BASE64", raising=False)
    monkeypatch.delenv("RELEASE_KEYSTORE_BASE64_FILE", raising=False)
    return home


def install_key(home, payload):
    key = home / ".gradle/release-key.jks"
    key.parent.mkdir(parents=True, exist_ok=True)
    key.write_bytes(payload)
    return key


def configure_credentials(home):
    signing.write_properties(home / ".gradle/gradle.properties", {
        "releaseStorePassword": TEST_STORE_PASSWORD,
        "releaseKeyPassword": TEST_KEY_PASSWORD,
    })


def test_existing_keystore_setup_is_idempotent_and_preserves_other_properties(local_home, test_key):
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
    props = key.parent / "gradle.properties"
    signing.write_properties(props, {
        "custom.flag": "retain",
        "org.gradle.jvmargs": "-Xmx1536m",
    })
    result = signing.prepare(signing.resolve())
    assert result["releaseStoreFile"] == str(key)
    before = props.read_bytes()
    signing.prepare(signing.resolve())
    assert props.read_bytes() == before
    assert signing.properties(props)["custom.flag"] == "retain"
    assert key.read_bytes() == test_key
    assert props.stat().st_mode & 0o777 == 0o600
    assert key.stat().st_mode & 0o777 == 0o600


def test_setup_repairs_stale_worker_path(local_home, test_key):
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
    signing.write_properties(
        key.parent / "gradle.properties",
        {"releaseStoreFile": "/nonexistent/runner/upload.jks"},
    )
    result = signing.prepare(signing.resolve())
    assert result["releaseStoreFile"] == str(key)
    assert signing.resolve()["releaseStoreFile"] == str(key)


def test_explicit_cloud_path_and_credentials_override_local_key(local_home, test_key, monkeypatch):
    install_key(local_home, test_key)
    configure_credentials(local_home)
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
    configure_credentials(local_home)
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


def test_invalid_decoded_key_does_not_create_a_release_keystore(local_home, monkeypatch):
    configure_credentials(local_home)
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64", base64.b64encode(b"not a keystore").decode())
    with pytest.raises(signing.SigningError, match="validation failed"):
        signing.prepare(signing.resolve())
    assert not (local_home / ".gradle/release-key.jks").exists()
    assert not list((local_home / ".gradle").glob("tmp*"))


def test_different_base64_never_replaces_existing_signing_identity(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
    monkeypatch.setenv("RELEASE_KEYSTORE_BASE64", base64.b64encode(b"different").decode())
    with pytest.raises(signing.SigningError, match="refusing to replace"):
        signing.prepare(signing.resolve())
    assert key.read_bytes() == test_key


def test_wrong_password_never_changes_gradle_properties(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
    props = key.parent / "gradle.properties"
    signing.write_properties(props, {"custom.flag": "unchanged"})
    before = props.read_bytes()
    monkeypatch.setenv("ORG_GRADLE_PROJECT_releaseKeyPassword", "wrong-secret")
    with pytest.raises(signing.SigningError, match="validation failed"):
        signing.prepare(signing.resolve())
    assert props.read_bytes() == before
    assert key.read_bytes() == test_key


def test_missing_key_is_actionable_and_no_key_is_generated(local_home):
    configure_credentials(local_home)
    with pytest.raises(signing.SigningError, match="incomplete"):
        signing.prepare(signing.resolve())
    assert not (local_home / ".gradle/release-key.jks").exists()


def test_properties_roundtrip_preserves_escaped_passwords_and_paths(tmp_path):
    path = tmp_path / "settings.properties"
    values = {"storeFile": "/home/space path/key.jks", "password": " pass=word:!#\\\nع"}
    signing.write_properties(path, values)
    assert signing.properties(path) == values


def test_bash_setup_and_guard_use_existing_key_without_environment_credentials(local_home, test_key, monkeypatch):
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
    # Signing-only preparation must not bootstrap/download Flutter inside Termux.
    monkeypatch.setenv("PREFIX", "/data/data/com.termux/files/usr")
    setup = subprocess.run(["bash", "-x", str(ROOT / "scripts/local-release.sh"), "--setup-only"],
                           capture_output=True, text=True, timeout=30)
    assert setup.returncode == 0, setup.stdout + setup.stderr
    assert "deutsch2026" not in setup.stdout + setup.stderr
    guard = subprocess.run(["bash", str(ROOT / "scripts/signing_guard.sh")],
                           capture_output=True, text=True, timeout=30)
    assert guard.returncode == 0, guard.stdout + guard.stderr
    assert key.read_bytes() == test_key


def test_guard_accepts_java21_and_does_not_call_disk_probe(tmp_path, monkeypatch):
    tools = tmp_path / "sdk/bin"
    tools.mkdir(parents=True)
    android = tmp_path / "android"
    (android / "platforms/android-36").mkdir(parents=True)
    (android / "build-tools/36.0.0").mkdir(parents=True)
    for name, output in {
        "flutter": "Flutter 3.44.9", "dart": "Dart SDK version: 3.12.2",
        "java": 'openjdk version "21.0.12"',
    }.items():
        path = tools / name
        path.write_text("#!/bin/sh\nprintf '%s\\n' '" + output + "'\n")
        path.chmod(0o755)
    disk_marker = tmp_path / "disk-called"
    df = tools / "df"
    df.write_text(f"#!/bin/sh\ntouch '{disk_marker}'\nexit 1\n")
    df.chmod(0o755)
    monkeypatch.setenv("PATH", str(tools) + os.pathsep + os.environ["PATH"])
    monkeypatch.setenv("ANDROID_SDK_ROOT", str(android))
    proc = subprocess.run(["bash", str(ROOT / "scripts/build_guard.sh")],
                          capture_output=True, text=True, timeout=30)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "Java 21 (validated)" in proc.stdout
    assert not disk_marker.exists()


@pytest.mark.parametrize("mode", ["fallback", "properties", "cli", "environment", "key_properties"])
def test_real_gradle_signing_resolution_on_java21(local_home, test_key, tmp_path, mode):
    gradle = os.environ.get("LOCAL_SIGNING_GRADLE")
    if not gradle:
        pytest.skip("Set LOCAL_SIGNING_GRADLE to run the isolated real Gradle fixture")
    key = install_key(local_home, test_key)
    configure_credentials(local_home)
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
        assert config.releaseStorePassword == System.getenv('EXPECTED_STORE_PASSWORD')
        assert config.releaseKeyAlias == System.getenv('EXPECTED_ALIAS')
        assert config.releaseKeyPassword == System.getenv('EXPECTED_KEY_PASSWORD')
        println 'SIGNING RESOLUTION PASS'
    }
}
""")
    env = {
        **os.environ,
        "EXPECTED_KEYSTORE": str(key),
        "EXPECTED_ALIAS": expected_alias,
        "EXPECTED_STORE_PASSWORD": TEST_STORE_PASSWORD,
        "EXPECTED_KEY_PASSWORD": TEST_KEY_PASSWORD,
    }
    if mode == "environment":
        signing.write_properties(key.parent / "gradle.properties", {"releaseKeyAlias": "stale-alias"})
        env["ORG_GRADLE_PROJECT_releaseKeyAlias"] = "env-alias"
        env["EXPECTED_ALIAS"] = "env-alias"
    proc = subprocess.run([gradle, "--no-daemon", "--offline", "-p", str(fixture),
                           "verifySigning", *arguments], env=env, capture_output=True, text=True, timeout=120)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "SIGNING RESOLUTION PASS" in proc.stdout


def test_production_signing_sources_have_no_embedded_password_defaults():
    tool = (ROOT / "tool/release_signing.py").read_text(encoding="utf-8")
    gradle = (ROOT / "android/release-signing.gradle").read_text(encoding="utf-8")
    for source in (tool, gradle):
        assert "deutsch2026" not in source
        assert "releaseStorePassword:" not in source or "null" in source
        assert "releaseKeyPassword:" not in source or "null" in source


def test_release_signing_cli_never_emits_credentials(local_home, test_key):
    install_key(local_home, test_key)
    configure_credentials(local_home)
    proc = subprocess.run(
        ["python3", str(ROOT / "tool/release_signing.py"), "--prepare"],
        capture_output=True,
        text=True,
        timeout=30,
        env=os.environ.copy(),
    )
    output = proc.stdout + proc.stderr
    assert proc.returncode == 0, output
    assert TEST_STORE_PASSWORD not in output
    assert TEST_KEY_PASSWORD not in output
    assert "ORG_GRADLE_PROJECT_releaseStorePassword" not in output
    assert "ORG_GRADLE_PROJECT_releaseKeyPassword" not in output
