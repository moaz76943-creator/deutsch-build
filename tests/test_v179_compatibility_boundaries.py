from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def test_tts_plugin_has_one_infrastructure_boundary():
    adapter = ROOT / "lib/core/infrastructure/audio/flutter_tts_audio_engine.dart"
    assert adapter.exists()
    assert "package:flutter_tts/flutter_tts.dart" in adapter.read_text(encoding="utf-8")
    for path in LIB.rglob("*.dart"):
        if path == adapter:
            continue
        assert "package:flutter_tts/flutter_tts.dart" not in path.read_text(encoding="utf-8"), path


def test_tts_compatibility_shim_does_not_expose_plugin_type():
    text = read("lib/ui_v35/safe_ui.dart")
    assert "package:flutter_tts/flutter_tts.dart" not in text
    assert "tts_service.dart" in text
    assert "FlutterTts" not in text


def test_speech_and_preferences_have_single_platform_plugin_boundaries():
    boundaries = {
        "shared_preferences": {ROOT / "lib/services/preferences_service.dart"},
        "speech_to_text": {
            ROOT / "lib/core/infrastructure/audio/speech_to_text_engine.dart"
        },
    }
    for package, allowed in boundaries.items():
        needle = f"package:{package}/"
        for path in LIB.rglob("*.dart"):
            if needle in path.read_text(encoding="utf-8"):
                assert path in allowed, f"{package} leaked outside its adapter: {path}"


def test_legacy_ui_entrypoints_are_not_the_runtime_entrypoint():
    main = read("lib/main.dart")
    assert "ui/phase3/phase3_production_shell.dart" in main
    assert "ui_v35/app.dart" not in main
    assert "ui/app.dart" not in main
    audit = ROOT / "docs/LEGACY_UI_AUDIT.md"
    assert audit.exists()
    text = audit.read_text(encoding="utf-8")
    assert "lib/ui/app.dart" in text
    assert "lib/ui_v35" in text
    assert "keep" in text.lower() or "retain" in text.lower()


def test_current_ui_imports_tts_service_boundary_not_plugin():
    current_ui = ROOT / "lib/ui_v35"
    for path in current_ui.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        assert "package:flutter_tts/flutter_tts.dart" not in text, path
        if "SafeTtsController" in text:
            if "safe_ui.dart" in text or "tts_service.dart" in text:
                continue
            part = re.search(r"part of ['\"]([^'\"]+)['\"];", text)
            assert part is not None, path
            library = (path.parent / part.group(1)).resolve()
            library_text = library.read_text(encoding="utf-8")
            assert "safe_ui.dart" in library_text or "tts_service.dart" in library_text, path
