from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v281_transport_model_exists(project_root=ROOT):
    path = project_root / 'lib' / 'models' / 'backend_transport.dart'
    assert path.exists()
    text = path.read_text()
    for symbol in (
        'BackendTransportOperation',
        'BackendTransportRequest',
        'BackendTransportResponse',
        'BackendTransportFailureCode',
    ):
        assert symbol in text


def test_v281_transport_interface_is_provider_neutral(project_root=ROOT):
    path = project_root / 'lib' / 'services' / 'backend_transport.dart'
    assert path.exists()
    text = path.read_text()
    assert 'abstract interface class BackendTransport' in text
    assert 'Future<BackendTransportResponse> send(' in text
    assert 'LearnerRepository' not in text
    assert 'LearnerState' not in text
    assert 'Subscription' not in text
    assert 'http://' not in text
    assert 'https://' not in text


def test_v281_unavailable_transport_fails_closed(project_root=ROOT):
    text = (project_root / 'lib' / 'services' / 'backend_transport.dart').read_text()
    factory = (project_root / 'lib' / 'services' / 'backend_transport_factory.dart').read_text()
    assert 'UnavailableBackendTransport' in factory
    assert 'BackendTransportFailureCode.unavailable' in text


def test_v281_transport_does_not_define_persistent_credentials(project_root=ROOT):
    texts = [
        (project_root / 'lib' / 'models' / 'backend_transport.dart').read_text(),
        (project_root / 'lib' / 'services' / 'backend_transport.dart').read_text(),
    ]
    combined = '\n'.join(texts)
    forbidden = ('SharedPreferences', 'password', 'refreshToken', 'accessToken', 'payment')
    assert not any(name in combined for name in forbidden)


def test_v281_gateway_can_be_built_on_transport_boundary(project_root=ROOT):
    text = (project_root / 'lib' / 'services' / 'authentication_backend_gateway.dart').read_text()
    assert 'BackendTransport' in text
    assert 'TransportBackendAuthenticationGateway' in text
    assert 'AuthenticationFailureCode.rateLimited' in text
    assert 'AuthenticationFailureCode.providerRejected' in text
    assert 'AuthenticationFailureCode.retryable' in text


def test_v281_main_remains_without_real_network_configuration(project_root=ROOT):
    text = (project_root / 'lib' / 'main.dart').read_text()
    factory = (project_root / 'lib' / 'services' / 'backend_transport_factory.dart').read_text()
    assert 'TransportBackendAuthenticationGateway' in text
    assert 'UnavailableBackendTransport' in factory
    assert 'http://' not in text
    assert 'https://' not in text
