from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_language_content_quality_contract_is_language_neutral():
    text = (ROOT / 'lib/language/language_content_quality.dart').read_text(encoding='utf-8')
    assert 'abstract interface class LanguageContentQuality' in text
    assert 'LearningContent' in text
    assert "../models/content.dart" not in text
    assert "'de'" not in text
    assert 'german' not in text
    assert 'arabic' not in text


def test_german_content_quality_owns_german_specific_rules():
    text = (ROOT / 'lib/language/german/german_content_quality.dart').read_text(encoding='utf-8')
    assert 'implements LanguageContentQuality' in text
    assert "'der', 'die', 'das'" in text
    assert 'German sentence format' in text
    assert 'Repeated German word' in text


def test_german_language_pack_exposes_content_quality():
    pack = (ROOT / 'lib/language/language_pack.dart').read_text(encoding='utf-8')
    german = (ROOT / 'lib/language/german/german_language_pack.dart').read_text(encoding='utf-8')
    assert 'LanguageContentQuality get contentQuality;' in pack
    assert 'LanguageContentQuality get contentQuality' in german
    assert 'GermanContentQuality' in german
