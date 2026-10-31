from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / 'lib/models/backend_authentication_api.dart'
SERVICE = ROOT / 'lib/services/backend_authentication_api.dart'


def test_v282_protocol_files_exist():
    assert MODEL.exists()
    assert SERVICE.exists()


def test_v282_protocol_has_exact_auth_operations():
    text = MODEL.read_text(encoding='utf-8')
    for name in ('requestEmailOtp', 'verifyEmailOtp', 'authenticateProvider', 'currentSession', 'signOut'):
        assert name in text


def test_v282_protocol_does_not_define_backend_location_or_credentials():
    text = (MODEL.read_text(encoding='utf-8') + SERVICE.read_text(encoding='utf-8'))
    assert not re.search(r'https?://', text, re.I)
    assert not re.search(r'\b(api[_-]?key|password|secret|access[_-]?token|refresh[_-]?token)\b', text, re.I)


def test_v282_protocol_does_not_own_learner_or_entitlement_state():
    text = (MODEL.read_text(encoding='utf-8') + SERVICE.read_text(encoding='utf-8')).lower()
    declarations = re.findall(r'final\s+[^;]+\s+(\w+)\s*;', text)
    forbidden_fields = {'learnerrepository', 'learnerstate', 'premium', 'subscription', 'entitlement'}
    assert not forbidden_fields.intersection(declarations)

def test_v282_adapter_avoids_unchecked_nullable_transport_fields():
    text = SERVICE.read_text(encoding='utf-8')
    assert 'request.email!' not in text
    assert 'request.otp!' not in text
    assert 'request.assertion!' not in text
