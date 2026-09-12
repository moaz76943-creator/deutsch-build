from pathlib import Path

ROOT=Path(__file__).parents[1]
Q=(ROOT/'lib/services/quality.dart').read_text()


def test_content_quality_has_precomputed_validation_cache_api():
    assert 'static final Expando<List<String>> _validationCache' in Q
    assert 'static List<String> issues(ContentItem item)' in Q
    assert 'static bool isLearnable(ContentItem item) => issues(item).isEmpty;' in Q


def test_hot_paths_use_cached_quality_issues():
    for rel in ['lib/services/learning_engine.dart','lib/services/reading_practice.dart','lib/services/assessment_engine.dart','lib/services/repair_engine.dart']:
        text=(ROOT/rel).read_text()
        assert ('ContentQuality.issues(' in text) or ('required LanguageContentQuality' in text and 'contentQuality.issues' in text) or ('required bool Function(' in text and 'isLearnable' in text) or ('exerciseStrategy.repairDrill' in text), rel


def test_quality_cache_does_not_change_collection_validation_contract():
    assert 'collectionErrors(List<ContentItem> xs)' in Q
    assert 'uniqueGerman(List<ContentItem> xs)' in Q
    assert 'uniqueIds(List<ContentItem> xs)' in Q
