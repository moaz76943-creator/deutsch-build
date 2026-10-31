import csv
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "sync_store_metadata.py"
spec = importlib.util.spec_from_file_location("sync_store_metadata", MODULE_PATH)
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class StoreMetadataSyncTest(unittest.TestCase):
    def _write_csv(self, path: Path, rows):
        with path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(
                handle,
                fieldnames=[
                    "Locale Code",
                    "App Name",
                    "Short Description",
                    "Full Description",
                ],
            )
            writer.writeheader()
            writer.writerows(rows)

    def test_generates_fastlane_files_without_mutating_text(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            csv_path = tmp / "metadata.csv"
            out = tmp / "fastlane" / "metadata" / "android"
            bundle = tmp / "api.json"
            rows = [
                {
                    "Locale Code": "en-US",
                    "App Name": "Deutsch بالعربي",
                    "Short Description": "Learn offline — privately.",
                    "Full Description": "Line one.\nLine two with العربية.",
                },
                {
                    "Locale Code": "ar",
                    "App Name": "تعلم اللغات",
                    "Short Description": "تعلّم بخصوصية وبدون إنترنت",
                    "Full Description": "وصف كامل للتطبيق.",
                },
            ]
            self._write_csv(csv_path, rows)

            listings = sync.sync_store_metadata(
                csv_path=csv_path,
                output_root=out,
                expected_locales=2,
                api_bundle_path=bundle,
            )

            self.assertEqual([item.locale for item in listings], ["en-US", "ar"])
            self.assertEqual(
                (out / "en-US" / "title.txt").read_text(encoding="utf-8"),
                rows[0]["App Name"],
            )
            self.assertEqual(
                (out / "en-US" / "short_description.txt").read_text(encoding="utf-8"),
                rows[0]["Short Description"],
            )
            self.assertEqual(
                (out / "en-US" / "full_description.txt").read_text(encoding="utf-8"),
                rows[0]["Full Description"],
            )
            payload = json.loads(bundle.read_text(encoding="utf-8"))
            self.assertEqual(payload["listings"][0]["language"], "en-US")
            self.assertEqual(payload["listings"][0]["title"], rows[0]["App Name"])
            self.assertEqual(
                payload["listings"][0]["shortDescription"],
                rows[0]["Short Description"],
            )
            self.assertEqual(
                payload["listings"][0]["fullDescription"],
                rows[0]["Full Description"],
            )

    def test_rejects_character_limit_violations_before_writing(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            csv_path = tmp / "metadata.csv"
            out = tmp / "metadata"
            self._write_csv(
                csv_path,
                [{
                    "Locale Code": "en-US",
                    "App Name": "x" * 31,
                    "Short Description": "short",
                    "Full Description": "full",
                }],
            )

            with self.assertRaisesRegex(sync.MetadataValidationError, "App Name.*30"):
                sync.sync_store_metadata(
                    csv_path=csv_path,
                    output_root=out,
                    expected_locales=1,
                )

            self.assertFalse(out.exists())

    def test_rejects_duplicate_locale_codes(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            csv_path = tmp / "metadata.csv"
            row = {
                "Locale Code": "de-DE",
                "App Name": "Deutsch",
                "Short Description": "Kurz",
                "Full Description": "Lang",
            }
            self._write_csv(csv_path, [row, row])

            with self.assertRaisesRegex(sync.MetadataValidationError, "Duplicate locale"):
                sync.sync_store_metadata(
                    csv_path=csv_path,
                    output_root=tmp / "metadata",
                    expected_locales=2,
                )

    def test_requires_exact_expected_locale_count(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            csv_path = tmp / "metadata.csv"
            self._write_csv(
                csv_path,
                [{
                    "Locale Code": "fr-FR",
                    "App Name": "Français",
                    "Short Description": "Court",
                    "Full Description": "Long",
                }],
            )

            with self.assertRaisesRegex(sync.MetadataValidationError, "Expected 87.*found 1"):
                sync.sync_store_metadata(
                    csv_path=csv_path,
                    output_root=tmp / "metadata",
                    expected_locales=87,
                )

    def test_google_play_upload_commits_after_all_locale_updates(self):
        listings = [
            sync.Listing("en-US", "Name", "Short", "Full"),
            sync.Listing("ar", "اسم", "قصير", "كامل"),
        ]

        with patch.object(sync, "_request_json") as request_json:
            request_json.side_effect = [{"id": "edit-123"}, {}, {}, {}]
            edit_id = sync.upload_to_google_play(
                listings,
                package_name="com.example.app",
                access_token="token",
            )

        self.assertEqual(edit_id, "edit-123")
        self.assertEqual(request_json.call_count, 4)
        self.assertTrue(request_json.call_args_list[0].args[1].endswith("/edits"))
        self.assertIn(
            "/edits/edit-123/listings/en-US",
            request_json.call_args_list[1].args[1],
        )
        self.assertIn(
            "/edits/edit-123/listings/ar",
            request_json.call_args_list[2].args[1],
        )
        self.assertTrue(
            request_json.call_args_list[3].args[1].endswith("/edits/edit-123:commit")
        )


if __name__ == "__main__":
    unittest.main()
