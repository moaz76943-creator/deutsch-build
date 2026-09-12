from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'lib/core/learning_core.dart'
DOC = ROOT / 'docs/V347B_LEARNING_CORE_LANGUAGE_NEUTRAL.md'
PLAN = ROOT / 'docs/superpowers/plans/2026-09-12-language-ready-architecture.md'


def test_v347b_release_document_and_plan_are_present_and_marked_complete():
    assert DOC.exists()
    assert 'Full pytest regression: 493 passed (V347b baseline).' in DOC.read_text(encoding='utf-8')
    plan = PLAN.read_text(encoding='utf-8')
    assert '- [x] Step 6: Migrate `LearningCore` to consume the language-neutral contract without changing learning behavior.' in plan


def test_learning_core_has_no_language_shaped_content_import_or_quality_policy():
    text = CORE.read_text(encoding='utf-8')
    assert "import '../models/content.dart';" not in text
    assert "import 'content_quality.dart';" not in text
    assert 'ContentItem' not in text
    assert 'ContentQuality' not in text
    assert 'LearningContent' in text
