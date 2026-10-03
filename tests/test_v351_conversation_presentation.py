from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANG_PRESENTATION = ROOT / 'lib/language/language_presentation.dart'
GERMAN_PRESENTATION = ROOT / 'lib/language/german/german_language_presentation.dart'
LANG_PACK = ROOT / 'lib/language/language_pack.dart'
GERMAN_PACK = ROOT / 'lib/language/german/german_language_pack.dart'
CONVERSATION = ROOT / 'lib/ui_v35/conversation_pages.dart'
APP = ROOT / 'lib/ui_v35/app.dart'


def test_language_presentation_contract_is_language_neutral():
    text = LANG_PRESENTATION.read_text(encoding='utf-8')
    assert 'abstract interface class LanguagePresentation' in text
    assert 'ConversationPresentation get conversation;' in text
    assert 'German' not in text
    assert 'الألمانية' not in text


def test_conversation_presentation_contract_exists_and_owns_language_aware_copy():
    text = LANG_PRESENTATION.read_text(encoding='utf-8')
    assert 'abstract interface class ConversationPresentation' in text
    for token in (
        'targetLanguageName',
        'targetLanguageInstruction',
        'speechPermissionError',
        'defaultSpeechStatus',
        'fallbackScenario',
    ):
        assert f'String get {token};' in text or f'ConversationScenario get {token};' in text


def test_german_presentation_owns_conversation_specific_german_copy_and_fallback():
    text = GERMAN_PRESENTATION.read_text(encoding='utf-8')
    assert 'class GermanLanguagePresentation implements LanguagePresentation' in text
    assert 'GermanConversationPresentation' in text
    for token in ('Wie geht es Ihnen?', 'Mir geht es gut.', 'تحدث بالألمانية'):
        assert token in text


def test_language_pack_exposes_language_presentation_and_german_pack_wires_it():
    pack = LANG_PACK.read_text(encoding='utf-8')
    german = GERMAN_PACK.read_text(encoding='utf-8')
    assert 'LanguagePresentation get presentation;' in pack
    assert 'LanguagePresentation get presentation' in german
    assert 'GermanLanguagePresentation()' in german


def test_conversation_ui_consumes_presentation_instead_of_owning_conversation_language_copy():
    text = CONVERSATION.read_text(encoding='utf-8')
    compact = ''.join(text.split())
    assert "import'../language/language_presentation.dart';" in compact
    assert 'requiredthis.presentation' in compact
    assert 'widget.presentation.conversation.fallbackScenario' in compact
    assert 'widget.presentation.conversation.targetLanguageInstruction' in compact
    assert 'widget.presentation.conversation.speechPermissionError' in compact
    assert "promptGerman:'Wie geht es Ihnen?'" not in text
    assert "expected:['Mir geht es gut.']" not in text
    assert 'تحدثبالألمانية،وسيقارنالتطبيق' not in compact
    assert 'إعداداللغةالألمانية' not in compact


def test_composition_root_passes_language_presentation_to_conversation_ui():
    compact = ''.join(APP.read_text(encoding='utf-8').split())
    assert 'presentation:widget.dependencies.languagePack.presentation' in compact
