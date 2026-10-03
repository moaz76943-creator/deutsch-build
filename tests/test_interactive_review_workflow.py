from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ai_collaboration_bridge.yml"
TEMPLATE = ROOT / "docs" / "architecture" / "ADR_DRAFT_TEMPLATE.md"


def test_inline_review_uses_trusted_base_posts_line_comments_and_blocks_findings():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "inline-static-review:" in text
    assert "github.event.pull_request.base.sha" in text
    assert "tools/automation/inline_reviewer.py" in text
    assert 'pulls/$NUMBER/reviews' in text
    assert "pull-requests: write" in text
    assert "Enforce inline review findings" in text
    assert 'if (( total != 0 )); then' in text


def test_feature_issue_trigger_generates_adr_under_architecture_from_srs_and_template():
    text = WORKFLOW.read_text(encoding="utf-8")

    assert "adr-draft-from-feature-issue:" in text
    assert "types: [opened, edited, reopened, labeled]" in text
    assert "tools/automation/rfc_draft_generator.py" in text
    assert "docs/architecture/ADR-DRAFT-issue-" in text
    assert "--template docs/architecture/ADR_DRAFT_TEMPLATE.md" in text
    assert "--srs-doc docs/V118_SMART_SRS_INTELLIGENCE.md" in text
    assert "contents: write" not in text
    assert "issues: write" in text


def test_adr_template_is_bounded_and_contains_required_sections():
    text = TEMPLATE.read_text(encoding="utf-8")

    assert "{{ISSUE_NUMBER}}" in text
    assert "{{FEATURE_REQUEST}}" in text
    assert "{{SRS_CONTEXT}}" in text
    assert "## Proposed decision" in text
    assert len(text.splitlines()) < 1000
