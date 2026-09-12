import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'content' / 'german'


def all_content():
    return '\n'.join(p.read_text(encoding='utf-8') for p in DATA.glob('content*.dart'))


def test_v180_content_is_unique_and_wired():
    text = all_content()
    rows = dict(re.findall(r"ContentItem\(id:'([^']+)',german:'([^']*)'", text))
    ids = [f'w{n}' for n in range(16130, 16150)]
    assert all(i in rows for i in ids)
    assert len(set(rows[i].lower() for i in ids)) == 20
    assert len(rows) == len(set(rows))
    all_rows = re.findall(r"ContentItem\(id:'([^']+)',german:'([^']*)'", text)
    legacy = {g.lower() for i,g in all_rows if i not in ids}
    assert all(rows[i].lower() not in legacy for i in ids)


def test_v180_verbs_have_complete_person_sets():
    text = (DATA / 'verb_conjugations_v180.dart').read_text(encoding='utf-8')
    for infinitive in ('beeinflussen', 'sich erkundigen', 'erwähnen'):
        block = text[text.index(f'infinitive:"{infinitive}"'):]
        block = block[:block.find('\n\n') if '\n\n' in block else len(block)]
        persons = re.findall(r'person:"([^"]+)"', block)
        assert persons == ['ich','du','er','sie','es','wir','ihr','sie','Sie']
        assert all('past:' in line and 'pastExample:' in line for line in block.splitlines() if 'VerbConjugation(' in line)


def test_v180_repaired_hinausgehen_and_erwidern_are_grammatical_shapes():
    text = (DATA / 'verb_conjugations_part_09.dart').read_text(encoding='utf-8')
    assert 'hingeausgeht' not in text
    assert 'Er hinausgeht hinausgeht heute.' not in text
    assert 'Ich hinausgehe heute.' not in text
    assert 'erwideen' not in text
    assert 'Er erwidet erwidet die Aufgabe.' not in text
    assert 'Ich gehe heute hinaus.' in text
    assert 'Ich erwidere die Frage.' in text
    assert 'Ich verteidige die Stadt.' in text


def test_v180_baseline_matches_current_corpus():
    text = all_content()
    ids = re.findall(r"ContentItem\(id:'([^']+)'", text)
    german = re.findall(r"ContentItem\(id:'[^']+',german:'([^']*)'", text)
    baseline = {}
    for line in (ROOT / 'tool' / 'content_baseline.lock').read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.startswith('#'):
            k,v=line.split('=',1); baseline[k]=v
    assert len(ids) == int(baseline['CONTENT_ENTRIES'])
    assert len(set(ids)) == int(baseline['UNIQUE_IDS'])
    assert len(set(x.lower() for x in german)) == int(baseline['UNIQUE_GERMAN'])
    assert hashlib.sha256('\n'.join(sorted(ids)).encode()).hexdigest() == baseline['IDS_SHA256']

def test_build_guard_fails_fast_for_missing_wrapper_jar():
    text = (ROOT / 'scripts' / 'build_guard.sh').read_text(encoding='utf-8')
    assert 'android/gradle/wrapper/gradle-wrapper.jar' in text
    assert 'Gradle Wrapper JAR is missing' in text
