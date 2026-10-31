from pathlib import Path


def test_language_specific_normalization_is_not_implemented_in_core():
    root = Path(__file__).resolve().parents[1]
    core = (root / 'lib/core/text_normalizer.dart').read_text(encoding='utf-8') if (root / 'lib/core/text_normalizer.dart').exists() else ''
    assert 'class TextNormalizer' not in core
    assert "replaceAll('ä', 'a')" not in core


def test_language_specific_quality_is_not_implemented_in_core():
    root = Path(__file__).resolve().parents[1]
    core = (root / 'lib/core/content_quality.dart').read_text(encoding='utf-8') if (root / 'lib/core/content_quality.dart').exists() else ''
    assert 'class ContentQuality' not in core
    assert 'Invalid Artikel' not in core


def test_compatibility_facades_delegate_to_language_layer():
    root = Path(__file__).resolve().parents[1]
    normalizer = (root / 'lib/services/text_normalizer.dart').read_text(encoding='utf-8')
    quality = (root / 'lib/services/quality.dart').read_text(encoding='utf-8')
    assert 'GermanTextNormalizer' in normalizer
    assert 'GermanContentQuality' in quality
