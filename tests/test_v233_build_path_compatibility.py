from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))

import v233_build_path_compatibility as gate


def test_build_paths_share_toolchain_and_keep_apk_commands():
    errors = gate.check()
    assert errors == [], '\n'.join(errors)


def test_ci_workflows_run_build_path_compatibility_gate():
    build_workflow = (ROOT / '.github' / 'workflows' / 'build-apk.yml').read_text()
    quality_workflow = (ROOT / '.github' / 'workflows' / 'quality.yml').read_text()
    assert 'python3 tool/v233_build_path_compatibility.py' in build_workflow
    assert 'python3 tool/v233_build_path_compatibility.py' in quality_workflow
