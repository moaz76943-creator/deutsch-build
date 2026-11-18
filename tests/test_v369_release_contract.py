from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v369_release_contract_declares_ui_language_boundary():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    presentation = (ROOT / 'lib/language/language_presentation.dart').read_text(encoding='utf-8')
    core = (ROOT / 'lib/ui_v35/pages/core_pages.dart').read_text(encoding='utf-8')
    learning_root = ROOT / 'lib/ui_v35/learning_pages.dart'
    learning = learning_root.read_text(encoding='utf-8') + '\n' + '\n'.join(
        path.read_text(encoding='utf-8')
        for path in sorted((ROOT / 'lib/ui_v35/learning').glob('*.dart'))
    )
    progress = (ROOT / 'lib/ui_v35/progress_pages.dart').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert "versionName " in gradle
    for getter in ('targetLanguageName', 'pronunciationTooltip', 'grammaticalMarkerLabel', 'pluralLabel'):
        assert f'String get {getter}' in presentation
    assert 'LanguagePresentation' in core
    assert 'LanguagePresentation' in learning
    assert 'LanguagePresentation' in progress
    assert '.german' not in core and '.arabic' not in core
    assert '.german' not in learning and '.arabic' not in learning
    assert '.german' not in progress and '.arabic' not in progress
