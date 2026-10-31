import pytest

import tool.project_record_sync as project_record_sync
from tool.project_record_sync import should_promote_to_canonical_runtime


@pytest.mark.parametrize(
    ("workflow", "branch", "expected"),
    [
        ("Engineering CI", "main", True),
        ("Recovery Checkpoint", "main", True),
        ("Engineering CI", "executor-a/auth-corrupted-credential-self-recovery", False),
        ("Recovery Checkpoint", "feature/recovery-probe", False),
        ("Engineering CI", "", False),
        ("Engineering CI", None, False),
        ("Quality Gates", "main", False),
    ],
)
def test_only_canonical_main_workflow_evidence_is_promoted(
    monkeypatch, workflow, branch, expected
):
    monkeypatch.setattr(project_record_sync, "reachable", lambda old_sha, new_sha: True)
    assert (
        should_promote_to_canonical_runtime(
            workflow,
            branch,
            "workflow-head-sha",
            "canonical-main-head-sha",
        )
        is expected
    )


def test_fork_or_unrelated_branch_named_main_cannot_promote_non_ancestor_sha(monkeypatch):
    monkeypatch.setattr(project_record_sync, "reachable", lambda old_sha, new_sha: False)

    assert (
        should_promote_to_canonical_runtime(
            "Engineering CI",
            "main",
            "fork-controlled-head-sha",
            "canonical-main-head-sha",
        )
        is False
    )


@pytest.mark.parametrize("workflow", ["Engineering CI", "Recovery Checkpoint"])
def test_missing_workflow_head_sha_fails_closed_without_ancestry_check(monkeypatch, workflow):
    def fail_if_called(old_sha, new_sha):
        raise AssertionError("ancestry must not be queried without a workflow head SHA")

    monkeypatch.setattr(project_record_sync, "reachable", fail_if_called)

    assert (
        should_promote_to_canonical_runtime(
            workflow,
            "main",
            "",
            "canonical-main-head-sha",
        )
        is False
    )
