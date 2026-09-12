from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUTH = ROOT / "lib/services/authentication_contract.dart"
MODEL = ROOT / "lib/models/account_session.dart"
SUBSCRIPTION = ROOT / "lib/services/subscription.dart"


def test_account_contract_files_exist_and_define_provider_neutral_surface():
    assert MODEL.exists()
    assert AUTH.exists()
    model = MODEL.read_text(encoding="utf-8")
    auth = AUTH.read_text(encoding="utf-8")
    assert "class AccountIdentity" in model
    assert "enum AccountProvider" in model
    assert "class AccountSession" in model
    assert "abstract interface class AuthenticationService" in auth
    for member in (
        "currentSession",
        "signInWithEmailOtp",
        "signInWithGoogle",
        "signInWithApple",
        "signOut",
    ):
        assert member in auth


def test_account_contract_has_no_password_otp_or_payment_storage_fields():
    text = MODEL.read_text(encoding="utf-8") + AUTH.read_text(encoding="utf-8")
    forbidden_field_names = (
        "password",
        "refreshToken",
        "accessToken",
        "paymentMethod",
        "cardNumber",
    )
    declared_fields = [
        line.strip()
        for line in text.splitlines()
        if line.strip().startswith("final ")
    ]
    assert not any(
        any(f" {name}" in line for name in forbidden_field_names)
        for line in declared_fields
    )
    assert "premium = true" not in text
    assert "premium=true" not in text


def test_authentication_boundary_does_not_own_or_mutate_learner_repository():
    text = AUTH.read_text(encoding="utf-8")
    assert "LearnerRepository" not in text
    assert "learner_repository" not in text


def test_subscription_remains_fail_closed():
    text = SUBSCRIPTION.read_text(encoding="utf-8")
    assert "static const billingReady = false;" in text
    assert "static Future<bool> isPremium() async => false;" in text


def test_account_session_contains_only_minimal_non_secret_state():
    model = MODEL.read_text(encoding="utf-8")
    import re

    fields = set(re.findall(r"^\s*final\s+[^;]+\s+(\w+)\s*;", model, re.MULTILINE))
    assert fields <= {"userId", "isAuthenticated", "identity", "expiresAt"}


def test_account_contract_does_not_introduce_local_credential_storage():
    auth = AUTH.read_text(encoding="utf-8")
    assert "SharedPreferences" not in auth
    assert "secure_storage" not in auth
    assert "http" not in auth.lower()
