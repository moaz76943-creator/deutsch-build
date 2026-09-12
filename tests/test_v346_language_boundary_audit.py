from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / 'docs/ARCHITECTURE_LANGUAGE_AUDIT_V346.md'


def test_v346_language_boundary_audit_exists_and_classifies_core_areas():
    assert AUDIT.exists(), 'V346 language audit must exist before migration begins'
    text = AUDIT.read_text(encoding='utf-8')
    required_labels = (
        'LANGUAGE-AGNOSTIC',
        'LANGUAGE-SPECIFIC',
        'CONTENT-SPECIFIC',
        'PRESENTATION-SHARED',
        'LANGUAGE-PRESENTATION',
        'INTEGRATION-SENSITIVE',
    )
    for label in required_labels:
        assert label in text, f'missing classification label: {label}'
    for path in (
        'lib/models/content.dart',
        'lib/services/verb_index.dart',
        'lib/services/content_depth.dart',
        'lib/services/search_index.dart',
        'lib/core/learning_core.dart',
    ):
        assert path in text, f'missing audited path: {path}'


def test_v346_audit_marks_content_model_as_integration_sensitive():
    text = AUDIT.read_text(encoding='utf-8')
    needle = 'lib/models/content.dart'
    start = text.index(needle)
    section = text[start:start + 600]
    assert 'INTEGRATION-SENSITIVE' in section


def test_v346_all_language_markers_in_core_are_explicitly_audited():
    import re

    audit = AUDIT.read_text(encoding='utf-8')
    pattern = re.compile(r'german|German|Deutsch|arabic|Arabic|sentenceAr|personAr|pastArabic|exampleAr|[ÄÖÜäöüß]')
    offenders = []
    for path in (ROOT / 'lib/core').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        if pattern.search(text) and str(path.relative_to(ROOT)) not in audit:
            offenders.append(str(path.relative_to(ROOT)))
    assert offenders == []
