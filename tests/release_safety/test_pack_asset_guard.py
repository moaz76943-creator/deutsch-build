"""Synthetic metadata only: no production assets or learner records."""
import json
import unittest

from tools.release_safety.pack_asset_guard import changes, UnsafePullRequest


def review(*records):
    return changes(json.dumps(list(records), separators=(',', ':')).encode())


def file(path, status='modified', **extra):
    return dict(filename=path, status=status, **extra)


class AssetPreservationTests(unittest.TestCase):
    def test_existing_language_sqlite_delete_is_blocked(self):
        result = review(file('assets/content/packs/de/sqlite/de-1.0.0.sqlite', 'removed'))
        self.assertEqual(result['status'], 'BLOCKED_PROTECTED_ASSET_MUTATION')
        self.assertFalse(result['release_authorized'])

    def test_existing_archive_replacement_is_blocked(self):
        result = review(file('assets/content/packs/de/bundles/de-1.0.0.pack.gz'))
        self.assertEqual(len(result['violations']), 1)

    def test_new_unverified_pack_is_blocked(self):
        result = review(file('assets/content/packs/ja/bundles/ja-1.0.0.pack.gz', 'added'))
        self.assertEqual(len(result['violations']), 1)

    def test_pack_rename_cannot_escape(self):
        result = review(file('unrelated/export.sqlite', 'renamed',
                             previous_filename='assets/content/packs/de/sqlite/de-1.0.0.sqlite'))
        self.assertEqual(len(result['violations']), 1)

    def test_deleted_factory_generators_are_blocked(self):
        result = review(file('tools/polyglot_v2/generate_deep_100_languages.py', 'removed'))
        self.assertEqual(len(result['violations']), 1)

    def test_unrelated_code_is_not_falsely_blocked(self):
        result = review(file('lib/widgets/cefr_filter_bar.dart'),
                        file('test/repairs/widget_test.dart', 'added'))
        self.assertEqual(result['violations'], [])
        self.assertFalse(result['release_authorized'])

    def test_missing_status_rejected(self):
        with self.assertRaises(UnsafePullRequest):
            changes(b'[{"filename":"assets/content/packs/de/a"}]')

    def test_ambiguous_duplicate_fields_rejected(self):
        with self.assertRaises(UnsafePullRequest):
            changes(b'[{"filename":"a","filename":"b","status":"modified"}]')

    def test_duplicated_entries_rejected(self):
        with self.assertRaises(UnsafePullRequest):
            review(file('lib/a.dart'), file('lib/a.dart'))

    def test_rename_missing_prior_path_is_rejected(self):
        with self.assertRaises(UnsafePullRequest):
            review(file('lib/new.dart', 'renamed'))

    def test_truncated_or_non_utf8_inventory_rejected(self):
        for payload in (b'[', b'\xff', b'{}'):
            with self.subTest(payload=payload):
                with self.assertRaises(UnsafePullRequest):
                    changes(payload)

    def test_incomplete_pr_file_page_is_rejected(self):
        raw = json.dumps([file('lib/a.dart')]).encode()
        with self.assertRaisesRegex(UnsafePullRequest, 'incomplete'):
            changes(raw, expected_files=25)

    def test_exact_expected_file_count_allows_complete_inventory(self):
        raw = json.dumps([file('lib/a.dart')]).encode()
        self.assertEqual(changes(raw, expected_files=1)['files_checked'], 1)

    def test_real_pr59_pattern_is_blocked(self):
        records = [file('assets/content/packs/ar/bundles/ar-1.0.0.pack.gz', 'removed'),
                   file('assets/content/packs/de/bundles/de-1.0.0.pack.gz', 'modified'),
                   file('tools/polyglot_v2/generate_deep_100_languages.py', 'removed')]
        result = review(*records)
        self.assertEqual(len(result['violations']), 3)


if __name__ == '__main__':
    unittest.main()
