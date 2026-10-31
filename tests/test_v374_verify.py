from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tool.change_impact import analyze_changes
from tool.verification_cache import fingerprint, store
from tool.verify import CheckSpec, analyze_changes as _analyze_changes, build_plan, run_plan


def test_content_plan_contains_targeted_and_content_checks():
    report = analyze_changes(Path('.'), ['content/content_items.json'])
    names = [c.name for c in build_plan(report) if not c.skipped]
    assert 'content_quality' in names
    assert 'compiler_parity' in names
    assert 'full_regression' not in names


def test_uncertain_plan_escalates_to_full_regression():
    report = analyze_changes(Path('.'), ['unknown/file.xyz'])
    names = [c.name for c in build_plan(report) if not c.skipped]
    assert 'full_regression' in names


def test_skipped_checks_are_explicit():
    report = analyze_changes(Path('.'), ['content/content_items.json'])
    plan = build_plan(report)
    assert 'security' in {c.name for c in plan if c.skipped}


def test_release_execution_does_not_reuse_cached_pass(tmp_path):
    changed = ['lib/example.dart']
    changed_path = tmp_path / changed[0]
    changed_path.parent.mkdir(parents=True)
    changed_path.write_text('example', encoding='utf-8')
    (tmp_path / 'tool').mkdir()
    (tmp_path / 'tool' / 'verify.py').write_text('verify', encoding='utf-8')
    (tmp_path / 'tool' / 'change_impact.py').write_text('impact', encoding='utf-8')

    command = (sys.executable, '-c', 'raise SystemExit(1)')
    spec = CheckSpec('release_gate', command)
    cache_path = tmp_path / 'cache.json'
    fp = fingerprint(
        [changed_path, tmp_path / 'tool' / 'verify.py', tmp_path / 'tool' / 'change_impact.py'],
        config={'check': spec.name, 'command': spec.command},
        tool_version='V383',
    )
    store(cache_path, spec.name, fp, {'status': 'PASS'})

    report = run_plan(
        tmp_path,
        [spec],
        cache_path=cache_path,
        changed_files=changed,
        affected_files=changed,
        use_cache=False,
    )

    assert report.failed == ['release_gate']
    assert report.cached == []
