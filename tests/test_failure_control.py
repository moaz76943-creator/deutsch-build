from tool.failure_control import classify


def test_known_quota_failure_uses_fast_failover():
    result = classify("Provider returned 429 rate limit exceeded")
    assert result["class"] == "AI_MODEL_QUOTA"
    assert result["path"] == "ROUTE_ALTERNATIVE_AND_RESUME"
    assert len(result["fingerprint"]) == 64


def test_session_loss_resumes_from_checkpoint():
    result = classify("OpenCode session crashed and session lost")
    assert result["class"] == "SESSION_CONTEXT"
    assert result["path"] == "RESUME_FROM_VERIFIED_CHECKPOINT"


def test_network_failure_is_bounded():
    result = classify("network timeout while syncing")
    assert result["class"] == "NETWORK_SYNC"
    assert result["path"] == "BOUNDED_RETRY_THEN_RESUME"


def test_repeated_failure_stops_the_loop():
    result = classify("same failure repeated, no progress, stalled")
    assert result["class"] == "NO_PROGRESS"
    assert result["path"] == "STOP_REASSESS_AND_SWITCH_PATH"


def test_unknown_is_stop():
    result = classify("an unfamiliar critical condition")
    assert result["class"] == "UNKNOWN"
    assert result["path"] == "STOP_AND_RECONCILE"
