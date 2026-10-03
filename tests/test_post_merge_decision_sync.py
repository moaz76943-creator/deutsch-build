from tools.post_merge_decision_sync import SyncError, sync_ledger_text


BASE = """# Ledger

<!-- BEGIN POST_MERGE_SYNC -->
- Last synced main SHA: `0000000000000000000000000000000000000000`
- Last merged PR: bootstrap
- Last merge title: bootstrap
- Synced at: bootstrap
<!-- END POST_MERGE_SYNC -->

## ADR-001 — Keep me
"""


def test_post_merge_sync_updates_only_managed_block():
    updated = sync_ledger_text(
        BASE,
        main_sha="a" * 40,
        pr_number=242,
        pr_title="Architecture memory",
        merged_at="2026-10-03T15:00:00Z",
    )

    assert f"Last synced main SHA: `{'a' * 40}`" in updated
    assert "Last merged PR: #242" in updated
    assert "Last merge title: Architecture memory" in updated
    assert "Synced at: 2026-10-03T15:00:00Z" in updated
    assert "## ADR-001 — Keep me" in updated


def test_post_merge_sync_is_idempotent_for_same_merge():
    once = sync_ledger_text(BASE, main_sha="b" * 40, pr_number=7, pr_title="Same", merged_at="now")
    twice = sync_ledger_text(once, main_sha="b" * 40, pr_number=7, pr_title="Same", merged_at="now")
    assert twice == once


def test_post_merge_sync_rejects_invalid_sha():
    try:
        sync_ledger_text(BASE, main_sha="not-a-sha", pr_number=1, pr_title="x", merged_at="now")
    except SyncError as exc:
        assert "40-character" in str(exc)
    else:
        raise AssertionError("invalid SHA must fail closed")
