#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
CONTENT_JSON = ROOT / 'content/content_items.json'
VERB_JSON = ROOT / 'content/verb_conjugations.json'

content_rows = json.loads(CONTENT_JSON.read_text(encoding='utf-8'))
verb_rows = json.loads(VERB_JSON.read_text(encoding='utf-8'))
ids = [str(row.get('id', '')) for row in content_rows]
german = [str(row.get('german', '')) for row in content_rows]
errors = []

if not content_rows:
    errors.append('content catalog is empty')
if any(not value.strip() for value in ids):
    errors.append('content ID must be a non-empty string')
if len(ids) != len(set(ids)):
    errors.append('duplicate content IDs')
if len(german) != len({x.lower() for x in german}):
    errors.append('duplicate German entries')

if any(row.get('infinitive') == 'vermutten' for row in verb_rows):
    errors.append('obsolete verb typo vermutten remains')

for row in content_rows:
    sentence = str(row.get('sentence', ''))
    if re.match(r'Ich (?:eine|einen|ein|die|den|das)\s+', sentence):
        errors.append('generated first-person sentence still places object before verb')
        break
if any(re.search(r'\s{2,}', str(row.get('sentence', ''))) for row in content_rows):
    errors.append('German sentence contains doubled whitespace')
for row in content_rows:
    headword = str(row.get('german', ''))
    sentence = str(row.get('sentence', ''))
    if re.fullmatch(r'[a-zäöüß]+en', headword) and re.match(
        r'Ich [a-zäöüß]+en (?:heute|jetzt|morgen)\.', sentence
    ):
        errors.append('generated first-person infinitive used as finite verb')
        break

content_text = '\n'.join(
    ' | '.join(
        str(row.get(field, ''))
        for field in ('id', 'german', 'arabic', 'sentence', 'sentenceAr')
    )
    for row in content_rows
)
verb_text = '\n'.join(
    ' | '.join(
        str(row.get(field, ''))
        for field in ('infinitive', 'person', 'form', 'example', 'pastExample')
    )
    for row in verb_rows
)

for typo in ('angefangt', 'angetwortet', 'nehmest mit', 'nehmet mit'):
    if typo in content_text:
        errors.append(f'known generated typo remains: {typo}')
if 'Die firma' in content_text:
    errors.append('German noun capitalization error remains: Firma')
if 'Ich zusage heute.' in verb_text:
    errors.append('obsolete separable-verb sentence remains')
if 'Die kundin' in content_text:
    errors.append('lowercase Kundin sentence remains')
for phrase in (
    'العميلة يؤكد',
    'العميلة يفحص',
    'العميلة يرسل',
    'العميلة يعالج',
    'العميلة يفتح',
    'العميلة يحفظ',
    'العميلة يخطط',
):
    if phrase in content_text:
        errors.append('feminine Arabic agreement error remains')

# Deep Arabic-example contamination checks: German headwords should not leak into Arabic examples.
for row in content_rows:
    iid = str(row.get('id', ''))
    g = str(row.get('german', ''))
    sentence_ar = str(row.get('sentenceAr', ''))
    head = re.sub(r'^(?:der|die|das)\s+', '', g).strip()
    if head and re.search(rf'(?<!\w){re.escape(head)}(?!\w)', sentence_ar, re.I):
        errors.append(f'German headword leaked into Arabic example: {iid}')

# Catch known truncated compound fragments only inside Arabic fields.
compound_fragments = (
    'sbeleg','sproblem','splan','sfr ist','nanfrage','nbetreuung','nberater',
    'nberatung','nportal','nzufriedenheit','sverkehr','sdienst','sdaten',
    'sinformation','snummer','sstatus','sweise','sfehler','saufforderung',
    'snachweis','sbetrag','stermin','seingang','chule','rüfung','enntnis',
    'enntnisse','ernen','bung','artner','artnerin','ehler','raining','raxis',
    'ehrer','ehrerin','ruppe','eise','evel','nummernänderung','kontaktperson',
    'schutzregel','schutzgesetz','übertragung','datei',
)
for row in content_rows:
    iid = str(row.get('id', ''))
    arabic = str(row.get('arabic', ''))
    sentence_ar = str(row.get('sentenceAr', ''))
    combined = arabic + ' ' + sentence_ar
    for bad_token in compound_fragments:
        if re.search(
            rf'(?<![A-Za-zÄÖÜäöüß]){re.escape(bad_token)}(?![A-Za-zÄÖÜäöüß])',
            combined,
            re.I,
        ):
            errors.append(
                f'Known Arabic compound-fragment contamination remains: {iid} / {bad_token}'
            )

# Catch obvious third-person leakage in first-person Arabic examples.
allowed_after_ar_want = ('ينبغي', 'ينقصني', 'يناسب', 'يعجبني', 'يُسمح لي', 'يكون')
for row in content_rows:
    sentence_ar = str(row.get('sentenceAr', ''))
    if sentence_ar.startswith('أريد أن ي') and not any(
        sentence_ar.startswith('أريد أن ' + value)
        for value in allowed_after_ar_want
    ):
        errors.append(
            'Likely third-person leakage after Arabic first-person أريد أن: '
            + sentence_ar
        )

# Latin words in Arabic examples are normally contamination; preserve standard technical acronyms.
latin_allow = {'USB','PDF','PIN','Wi-Fi','WLAN','QR','E-Mail','Online','App','SMS','WhatsApp'}
for row in content_rows:
    sentence_ar = str(row.get('sentenceAr', ''))
    for token in re.findall(r'(?<![A-Za-z])([A-Za-z][A-Za-z-]{2,})(?![A-Za-z])', sentence_ar):
        if token not in latin_allow:
            errors.append(f'Unexpected Latin token in Arabic example: {token}')
            break

# Catch generated ich-form conjugation suffix errors in the conjugation dataset.
for row in verb_rows:
    if row.get('person') != 'ich':
        continue
    inf = str(row.get('infinitive', ''))
    form = str(row.get('form', ''))
    if (form.endswith('ne') and len(form) > len(inf) and inf != 'tun') or form.endswith('ee'):
        errors.append(f'Generated ich-conjugation typo: {inf} -> {form}')

if errors:
    print('QUALITY AUDIT: FAIL')
    for error in errors:
        print('ERROR:', error)
    sys.exit(1)

print('QUALITY AUDIT: PASS')
print(f'Content entries: {len(ids)}')
print(f'Unique IDs: {len(set(ids))}')
print(f'Unique German entries: {len({x.lower() for x in german})}')
