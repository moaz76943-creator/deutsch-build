from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_local_quality_gate_runs_architecture_and_flutter_analyze():
    text = (ROOT / 'scripts/local_quality_gate.sh').read_text(encoding='utf-8')
    assert 'tool/architecture_audit.py' in text
    assert 'flutter analyze' in text
    assert 'flutter test' in text
    assert 'flutter build' not in text


def test_atomic_design_system_files_do_not_import_audio_hardware_plugins():
    for path in (
        ROOT / 'lib/design_system/app_glass_card.dart',
        ROOT / 'lib/design_system/app_audio_button.dart',
        ROOT / 'lib/design_system/app_typography.dart',
    ):
        text = path.read_text(encoding='utf-8')
        assert 'package:flutter_tts/' not in text
        assert 'package:speech_to_text/' not in text
