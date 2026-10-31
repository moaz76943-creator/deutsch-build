from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SHARED_UI = [
    ROOT / 'lib/ui/app.dart',
    ROOT / 'lib/ui_v35/learning_pages.dart',
    *sorted((ROOT / 'lib/ui_v35/learning').glob('*.dart')),
    ROOT / 'lib/ui_v35/pages/core_pages.dart',
    ROOT / 'lib/ui_v35/progress_pages.dart',
]
FORBIDDEN = (r'\.german\b', r'\.arabic\b', r'\.sentenceAr\b', r'\.sentence\b', r'\.article\b', r'\.plural\b', r'\.accepted\b')

def test_shared_ui_no_longer_reads_language_shaped_content_fields_directly():
    offenders = []
    for path in SHARED_UI:
        text = path.read_text()
        for token in FORBIDDEN:
            if re.search(token, text):
                offenders.append(f'{path.relative_to(ROOT)}:{token}')
    assert not offenders, '\n'.join(offenders)

def test_shared_ui_uses_language_presentation_for_target_language_copy():
    presentation = (ROOT / 'lib/language/language_presentation.dart').read_text()
    german = (ROOT / 'lib/language/german/german_language_presentation.dart').read_text()
    learning = (ROOT / 'lib/ui_v35/learning_pages.dart').read_text() + '\n' + '\n'.join(
        path.read_text() for path in sorted((ROOT / 'lib/ui_v35/learning').glob('*.dart'))
    )
    core = (ROOT / 'lib/ui_v35/pages/core_pages.dart').read_text()
    assert 'LanguagePresentation' in core
    for getter in ('targetLanguageName', 'pronunciationTooltip', 'grammaticalMarkerLabel', 'pluralLabel'):
        assert f'String get {getter}' in presentation
        assert getter in german
    assert "'نطق ألماني'" not in core
    assert "'Artikel: ${" not in core
    assert "'Plural: ${" not in core
    assert "اكتب بالألمانية" not in learning
