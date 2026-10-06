#!/usr/bin/env python3
"""Resolve, validate and optionally persist local release signing; never print secrets."""
from __future__ import annotations

import argparse
import base64
import getpass
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ALIASES = {
    "releaseStoreFile": ("RELEASE_KEYSTORE_PATH", "storeFile"),
    "releaseStorePassword": ("RELEASE_STORE_PASSWORD", "storePassword"),
    "releaseKeyAlias": ("RELEASE_KEY_ALIAS", "keyAlias"),
    "releaseKeyPassword": ("RELEASE_KEY_PASSWORD", "keyPassword"),
}


class SigningError(Exception):
    """Safe diagnostic that never contains credentials."""


def properties(path: Path) -> dict[str, str]:
    """Read Java properties, including escaped paths/passwords and continuations."""
    if not path.is_file():
        return {}
    return parse_properties(path.read_text(encoding="iso-8859-1"))


def parse_properties(text: str) -> dict[str, str]:
    def unescape(value: str) -> str:
        decoded = re.sub(r"\\(u[0-9a-fA-F]{4}|.)", lambda m: (
            chr(int(m[1][1:], 16)) if m[1].startswith("u") else
            {"t": "\t", "n": "\n", "r": "\r", "f": "\f"}.get(m[1], m[1])
        ), value)
        return decoded.encode("utf-16", "surrogatepass").decode("utf-16")
    result = {}
    pending = ""
    for raw in text.splitlines():
        line = pending + raw.lstrip()
        if (len(line) - len(line.rstrip("\\"))) % 2:
            pending = line[:-1]
            continue
        pending = ""
        if not line or line.startswith(("#", "!")):
            continue
        match = re.match(r"((?:\\.|[^\s=:])+)(?:\s*[=:]\s*|\s+)?(.*)", line)
        if match:
            result[unescape(match[1])] = unescape(match[2])
    return result


def resolve(root: Path = ROOT) -> dict[str, str]:
    home = Path.home()
    default = home / ".gradle/release-key.jks"
    gradle_home = Path(os.environ.get("GRADLE_USER_HOME", home / ".gradle"))
    gradle_props = properties(root / "android/gradle.properties")
    gradle_props.update(properties(gradle_home / "gradle.properties"))
    keys = properties(root / "android/key.properties")
    defaults = dict(zip(ALIASES, (str(default) if default.is_file() else "", "", "", "")))
    result = {}
    for name, (env_alias, file_alias) in ALIASES.items():
        result[name] = next((value for value in (
            os.environ.get("ORG_GRADLE_PROJECT_" + name), gradle_props.get(name),
            os.environ.get(env_alias), keys.get(name), keys.get(file_alias), defaults[name],
        ) if value and value.strip()), "")
    if result["releaseStoreFile"]:
        path = Path(result["releaseStoreFile"]).expanduser()
        if not path.is_absolute():
            path = root / "android/app" / path
        result["releaseStoreFile"] = str(path.resolve())
    return result


def resolve_ephemeral(root: Path = ROOT) -> dict[str, str]:
    """Resolve runner signing exclusively from environment variables.

    Ephemeral mode deliberately ignores Gradle/user/key property files so a
    self-hosted runner cannot inherit stale durable credentials from HOME.
    """
    result = {}
    for name, (env_alias, _) in ALIASES.items():
        result[name] = next((value for value in (
            os.environ.get("ORG_GRADLE_PROJECT_" + name),
            os.environ.get(env_alias),
        ) if value and value.strip()), "")
    if result["releaseStoreFile"]:
        path = Path(result["releaseStoreFile"]).expanduser()
        if not path.is_absolute():
            path = root / "android/app" / path
        result["releaseStoreFile"] = str(path.resolve())
    return result


def validate(config: dict[str, str]) -> None:
    if not all(config.values()):
        raise SigningError("Release signing is incomplete. Provide an existing ~/.gradle/release-key.jks or RELEASE_KEYSTORE_BASE64[_FILE] and signing credentials.")
    path = Path(config["releaseStoreFile"])
    if not path.is_file() or not path.stat().st_size:
        raise SigningError(f"Release keystore was not found or is empty: {path}")
    if not shutil.which("keytool"):
        raise SigningError("keytool is missing; install a supported JDK (17 or 21).")
    env = os.environ.copy()
    env["DEUTSCH_STORE_PASS"] = config["releaseStorePassword"]
    env["DEUTSCH_KEY_PASS"] = config["releaseKeyPassword"]
    # A certificate request exercises the private key and both passwords without modifying it.
    command = ["keytool", "-certreq", "-keystore", str(path), "-alias", config["releaseKeyAlias"],
               "-storepass:env", "DEUTSCH_STORE_PASS", "-keypass:env", "DEUTSCH_KEY_PASS", "-file", os.devnull]
    proc = subprocess.run(command, env=env, capture_output=True, timeout=30)
    if proc.returncode:
        raise SigningError("Keystore validation failed: check store password, private-key alias and key password. The existing keystore was preserved.")


def certificate_sha256(config: dict[str, str]) -> str:
    """Return the public signing-certificate fingerprint without exposing secrets."""
    env = os.environ.copy()
    env["DEUTSCH_STORE_PASS"] = config["releaseStorePassword"]
    proc = subprocess.run(
        [
            "keytool",
            "-exportcert",
            "-keystore",
            config["releaseStoreFile"],
            "-alias",
            config["releaseKeyAlias"],
            "-storepass:env",
            "DEUTSCH_STORE_PASS",
        ],
        env=env,
        capture_output=True,
        timeout=30,
    )
    if proc.returncode or not proc.stdout:
        raise SigningError(
            "Signing certificate fingerprint could not be read from the configured keystore."
        )
    return hashlib.sha256(proc.stdout).hexdigest()


def escape(value: str) -> str:
    def unicode_escape(c: str) -> str:
        encoded = c.encode("utf-16-be")
        return "".join(f"\\u{int.from_bytes(encoded[i:i+2], 'big'):04x}" for i in range(0, len(encoded), 2))
    return "".join("\\" + c if c in "\\ =:#!" else
                   {"\n": "\\n", "\r": "\\r", "\t": "\\t"}.get(c,
                   unicode_escape(c) if ord(c) > 127 else c) for c in value)


def write_properties(path: Path, config: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    entries = properties(path)
    if path.is_file() and all(entries.get(name) == value for name, value in config.items()):
        path.chmod(0o600)
        return
    # Preserve unrelated lines/comments/continuations and replace configured keys once.
    original = path.read_text(encoding="iso-8859-1") if path.is_file() else ""
    chunks, pending = [], ""
    for line in original.splitlines(keepends=True):
        pending += line
        content = line.rstrip("\r\n")
        if (len(content) - len(content.rstrip("\\"))) % 2:
            continue
        chunks.append(pending)
        pending = ""
    if pending:
        chunks.append(pending)
    output, written = [], set()
    for chunk in chunks:
        name = next(iter(parse_properties(chunk)), None)
        if name in config:
            if name not in written:
                output.append(f"{escape(name)}={escape(config[name])}\n")
                written.add(name)
        else:
            output.append(chunk)
    if output and not output[-1].endswith("\n"):
        output[-1] += "\n"
    output.extend(f"{escape(name)}={escape(value)}\n" for name, value in config.items() if name not in written)
    with tempfile.NamedTemporaryFile(dir=path.parent, mode="w", encoding="iso-8859-1", delete=False) as tmp:
        temporary = Path(tmp.name)
        tmp.write("".join(output))
    temporary.chmod(0o600)
    temporary.replace(path)


def prepare(
    config: dict[str, str],
    interactive: bool = False,
    persist: bool = True,
    ephemeral: bool = False,
) -> dict[str, str]:
    if ephemeral:
        if interactive:
            raise SigningError(
                "Ephemeral runner signing is non-interactive and must use environment variables."
            )
        persist = False
    # Setup is an explicit reconfiguration operation. RELEASE_* inputs must be
    # able to repair an obsolete profile; normal Gradle resolution stays unchanged.
    for name, (alias, _) in ALIASES.items():
        supplied = os.environ.get("ORG_GRADLE_PROJECT_" + name) or os.environ.get(alias)
        if supplied and supplied.strip():
            config[name] = supplied
    if config["releaseStoreFile"]:
        path = Path(config["releaseStoreFile"]).expanduser()
        if not path.is_absolute():
            path = ROOT / "android/app" / path
        config["releaseStoreFile"] = str(path.resolve())
    encoded = os.environ.get("RELEASE_KEYSTORE_BASE64", "")
    encoded_file = os.environ.get("RELEASE_KEYSTORE_BASE64_FILE", "")
    if encoded and encoded_file:
        raise SigningError("Use either RELEASE_KEYSTORE_BASE64 or RELEASE_KEYSTORE_BASE64_FILE, not both.")
    if encoded_file:
        encoded = Path(encoded_file).expanduser().read_text(encoding="ascii")
    local = Path.home() / ".gradle/release-key.jks"
    explicit = os.environ.get("ORG_GRADLE_PROJECT_releaseStoreFile") or os.environ.get("RELEASE_KEYSTORE_PATH")
    if (
        not ephemeral
        and not encoded
        and local.is_file()
        and not explicit
        and not Path(config["releaseStoreFile"]).is_file()
    ):
        config["releaseStoreFile"] = str(local)
    if interactive and sys.stdin.isatty():
        # Already configured credentials are verified before any prompting or writes.
        if not encoded and all(config.values()) and Path(config["releaseStoreFile"]).is_file():
            try:
                validate(config)
            except SigningError:
                print("Stored signing credentials are unusable; re-enter credentials for the existing key.", file=sys.stderr)
                for name in ("releaseStorePassword", "releaseKeyAlias", "releaseKeyPassword"):
                    config[name] = ""
        if not encoded and not Path(config["releaseStoreFile"]).is_file():
            encoded = getpass.getpass("Existing production JKS Base64 (hidden): ")
        for name in ("releaseStorePassword", "releaseKeyAlias", "releaseKeyPassword"):
            if not config[name]:
                config[name] = getpass.getpass(f"{name} (hidden): ")
    if encoded:
        payload = base64.b64decode("".join(encoded.split()), validate=True)
        if not payload:
            raise SigningError("Decoded keystore is empty.")
        if ephemeral and not explicit:
            raise SigningError(
                "Ephemeral signing requires an explicit runner keystore path in the environment."
            )
        destination = Path(
            config["releaseStoreFile"] if explicit else local
        ).expanduser().resolve()
        if ephemeral:
            runner_temp_raw = os.environ.get("RUNNER_TEMP", "").strip()
            if runner_temp_raw:
                runner_temp = Path(runner_temp_raw).expanduser().resolve()
                if destination != runner_temp and runner_temp not in destination.parents:
                    raise SigningError(
                        "Ephemeral signing keystore path must stay inside RUNNER_TEMP."
                    )
        config["releaseStoreFile"] = str(destination)
        if destination.exists():
            if destination.read_bytes() != payload:
                raise SigningError("Base64 input differs from the existing keystore; refusing to replace the release signing identity.")
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as tmp:
                temporary = Path(tmp.name)
                tmp.write(payload)
            try:
                temporary_config = {**config, "releaseStoreFile": str(temporary)}
                validate(temporary_config)
                expected_certificate = certificate_sha256(temporary_config)
                temporary.chmod(0o600)
                temporary.replace(destination)
                if certificate_sha256(config) != expected_certificate:
                    raise SigningError(
                        "Signing certificate identity changed while materializing the keystore."
                    )
            finally:
                temporary.unlink(missing_ok=True)
    validate(config)
    Path(config["releaseStoreFile"]).chmod(0o600)
    gradle_home = Path(os.environ.get("GRADLE_USER_HOME", Path.home() / ".gradle"))
    if persist:
        write_properties(gradle_home / "gradle.properties", config)
    return config


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--interactive", action="store_true")
    parser.add_argument("--ephemeral", action="store_true", help="Runner signing: do not persist credentials to user properties")
    parser.add_argument("--fingerprint", action="store_true", help="Print the public signing certificate SHA256")
    args = parser.parse_args()
    try:
        config = resolve_ephemeral() if args.ephemeral else resolve()
        if args.prepare:
            config = prepare(
                config,
                interactive=args.interactive,
                persist=not args.ephemeral,
                ephemeral=args.ephemeral,
            )
        else:
            validate(config)
        if args.fingerprint:
            print(certificate_sha256(config))
        else:
            print("Release signing: verified")
        return 0
    except SigningError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1
    except (EOFError, KeyboardInterrupt):
        print("[ERROR] Signing setup interrupted; existing production key was preserved.", file=sys.stderr)
        return 1
    except (ValueError, OSError, subprocess.SubprocessError):
        # Never echo the Base64 input, passwords or Python exception payloads.
        print("[ERROR] Release signing setup failed. Check keystore path, Base64 input and alias/passwords. Existing signing material is preserved.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
