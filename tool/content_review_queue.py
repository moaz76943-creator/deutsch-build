#!/usr/bin/env python3
from pathlib import Path
from collections import defaultdict
import json, re
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'content/german'
OUT=ROOT/'tool/content_review_queue.json'
text='\n'.join(p.read_text(encoding='utf-8') for p in sorted(DATA.glob('content*.dart')))
entries=re.findall(r"ContentItem\(id:'([^']+)',german:'([^']*)',arabic:'([^']*)',sentence:'([^']*)',sentenceAr:'([^']*)'",text)

def norm(x): return re.sub(r'\s+',' ',x.lower()).strip()
def dist(a,b):
    if abs(len(a)-len(b))>2:return 99
    prev=list(range(len(b)+1))
    for i,ca in enumerate(a,1):
        cur=[i]
        for j,cb in enumerate(b,1):cur.append(min(cur[-1]+1,prev[j]+1,prev[j-1]+(ca!=cb)))
        prev=cur
    return prev[-1]
buckets=defaultdict(list)
for row in entries:
    g=norm(row[1])
    if len(g)>=5:buckets[g[:5]].append(row)
queue=[]
seen=set()
for rows in buckets.values():
    for i,a in enumerate(rows):
        for b in rows[i+1:]:
            ga,gb=norm(a[1]),norm(b[1])
            key=tuple(sorted((a[0],b[0])))
            if key in seen:continue
            if dist(ga,gb)<= (1 if max(len(ga),len(gb))<=9 else 2):
                seen.add(key)
                queue.append({'id_a':a[0],'german_a':a[1],'arabic_a':a[2],'sentence_a':a[3],'sentence_ar_a':a[4],
                              'id_b':b[0],'german_b':b[1],'arabic_b':b[2],'sentence_b':b[3],'sentence_ar_b':b[4],
                              'status':'needs_human_review'})
# Near-duplicate similarity review-only artifact: deliberately no deletion or source mutation.
OUT.write_text(json.dumps({'review_only':True,'count':len(queue),'items':queue},ensure_ascii=False,indent=2),encoding='utf-8')
print('CONTENT REVIEW QUEUE: PASS')
print(f'Candidates: {len(queue)}')
print(f'Output: {OUT.relative_to(ROOT)}')
print('Mutation: NONE (review-only)')

# Safety contract: this review tool must never delete source content.
