from pathlib import Path


WORKFLOW = Path(".github/workflows/project-record-engineering-ci.yml")


def _capture_job_header(text: str) -> str:
    capture = text.split("  capture:\n", 1)[1]
    return capture.split("    steps:\n", 1)[0]


def test_project_record_capture_requires_canonical_main_push_source():
    text = WORKFLOW.read_text(encoding="utf-8")
    header = _capture_job_header(text)

    assert "github.event.workflow_run.event == 'push'" in header
    assert "github.event.workflow_run.head_branch == 'main'" in header
    assert (
        "github.event.workflow_run.head_repository.full_name == github.repository"
        in header
    )


def test_branch_name_only_gate_cannot_regress():
    text = WORKFLOW.read_text(encoding="utf-8")
    header = _capture_job_header(text)

    assert "if: ${{ github.event.workflow_run.head_branch == 'main' }}" not in header


def test_main_project_record_writer_has_no_direct_main_push():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "git push origin HEAD:main" not in text
    assert "PROJECT_RECORD_BRANCH: ${{ github.event.workflow_run.head_branch }}" in text
