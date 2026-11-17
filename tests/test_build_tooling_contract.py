"""Regression tests for safe, reproducible local build commands."""
from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def lock_values() -> dict[str, str]:
    values: dict[str, str] = {}
    for line in (ROOT / "toolchain.lock").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key] = value.strip().strip('"')
    return values


class BuildToolingContractTests(unittest.TestCase):
    def test_all_runs_only_analysis_and_tests_without_git_mutation(self):
        source = (ROOT / "Makefile").read_text(encoding="utf-8")
        all_target = re.search(r"(?m)^all:\s*(.+)$", source)
        self.assertIsNotNone(all_target, "Makefile must define the all target")
        self.assertEqual(
            all_target.group(1).split(),
            ["analyze", "test"],
            "make all must not clean user caches or commit/push repository changes",
        )

    def test_test_target_does_not_swallow_failures(self):
        source = (ROOT / "Makefile").read_text(encoding="utf-8")
        match = re.search(r"(?ms)^test:\n((?:\t.*\n|\n)*)", source)
        self.assertIsNotNone(match, "Makefile must define test")
        recipe = match.group(1)
        self.assertIn("flutter test", recipe)
        self.assertNotIn("|| true", recipe)
        self.assertNotIn("|| :", recipe)

    def test_makefile_has_no_automatic_git_push_or_commit_target(self):
        source = (ROOT / "Makefile").read_text(encoding="utf-8")
        self.assertNotRegex(source, r"(?m)^sync\s*:")
        self.assertNotIn("git push", source)
        self.assertNotIn("git commit", source)

    def test_build_targets_have_valid_make_recipe_indentation(self):
        source = (ROOT / "Makefile").read_text(encoding="utf-8")
        lines = source.splitlines()
        for target in ("build-apk", "build-debug-apk"):
            with self.subTest(target=target):
                index = next(
                    (i for i, line in enumerate(lines) if line == f"{target}:"),
                    None,
                )
                self.assertIsNotNone(index, f"Missing {target} target")
                self.assertGreater(index + 1, 0)
                self.assertTrue(
                    lines[index + 1].startswith("\t"),
                    f"{target} recipe must start with a tab, not spaces",
                )

    def test_android_gradle_versions_match_the_single_toolchain_lock(self):
        lock = lock_values()
        settings = (ROOT / "android" / "settings.gradle").read_text(encoding="utf-8")
        wrapper = (
            ROOT / "android" / "gradle" / "wrapper" / "gradle-wrapper.properties"
        ).read_text(encoding="utf-8")
        self.assertIn(
            f'id "com.android.application" version "{lock["AGP_VERSION"]}"',
            settings,
        )
        self.assertIn(
            f'id "org.jetbrains.kotlin.android" version "{lock["KOTLIN_VERSION"]}"',
            settings,
        )
        self.assertIn(
            f"gradle-{lock['GRADLE_VERSION']}-all.zip",
            wrapper,
        )
        self.assertIn(
            lock["GRADLE_DISTRIBUTION_SHA256"],
            wrapper,
        )

    def test_kotlin_gradle_plugin_is_supported_with_the_locked_agp(self):
        lock = lock_values()
        kotlin = tuple(int(part) for part in lock["KOTLIN_VERSION"].split("."))
        agp = tuple(int(part) for part in lock["AGP_VERSION"].split("."))
        # Kotlin 2.3.20 supports AGP 8.2.2 through 9.0.0.
        if kotlin >= (2, 3, 20):
            self.assertGreaterEqual(agp, (8, 2, 2))
            self.assertLessEqual(agp, (9, 0, 0))
        elif kotlin >= (2, 3, 10):
            self.assertGreaterEqual(agp, (8, 2, 2))
            self.assertLessEqual(agp, (9, 0, 0))
        elif kotlin >= (2, 3, 0):
            self.assertGreaterEqual(agp, (8, 2, 2))
            self.assertLessEqual(agp, (8, 13, 0))
        else:
            self.fail(f"Unreviewed Kotlin Gradle Plugin version: {lock['KOTLIN_VERSION']}")


if __name__ == "__main__":
    unittest.main()
