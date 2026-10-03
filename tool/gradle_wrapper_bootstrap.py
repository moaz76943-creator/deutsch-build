#!/usr/bin/env python3
from __future__ import annotations

import hashlib
from pathlib import Path
import tempfile
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
WRAPPER_PATH = ROOT / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.jar'
WRAPPER_URL = 'https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar'
EXPECTED_SHA256 = '16caeaf66d57a0d1d2087fef6a97efa62de8da69afa5b908f40db35afc4342da'


def write_verified_wrapper(target: Path, payload: bytes, expected_sha256: str) -> tuple[bool, str]:
    actual = hashlib.sha256(payload).hexdigest()
    if actual != expected_sha256:
        return False, f'SHA-256 mismatch: expected {expected_sha256}, found {actual}'
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent, prefix='.gradle-wrapper-', suffix='.tmp', delete=False) as tmp:
        tmp.write(payload)
        tmp.flush()
        tmp_path = Path(tmp.name)
    tmp_path.replace(target)
    return True, f'Gradle Wrapper JAR installed with verified SHA-256: {actual}'


def download_and_install(target: Path = WRAPPER_PATH) -> tuple[bool, str]:
    req = Request(WRAPPER_URL, headers={'User-Agent': 'Deutsch-bilarabi-secure-build/1.0'})
    try:
        with urlopen(req, timeout=30) as response:
            payload = response.read(2 * 1024 * 1024)
            if len(payload) >= 2 * 1024 * 1024:
                return False, 'Gradle Wrapper JAR download exceeded the 2 MiB safety limit'
    except Exception as exc:
        return False, f'Unable to download official Gradle Wrapper JAR: {exc}'
    return write_verified_wrapper(target, payload, EXPECTED_SHA256)


def main() -> int:
    if WRAPPER_PATH.is_file() and WRAPPER_PATH.stat().st_size > 0:
        print('Gradle Wrapper JAR already present; integrity gate will verify it.')
        return 0
    ok, message = download_and_install()
    print('GRADLE WRAPPER BOOTSTRAP: PASS' if ok else 'GRADLE WRAPPER BOOTSTRAP: FAIL')
    print(message)
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
