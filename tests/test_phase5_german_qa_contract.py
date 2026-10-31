from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase5_factory_is_wired_into_pack_compilation():
    factory = read("tools/language_pack_factory.py")
    assert "assert_german_source" in factory
    assert "assert_german_sqlite" in factory
    assert "GermanLinguisticQaError" in factory


def test_phase5_runtime_grammar_compiler_is_fail_closed():
    compiler = read("lib/services/canonical_grammar_compiler.dart")
    assert "GermanLinguisticValidator" in compiler
    assert "throwIfInvalid" in compiler


def test_phase5_qa_has_no_network_or_paid_runtime_dependency():
    qa = read("tools/german_linguistic_qa.py")
    forbidden = ("requests", "httpx", "openai", "anthropic", "firebase", "boto3")
    assert not any(token in qa for token in forbidden)
