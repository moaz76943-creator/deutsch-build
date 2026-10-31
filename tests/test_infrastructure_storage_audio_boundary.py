from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
INFRA_AUDIO = Path("lib/core/infrastructure/audio")


def test_audio_packages_are_isolated_to_infrastructure():
    forbidden = ("package:flutter_tts/", "package:audioplayers/", "package:speech_to_text/")
    leaks = []
    for path in LIB.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        for package in forbidden:
            if package in text:
                rel = path.relative_to(ROOT)
                if not rel.is_relative_to(INFRA_AUDIO):
                    leaks.append(f"{rel}: {package}")
    assert not leaks, "\n".join(leaks)


def test_audio_service_contract_and_tts_adapter_live_in_infrastructure():
    contract = ROOT / INFRA_AUDIO / "audio_service.dart"
    adapter = ROOT / INFRA_AUDIO / "flutter_tts_audio_engine.dart"
    assert contract.exists()
    assert adapter.exists()
    assert "abstract interface class AudioService" in contract.read_text(encoding="utf-8")
    assert "package:flutter_tts/flutter_tts.dart" in adapter.read_text(encoding="utf-8")


def test_speech_plugin_adapter_is_in_infrastructure():
    adapter = ROOT / INFRA_AUDIO / "speech_to_text_engine.dart"
    facade = ROOT / "lib/services/speech_service.dart"
    assert "package:speech_to_text/speech_to_text.dart" in adapter.read_text(encoding="utf-8")
    assert "package:speech_to_text/" not in facade.read_text(encoding="utf-8")


def test_secure_storage_contract_uses_sqlcipher_backend():
    storage = ROOT / "lib/core/infrastructure/storage/local_storage_repository.dart"
    backend = ROOT / "lib/core/infrastructure/storage/sqlcipher_storage_backend.dart"
    assert storage.exists()
    assert backend.exists()
    backend_text = backend.read_text(encoding="utf-8")
    assert "sqflite_sqlcipher" in backend_text
    assert "password:" in backend_text
    assert "cipher_integrity_check" in backend_text
