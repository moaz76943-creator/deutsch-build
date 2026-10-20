"""Focused regression guard for repaired private GitHub Actions YAML.

This test does not trigger Flutter builds, publish APK/AAB, or call GitHub.
"""
import importlib.util
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = ROOT / ".github" / "workflows"
REPAIRED = (
    "build.yml",
    "build_apk.yml",
    "build_aab.yml",
    "content_expansion_bot.yml",
    "auto_multilingual_builder.yml",
)


class RecoveredWorkflowContracts(unittest.TestCase):
    def read(self, name):
        return (WORKFLOWS / name).read_text(encoding="utf-8")

    def test_repaired_workflows_have_no_merge_markers(self):
        for name in REPAIRED:
            with self.subTest(name=name):
                source = self.read(name)
                self.assertNotRegex(source, r"(?m)^(?:<<<<<<< |=======\\s*$|>>>>>>> )")
                self.assertRegex(source, r"(?m)^name: ")
                self.assertRegex(source, r"(?m)^on:")
                self.assertRegex(source, r"(?m)^jobs:")

    def test_yaml_is_parsable_when_a_yaml_parser_is_available(self):
        if importlib.util.find_spec("yaml") is None:
            self.skipTest("PyYAML not installed; structural checks still run")
        import yaml
        for name in REPAIRED:
            with self.subTest(name=name):
                workflow = yaml.load(self.read(name), Loader=yaml.BaseLoader)
                self.assertIsInstance(workflow, dict)
                self.assertIn("on", workflow)
                jobs = workflow.get("jobs")
                self.assertIsInstance(jobs, dict)
                self.assertTrue(jobs)
                for job in jobs.values():
                    self.assertIsInstance(job.get("steps"), list)

    def test_flutter_ci_uses_locked_version(self):
        source = self.read("build.yml")
        self.assertIn("source toolchain.lock", source)
        self.assertIn("steps.toolchain.outputs.flutter", source)
        self.assertIn("dart analyze", source)
        self.assertIn("flutter test", source)

    def test_apk_requires_main_analyze_tests_before_release(self):
        source = self.read("build_apk.yml")
        self.assertIn("github.ref == 'refs/heads/main'", source)
        self.assertIn("source toolchain.lock", source)
        self.assertIn("flutter pub get --enforce-lockfile", source)
        self.assertLess(source.index("dart analyze"), source.index("flutter build apk"))
        self.assertLess(source.index("flutter test"), source.index("flutter build apk"))
        self.assertLess(source.index("flutter build apk"), source.index("Publish Direct APK Release"))
        self.assertNotIn("branches: [ main, staging/v2-full-platform ]", source)

    def test_signed_aab_preserves_main_and_secret_gate(self):
        source = self.read("build_aab.yml")
        self.assertIn('branches: [ "main" ]', source)
        self.assertIn("github.ref_name == 'main'", source)
        self.assertIn("Validate signing secrets", source)
        self.assertIn("jarsigner -verify -strict", source)
        self.assertIn("Upload signed AAB artifact", source)
        self.assertIn("Upload debug symbols artifact", source)

    def test_legacy_api_generator_is_manual_only(self):
        source = self.read("auto_multilingual_builder.yml")
        self.assertIn("workflow_dispatch:", source)
        self.assertNotRegex(source, r"(?m)^  schedule:")
        self.assertIn("Manual-only", source)

    def test_content_bot_remains_review_only(self):
        source = self.read("content_expansion_bot.yml")
        self.assertIn("GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED", source)
        self.assertIn("quarantine", source)
        self.assertIn("Stop when a bot review PR is already open", source)


if __name__ == "__main__":
    unittest.main()
