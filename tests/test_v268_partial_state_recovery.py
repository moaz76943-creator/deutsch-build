from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_loader_filters_non_string_top_level_keys_before_typed_map_conversion():
    load = REPO[REPO.index('LearnerState load()'):REPO.index('  Future<void> save(')]
    assert "final j = <String, dynamic>{};" in load
    assert "for (final entry in decoded.entries)" in load
    assert "if (entry.key is String) j[entry.key as String] = entry.value;" in load


def test_loader_keeps_valid_fields_when_one_top_level_storage_key_is_malformed():
    load = REPO[REPO.index('LearnerState load()'):REPO.index('  Future<void> save(')]
    assert 'final decoded = jsonDecode(raw);' in load
    assert "if (decoded is! Map) return LearnerState(updatedAt: DateTime.now());" in load
    assert "final j = <String, dynamic>{};" in load
