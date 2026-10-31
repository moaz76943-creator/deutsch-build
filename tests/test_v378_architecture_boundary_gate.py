from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tool'))

from architecture_boundary_gate import scan_tree


def test_core_and_models_cannot_depend_on_services(tmp_path):
    (tmp_path / 'lib/core').mkdir(parents=True)
    (tmp_path / 'lib/models').mkdir(parents=True)
    (tmp_path / 'lib/services').mkdir(parents=True)
    (tmp_path / 'lib/core/bad.dart').write_text("import '../services/repository.dart';\n", encoding='utf-8')
    (tmp_path / 'lib/models/bad.dart').write_text("import '../services/preferences_service.dart';\n", encoding='utf-8')
    findings = scan_tree(tmp_path)
    assert {f.reason for f in findings} == {'core/model depends on services'}


def test_shared_preferences_is_owned_by_adapter(tmp_path):
    (tmp_path / 'lib/core').mkdir(parents=True)
    (tmp_path / 'lib/services').mkdir(parents=True)
    (tmp_path / 'lib/core/bad.dart').write_text("import 'package:shared_preferences/shared_preferences.dart';\n", encoding='utf-8')
    (tmp_path / 'lib/services/preferences_service.dart').write_text("import 'package:shared_preferences/shared_preferences.dart';\n", encoding='utf-8')
    findings = scan_tree(tmp_path)
    assert [(f.file, f.reason) for f in findings] == [('lib/core/bad.dart', 'shared_preferences outside adapter')]


def test_clean_tree_has_no_boundary_findings():
    findings = scan_tree(ROOT)
    assert findings == []


def test_network_clients_are_confined_to_network_adapters(tmp_path):
    (tmp_path / 'lib/core').mkdir(parents=True)
    (tmp_path / 'lib/services').mkdir(parents=True)
    (tmp_path / 'lib/core/bad.dart').write_text(
        "import 'package:http/http.dart' as http;\n", encoding='utf-8'
    )
    (tmp_path / 'lib/services/backend_http_transport.dart').write_text(
        "import 'package:http/http.dart' as http;\n", encoding='utf-8'
    )
    findings = scan_tree(tmp_path)
    assert [(f.file, f.reason) for f in findings] == [
        ('lib/core/bad.dart', 'network client outside adapter')
    ]


def test_raw_dart_io_is_confined_to_network_and_platform_adapters(tmp_path):
    (tmp_path / 'lib/models').mkdir(parents=True)
    (tmp_path / 'lib/services').mkdir(parents=True)
    (tmp_path / 'lib/models/bad.dart').write_text(
        "import 'dart:io';\n", encoding='utf-8'
    )
    (tmp_path / 'lib/services/backend_http_transport.dart').write_text(
        "import 'dart:io';\n", encoding='utf-8'
    )
    findings = scan_tree(tmp_path)
    assert [(f.file, f.reason) for f in findings] == [
        ('lib/models/bad.dart', 'dart:io outside adapter')
    ]


def test_compile_time_environment_reads_are_confined_to_configuration_boundaries(tmp_path):
    (tmp_path / 'lib/ui').mkdir(parents=True)
    (tmp_path / 'lib/models').mkdir(parents=True)
    (tmp_path / 'lib/ui/bad.dart').write_text(
        "const endpoint = String.fromEnvironment('BAD');\n", encoding='utf-8'
    )
    (tmp_path / 'lib/models/backend_runtime_config.dart').write_text(
        "const endpoint = String.fromEnvironment('GOOD');\n", encoding='utf-8'
    )
    findings = scan_tree(tmp_path)
    assert [(f.file, f.reason) for f in findings] == [
        ('lib/ui/bad.dart', 'compile-time environment read outside configuration boundary')
    ]
