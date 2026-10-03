import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT_JSON = ROOT / 'content' / 'content_items.json'
VERB_JSON = ROOT / 'content' / 'verb_conjugations.json'
BASELINE = ROOT / 'tool' / 'content_baseline.lock'


def _content():
    return json.loads(CONTENT_JSON.read_text(encoding='utf-8'))


def _verbs():
    return json.loads(VERB_JSON.read_text(encoding='utf-8'))


def _baseline():
    values = {}
    for line in BASELINE.read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.startswith('#'):
            key, value = line.split('=', 1)
            values[key] = value
    return values


def test_v180_content_is_unique_and_wired():
    rows = {row['id']: row['german'] for row in _content()}
    ids = [f'w{n}' for n in range(16130, 16150)]
    assert all(i in rows for i in ids)
    assert len({rows[i].lower() for i in ids}) == 20
    legacy = {g.lower() for i, g in rows.items() if i not in ids}
    assert all(rows[i].lower() not in legacy for i in ids)


def test_v180_verbs_have_complete_person_sets():
    rows = _verbs()
    for infinitive in ('beeinflussen', 'sich erkundigen', 'erwähnen'):
        block = [row for row in rows if row['infinitive'] == infinitive]
        persons = [row['person'] for row in block]
        assert persons == ['ich','du','er','sie','es','wir','ihr','sie','Sie']
        assert all('past' in row and 'pastExample' in row for row in block)


def test_v180_repaired_hinausgehen_and_erwidern_are_grammatical_shapes():
    rows = _verbs()
    serialized = '\n'.join(
        f"{row['form']}|{row['example']}|{row['pastExample']}" for row in rows
    )
    assert 'hingeausgeht' not in serialized
    assert 'Er hinausgeht hinausgeht heute.' not in serialized
    assert 'Ich hinausgehe heute.' not in serialized
    assert 'erwideen' not in serialized
    assert 'Er erwidet erwidet die Aufgabe.' not in serialized
    assert 'Ich gehe heute hinaus.' in serialized
    assert 'Ich erwidere die Frage.' in serialized
    assert 'Ich verteidige die Stadt.' in serialized


def test_v180_baseline_matches_current_corpus():
    content = _content()
    ids = [row['id'] for row in content]
    german = [row['german'] for row in content]
    baseline = _baseline()
    assert len(ids) == int(baseline['CONTENT_ENTRIES'])
    assert len(set(ids)) == int(baseline['UNIQUE_IDS'])
    assert len({x.lower() for x in german}) == int(baseline['UNIQUE_GERMAN'])
    assert hashlib.sha256('\n'.join(sorted(ids)).encode()).hexdigest() == baseline['IDS_SHA256']


def test_build_guard_fails_fast_for_missing_wrapper_jar():
    text = (ROOT / 'scripts' / 'build_guard.sh').read_text(encoding='utf-8')
    assert 'android/gradle/wrapper/gradle-wrapper.jar' in text
    assert 'Gradle Wrapper JAR is missing' in text
