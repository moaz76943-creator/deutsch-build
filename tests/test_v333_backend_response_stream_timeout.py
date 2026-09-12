from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "lib/services/backend_http_transport.dart"


def test_response_stream_is_bounded_by_transport_timeout():
    text = SRC.read_text(encoding="utf-8")
    assert "final responseDeadline = DateTime.now().add(timeout);" in text
    assert "await iterator.moveNext().timeout(_remainingUntil(responseDeadline))" in text
    assert "await iterator.cancel();" in text
