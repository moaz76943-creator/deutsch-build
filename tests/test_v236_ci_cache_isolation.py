from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
QUALITY = ROOT / '.github/workflows/quality.yml'
RELEASE = ROOT / '.github/workflows/build-apk.yml'


def _step_block(text: str, name: str) -> str:
    m = re.search(rf"- name: {re.escape(name)}\n(.*?)(?=\n      - name:|\Z)", text, re.S)
    assert m, f'missing step: {name}'
    return m.group(0)


def test_quality_workflow_disables_flutter_cache_for_untrusted_pr_surface():
    text = QUALITY.read_text(encoding='utf-8')
    block = _step_block(text, 'Set up Flutter')
    assert 'cache: false' in block


def test_quality_workflow_disables_gradle_cache_for_untrusted_pr_surface():
    text = QUALITY.read_text(encoding='utf-8')
    block = _step_block(text, 'Set up Gradle')
    assert 'cache-disabled: true' in block


def test_release_workflow_keeps_cache_only_on_protected_release_surface():
    text = RELEASE.read_text(encoding='utf-8')
    assert 'cache: true' in _step_block(text, 'Set up Flutter')
    assert 'gradle-version:' in _step_block(text, 'Set up Gradle')
