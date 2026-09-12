from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
MAIN = ROOT / 'lib/main.dart'


def test_modern_ui_does_not_construct_app_wide_dependencies():
    offenders = []
    app_wide = ('SearchIndex(', 'VerbIndex(', 'ContentEngine(', 'LearnerRepository(', 'BackendTransportFactory.')
    for path in (LIB / 'ui_v35').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        for token in app_wide:
            if token in text:
                offenders.append((str(path.relative_to(ROOT)), token))
    assert offenders == []


def test_main_is_the_content_and_index_composition_root():
    text = MAIN.read_text(encoding='utf-8')
    assert 'final contentPack = languagePack.contentPack;' in text
    assert 'final corpus = contentPack.items.toList(growable: false);' in text
    assert 'final searchIndex = SearchIndex(corpus, contentPack.verbIndex, languagePack.textNormalizer);' in text
    assert 'final dependencies = AppDependencies<ContentItem>(' in text


def test_legacy_ui_has_no_global_content_or_verb_lookup():
    text = (LIB / 'ui/app.dart').read_text(encoding='utf-8')
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text
