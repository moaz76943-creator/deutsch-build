from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
GATEWAY = ROOT / 'lib/services/ai_gateway.dart'
text = GATEWAY.read_text(encoding='utf-8')

def test_gateway_blocks_common_sensitive_payloads_before_http_send():
    assert '_guardOutgoingText' in text
    assert re.search(r"_sensitivePayload", text)

def test_gateway_checks_both_conversation_fields():
    assert 'scenario' in text and 'message' in text
    assert re.search(r"_guardOutgoingText\(scenario\)", text)
    assert re.search(r"_guardOutgoingText\(message\)", text)
