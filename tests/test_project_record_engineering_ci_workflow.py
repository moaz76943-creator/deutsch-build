from pathlib import Path


WORKFLOW = Path(".github/workflows/project-record-engineering-ci.yml")


def _capture_job_header(text: str) -> str:
    capture = text.split("  capture:\n", 1)[1]
    return capture.split("    steps:\n", 1)[0]


def test_project_record_capture_only_runs_for_main_engineering_ci():
    text = WORKFLOW.read_text(encoding="utf-8")
    header = _capture_job_header(text)

    assert "if: ${{ github.event.workflow_run.head_branch == 'main' }}" in header


def test_main_project_record_writer_is_still_present():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "git push origin HEAD:main" in text
    assert "PROJECT_RECORD_BRANCH: ${{ github.event.workflow_run.head_branch }}" in text
