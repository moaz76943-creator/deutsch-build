from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_ui_does_not_read_compile_time_environment_configuration():
    offenders = []
    for path in (ROOT / 'lib/ui').rglob('*.dart'):
        if 'String.fromEnvironment' in path.read_text(encoding='utf-8'):
            offenders.append(path.relative_to(ROOT).as_posix())
    for path in (ROOT / 'lib/ui_v35').rglob('*.dart'):
        if 'String.fromEnvironment' in path.read_text(encoding='utf-8'):
            offenders.append(path.relative_to(ROOT).as_posix())
    assert offenders == []


def test_ai_runtime_configuration_has_a_single_owner():
    config = ROOT / 'lib/models/ai_runtime_config.dart'
    factory = ROOT / 'lib/services/ai_gateway_factory.dart'
    assert config.exists()
    assert factory.exists()
    assert 'DEUTSCH_AI_BASE_URL' in config.read_text(encoding='utf-8')
    assert 'AiRuntimeConfig' in factory.read_text(encoding='utf-8')


def test_ai_gateway_is_composition_root_dependency():
    source = (ROOT / 'lib/services/app_dependencies.dart').read_text(encoding='utf-8')
    assert 'AiGateway' in source
    assert 'aiGateway' in source
