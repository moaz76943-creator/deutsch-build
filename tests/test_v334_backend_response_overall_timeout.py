from pathlib import Path


TRANSPORT = Path('lib/services/backend_http_transport.dart').read_text()


def test_response_read_uses_an_overall_deadline_not_only_per_chunk_timeout():
    assert 'final responseDeadline = DateTime.now().add(timeout);' in TRANSPORT
    assert '_remainingUntil(responseDeadline)' in TRANSPORT
    assert 'response.timeout(timeout)' not in TRANSPORT
