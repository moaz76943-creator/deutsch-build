from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SAFE=(ROOT/'lib/services/tts_service.dart').read_text()

def test_tts_operations_are_serialized_per_engine():
    assert 'class _TtsGate' in SAFE
    assert 'Expando<_TtsGate>' in SAFE
    assert '_ttsGates' in SAFE
    assert '_enqueueTts' in SAFE

def test_stop_invalidates_queued_speech():
    start=SAFE.index('Future<void> safeSpeak')
    body=SAFE[start:SAFE.index('Future<void> safeTtsStop', start)]
    assert 'generation' in body
    assert 'gate.generation' in body
    assert 'gate.generation' in body

def test_shutdown_invalidates_future_speech_and_is_awaitable():
    start=SAFE.index('Future<void> safeTtsShutdown')
    body=SAFE[start:]
    assert 'gate.generation++' in body
    assert 'shutdown()' in body
    assert 'await gate.tail' in body
