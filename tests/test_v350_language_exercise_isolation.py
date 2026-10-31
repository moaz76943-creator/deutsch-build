from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / 'lib/language/language_exercise_strategy.dart'
GERMAN = ROOT / 'lib/language/german/german_language_exercise_strategy.dart'
LANG_PACK = ROOT / 'lib/language/language_pack.dart'
ASSESS = ROOT / 'lib/services/assessment_engine.dart'
PROD = ROOT / 'lib/services/production_engine.dart'
REPAIR = ROOT / 'lib/services/repair_engine.dart'
CONV = ROOT / 'lib/services/conversation_engine.dart'
LEARNING = ROOT / 'lib/services/learning_engine.dart'
MAIN = ROOT / 'lib/main.dart'


def test_language_exercise_strategy_contract_exists_and_is_neutral():
    text = PACK.read_text(encoding='utf-8')
    assert 'abstract interface class LanguageExerciseStrategy' in text
    for token in ('AssessmentQuestion', 'ProductionTask', 'RepairDrill', 'ConversationScenario'):
        assert token in text
    assert 'german' not in text.lower()
    assert 'arabic' not in text.lower()


def test_german_strategy_owns_language_specific_exercise_wording_and_scenarios():
    text = GERMAN.read_text(encoding='utf-8')
    assert 'class GermanLanguageExerciseStrategy implements LanguageExerciseStrategy' in text
    for token in ('ترجم إلى الألمانية', 'اكتب جملة ألمانية', 'Guten Tag. Was möchten Sie?'):
        assert token in text


def test_language_pack_exposes_exercise_strategy():
    text = LANG_PACK.read_text(encoding='utf-8')
    assert "import 'language_exercise_strategy.dart';" in text
    assert 'LanguageExerciseStrategy get exerciseStrategy;' in text


def test_language_specific_strings_are_removed_from_generic_exercise_services():
    for path in (ASSESS, PROD, REPAIR, CONV):
        text = path.read_text(encoding='utf-8')
        assert 'German' not in text
        assert 'الألمانية' not in text
        assert 'promptGerman' not in text
        assert 'promptArabic' not in text
        assert "'Guten Tag. Was möchten Sie?'" not in text


def test_generic_exercise_services_delegate_language_specific_behavior():
    assess = ASSESS.read_text(encoding='utf-8')
    prod = PROD.read_text(encoding='utf-8')
    repair = REPAIR.read_text(encoding='utf-8')
    conv = CONV.read_text(encoding='utf-8')
    learning = LEARNING.read_text(encoding='utf-8')
    assert 'required LanguageExerciseStrategy exerciseStrategy' in assess
    assert 'exerciseStrategy.assessmentQuestion' in assess
    assert 'required LanguageExerciseStrategy exerciseStrategy' in prod
    assert 'exerciseStrategy.productionTask' in prod
    assert 'required LanguageExerciseStrategy exerciseStrategy' in repair
    assert 'exerciseStrategy.repairDrill' in repair
    assert 'ConversationEngine(' in conv
    assert 'required this.exerciseStrategy' in conv
    assert 'exerciseStrategy.conversationScenarios' in conv
    assert 'required LanguageExerciseStrategy exerciseStrategy' in learning


def test_phase3_root_selects_language_identity_without_legacy_exercise_graph():
    main = MAIN.read_text(encoding='utf-8')
    lang_pack = LANG_PACK.read_text(encoding='utf-8')
    assert 'exerciseStrategy' in lang_pack
    assert 'const activeLanguagePack = GermanLanguagePack();' in main
    assert 'activeLanguagePack.languageCode' in main
    assert 'LanguageExerciseStrategy(' not in main
