from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'content/german'


def _rows(pattern, glob):
    return [
        line for p in sorted(DATA.glob(glob))
        for line in p.read_text(encoding='utf-8').splitlines()
        if re.match(pattern, line.strip())
    ]


def test_large_data_tables_are_chunked_and_aggregators_are_small():
    content = DATA / 'content_a1.dart'
    verbs = DATA / 'verb_conjugations.dart'
    assert len(content.read_text(encoding='utf-8').splitlines()) < 300
    assert len(verbs.read_text(encoding='utf-8').splitlines()) < 300
    content_parts = sorted(DATA.glob('content_a1_part_*.dart'))
    verb_parts = sorted(DATA.glob('verb_conjugations_part_*.dart'))
    assert len(content_parts) == 16
    assert len(verb_parts) == 15
    assert all(len(p.read_text(encoding='utf-8').splitlines()) <= 804 for p in content_parts)
    assert all(len(p.read_text(encoding='utf-8').splitlines()) <= 804 for p in verb_parts)


def test_chunked_data_cardinality_and_ids_are_preserved():
    content_rows = _rows(r"ContentItem\(", 'content_a1_part_*.dart')
    verb_rows = _rows(r"VerbConjugation\(", 'verb_conjugations_part_*.dart')
    ids = re.findall(r"ContentItem\(id:'([^']+)'", '\n'.join(content_rows))
    assert len(content_rows) == 12409
    assert len(ids) == len(set(ids))
    assert ids[0] == 'w0001'
    assert ids[-1] == 'w15776'
    assert len(verb_rows) == 11691
    assert 'infinitive:"vereinbaren"' in '\n'.join(verb_rows)
    assert 'infinitive:"vermeiden"' in '\n'.join(verb_rows)
