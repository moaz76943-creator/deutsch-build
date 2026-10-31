#!/usr/bin/env python3
"""Fail-closed, read-only PR-file review guard for last-known-good pack assets.

Input is the complete GitHub REST /pulls/{number}/files response array, saved as
UTF-8 JSON. This does not authorize content publication or validate a new pack.
No network, writes, token access, or CI configuration changes are performed.
"""
import argparse
import json
from pathlib import Path
import sys

MAX_INPUT_BYTES = 4 * 1024 * 1024
MAX_FILES = 3000
PACK_ROOT = 'assets/content/packs/'
GENERATORS = frozenset({
    'tools/polyglot_v2/generate_deep_100_languages.py',
    'tools/polyglot_v2/generate_master_100_languages.py',
})
STATUS = frozenset({'added', 'removed', 'modified', 'renamed', 'copied', 'changed', 'unchanged'})


class UnsafePullRequest(ValueError):
    pass


def distinct_keys(pairs):
    result = {}
    for key, val in pairs:
        if key in result:
            raise UnsafePullRequest('duplicate JSON field')
        result[key] = val
    return result


def changes(raw, expected_files=None):
    if not isinstance(raw, bytes) or len(raw) > MAX_INPUT_BYTES:
        raise UnsafePullRequest('invalid or oversized review payload')
    try:
        payload = json.loads(raw.decode('utf-8'), object_pairs_hook=distinct_keys,
                             parse_constant=lambda _: (_ for _ in ()).throw(UnsafePullRequest('nonfinite JSON value')))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise UnsafePullRequest('invalid UTF-8 or JSON') from exc
    if not isinstance(payload, list) or len(payload) > MAX_FILES:
        raise UnsafePullRequest('expected complete bounded pull-request file list')
    if expected_files is not None and (type(expected_files) is not int or expected_files != len(payload)):
        raise UnsafePullRequest('incomplete PR file list: count does not match GitHub PR changed_files')
    seen = set()
    violations = []
    for item in payload:
        if not isinstance(item, dict):
            raise UnsafePullRequest('invalid changed-file entry')
        path, state = item.get('filename'), item.get('status')
        if not isinstance(path, str) or not path or not isinstance(state, str) or state not in STATUS:
            raise UnsafePullRequest('missing path or invalid file status')
        if path in seen:
            raise UnsafePullRequest('duplicate changed-file entry')
        seen.add(path)
        old = item.get('previous_filename')
        if state == 'renamed' and (not isinstance(old, str) or not old):
            raise UnsafePullRequest('rename source path is missing')
        if old is not None and (not isinstance(old, str) or not old):
            raise UnsafePullRequest('invalid previous path')
        for candidate in (path, old):
            if candidate and (candidate.startswith(PACK_ROOT)
                              or candidate in GENERATORS and state in ('removed', 'renamed')):
                violations.append({'filename': path, 'previous_filename': old,
                                   'status': state, 'protected_path': candidate})
                break
    return {'status': 'BLOCKED_PROTECTED_ASSET_MUTATION' if violations else 'NO_PROTECTED_ASSET_MUTATION',
            'files_checked': len(payload), 'violations': violations,
            'release_authorized': False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('pr_files_json', type=Path)
    parser.add_argument('--expected-files', type=int, required=True,
                        help='Exact changed_files count from GitHub PR metadata')
    args = parser.parse_args(argv)
    try:
        if not args.pr_files_json.is_file() or args.pr_files_json.stat().st_size > MAX_INPUT_BYTES:
            raise UnsafePullRequest('missing or oversized PR file inventory')
        outcome = changes(args.pr_files_json.read_bytes(), expected_files=args.expected_files)
        print(json.dumps(outcome, sort_keys=True))
        return 2 if outcome['violations'] else 0
    except (UnsafePullRequest, OSError) as exc:
        print(json.dumps({'status': 'INVALID_REVIEW_INPUT', 'error': str(exc),
                          'release_authorized': False}, sort_keys=True), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
