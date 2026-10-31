from tools.automation.inline_reviewer import analyze_file


def test_flags_direct_audio_import_and_lint_ignore_in_presentation():
    patch = """@@ -1,1 +1,3 @@
 import 'package:flutter/material.dart';
+// ignore: avoid_print
+import 'package:flutter_tts/flutter_tts.dart';
"""
    findings = analyze_file(
        path="lib/ui_v35/example_page.dart",
        patch=patch,
        content="import 'package:flutter/material.dart';\n// ignore: avoid_print\nimport 'package:flutter_tts/flutter_tts.dart';\n",
    )

    assert [item["line"] for item in findings] == [2, 3]
    assert "Lint suppression" in findings[0]["body"]
    assert "Presentation boundary" in findings[1]["body"]


def test_flags_speech_to_text_in_nested_presentation_folder():
    patch = """@@ -4,0 +5,1 @@
+import 'package:speech_to_text/speech_to_text.dart';
"""
    findings = analyze_file(
        path="lib/features/conversation/presentation/voice_panel.dart",
        patch=patch,
        content="\n".join(["x"] * 4 + ["import 'package:speech_to_text/speech_to_text.dart';"]),
    )

    assert len(findings) == 1
    assert findings[0]["line"] == 5
    assert "Presentation boundary" in findings[0]["body"]


def test_existing_ignore_in_changed_file_is_blocking():
    patch = """@@ -2,1 +2,2 @@
 void oldCode() {}
+void newCode() {}
"""
    findings = analyze_file(
        path="lib/services/example.dart",
        patch=patch,
        content="// ignore_for_file: avoid_print\nvoid oldCode() {}\nvoid newCode() {}\n",
    )

    assert len(findings) == 1
    assert findings[0]["line"] == 3
    assert "source line 1" in findings[0]["body"]
    assert "Lint suppression" in findings[0]["body"]


def test_existing_audio_import_in_changed_presentation_file_is_blocking():
    patch = """@@ -2,1 +2,2 @@
 class VoicePanel {}
+class VoicePanelState {}
"""
    findings = analyze_file(
        path="lib/features/conversation/presentation/voice_panel.dart",
        patch=patch,
        content="import 'package:flutter_tts/flutter_tts.dart';\nclass VoicePanel {}\nclass VoicePanelState {}\n",
    )

    assert len(findings) == 1
    assert findings[0]["line"] == 3
    assert "source line 1" in findings[0]["body"]
    assert "Presentation boundary" in findings[0]["body"]


def test_removed_violation_is_not_reported():
    patch = """@@ -1,2 +1,1 @@
-import 'package:flutter_tts/flutter_tts.dart';
 import 'package:flutter/material.dart';
"""
    assert analyze_file(
        path="lib/ui/example.dart",
        patch=patch,
        content="import 'package:flutter/material.dart';\n",
    ) == []


def test_flags_changed_file_over_1000_lines():
    patch = """@@ -1,1 +1,2 @@
 first
+second
"""
    findings = analyze_file(
        path="lib/services/large_service.dart",
        patch=patch,
        content="\n".join(f"line {i}" for i in range(1001)),
    )

    assert len(findings) == 1
    assert findings[0]["line"] == 2
    assert "1001 lines" in findings[0]["body"]
