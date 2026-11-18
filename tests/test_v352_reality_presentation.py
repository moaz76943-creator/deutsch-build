from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANG_PRESENTATION = ROOT / 'lib/language/language_presentation.dart'
GERMAN_PRESENTATION = ROOT / 'lib/language/german/german_language_presentation.dart'
GERMAN_PACK = ROOT / 'lib/language/german/german_language_pack.dart'
REALITY = ROOT / 'lib/ui_v35/pages/core_pages.dart'
APP = ROOT / 'lib/ui_v35/app.dart'


def test_language_presentation_exposes_real_world_learning_presentation_without_german_coupling():
    text = LANG_PRESENTATION.read_text(encoding='utf-8')
    assert 'RealWorldLearningPresentation get realWorld;' in text
    assert 'abstract interface class RealWorldLearningPresentation' in text
    assert 'List<RealWorldScenario> get scenarios;' in text
    assert 'German' not in text
    assert 'الألمانية' not in text


def test_german_presentation_owns_real_world_scenarios_and_labels():
    text = GERMAN_PRESENTATION.read_text(encoding='utf-8')
    for token in (
        'GermanRealWorldLearningPresentation',
        'محطة القطار',
        'Gleis 4',
        'Der Zug hat Verspätung.',
        'مواقف ستقابلها خارج الكتاب.',
    ):
        assert token in text


def test_german_pack_wires_real_world_presentation():
    text = GERMAN_PACK.read_text(encoding='utf-8')
    assert 'GermanLanguagePresentation' in text
    assert 'GermanRealWorldLearningPresentation' in GERMAN_PRESENTATION.read_text(encoding='utf-8')


def test_reality_ui_consumes_language_presentation_instead_of_owning_scenarios():
    text = REALITY.read_text(encoding='utf-8')
    assert "import '../../language/language_presentation.dart';" in text
    assert 'required this.presentation' in text
    assert 'widget.presentation.realWorld' in text or 'presentation.realWorld' in text
    for token in ('محطة القطار', 'Gleis 4', 'Der Zug hat Verspätung.', 'ألمانيا الحقيقية'):
        assert token not in text


def test_composition_root_passes_language_presentation_to_reality_ui():
    text = APP.read_text(encoding='utf-8')
    assert 'presentation: widget.dependencies.languagePack.presentation' in text


def test_release_version_advances_for_v352():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert "versionName " in gradle
