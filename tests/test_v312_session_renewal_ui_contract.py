from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"
PAGE = ROOT / "lib/ui_v35/account_auth_page.dart"


def test_auth_controller_exposes_session_renewal_action():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "Future<void> renewSession() async" in text
    assert "_authenticationService.renewSession" in text


def test_account_ui_exposes_renewal_without_learner_or_subscription_ownership():
    text = PAGE.read_text(encoding="utf-8")
    assert "renewSession" in text
    assert "LearnerRepository" not in text
    assert "SubscriptionService" not in text
    assert "isPremium" not in text
