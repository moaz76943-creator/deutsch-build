from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.agents.anti_cheat_sentinel import scan_file


class AntiCheatSentinelTest(unittest.TestCase):
    def write(self, relative: str, content: str) -> tuple[Path, str]:
        root = Path(tempfile.mkdtemp(prefix="sentinel-test-"))
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return root, relative

    def test_rejects_audio_plugin_import_from_presentation(self) -> None:
        root, relative = self.write(
            "lib/ui_v35/conversation_page.dart",
            "import 'package:flutter_tts/flutter_tts.dart';\nvoid main() {}\n",
        )

        violations = scan_file(root, relative)

        self.assertEqual(["presentation-audio-import"], [v.rule for v in violations])

    def test_allows_audio_plugin_import_outside_presentation(self) -> None:
        root, relative = self.write(
            "lib/infrastructure/audio/flutter_tts_adapter.dart",
            "import 'package:flutter_tts/flutter_tts.dart';\n",
        )

        self.assertEqual([], scan_file(root, relative))

    def test_rejects_dart_lint_bypass(self) -> None:
        marker = "// " + "ignore_for_file: avoid_print"
        root, relative = self.write("tools/example.dart", marker + "\nvoid main() {}\n")

        violations = scan_file(root, relative)

        self.assertEqual(["quality-bypass"], [v.rule for v in violations])

    def test_rejects_non_fatal_analyzer_bypass(self) -> None:
        root, relative = self.write(
            ".github/workflows/example.yml",
            "run: flutter analyze --no-" + "fatal-warnings\n",
        )

        violations = scan_file(root, relative)

        self.assertEqual(["quality-bypass"], [v.rule for v in violations])

    def test_rejects_continue_on_error_in_workflow(self) -> None:
        root, relative = self.write(
            ".github/workflows/example.yml",
            "steps:\n  - run: python tool/quality_audit.py\n    continue-on-error: true\n",
        )

        violations = scan_file(root, relative)

        self.assertEqual(["quality-bypass"], [v.rule for v in violations])


if __name__ == "__main__":
    unittest.main()
