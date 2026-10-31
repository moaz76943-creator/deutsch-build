from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_categories_page_does_not_rebuild_topic_map_inside_build():
    text = (ROOT / 'lib/ui_v35/pages/core_pages.dart').read_text()
    page = text[text.index('class CategoriesPage'):text.index('class CategoryWordsPage')]
    build = page[page.index('Widget build'):]
    assert 'final m=<String,List<ContentItem>>{};' not in build
    assert 'searchIndex.topicGroups' in build


def test_learning_core_weakest_skill_avoids_repeated_list_materialization():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'static String weakestSkill(LearnerState s)' in text
    assert 'final attemptsBySkill = _attemptsBySkill(s);' in text
    assert '.where((x)=>x.skill==skill).toList()' not in text


def test_learning_core_skill_scores_uses_shared_skill_buckets():
    text = (ROOT / 'lib/core/learning_core.dart').read_text()
    assert 'static Map<String, double> skillScores(LearnerState s)' in text
    assert 'final attemptsBySkill = _attemptsBySkill(s);' in text
    assert 'k: _score(attemptsBySkill[k] ?? const <Attempt>[])' in text
