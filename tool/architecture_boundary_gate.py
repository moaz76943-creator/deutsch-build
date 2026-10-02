#!/usr/bin/env python3
"""Fail-closed static checks for high-value application architecture boundaries."""
from dataclasses import dataclass
from pathlib import Path
import re

@dataclass(frozen=True)
class Finding:
    file: str
    line: int
    reason: str

_CORE_MODEL_SERVICE = re.compile(r"^import\s+['\"](?:\.\./)+services/")
_SHARED_PREFS = re.compile(r"^import\s+['\"]package:shared_preferences/")
_NETWORK_CLIENT = re.compile(r"^import\s+['\"]package:http/")
_DART_IO = re.compile(r"^import\s+['\"]dart:io['\"]")
_ENV_READ = re.compile(r"String\.fromEnvironment\s*\(")
_ADAPTER = Path('lib/services/preferences_service.dart')
_NETWORK_ADAPTERS = {
    Path('lib/services/backend_http_transport.dart'),
    Path('lib/services/ai_gateway.dart'),
    Path('lib/services/pack_manager_service.dart'),
    Path('lib/services/pack_database_security.dart'),
}
_CONFIGURATION_FILES = {
    Path('lib/services/release.dart'),
}

_PLATFORM_ADAPTERS = {
    Path('lib/services/android_secure_session_storage.dart'),
    Path('lib/services/offline_backup_system.dart'),
    Path('lib/services/database_migration_helper.dart'),
    Path('lib/services/pack_manager_service.dart'),
}
_SCAN_ROOTS = (Path('lib/core'), Path('lib/models'), Path('lib/services'), Path('lib/ui'), Path('lib/ui_v35'))


def scan_tree(root: Path) -> list[Finding]:
    findings: list[Finding] = []
    for base in _SCAN_ROOTS:
        directory = root / base
        if not directory.exists():
            continue
        for path in sorted(directory.rglob('*.dart')):
            rel = path.relative_to(root).as_posix()
            for number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
                if base in (Path('lib/core'), Path('lib/models')) and _CORE_MODEL_SERVICE.search(line):
                    findings.append(Finding(rel, number, 'core/model depends on services'))
                rel_path = Path(rel)
                if _SHARED_PREFS.search(line) and rel != _ADAPTER.as_posix():
                    findings.append(Finding(rel, number, 'shared_preferences outside adapter'))
                if _NETWORK_CLIENT.search(line) and rel_path not in _NETWORK_ADAPTERS:
                    findings.append(Finding(rel, number, 'network client outside adapter'))
                if _DART_IO.search(line) and rel_path not in _NETWORK_ADAPTERS | _PLATFORM_ADAPTERS:
                    findings.append(Finding(rel, number, 'dart:io outside adapter'))
                if _ENV_READ.search(line) and not (rel_path in _CONFIGURATION_FILES or rel_path.name.endswith('_runtime_config.dart')):
                    findings.append(Finding(rel, number, 'compile-time environment read outside configuration boundary'))
    return findings


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('root', nargs='?', default='.')
    args = parser.parse_args()
    findings = scan_tree(Path(args.root).resolve())
    print(f'findings={len(findings)}')
    for finding in findings:
        print(f'{finding.file}:{finding.line}: {finding.reason}')
    raise SystemExit(1 if findings else 0)
