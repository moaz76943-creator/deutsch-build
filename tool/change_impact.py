#!/usr/bin/env python3
"""Fail-closed change impact analysis for fast development verification."""
from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
import re
import subprocess

class RiskLevel(Enum):
    LOW = 'LOW'
    MEDIUM = 'MEDIUM'
    HIGH = 'HIGH'
    CRITICAL = 'CRITICAL'

@dataclass(frozen=True)
class ImpactReport:
    changed_files: tuple[str, ...]
    affected_files: tuple[str, ...]
    risk: RiskLevel
    affected_domains: tuple[str, ...]
    selected_checks: tuple[str, ...]
    skipped_checks: tuple[str, ...]
    uncertain: bool


_IMPORT_RE = re.compile(r"(?:import|export)\s+['\"]([^'\"]+)['\"]")

def _resolve_import(root: Path, source: Path, target: str) -> str | None:
    if target.startswith('dart:'):
        return None
    if target.startswith('package:'):
        package, _, relative = target[len('package:'):].partition('/')
        if package != root.name or not relative:
            return None
        candidate = root / 'lib' / relative
    else:
        candidate = (source.parent / target).resolve()
    try:
        candidate = candidate.resolve()
        candidate.relative_to(root.resolve())
    except ValueError:
        return None
    if candidate.suffix != '.dart' or not candidate.exists():
        return None
    return candidate.relative_to(root.resolve()).as_posix()

def build_dependency_graph(root: Path) -> dict[str, set[str]]:
    """Build a reverse Dart import/export graph: dependency -> direct dependents."""
    graph: dict[str, set[str]] = {}
    for source in list((root / 'lib').rglob('*.dart')) + list((root / 'test').rglob('*.dart')) + list((root / 'tests').rglob('*.dart')):
        try:
            text = source.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue
        source_rel = source.relative_to(root).as_posix()
        for target in _IMPORT_RE.findall(text):
            dependency = _resolve_import(root, source, target)
            if dependency:
                graph.setdefault(dependency, set()).add(source_rel)
    return graph

def affected_dependents(graph: dict[str, set[str]], changed: set[str]) -> set[str]:
    """Return all transitive reverse dependents of changed files."""
    found: set[str] = set()
    pending = list(changed)
    while pending:
        dependency = pending.pop()
        for dependent in graph.get(dependency, set()):
            if dependent not in found and dependent not in changed:
                found.add(dependent)
                pending.append(dependent)
    return found

_RULES = [
    ('CRITICAL', ('auth', 'authentication', 'authorization', 'entitlement', 'payment', 'secret', 'encryption', 'secure_storage', 'credential'), ('security', 'privacy', 'full_regression')),
    ('HIGH', ('srs', 'mastery', 'learner', 'progress', 'repository', 'storage', 'network', 'api', 'backend', 'lib/core/', 'lib/services/'), ('targeted', 'integration', 'full_regression')),
    ('MEDIUM', ('lib/widgets/', 'lib/pages/', 'lib/ui/', 'lib/ui_v35/', 'presentation', 'accessibility'), ('targeted', 'accessibility')),
    ('LOW', ('content/', 'content_items', 'verb_conjugations', 'content_authoring', 'content_quality', 'content_diff'), ('targeted', 'content_quality', 'compiler_parity')),
]

def detect_changed_files(root: Path) -> list[str]:
    try:
        result = subprocess.run(['git', '-C', str(root), 'status', '--porcelain', '-uall'], capture_output=True, text=True, check=True)
    except (OSError, subprocess.CalledProcessError):
        return []
    paths = []
    for line in result.stdout.splitlines():
        if len(line) >= 4:
            value = line[3:].strip()
            if ' -> ' in value:
                value = value.split(' -> ', 1)[1]
            paths.append(value)
    return sorted(set(paths))

def analyze_changes(root: Path, changed_files: list[str]) -> ImpactReport:
    normalized = tuple(sorted(set(str(Path(p).as_posix()) for p in changed_files)))
    if not normalized:
        return ImpactReport(normalized, normalized, RiskLevel.HIGH, ('unknown',), ('full_regression',), ('targeted', 'content_quality', 'compiler_parity', 'security', 'privacy', 'accessibility'), True)
    rank = {'LOW': 0, 'MEDIUM': 1, 'HIGH': 2, 'CRITICAL': 3}
    highest = 'LOW'
    domains: set[str] = set()
    checks: set[str] = set()
    uncertain = False

    graph = build_dependency_graph(root)
    direct = set(normalized)
    dependents = affected_dependents(graph, direct)
    impacted = tuple(sorted(direct | dependents))

    def apply_rule(path: str) -> bool:
        nonlocal highest
        matched = False
        lowered = path.lower()
        for level, needles, rule_checks in _RULES:
            if any(n in lowered for n in needles):
                matched = True
                if rank[level] > rank[highest]:
                    highest = level
                domains.add('security' if level == 'CRITICAL' else 'data' if level == 'HIGH' else 'ui' if level == 'MEDIUM' else 'content')
                checks.update(rule_checks)
                break
        return matched

    for path in normalized:
        if not apply_rule(path):
            uncertain = True
    for path in dependents:
        if not apply_rule(path):
            uncertain = True

    if dependents:
        domains.add('dependencies')
    if uncertain:
        highest = 'HIGH' if rank[highest] < rank['HIGH'] else highest
        domains.add('unknown')
        checks.update(('full_regression', 'security', 'architecture'))
    risk = RiskLevel(highest)
    all_checks = {'targeted', 'content_quality', 'compiler_parity', 'security', 'privacy', 'accessibility', 'integration', 'full_regression', 'architecture'}
    return ImpactReport(normalized, impacted, risk, tuple(sorted(domains)), tuple(sorted(checks)), tuple(sorted(all_checks - checks)), uncertain)
