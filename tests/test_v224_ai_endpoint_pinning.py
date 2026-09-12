from pathlib import Path

SRC = Path('lib/services/ai_gateway.dart').read_text(encoding='utf-8')


def test_cloud_ai_endpoint_requires_owner_host_pinning():
    assert 'allowedHosts' in SRC
    assert 'baseUri.host.toLowerCase()' in SRC
    assert 'Allowed AI endpoint host' in SRC


def test_composition_root_owns_compile_time_allowed_hosts():
    config = Path('lib/models/ai_runtime_config.dart').read_text(encoding='utf-8')
    factory = Path('lib/services/ai_gateway_factory.dart').read_text(encoding='utf-8')
    ui = Path('lib/ui_v35/conversation_pages.dart').read_text(encoding='utf-8')
    assert 'DEUTSCH_AI_ALLOWED_HOSTS' in config
    assert 'allowedHostsCsv:' in factory
    assert 'DEUTSCH_AI_ALLOWED_HOSTS' not in ui
