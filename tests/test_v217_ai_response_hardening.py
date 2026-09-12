from pathlib import Path
SRC = Path('lib/services/ai_gateway.dart').read_text()

def test_ai_gateway_bounds_remote_response_before_json_decode():
    assert 'maxResponseBytes' in SRC
    assert 'response.bodyBytes.length > maxResponseBytes' in SRC

def test_ai_gateway_requires_json_response_content_type():
    assert "response.headers['content-type']" in SRC
    assert "application/json" in SRC

def test_ai_gateway_keeps_request_timeout():
    assert '.timeout(timeout)' in SRC
