from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANG_PRESENTATION = ROOT / 'lib/language/language_presentation.dart'
GERMAN_PRESENTATION = ROOT / 'lib/language/german/german_language_presentation.dart'
GERMAN_PACK = ROOT / 'lib/language/german/german_language_pack.dart'
CORE = ROOT / 'lib/ui_v35/pages/core_pages.dart'
APP = ROOT / 'lib/ui_v35/app.dart'


def test_language_presentation_exposes_placement_without_german_coupling():
    text = LANG_PRESENTATION.read_text(encoding='utf-8')
    assert 'PlacementPresentation get placement;' in text
    assert 'abstract interface class PlacementPresentation' in text
    assert 'List<PlacementQuestion> get questions;' in text
    assert 'German' not in text
    assert 'الألمانية' not in text


def test_german_presentation_owns_placement_questions_and_labels():
    text = GERMAN_PRESENTATION.read_text(encoding='utf-8')
    for token in (
        'GermanPlacementPresentation',
        'ما ترجمة: Haus؟',
        'ما الكلمة الصحيحة: ___ Arzt',
        'أكمل: Ich ___ Deutsch.',
        'ما ترجمة: Wasser؟',
        'أكمل: Ich fahre mit ___ Bus.',
        'ما الصحيح: Ich habe ___ Problem.',
    ):
        assert token in text


def test_german_pack_exposes_placement_presentation():
    text = GERMAN_PACK.read_text(encoding='utf-8')
    assert 'GermanLanguagePresentation' in text
    assert 'GermanPlacementPresentation' in GERMAN_PRESENTATION.read_text(encoding='utf-8')


def test_placement_ui_consumes_language_presentation_instead_of_owning_questions():
    text = CORE.read_text(encoding='utf-8')
    assert 'LanguagePresentation' in text
    assert 'presentation.placement' in text
    for token in ('ما ترجمة: Haus؟', 'ما الكلمة الصحيحة: ___ Arzt', 'أكمل: Ich ___ Deutsch.'):
        assert token not in text


def test_composition_root_passes_language_presentation_to_placement_ui():
    text = APP.read_text(encoding='utf-8')
    assert 'presentation: widget.dependencies.languagePack.presentation' in text


def test_release_version_advances_for_v353():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
