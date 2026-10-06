#!/usr/bin/env python3
"""Resolve, validate and optionally persist local release signing; never print secrets."""
from __future__ import annotations

import argparse
import base64
import getpass
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
    def unescape(value: str) -> str:
        return re.sub(r"\\(u[0-9a-fA-F]{4}|.)", lambda m: (
            chr(int(m[1][1:], 16)) if m[1].startswith("u") else
            {"t": "\t", "n": "\n", "r": "\r", "f": "\f"}.get(m[1], m[1])
        ), value)
    result = {}
    pending = ""
    for raw in path.read_text(encoding="iso-8859-1").splitlines():
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
    defaults = {
        "releaseStoreFile": str(default) if default.is_file() else "",
        "releaseStorePassword": "",
        "releaseKeyAlias": "release",
        "releaseKeyPassword": "",
    }
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


def escape(value: str) -> str:
    return "".join("\\" + c if c in "\\ =:#!" else
                   {"\n": "\\n", "\r": "\\r", "\t": "\\t"}.get(c,
                   f"\\u{ord(c):04x}" if ord(c) > 127 else c) for c in value)


def write_properties(path: Path, config: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    entries = properties(path)
    entries.update(config)
    # Keep all unrelated settings and replace signing keys instead of appending duplicates.
    with tempfile.NamedTemporaryFile(dir=path.parent, mode="w", encoding="ascii", delete=False) as tmp:
        temporary = Path(tmp.name)
        for name, value in entries.items():
            tmp.write(f"{escape(name)}={escape(value)}\n")
    temporary.chmod(0o600)
    temporary.replace(path)


def prepare(config: dict[str, str]) -> dict[str, str]:
    encoded = os.environ.get("RELEASE_KEYSTORE_BASE64", "")
    encoded_file = os.environ.get("RELEASE_KEYSTORE_BASE64_FILE", "")
    if encoded and encoded_file:
        raise SigningError("Use either RELEASE_KEYSTORE_BASE64 or RELEASE_KEYSTORE_BASE64_FILE, not both.")
    if encoded_file:
        encoded = Path(encoded_file).expanduser().read_text(encoding="ascii")
    if encoded:
        payload = base64.b64decode("".join(encoded.split()), validate=True)
        if not payload:
            raise SigningError("Decoded keystore is empty.")
        # Explicit decoding repairs stale worker paths without writing under RUNNER_TEMP.
        destination = Path(os.environ.get("RELEASE_KEYSTORE_PATH", Path.home() / ".gradle/release-key.jks")).expanduser().resolve()
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
                validate({**config, "releaseStoreFile": str(temporary)})
                temporary.chmod(0o600)
                temporary.replace(destination)
            finally:
                temporary.unlink(missing_ok=True)
    elif not Path(config["releaseStoreFile"]).is_file():
        local = Path.home() / ".gradle/release-key.jks"
        explicit = os.environ.get("ORG_GRADLE_PROJECT_releaseStoreFile") or os.environ.get("RELEASE_KEYSTORE_PATH")
        if local.is_file() and not explicit:
            # Recover only the local path. Credentials must always come from
            # private user properties, environment variables, or an interactive
            # setup prompt; they are never embedded in tracked source.
            config = dict(config)
            config["releaseStoreFile"] = str(local)
    validate(config)
    Path(config["releaseStoreFile"]).chmod(0o600)
    gradle_home = Path(os.environ.get("GRADLE_USER_HOME", Path.home() / ".gradle"))
    write_properties(gradle_home / "gradle.properties", config)
    return config


def _prompt_missing_credentials(config: dict[str, str]) -> dict[str, str]:
    """Fill missing private credentials only on an interactive terminal."""
    if not sys.stdin.isatty():
        return config
    has_key_input = bool(
        config.get("releaseStoreFile")
        or os.environ.get("RELEASE_KEYSTORE_BASE64")
        or os.environ.get("RELEASE_KEYSTORE_BASE64_FILE")
    )
    if not has_key_input:
        return config
    resolved = dict(config)
    if not resolved.get("releaseStorePassword"):
        resolved["releaseStorePassword"] = getpass.getpass("Release keystore password: ")
    if not resolved.get("releaseKeyAlias"):
        alias = input("Release key alias [release]: ").strip()
        resolved["releaseKeyAlias"] = alias or "release"
    if not resolved.get("releaseKeyPassword"):
        resolved["releaseKeyPassword"] = getpass.getpass("Release key password: ")
    return resolved


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare", action="store_true")
    args = parser.parse_args()
    try:
        config = resolve()
        if args.prepare:
            config = prepare(_prompt_missing_credentials(config))
        else:
            validate(config)
        print("[OK] Release signing configuration validated.")
        return 0
    except SigningError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1
    except (ValueError, OSError, subprocess.TimeoutExpired):
        # Never echo the Base64 input, passwords or Python exception payloads.
        print("[ERROR] Release signing setup failed. Check keystore path, Base64 input and alias/passwords. Existing signing material is preserved.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
