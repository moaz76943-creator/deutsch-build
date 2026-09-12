from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_authentication_domain_is_split_by_responsibility():
    services = ROOT / 'lib/services'
    for name in ['authentication.dart','authentication_failures.dart','authentication_contract.dart','authentication_backend_gateway.dart']:
        assert (services / name).exists(), name

def test_root_authentication_file_stays_small_and_contract_only():
    text = (ROOT / 'lib/services/authentication.dart').read_text(encoding='utf-8')
    assert len(text.splitlines()) <= 220
    assert 'BackendAuthenticationGateway' not in text
    assert 'BackendAuthenticationFailureCode' not in text

def test_split_files_do_not_duplicate_learner_or_subscription_ownership():
    services = ROOT / 'lib/services'
    for name in ['authentication_contract.dart','authentication_failures.dart','authentication_backend_gateway.dart']:
        text = (services / name).read_text(encoding='utf-8').lower()
        assert 'learnerrepository' not in text
        assert 'learnerstate' not in text
        assert 'subscriptionservice' not in text
