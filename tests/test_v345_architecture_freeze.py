from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_architecture_baseline_exists_and_names_canonical_layers():
    baseline = ROOT / 'docs/ARCHITECTURE_BASELINE_V345.md'
    assert baseline.exists()
    text = baseline.read_text(encoding='utf-8')
    for token in ('Composition Root', 'Core', 'Content', 'Learner State', 'Authentication', 'Subscription', 'Transport', 'UI'):
        assert token in text


def test_core_and_v35_have_no_singleton_lookup():
    for root in (ROOT / 'lib/core', ROOT / 'lib/ui_v35'):
        for path in root.rglob('*.dart'):
            text = path.read_text(encoding='utf-8')
            assert '.instance' not in text, str(path)


def test_modern_ui_does_not_construct_legacy_search_facade():
    for path in (ROOT / 'lib/ui_v35').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        assert 'LegacySearchIndex' not in text
        assert 'search_index_legacy.dart' not in text
