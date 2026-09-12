from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs/V349_GERMAN_CONTENT_NAMESPACE.md'
PLAN = ROOT / 'docs/superpowers/plans/2026-09-12-language-ready-architecture.md'


def test_v349_release_document_and_plan_are_present_and_complete():
    assert DOC.exists()
    text = DOC.read_text(encoding='utf-8')
    assert 'V349 — German Content Namespace Migration' in text
    assert '14,813' in text
    assert '14,813 unique IDs' in text
    plan = PLAN.read_text(encoding='utf-8')
    assert '- [x] Step 5: Full regression + content quality audit.' in plan


def test_v349_moves_runtime_content_imports_to_canonical_namespace():
    offenders = []
    for path in (ROOT / 'lib').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        if "../data/content_a1.dart" in text or "../data/verb_conjugations.dart" in text or "../data/generated/" in text:
            offenders.append(str(path.relative_to(ROOT)))
    assert offenders == []


def test_v349_legacy_data_surface_is_compatibility_only():
    for path in sorted((ROOT / 'lib/data').glob('*.dart')):
        text = path.read_text(encoding='utf-8')
        if path.name.startswith(('content', 'verb_conjugations')):
            assert 'Compatibility export' in text
            assert 'content/german/' in text
