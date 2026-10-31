#!/usr/bin/env python3
from __future__ import annotations
from collections import Counter, defaultdict
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'content/german'
files = sorted(DATA.glob('content*.dart'))
text = '\n'.join(p.read_text(encoding='utf-8') for p in files)
entries = re.findall(r"ContentItem\(id:'([^']+)',german:'([^']*)',arabic:'([^']*)',sentence:'([^']*)',sentenceAr:'([^']*)',topic:'([^']*)',skill:'([^']*)'(?P<tail>.*?)\),", text)
errors = []
if not entries:
    errors.append('no content entries parsed')
ids = [e[0] for e in entries]
german = [e[1].strip().lower() for e in entries]
topics = Counter(e[5].strip() or 'غير مصنف' for e in entries)
skills = Counter(e[6].strip() for e in entries)

dup_ids = len(ids) - len(set(ids))
dup_german = len(german) - len(set(german))
if dup_ids:
    errors.append(f'duplicate IDs: {dup_ids}')
if dup_german:
    errors.append(f'duplicate German entries: {dup_german}')

# Bounded near-duplicate audit: only compare entries sharing a normalized 5-char prefix.
buckets = defaultdict(list)
for g in set(german):
    if len(g) >= 5:
        buckets[g[:5]].append(g)

def dist(a, b):
    if abs(len(a) - len(b)) > 2:
        return 9
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(cur[-1] + 1, prev[j] + 1, prev[j-1] + (ca != cb)))
        prev = cur
    return prev[-1]
near = []
for values in buckets.values():
    values = values[:80]
    for i, a in enumerate(values):
        for b in values[i+1:]:
            if dist(a, b) <= (1 if max(len(a), len(b)) <= 9 else 2):
                near.append((a, b))

# Metadata and progression checks.
tails = [e[7] for e in entries]
articles = sum("article:'" in tail or 'article:\"' in tail for tail in tails)
plurals = sum("plural:'" in tail or 'plural:\"' in tail for tail in tails)
examples = sum(bool(e[3].strip()) and bool(e[4].strip()) for e in entries)
a2 = sum('المستوى A2' in e[5] for e in entries)
if a2 < 24:
    errors.append(f'A2 curriculum expansion too small: {a2}')
if len(set(skills)) < 3:
    errors.append('skill coverage is too narrow')
if examples / max(len(entries), 1) < .995:
    errors.append('example coverage unexpectedly low')

# Word-family candidates are intentionally heuristic; report, never mutate, uncertain relations.
def family(word):
    w = word.lower().split()[0]
    for suffix in ('lichkeit','igkeit','ung','heit','schaft','tion','isch','lich','er','en','e'):
        if len(w) > len(suffix) + 4 and w.endswith(suffix):
            return w[:-len(suffix)]
    return w
families = Counter(family(g) for g in german if g)

print('CONTENT INTELLIGENCE AUDIT: PASS' if not errors else 'CONTENT INTELLIGENCE AUDIT: FAIL')
print(f'Entries: {len(entries)} | unique IDs: {len(set(ids))} | unique German: {len(set(german))}')
print(f'A2 curated entries: {a2} | article metadata: {articles} | plural metadata: {plurals} | examples: {examples}')
print(f'Skills: {dict(skills)}')
print(f'Topics: {len(topics)} | near-duplicate candidate pairs: {len(near)} | word-family candidates: {len(families)}')
if near:
    print('Near-duplicate candidates (review only):')
    for a, b in near[:12]: print(f'  - {a} <-> {b}')
for e in errors:
    print('ERROR:', e)
if errors:
    sys.exit(1)
