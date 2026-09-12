#!/usr/bin/env python3
from pathlib import Path
import re, sys, hashlib
ROOT=Path(__file__).resolve().parents[1]
content_files=sorted((ROOT/'content/german').glob('content*.dart'))
all_content='\n'.join(p.read_text(encoding='utf-8') for p in content_files)
content=(ROOT/'content/german/content_a1.dart').read_text(encoding='utf-8')
verbs=(ROOT/'content/german/verb_conjugations.dart').read_text(encoding='utf-8')
ids=re.findall(r"ContentItem\(id:'([^']+)'",all_content)
german=re.findall(r"ContentItem\(id:'[^']+',german:'([^']*)'",all_content)
errors=[]

baseline_file = ROOT / 'tool/content_baseline.lock'
if not baseline_file.exists():
    errors.append('content integrity baseline is missing')
else:
    baseline = {}
    for line in baseline_file.read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            k, v = line.split('=', 1)
            baseline[k.strip()] = v.strip()
    expected_entries = int(baseline.get('CONTENT_ENTRIES', '-1'))
    expected_ids = int(baseline.get('UNIQUE_IDS', '-1'))
    expected_german = int(baseline.get('UNIQUE_GERMAN', '-1'))
    ids_hash = hashlib.sha256('\n'.join(sorted(ids)).encode('utf-8')).hexdigest()
    if len(ids) != expected_entries:
        errors.append(f'content entry count changed from baseline: expected {expected_entries}, found {len(ids)}')
    if len(set(ids)) != expected_ids:
        errors.append(f'unique content ID count changed from baseline: expected {expected_ids}, found {len(set(ids))}')
    if len(set(x.lower() for x in german)) != expected_german:
        errors.append(f'unique German entry count changed from baseline: expected {expected_german}, found {len(set(x.lower() for x in german))}')
    if ids_hash != baseline.get('IDS_SHA256'):
        errors.append('content ID hash differs from the reviewed baseline')

if len(ids)!=len(set(ids)): errors.append('duplicate content IDs')
if len(german)!=len(set(x.lower() for x in german)): errors.append('duplicate German entries')
if 'vermutten' in verbs: errors.append('obsolete verb typo vermutten remains')
if re.search(r"sentence:'Ich (?:eine|einen|ein|die|den|das) [^']*'", all_content): errors.append('generated first-person sentence still places object before verb')
if re.search(r"sentence:'[^']*\s{2,}[^']*'", all_content): errors.append('German sentence contains doubled whitespace')
if re.search(r"german:'[a-zäöüß]+en'[^\n]*sentence:'Ich [a-zäöüß]+en (?:heute|jetzt|morgen)\.'", all_content): errors.append('generated first-person infinitive used as finite verb')
for typo in ('angefangt', 'angetwortet', 'nehmest mit', 'nehmet mit'):
 if typo in content: errors.append(f'known generated typo remains: {typo}')
if 'Die firma' in content: errors.append('German noun capitalization error remains: Firma')
if 'Ich zusage heute.' in verbs: errors.append('obsolete separable-verb sentence remains')
if "Die kundin" in content: errors.append('lowercase Kundin sentence remains')
if 'العميلة يؤكد' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يفحص' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يرسل' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يعالج' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يفتح' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يحفظ' in content: errors.append('feminine Arabic agreement error remains')
if 'العميلة يخطط' in content: errors.append('feminine Arabic agreement error remains')

# Deep Arabic-example contamination checks: German headwords should not leak into Arabic examples.
for block in re.findall(r'ContentItem\((.*?)\),', all_content):
 m=re.search(r"id:'([^']*)'.*?german:'([^']*)'.*?sentenceAr:'([^']*)'", block)
 if not m: continue
 iid, g, sentence_ar = m.groups()
 head = re.sub(r'^(?:der|die|das)\s+', '', g).strip()
 if head and re.search(rf'(?<!\w){re.escape(head)}(?!\w)', sentence_ar, re.I):
  errors.append(f'German headword leaked into Arabic example: {iid}')
# Catch known truncated compound fragments only inside Arabic fields.
compound_fragments = ('sbeleg','sproblem','splan','sfr ist','nanfrage','nbetreuung','nberater','nberatung','nportal','nzufriedenheit','sverkehr','sdienst','sdaten','sinformation','snummer','sstatus','sweise','sfehler','saufforderung','snachweis','sbetrag','stermin','seingang','chule','rüfung','enntnis','enntnisse','ernen','bung','artner','artnerin','ehler','raining','raxis','ehrer','ehrerin','ruppe','eise','evel','nummernänderung','kontaktperson','schutzregel','schutzgesetz','übertragung','datei')
for block in re.findall(r'ContentItem\((.*?)\),', all_content):
 m=re.search(r"id:'([^']*)'.*?arabic:'([^']*)'.*?sentenceAr:'([^']*)'", block)
 if not m: continue
 iid, arabic, sentence_ar = m.groups()
 for bad_token in compound_fragments:
  if re.search(rf'(?<![A-Za-zÄÖÜäöüß]){re.escape(bad_token)}(?![A-Za-zÄÖÜäöüß])', arabic + ' ' + sentence_ar, re.I):
   errors.append(f'Known Arabic compound-fragment contamination remains: {iid} / {bad_token}')
# Catch obvious third-person leakage in first-person Arabic examples.
# A few impersonal constructions legitimately begin with ي (e.g. ينبغي, يناسب), so keep a narrow allowlist.
allowed_after_ar_want = ('ينبغي', 'ينقصني', 'يناسب', 'يعجبني', 'يُسمح لي', 'يكون')
for sentence_ar in re.findall(r"sentenceAr:'([^']*)'", all_content):
 if sentence_ar.startswith('أريد أن ي') and not any(sentence_ar.startswith('أريد أن '+x) for x in allowed_after_ar_want):
  errors.append(f'Likely third-person leakage after Arabic first-person أريد أن: {sentence_ar}')
# Latin words in Arabic examples are normally contamination; preserve standard technical acronyms.
latin_allow = {'USB','PDF','PIN','Wi-Fi','WLAN','QR','E-Mail','Online','App','SMS','WhatsApp'}
for sentence_ar in re.findall(r"sentenceAr:'([^']*)'", all_content):
 for token in re.findall(r"(?<![A-Za-z])([A-Za-z][A-Za-z-]{2,})(?![A-Za-z])", sentence_ar):
  if token not in latin_allow:
   errors.append(f'Unexpected Latin token in Arabic example: {token}')
   break

# Catch generated ich-form conjugation suffix errors in the conjugation dataset.
for inf, form in re.findall(r'VerbConjugation\(infinitive:"([^"]+)".*?person:"ich".*?form:"([^"]+)"', verbs):
 if (form.endswith('ne') and len(form) > len(inf) and inf != 'tun') or form.endswith('ee'):
  errors.append(f'Generated ich-conjugation typo: {inf} -> {form}')

if errors:
 print('QUALITY AUDIT: FAIL'); [print('ERROR:',x) for x in errors]; sys.exit(1)
print('QUALITY AUDIT: PASS')
print(f'Content entries: {len(ids)}')
print(f'Unique IDs: {len(set(ids))}')
print(f'Unique German entries: {len(set(x.lower() for x in german))}')
