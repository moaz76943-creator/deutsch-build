import json

from tools.automation.collaboration_mock_harness import inspect_event, main


def test_issue_comment_is_read_locally_without_provider_calls():
    payload = {
        "issue": {"number": 241, "title": "Bridge review"},
        "comment": {"body": "please review this architecture change"},
    }
    report = inspect_event(
        "issue_comment",
        payload,
        env={
            "AI_COLLABORATION_ENABLED": "true",
            "AI_COLLABORATION_BILLING_APPROVED": "true",
            "OPENAI_API_KEY": "must-not-be-used",
            "GEMINI_API_KEY": "must-not-be-used",
        },
    )

    assert report["mode"] == "MOCK_ONLY"
    assert report["provider_calls_executed"] == 0
    assert report["network_enabled"] is False
    assert report["message_count"] == 1
    assert report["messages"] == ["please review this architecture change"]
    assert report["live_guard_would_activate"] is True


def test_guard_stays_fail_closed_when_billing_is_not_approved():
    report = inspect_event(
        "issues",
        {"issue": {"number": 1, "title": "x", "body": "body"}},
        env={"AI_COLLABORATION_ENABLED": "true", "AI_COLLABORATION_BILLING_APPROVED": "false"},
    )

    assert report["live_guard_would_activate"] is False
    assert report["provider_calls_executed"] == 0


def test_cli_is_silent_by_default_and_report_is_opt_in(tmp_path, capsys):
    event = tmp_path / "event.json"
    event.write_text(json.dumps({"issue": {"number": 2, "body": "hello"}}), encoding="utf-8")

    assert main(["--event-name", "issues", "--event-file", str(event)]) == 0
    assert capsys.readouterr().out == ""

    assert main(["--event-name", "issues", "--event-file", str(event), "--report"]) == 0
    output = json.loads(capsys.readouterr().out)
    assert output["mode"] == "MOCK_ONLY"
    assert output["provider_calls_executed"] == 0
