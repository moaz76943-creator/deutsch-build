from pathlib import Path
import re

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
    assert 'final activeLanguagePack = runtime.languagePack;' in text
    assert 'final contentPack = activeLanguagePack.contentPack;' in text
    assert 'final corpus = contentPack.items;' in text
    assert 'final verbIndex = contentPack.verbIndex;' in text
    assert re.search(
        r'final searchIndex\s*=\s*SearchIndex\(\s*corpus\s*,\s*verbIndex\s*,\s*'
        r'activeLanguagePack\.textNormalizer\s*,?\s*\);',
        text,
        re.DOTALL,
    )
    assert 'final dependencies = AppDependencies<ContentItem>(' in text


def test_legacy_ui_has_no_global_content_or_verb_lookup():
    text = (LIB / 'ui/app.dart').read_text(encoding='utf-8')
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text
