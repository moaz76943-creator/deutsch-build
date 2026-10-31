from pathlib import Path


def test_content_depth_uses_neutral_content_contract():
    text = Path("lib/services/content_depth.dart").read_text()
    assert "import '../core/content_contract.dart';" in text
    assert "import '../models/content.dart';" not in text
    assert "depthFor(ContentItem x)" not in text


def test_reading_practice_uses_neutral_content_contract():
    text = Path("lib/services/reading_practice.dart").read_text()
    assert "import '../core/content_contract.dart';" in text
    assert "import '../models/content.dart';" not in text
    assert "List<ContentItem>" not in text
