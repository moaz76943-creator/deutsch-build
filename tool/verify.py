#!/usr/bin/env python3
"""Change-aware verification runner. Release mode is intentionally full."""
from __future__ import annotations
from dataclasses import dataclass, asdict, field
from pathlib import Path
import argparse, json, subprocess, sys
from concurrent.futures import ThreadPoolExecutor, as_completed
TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path: sys.path.insert(0, str(TOOL_DIR))
from change_impact import ImpactReport, analyze_changes, detect_changed_files
from verification_cache import fingerprint, load, is_valid, store

@dataclass(frozen=True)
class CheckSpec:
    name: str
    command: tuple[str, ...]
    domains: tuple[str, ...] = ()
    skipped: bool = False

@dataclass
class VerificationReport:
    changed: list[str]
    risk: str
    selected: list[str]
    skipped: list[str]
    passed: list[str]
    failed: list[str]
    security: str
    content: str
    compiler: str
    warnings: list[str]
    cached: list[str]
    affected_files: list[str] = field(default_factory=list)

def build_plan(report: ImpactReport, *, release: bool = False) -> list[CheckSpec]:
    root_cmd = (sys.executable,)
    catalog = {
        'targeted': CheckSpec('targeted', root_cmd + ('-m','pytest','-q','tests/test_v373_content_intelligence_language_boundary.py','tests/test_v372_shared_service_language_projection.py','tests/test_v356_bulk_content_import.py','tests/test_v357_bulk_apply.py')),
        'content_quality': CheckSpec('content_quality', root_cmd + ('tool/quality_audit.py',), ('content',)),
        'compiler_parity': CheckSpec('compiler_parity', root_cmd + ('-c', 'from pathlib import Path; from tool.content_compiler import compile_to, parity; d=Path("/tmp/deutsch_fast_compile"); compile_to(d, cache_path=Path(".verification_cache/compiler_parity.json")); print(parity(d))'), ('content',)),
        'security': CheckSpec('security', root_cmd + ('tool/security_audit.py',), ('security',)),
        'privacy': CheckSpec('privacy', root_cmd + ('tool/privacy_audit.py',), ('privacy',)),
        'accessibility': CheckSpec('accessibility', root_cmd + ('tool/accessibility_audit.py',), ('ui',)),
        'architecture': CheckSpec('architecture', root_cmd + ('tool/architecture_audit.py',), ('architecture',)),
        'integration': CheckSpec('integration', root_cmd + ('-m','pytest','-q','tests/test_core_domain_isolation.py')),
        'full_regression': CheckSpec('full_regression', root_cmd + ('-m','pytest','-q','tests')),
    }
    if release:
        names = ('full_regression','content_quality','compiler_parity','security','privacy','accessibility','architecture')
        return [catalog[n] for n in names]
    selected = set(report.selected_checks)
    plan = [catalog[n] for n in sorted(selected) if n in catalog]
    selected_names = {p.name for p in plan}
    plan.extend(CheckSpec(n, (), skipped=True) for n in sorted(set(catalog) - selected_names))
    return plan

def _run(spec: CheckSpec, root: Path) -> tuple[str, str, bool]:
    if spec.skipped: return ('SKIPPED — unaffected', '', True)
    proc = subprocess.run(spec.command, cwd=root, text=True, capture_output=True)
    output = (proc.stdout + proc.stderr).strip()
    return ('PASS' if proc.returncode == 0 else 'FAIL', output, proc.returncode == 0)

def _cache_scope(root: Path, changed_files: list[str], affected_files: list[str]) -> list[Path]:
    """Include direct changes and proven transitive dependents in cache fingerprints."""
    paths: list[Path] = []
    for relative in sorted(set(changed_files) | set(affected_files)):
        candidate = root / relative
        if candidate.exists():
            paths.append(candidate)
    paths.append(root / 'tool' / 'verify.py')
    paths.append(root / 'tool' / 'change_impact.py')
    return paths


def run_plan(
    root: Path,
    plan: list[CheckSpec],
    *,
    cache_path: Path,
    changed_files: list[str] | None = None,
    affected_files: list[str] | None = None,
    use_cache: bool = True,
) -> VerificationReport:
    """Run a verification plan; release callers must disable cache reuse."""
    changed = changed_files or []
    affected = affected_files or changed
    passed=[]; failed=[]; skipped=[]; warnings=[]; cached=[]
    content = compiler = security = 'NOT RUN'
    cache = load(cache_path) if use_cache else {}
    runnable: list[tuple[CheckSpec, str, dict]] = []
    for spec in plan:
        if spec.skipped:
            skipped.append(f'{spec.name}: SKIPPED — unaffected')
            continue
        paths = _cache_scope(root, changed, affected)
        fp = fingerprint(paths, config={'check':spec.name,'command':spec.command}, tool_version='V383')
        if use_cache and is_valid(cache.get(spec.name, {}), fp):
            passed.append(spec.name)
            cached.append(spec.name)
            if spec.name == 'content_quality': content = 'PASS'
            if spec.name == 'compiler_parity': compiler = 'PASS'
            if spec.name == 'security': security = 'PASS'
        else:
            runnable.append((spec, fp, cache))

    results: dict[str, tuple[str, str, bool, str]] = {}
    if runnable:
        with ThreadPoolExecutor(max_workers=min(4, len(runnable))) as executor:
            futures = {executor.submit(_run, spec, root): (spec, fp) for spec, fp, _ in runnable}
            for future in as_completed(futures):
                spec, fp = futures[future]
                status, output, ok = future.result()
                results[spec.name] = (status, output, ok, fp)

    for spec, fp, _ in runnable:
        status, output, ok, _ = results[spec.name]
        if status == 'PASS':
            passed.append(spec.name)
            if use_cache:
                store(cache_path, spec.name, fp, {'status':'PASS'})
        else:
            failed.append(spec.name)
        if spec.name == 'content_quality': content = status
        if spec.name == 'compiler_parity': compiler = status
        if spec.name == 'security': security = status
        if status != 'PASS' and output:
            warnings.append(f'{spec.name}: {output[-500:]}')
    selected = sorted({p.name for p in plan if not p.skipped})
    return VerificationReport(changed, 'UNKNOWN', selected, skipped, sorted(set(passed)), sorted(set(failed)), security, content, compiler, warnings, sorted(set(cached)), list(affected))

def main() -> int:
    ap=argparse.ArgumentParser(); sub=ap.add_subparsers(dest='mode', required=True)
    for mode in ('fast','release'):
        p=sub.add_parser(mode); p.add_argument('--changed', action='append'); p.add_argument('--report', type=Path)
    args=ap.parse_args(); root=Path(__file__).resolve().parents[1]
    changed=args.changed or detect_changed_files(root)
    impact=analyze_changes(root, changed)
    plan=build_plan(impact, release=args.mode=='release')
    report=run_plan(root, plan, cache_path=root/'.verification_cache/cache.json', changed_files=list(impact.changed_files), affected_files=list(impact.affected_files), use_cache=args.mode!='release')
    report.changed=list(impact.changed_files); report.affected_files=list(impact.affected_files); report.risk=impact.risk.value
    payload=json.dumps(asdict(report), ensure_ascii=False, indent=2)+'\n'
    if args.report: args.report.parent.mkdir(parents=True, exist_ok=True); args.report.write_text(payload, encoding='utf-8')
    else: print(payload, end='')
    return 1 if report.failed else 0
if __name__=='__main__': raise SystemExit(main())
