from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v280_backend_contract_model_exists(project_root=ROOT):
    path = project_root / 'lib' / 'models' / 'backend_authentication_contract.dart'
    assert path.exists()
    text = path.read_text()
    for symbol in (
        'BackendAuthenticationFailureCode',
        'ProviderAuthenticationAssertion',
        'BackendAuthenticatedSession',
        'EmailOtpRequest',
        'EmailOtpVerification',
    ):
        assert symbol in text

def test_v280_authentication_declares_backend_gateway(project_root=ROOT):
    text = (project_root / 'lib' / 'services' / 'authentication_contract.dart').read_text()
    assert 'BackendAuthenticationGateway' in text
    assert 'requestEmailOtp' in text
    assert 'verifyEmailOtp' in text
    assert 'authenticateProvider' in text
    assert 'getCurrentSession' in text
    assert 'signOut' in text

def test_v280_account_session_remains_credential_free(project_root=ROOT):
    text = (project_root / 'lib' / 'models' / 'account_session.dart').read_text()
    forbidden = ('password', 'refreshToken', 'accessToken', 'otp', 'payment')
    assert not any(name in text for name in forbidden)


def test_v280_authentication_remains_decoupled_from_learner_state(project_root=ROOT):
    text = (project_root / 'lib' / 'services' / 'authentication_contract.dart').read_text()
    assert 'LearnerRepository' not in text
    assert 'LearnerState' not in text


def test_v280_offline_production_root_remains_fail_closed(project_root=ROOT):
    text = (project_root / 'lib' / 'main.dart').read_text()
    factory = (
        project_root / 'lib' / 'services' / 'backend_transport_factory.dart'
    ).read_text()
    assert 'UnavailableBackendTransport' in factory
    assert 'BackendTransportFactory' not in text
    assert 'TransportBackendAuthenticationGateway' not in text
    assert 'UnavailableEmailOtpProvider' not in text
    assert 'UnavailableSocialAuthenticationProvider' not in text
    assert 'http://' not in text
    assert 'https://' not in text


def test_v280_adds_no_dependency(project_root=ROOT):
    text = (project_root / 'pubspec.yaml').read_text()
    assert 'shared_preferences:' in text
    assert 'http:' in text
    assert 'backend_authentication_sdk:' not in text

def test_v280_email_otp_request_stays_behind_provider_boundary(project_root=ROOT):
    text = (project_root / 'lib' / 'services' / 'authentication_service.dart').read_text()
    assert 'requestEmailOtp({required String email})' in text
    assert '_emailOtpProvider.requestCode(email: email)' in text
