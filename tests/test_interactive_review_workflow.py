from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ai_collaboration_bridge.yml"


def test_inline_review_uses_trusted_base_and_posts_line_comments():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "inline-static-review:" in text
    assert "github.event.pull_request.base.sha" in text
    assert "tools/automation/inline_reviewer.py" in text
    assert 'pulls/$NUMBER/reviews' in text
    assert "pull-requests: write" in text


def test_feature_issue_trigger_generates_rfc_under_architecture_without_source_write():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "rfc-draft-from-feature-issue:" in text
    assert "types: [opened, edited, reopened, labeled]" in text
    assert "tools/automation/rfc_draft_generator.py" in text
    assert "docs/architecture/RFC-DRAFT-issue-" in text
    assert "contents: write" not in text
    assert "issues: write" in text
