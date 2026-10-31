import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "verb_conjugation"

FILES = [
    FEATURE / "domain" / "verb_models.dart",
    FEATURE / "domain" / "verb_repository.dart",
    FEATURE / "domain" / "verb_conjugation_factory.dart",
    FEATURE / "data" / "common_verb_seeds.dart",
    FEATURE / "data" / "local_verb_repository.dart",
    FEATURE / "application" / "verb_drill_notifier.dart",
    FEATURE / "presentation" / "screens" / "verb_conjugation_screen.dart",
    FEATURE / "presentation" / "widgets" / "rapid_conjugation_drill_widget.dart",
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_every_feature_file_stays_under_strict_1000_line_ceiling():
    for path in FILES:
        assert path.is_file(), path
        assert len(read(path).splitlines()) < 1000, path


def test_common_bank_contains_exactly_50_seed_records():
    text = read(FEATURE / "data" / "common_verb_seeds.dart")
    assert len(re.findall(r"^\s*_seed\($", text, re.MULTILINE)) == 50
    for verb in ("sein", "haben", "gehen", "fahren", "sehen", "anfangen"):
        assert f"'{verb}'" in text


def test_domain_owns_tenses_pronouns_and_perfect_auxiliary_rules():
    models = read(FEATURE / "domain" / "verb_models.dart")
    factory = read(FEATURE / "domain" / "verb_conjugation_factory.dart")
    for token in ("praesens", "praeteritum", "perfekt"):
        assert token in models
    for pronoun in ("ich", "du", "erSieEs", "wir", "ihr", "sieSie"):
        assert pronoun in models
    assert "PerfectAuxiliary.haben" in factory
    assert "PerfectAuxiliary.sein" in factory
    assert "presentEmphasisTokens" in models


def test_application_owns_speed_scoring_timeout_and_mistake_tracking():
    notifier = read(FEATURE / "application" / "verb_drill_notifier.dart")
    for token in (
        "speedBonus",
        "streakBonus",
        "repeatedMistakes",
        "remainingSeconds",
        "forceTimeout",
        "VerbDrillMode.letterOrder",
        "VerbDrillMode.multipleChoice",
    ):
        assert token in notifier


def test_presentation_uses_canonical_glass_design_system_and_no_audio_plugins():
    presentation = "\n".join(
        read(path)
        for path in FILES
        if "/presentation/" in path.as_posix()
    )
    assert presentation.count("AppGlassCard") >= 4
    assert "AppColors." in presentation
    assert "AppTypography." in presentation
    for package in (
        "flutter_tts",
        "speech_to_text",
        "audioplayers",
        "just_audio",
        "flutter_sound",
    ):
        assert package not in presentation


def test_no_placeholder_or_quality_bypass_markers_were_added():
    combined = "\n".join(read(path) for path in FILES)
    assert "TODO" not in combined
    assert "FIXME" not in combined
    assert "ignore_for_file" not in combined
    assert "// ignore:" not in combined


def test_feature_is_exposed_through_live_app_navigation():
    app = read(ROOT / "lib" / "ui_v35" / "app.dart")
    assert "verb_conjugation/data/local_verb_repository.dart" in app
    assert "verb_conjugation/presentation/screens/verb_conjugation_screen.dart" in app
    assert "builder: (_) => VerbConjugationScreen(" in app
    assert "repository: LocalVerbRepository()" in app
    assert "builder: (_) => VerbConjugationPage(" not in app


def test_deadline_is_enforced_inside_application_submit():
    notifier = read(FEATURE / "application" / "verb_drill_notifier.dart")
    assert "deadlineReached" in notifier
    assert "elapsed >= Duration(seconds: _secondsPerQuestion)" in notifier
    assert "final timedOut = forceTimeout || deadlineReached;" in notifier


def test_fahren_seed_is_scoped_to_movement_sense_for_sein_perfect():
    seeds = read(FEATURE / "data" / "common_verb_seeds.dart")
    assert "'fahren', 'يسافر / ينتقل بمركبة', VerbKind.irregular" in seeds
    assert "'fahren', 'يسافر / يقود', VerbKind.irregular" not in seeds
