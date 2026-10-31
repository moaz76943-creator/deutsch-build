#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
WRAPPER = ROOT / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.jar'
LOCK = ROOT / 'toolchain.lock'
EXPECTED = 'GRADLE_WRAPPER_JAR_SHA256'
EXPECTED_DIST = 'GRADLE_DISTRIBUTION_SHA256'
EXPECTED_VERSION = 'GRADLE_VERSION'


def locked_sha256() -> str:
    text = LOCK.read_text(encoding='utf-8')
    match = re.search(rf'^{EXPECTED}=([0-9a-f]{{64}})$', text, re.M)
    if not match:
        raise RuntimeError(f'{EXPECTED} is missing or malformed')
    return match.group(1)


def verify_wrapper(root: Path = ROOT) -> tuple[bool, str]:
    wrapper = root / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.jar'
    lock = root / 'toolchain.lock'
    text = lock.read_text(encoding='utf-8')
    match = re.search(rf'^{EXPECTED}=([0-9a-f]{{64}})$', text, re.M)
    if not match:
        return False, f'{EXPECTED} is missing or malformed'
    if not wrapper.is_file() or wrapper.stat().st_size == 0:
        return False, f'Gradle Wrapper JAR is missing or empty: {wrapper.relative_to(root)}'
    actual = hashlib.sha256(wrapper.read_bytes()).hexdigest()
    expected = match.group(1)
    if actual != expected:
        return False, f'Gradle Wrapper JAR SHA-256 mismatch: expected {expected}, found {actual}'
    return True, f'Gradle Wrapper JAR SHA-256 verified: {actual}'



_CONFLICT_MARKER = re.compile(r'^(<<<<<<<|=======|>>>>>>>)', re.M)


def verify_distribution_properties(properties: Path, lock: Path) -> tuple[bool, str]:
    props_text = properties.read_text(encoding='utf-8')
    lock_text = lock.read_text(encoding='utf-8')
    # Java Properties keeps the last duplicate key. A merged conflict can
    # therefore select a different distributionUrl than the checksum beside it,
    # and the wrapper refuses to start. Require one URL and one checksum.
    if _CONFLICT_MARKER.search(props_text):
        return False, 'Gradle wrapper properties contain unresolved merge conflict markers'
    version_match = re.search(r'^GRADLE_VERSION=([^\n]+)$', lock_text, re.M)
    sha_match = re.search(r'^GRADLE_DISTRIBUTION_SHA256=([0-9a-f]{64})$', lock_text, re.M)
    urls = re.findall(r'^distributionUrl=(.+)$', props_text, re.M)
    sha_lines = re.findall(r'^distributionSha256Sum=(.*)$', props_text, re.M)
    shas = re.findall(r'^distributionSha256Sum=([0-9a-f]{64})$', props_text, re.M)
    if not version_match:
        return False, 'GRADLE_VERSION is missing from toolchain.lock'
    if not sha_match:
        return False, 'GRADLE_DISTRIBUTION_SHA256 is missing or malformed'
    if len(urls) != 1:
        return False, (
            'Gradle wrapper properties must declare exactly one distributionUrl, '
            f'found {len(urls)}'
        )
    if len(sha_lines) != 1 or len(shas) != 1:
        return False, 'Gradle distributionSha256Sum is missing or malformed'
    version = version_match.group(1).strip()
    expected_sha = sha_match.group(1)
    url = urls[0].replace('\\:', ':').strip()
    expected_url = f'https://services.gradle.org/distributions/gradle-{version}-all.zip'
    if url != expected_url:
        return False, f'Gradle distributionUrl mismatch: expected {expected_url}, found {url}'
    actual_props_sha = shas[0]
    if actual_props_sha != expected_sha:
        return False, f'distributionSha256Sum mismatch: expected {expected_sha}, found {actual_props_sha}'
    return True, f'Gradle distribution URL and SHA-256 verified for {version}'

def main() -> int:
    wrapper_ok, wrapper_message = verify_wrapper()
    dist_ok, dist_message = verify_distribution_properties(
        ROOT / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.properties',
        ROOT / 'toolchain.lock',
    )
    ok = wrapper_ok and dist_ok
    print('GRADLE WRAPPER INTEGRITY: PASS' if wrapper_ok else 'GRADLE WRAPPER INTEGRITY: FAIL')
    print(wrapper_message)
    print('GRADLE DISTRIBUTION INTEGRITY: PASS' if dist_ok else 'GRADLE DISTRIBUTION INTEGRITY: FAIL')
    print(dist_message)
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
