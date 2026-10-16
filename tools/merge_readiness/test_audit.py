"""Offline synthetic regression tests for read-only PR inventory classifier."""
import unittest
from tools.merge_readiness.audit import AuditError, fetch_files, fetch_open_prs, make_matrix, risk_flags, validate_repo


def pr(n, branch='staging/v2-full-platform', draft=False):
    return {'number': n, 'base': {'ref': branch}, 'draft': draft,
            'head': {'sha': 'a' * 40}, 'title': f'Synthetic {n}', 'html_url': f'https://github.test/{n}'}


def file(path, status='modified'):
    return {'filename': path, 'status': status}


class TestAudit(unittest.TestCase):
    def test_rejects_untrusted_repo_name(self):
        for item in ('org/repo/other', '../evil', 'org/repo\nheader', 'single'):
            with self.assertRaises(AuditError):
                validate_repo(item)

    def test_deletions_and_binary_pack_replacement_are_blocked(self):
        rows = [pr(59)]
        files = {59: [file('assets/content/packs/de/sqlite/de.sqlite', 'removed')]}
        x = make_matrix(rows, files, 'staging/v2-full-platform')['prs'][0]
        self.assertIn('PACK_BYTES_AT_RISK', x['flags'])
        self.assertEqual(x['suggested_action'], 'HOLD_FOR_SAFETY')

    def test_overlap_not_misreported_as_confirmed_git_conflict(self):
        rows = [pr(95), pr(99)]
        files = {95: [file('lib/core/srs_engine.dart')], 99: [file('lib/core/srs_engine.dart')]}
        result = make_matrix(rows, files, 'staging/v2-full-platform')
        self.assertEqual(result['overlap_pairs'], [[95, 99]])
        self.assertIn('POTENTIAL_FILE_OVERLAP', result['prs'][0]['flags'])
        self.assertFalse(result['prs'][1]['checks_verified'])

    def test_draft_and_wrong_base_never_called_ready(self):
        x = make_matrix([pr(70, branch='main', draft=True)], {70: []}, 'staging/v2-full-platform')
        self.assertEqual(x['prs'][0]['suggested_action'], 'OWNER_RECONCILIATION')
        self.assertEqual(x['wrong_base_count'], 1)
        self.assertEqual(x['draft_count'], 1)

    def test_missing_file_inventory_fails_closed(self):
        x = make_matrix([pr(50)], {}, 'staging/v2-full-platform')['prs'][0]
        self.assertIn('FILES_UNVERIFIED', x['flags'])
        self.assertEqual(x['suggested_action'], 'HOLD_FOR_SAFETY')

    def test_pagination_returns_exact_records(self):
        def fetch(path):
            return [pr(1), pr(2)]
        self.assertEqual(len(fetch_open_prs('owner/repo', fetch, 5)), 2)

    def test_incomplete_files_raise(self):
        with self.assertRaisesRegex(AuditError, 'incomplete'):
            fetch_files('owner/repo', 8, lambda path: [file('some.dart')], 2)

    def test_shared_root_and_workflow_flags(self):
        flags = risk_flags([file('lib/main.dart'), file('.github/workflows/new.yml')])
        self.assertIn('SHARED_ROOT_FILE', flags)
        self.assertIn('WORKFLOW_CHANGE_REQUIRES_OWNER', flags)


if __name__ == '__main__':
    unittest.main()
