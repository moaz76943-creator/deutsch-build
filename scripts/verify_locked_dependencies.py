#!/usr/bin/env python3
"""Fail-closed, stdlib-only direct-dependency preflight (not a pub solver)."""
import argparse
import re
from pathlib import Path

NAME = r'[A-Za-z][A-Za-z0-9_]*'
VERSION = re.compile(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$')


def declared_dependencies(text):
    result = {}
    section = None
    for line in text.splitlines():
        if line and not line[0].isspace() and not line.startswith('#'):
            section = line[:-1] if line.endswith(':') else None
            continue
        if section not in ('dependencies', 'dev_dependencies'):
            continue
        match = re.fullmatch(rf'  ({NAME}):(?:\s*(.*))?', line)
        if match:
            name, constraint = match.groups()
            if name in result:
                raise ValueError(f'duplicate direct dependency: {name}')
            if name in ('flutter', 'flutter_test'):
                continue
            if not constraint:
                raise ValueError(f'unsupported dependency declaration: {name}')
            result[name] = (section, constraint.strip("'\" "))
    return result


def locked_packages(text):
    result, current, in_packages = {}, None, False
    for line in text.splitlines():
        if line == 'packages:':
            in_packages = True
            continue
        if not in_packages:
            continue
        if line and not line[0].isspace():
            break
        match = re.fullmatch(rf'  ({NAME}):', line)
        if match:
            current = match.group(1)
            if current in result:
                raise ValueError(f'duplicate locked package: {current}')
            result[current] = {}
            continue
        match = re.match(r'^    (dependency|version|source):\s*(.*?)\s*$', line)
        if match and current:
            key, value = match.groups()
            result[current][key] = value.strip("'\"")
    return result


def tuple_version(raw):
    match = VERSION.fullmatch(raw)
    if not match:
        raise ValueError(f'unsupported version: {raw}')
    return tuple(int(n or 0) for n in match.groups())


def matches_constraint(raw, constraint):
    version = tuple_version(raw)
    if constraint == 'any':
        return True
    if constraint.startswith('^'):
        low = tuple_version(constraint[1:])
        major, minor, patch, _ = low
        if major:
            upper = (major + 1, 0, 0, 0)
        elif minor:
            upper = (0, minor + 1, 0, 0)
        else:
            upper = (0, 0, patch + 1, 0)
        return low <= version < upper
    if constraint.startswith(('>', '<')):
        parts = constraint.split()
        if not parts or any(not re.fullmatch(r'(?:>=|<=|>|<)\d+\.\d+\.\d+(?:\+\d+)?', p) for p in parts):
            raise ValueError(f'unsupported constraint: {constraint}')
        for part in parts:
            op = next(op for op in ('>=', '<=', '>', '<') if part.startswith(op))
            bound = tuple_version(part[len(op):])
            if not {'>=': version >= bound, '<=': version <= bound, '>': version > bound, '<': version < bound}[op]:
                return False
        return True
    return version == tuple_version(constraint)


def verify(pubspec, lock):
    declared = declared_dependencies(pubspec)
    locked = locked_packages(lock)
    errors = []
    for name, (section, constraint) in sorted(declared.items()):
        item = locked.get(name)
        if not item:
            errors.append(f'{name}: missing from pubspec.lock')
            continue
        expected_kind = 'direct main' if section == 'dependencies' else 'direct dev'
        if item.get('dependency') != expected_kind:
            errors.append(f'{name}: expected {expected_kind}, found {item.get("dependency", "missing")}')
        if not item.get('version'):
            errors.append(f'{name}: missing resolved version')
            continue
        try:
            if not matches_constraint(item['version'], constraint):
                errors.append(f'{name}: resolved {item["version"]} outside {constraint}')
        except ValueError as exc:
            errors.append(f'{name}: {exc}')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pubspec', type=Path, default=Path('pubspec.yaml'))
    parser.add_argument('--lock', type=Path, default=Path('pubspec.lock'))
    args = parser.parse_args()
    try:
        errors = verify(args.pubspec.read_text(), args.lock.read_text())
    except (OSError, ValueError) as exc:
        errors = [str(exc)]
    if errors:
        for error in errors:
            print(f'[DEPENDENCY_LOCK_ERROR] {error}')
        return 11
    print('[DEPENDENCY_LOCK_OK] Direct dependency metadata and constraints agree')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
