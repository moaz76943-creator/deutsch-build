from pathlib import Path

SRC = Path('lib/services/ai_gateway.dart').read_text(encoding='utf-8')


def test_cloud_ai_disables_automatic_redirect_following():
    assert '..followRedirects = false' in SRC


def test_cloud_ai_rejects_redirect_responses():
    assert "response.statusCode >= 300 && response.statusCode < 400" in SRC
