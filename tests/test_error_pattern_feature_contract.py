from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / 'lib/features/error_pattern_agent'
FILES = list(FEATURE.rglob('*.dart'))


def read(path):
    return path.read_text(encoding='utf-8')


def test_feature_layers_and_models_exist():
    assert (FEATURE / 'domain/error_pattern_models.dart').is_file()
    assert (FEATURE / 'domain/error_pattern_analyzer.dart').is_file()
    assert (FEATURE / 'data/local_error_diagnostic_repository.dart').is_file()
    assert (FEATURE / 'application/error_pattern_agent_notifier.dart').is_file()
    assert (FEATURE / 'presentation/blind_spot_radar_screen.dart').is_file()
    assert (
        FEATURE / 'presentation/widgets/glass_diagnostic_card.dart'
    ).is_file()


def test_models_cover_only_linguistic_error_patterns():
    text = read(FEATURE / 'domain/error_pattern_models.dart')
    for token in ('genderConfusion', 'caseMismatch', 'wordOrderDrift'):
        assert token in text
    for forbidden in (
        'personality',
        'intelligence',
        'iq',
        'disorder',
        'diagnosisMedical',
    ):
        assert forbidden not in text.lower()


def test_analyzer_owns_classification_frequency_top3_and_severity():
    text = read(FEATURE / 'domain/error_pattern_analyzer.dart')
    for token in (
        'classify(',
        'count / all.length',
        'diagnostics.take(3)',
        'DiagnosticSeverity.high',
        'recommendationFor',
    ):
        assert token in text


def test_local_repository_is_bounded_and_uses_preferences_adapter():
    text = read(FEATURE / 'data/local_error_diagnostic_repository.dart')
    assert 'PreferencesService' in text
    assert 'maxEntries = 500' in text
    assert 'error_pattern_diagnostic_entries_v1' in text


def test_presentation_uses_glass_and_design_tokens_without_analysis_logic():
    text = '\n'.join(
        read(path)
        for path in FILES
        if '/presentation/' in path.as_posix()
    )
    assert text.count('AppGlassCard') >= 4
    assert 'AppColors.' in text
    assert 'AppTypography.' in text
    assert 'classify(' not in text
    assert 'buildReport(' not in text


def test_all_feature_files_under_1000_lines_and_no_quality_bypass():
    assert FILES
    for path in FILES:
        text = read(path)
        assert len(text.splitlines()) < 1000, path
        assert ('TO' + 'DO') not in text
        assert ('FIX' + 'ME') not in text
        assert ('ignore_' + 'for_file') not in text


def test_academic_ethics_copy_is_explicitly_non_personal():
    text = read(FEATURE / 'presentation/blind_spot_radar_screen.dart')
    assert 'لا يقيّم الشخصية' in text
    assert 'أنماط الإجابات' in text


def test_error_pattern_feature_remains_isolated_from_phase3_root():
    learner = read(ROOT / 'lib/services/repository.dart')
    grammar = read(
        ROOT / 'lib/features/grammar/application/grammar_drill_notifier.dart'
    )
    app = read(ROOT / 'lib/ui_v35/app.dart')
    main = read(ROOT / 'lib/main.dart')
    assert 'errorDiagnosticSink.recordFailure' in learner
    assert "skillTag: 'sentence_reorder'" in grammar
    assert "skillTag: 'case_" in grammar
    assert 'BlindSpotRadarScreen(' in app
    assert 'LocalErrorDiagnosticRepository(prefs)' not in main
    assert 'errorPatternAgent: errorPatternAgent' not in main


def test_modified_integration_files_stay_under_1000_lines():
    for relative in (
        'lib/ui_v35/app.dart',
        'lib/services/repository.dart',
        'lib/features/grammar/application/grammar_drill_notifier.dart',
        'lib/features/grammar/presentation/screens/grammar_drill_screen.dart',
        'lib/ui_v35/grammar/grammar_hub_page.dart',
    ):
        path = ROOT / relative
        assert len(read(path).splitlines()) < 1000, relative
