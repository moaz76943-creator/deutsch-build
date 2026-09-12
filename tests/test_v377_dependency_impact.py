from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.change_impact import build_dependency_graph, affected_dependents, analyze_changes


def test_dependency_graph_finds_transitive_reverse_dependents(tmp_path):
    lib = tmp_path / 'lib'
    (lib / 'a').mkdir(parents=True)
    (lib / 'b').mkdir(parents=True)
    (lib / 'c').mkdir(parents=True)
    (lib / 'c' / 'base.dart').write_text('class Base {}')
    (lib / 'b' / 'middle.dart').write_text("import '../c/base.dart';\nclass Middle extends Base {}")
    (lib / 'a' / 'top.dart').write_text("import '../b/middle.dart';\nclass Top extends Middle {}")

    graph = build_dependency_graph(tmp_path)
    assert 'lib/c/base.dart' in graph
    assert graph['lib/c/base.dart'] == {'lib/b/middle.dart'}
    assert affected_dependents(graph, {'lib/c/base.dart'}) == {'lib/b/middle.dart', 'lib/a/top.dart'}


def test_dependency_impact_escalates_for_affected_security_dependent(tmp_path):
    lib = tmp_path / 'lib'
    (lib / 'core').mkdir(parents=True)
    (lib / 'security').mkdir(parents=True)
    (lib / 'core' / 'contract.dart').write_text('class Contract {}')
    (lib / 'security' / 'auth_service.dart').write_text("import '../core/contract.dart';\nclass Auth {}")

    report = analyze_changes(tmp_path, ['lib/core/contract.dart'])
    assert report.uncertain is False
    assert report.risk.value == 'CRITICAL'
    assert 'security' in report.selected_checks
    assert 'lib/security/auth_service.dart' in report.affected_files
