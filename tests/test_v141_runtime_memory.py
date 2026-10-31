from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
SRC=(ROOT/'lib/services/search_index.dart').read_text(encoding='utf-8')

def test_search_does_not_eagerly_materialize_entry_objects():
    assert 'late final List<_Entry> _entries =' not in SRC

def test_search_keeps_entry_cache_bounded_by_touched_items():
    assert 'final Map<String, _Entry<T>> _entryCache' in SRC
    assert '_entryCache[item.id] ??= _Entry<T>(item, _textNormalizer)' in SRC

def test_exact_indexes_build_directly_from_content_without_entry_list():
    assert re.search(r'_buildExact\(\s*_items\s*,', SRC, re.DOTALL)

def test_entry_by_id_full_map_is_removed():
    assert 'Map<String, _Entry> _entryById' not in SRC
