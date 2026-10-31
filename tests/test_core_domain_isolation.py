from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "lib" / "core"
FORBIDDEN_IMPORT_MARKERS = (
    "../services/",
    "../ui",
    "../data/",
    "package:flutter/",
    "dart:io",
)


def test_core_does_not_depend_on_upper_layers():
    violations = []
    for path in sorted(CORE.rglob("*.dart")):
        for line_no, line in enumerate(
            path.read_text(encoding="utf-8").splitlines(),
            1,
        ):
            if line.strip().startswith(("import ", "export ")) and any(
                marker in line for marker in FORBIDDEN_IMPORT_MARKERS
            ):
                violations.append(
                    f"{path.relative_to(ROOT)}:{line_no}: {line.strip()}"
                )
    assert not violations, (
        "Core layer has upward/platform dependencies:\n" + "\n".join(violations)
    )


def test_flutter_presentation_infrastructure_is_outside_core():
    assert not (CORE / "theme" / "app_theme.dart").exists()
    assert not (CORE / "widgets" / "glass_card.dart").exists()
    assert (ROOT / "lib/ui_v35/theme/app_theme.dart").exists()
    assert (ROOT / "lib/ui_v35/widgets/glass_card.dart").exists()


def test_legacy_service_facades_reexport_canonical_core_primitives():
    expected = {
        "lib/services/text_normalizer.dart": "GermanTextNormalizer",
        "lib/services/quality.dart": "GermanContentQuality",
        "lib/services/srs.dart": "export '../core/srs.dart';",
        "lib/services/memory.dart": "export '../core/memory.dart';",
        "lib/services/mastery.dart": "export '../core/mastery.dart';",
    }
    for relative_path, export_line in expected.items():
        text = (ROOT / relative_path).read_text(encoding="utf-8").strip()
        assert export_line in text, relative_path
