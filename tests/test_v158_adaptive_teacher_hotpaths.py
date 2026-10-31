from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'lib/services/adaptive_teacher.dart'


def test_adaptive_teacher_groups_attempts_by_skill_once():
    text = SRC.read_text(encoding='utf-8')
    assert 'final attemptsBySkill = <String, List<Attempt>>{};' in text
    assert '(attemptsBySkill[a.skill] ??= <Attempt>[]).add(a);' in text
    assert '_weakest(state, attemptsBySkill, scoresBySkill)' in text


def test_adaptive_teacher_reuses_skill_scores_instead_of_rescanning_attempts():
    text = SRC.read_text(encoding='utf-8')
    assert 'final scoresBySkill = <String, double>{};' in text
    assert 'scoresBySkill[skill]' in text
    assert 'state.attempts.where((a) => a.skill == skill)' not in text


def test_adaptive_teacher_computes_recent_failures_in_one_pass():
    text = SRC.read_text(encoding='utf-8')
    assert 'recentFailureCount' in text
    assert 'recentAttemptCount' in text
    assert '_recentFailureRate(state.attempts, at)' not in text
