from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUTH = ROOT / "lib/services/authentication_service.dart"
MODEL = ROOT / "lib/models/account_session.dart"

def test_provider_stage_has_separate_adapters_and_orchestrator():
    text = AUTH.read_text(encoding="utf-8")
    assert "EmailOtpProvider" in text
    assert "SocialAuthenticationProvider" in text
    assert "ProviderAuthenticationService" in text
    assert "AccountProvider.google" in text
    assert "AccountProvider.apple" in text

def test_provider_stage_has_no_learner_repository_coupling():
    text = AUTH.read_text(encoding="utf-8")
    assert "LearnerRepository" not in text
    assert "LearnerState" not in text

def test_provider_stage_has_no_credential_storage_or_payment_fields():
    text = AUTH.read_text(encoding="utf-8") + MODEL.read_text(encoding="utf-8")
    for forbidden in ("SharedPreferences", "password", "refreshToken", "accessToken", "cardNumber", "premium = true"):
        assert forbidden not in text

def test_provider_stage_rejects_noncanonical_authenticated_results():
    text = AUTH.read_text(encoding="utf-8")
    assert "isAuthenticated" in text
    assert "identity" in text
    assert "unauthenticated" in text


def test_fail_closed_adapters_do_not_store_credentials():
    provider = ROOT / "lib/services/authentication_providers.dart"
    text = provider.read_text(encoding="utf-8")
    for forbidden in ("SharedPreferences", "password", "refreshToken", "accessToken", "cardNumber"):
        assert forbidden not in text
    assert "AuthenticationFailureCode.unavailable" in text


def test_authentication_provider_stage_has_no_learner_state_dependency():
    for path in (AUTH, ROOT / "lib/services/authentication_providers.dart"):
        text = path.read_text(encoding="utf-8")
        assert "LearnerRepository" not in text
        assert "LearnerState" not in text
