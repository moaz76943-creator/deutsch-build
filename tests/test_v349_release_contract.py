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


def test_v349_lib_runtime_does_not_import_authoring_files_outside_package():
    offenders = []
    for path in (ROOT / 'lib').rglob('*.dart'):
        for line in path.read_text(encoding='utf-8').splitlines():
            stripped = line.strip()
            if not stripped.startswith(('import ', 'export ')):
                continue
            if 'content/german/' in stripped:
                offenders.append(str(path.relative_to(ROOT)))
    assert offenders == []


def test_v349_runtime_facades_are_package_local_and_table_free():
    content = (ROOT / 'lib/data/content_a1.dart').read_text(encoding='utf-8')
    verbs = (ROOT / 'lib/data/verb_conjugations.dart').read_text(encoding='utf-8')
    assert 'generated/content_items_generated.dart' in content
    assert 'generated/verb_conjugations_generated.dart' in verbs
    assert '../../content/german/' not in content
    assert '../../content/german/' not in verbs
    assert "ContentItem(id:" not in content
    assert "VerbConjugation(infinitive:" not in verbs
