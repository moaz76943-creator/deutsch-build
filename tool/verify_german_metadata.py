import re
from pathlib import Path

def check_file(filepath: Path, expected_fields: list[str]):
    print(f"Checking {filepath}...")
    if not filepath.exists():
        print(f"  Error: {filepath} does not exist.")
        return False

    content = filepath.read_text(encoding='utf-8')
    missing_fields = []

    for field in expected_fields:
        # Simplistic check: just look for the field name in the file content.
        # A more robust check might involve parsing Dart code, but this is a start.
        # We look for `field` taking into account it could be in a list of variables or 'this.field'

        if not re.search(r'\b' + re.escape(field) + r'\b', content):
            missing_fields.append(field)

    if missing_fields:
        print(f"  Missing fields: {', '.join(missing_fields)}")
        return False

    print(f"  All expected fields ({', '.join(expected_fields)}) are present.")
    return True

def main():
    root_dir = Path(__file__).resolve().parents[1]

    content_dart = root_dir / 'lib' / 'models' / 'content.dart'
    # According to lib/models/content.dart we expect:
    # id, german, arabic, sentence, sentenceAr, topic, skill, article, plural, accepted
    expected_content_fields = ['id', 'german', 'arabic', 'sentence', 'sentenceAr', 'topic', 'skill', 'article', 'plural', 'accepted']
    content_ok = check_file(content_dart, expected_content_fields)

    verb_conjugation_dart = root_dir / 'lib' / 'models' / 'verb_conjugation.dart'
    # According to lib/models/verb_conjugation.dart we expect:
    # infinitive, arabic, group, person, personAr, form, past, pastArabic, example, exampleAr, pastExample, pastExampleAr
    expected_verb_fields = ['infinitive', 'arabic', 'group', 'person', 'personAr', 'form', 'past', 'pastArabic', 'example', 'exampleAr', 'pastExample', 'pastExampleAr']
    verb_ok = check_file(verb_conjugation_dart, expected_verb_fields)

    print()
    if content_ok and verb_ok:
        print("Data models align with the expected German grammatical metadata schema.")
        return 0
    else:
        print("Data models do NOT fully align with the expected schema.")
        return 1

if __name__ == '__main__':
    exit(main())
