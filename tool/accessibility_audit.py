#!/usr/bin/env python3
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
UI_DIR = ROOT / 'lib/ui_v35'

# app.dart is now a composition root. Accessibility checks must cover every
# split UI library, while excluding the safe TTS helper (which has no widgets).
ui_files = [p for p in sorted(UI_DIR.rglob('*.dart')) if p.name != 'safe_ui.dart']
s = '\n'.join(p.read_text(encoding='utf-8') for p in ui_files)
errors=[]
warnings=[]
if 'Semantics(' not in s: errors.append('no Semantics widgets found in primary UI')
if 'tooltip:' not in s: errors.append('no tooltips found in primary UI')
if 'labelText:' not in s: errors.append('no explicit input labels found')
# Icon-only buttons should expose tooltip/semantic context in the same widget region.
for m in re.finditer(r'IconButton\((.*?)\)', s, re.S):
    body=m.group(1)
    if 'tooltip:' not in body and 'Semantics' not in s[max(0,m.start()-180):m.end()+180]:
        warnings.append('icon-only IconButton without local tooltip/semantic context')
if 'TextDirection.ltr' not in s: warnings.append('no explicit LTR input direction found')
if 'TextDirection.rtl' not in s: warnings.append('no explicit RTL input direction found; verify inherited RTL semantics')
print('ACCESSIBILITY AUDIT: FAIL' if errors else 'ACCESSIBILITY AUDIT: PASS')
for x in errors: print('ERROR:',x)
print(f'Warnings: {len(warnings)}')
for x in warnings[:12]: print('WARN:',x)
sys.exit(1 if errors else 0)
