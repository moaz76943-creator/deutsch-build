from pathlib import Path

SRC = Path("lib/services/ai_gateway.dart").read_text()

def test_https_endpoint_has_strict_authority_guards():
    assert "baseUri.scheme != 'https'" in SRC
    assert "baseUri.host.isEmpty" in SRC
    assert "baseUri.userInfo.isNotEmpty" in SRC
    assert "baseUri.query.isNotEmpty || baseUri.fragment.isNotEmpty" in SRC
    assert "baseUri.host.length > 253" in SRC
