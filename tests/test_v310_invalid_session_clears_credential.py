from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_current_session_clears_credential_when_backend_rejects_session():
    text = read("lib/services/authentication_backend_gateway.dart")
    start = text.index("Future<AccountSession> getCurrentSession() async {")
    end = text.index("\n  @override\n  Future<void> signOut()", start)
    block = text[start:end]
    assert "on AuthenticationFailure catch (error)" in block
    assert "if (error.code == AuthenticationFailureCode.invalidSession)" in block
    assert "await _secureSessionStorage.clear();" in block or "await _clearCredential(operationGeneration);" in block
    assert "rethrow;" in block
