from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACCOUNT = ROOT / "lib/ui_v35/account_auth_page.dart"
APP = ROOT / "lib/ui_v35/app.dart"


def test_account_page_depends_on_auth_controller_and_exposes_provider_actions():
    text = ACCOUNT.read_text(encoding="utf-8")
    assert "class AccountPage" in text
    assert "AuthSessionController" in text
    assert "requestEmailOtp" in text
    assert "signInWithEmailOtp" in text
    assert "signInWithGoogle" in text
    assert "signInWithApple" in text
    assert "signOut" in text


def test_account_ui_has_no_learner_or_subscription_ownership():
    text = ACCOUNT.read_text(encoding="utf-8")
    assert "LearnerRepository" not in text
    assert "SubscriptionService" not in text
    assert "isPremium" not in text
    assert "premium = true" not in text


def test_account_ui_does_not_render_or_persist_secrets():
    text = ACCOUNT.read_text(encoding="utf-8")
    for forbidden in ("password", "accessToken", "refreshToken", "cardNumber", "SharedPreferences", "SecureSessionStorage"):
        assert forbidden not in text


def test_home_wires_account_page_without_replacing_learning_dependencies():
    text = APP.read_text(encoding="utf-8")
    assert "AccountPage(auth: widget.auth)" in text
    assert "auth: widget.auth" in text
