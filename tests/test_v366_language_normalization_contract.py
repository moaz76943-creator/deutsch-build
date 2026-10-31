from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_language_normalization_contract_is_exposed_by_language_pack():
    contract = ROOT / 'lib/language/language_text_normalizer.dart'
    pack = ROOT / 'lib/language/language_pack.dart'
    german = ROOT / 'lib/language/german/german_text_normalizer.dart'
    german_pack = ROOT / 'lib/language/german/german_language_pack.dart'

    assert contract.exists()
    assert 'abstract interface class LanguageTextNormalizer' in contract.read_text()
    assert 'LanguageTextNormalizer get textNormalizer;' in pack.read_text()
    assert 'class GermanTextNormalizer' in german.read_text()
    assert 'LanguageTextNormalizer get textNormalizer' in german_pack.read_text()


def test_learning_core_no_longer_owns_german_normalization_rules():
    core = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'TextNormalizer' not in core
