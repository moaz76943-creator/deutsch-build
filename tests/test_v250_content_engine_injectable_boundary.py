from pathlib import Path

SRC = Path('lib/services/content_engine.dart').read_text(encoding='utf-8')


def test_content_engine_accepts_a_content_source_without_source_selection_in_public_constructor():
    assert 'const ContentEngine(this._source);' in SRC
    assert 'final ContentSource<T> _source;' in SRC
    assert 'ContentEngine<T extends LearningContent>' in SRC


def test_existing_sources_remain_intact_and_generated_factory_is_preserved():
    assert 'ContentSource<T extends LearningContent>' in SRC
    assert 'const ContentEngine(this._source);' in SRC
    assert 'T? byId(String id)' in SRC
