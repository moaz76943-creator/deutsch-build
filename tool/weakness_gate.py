#!/usr/bin/env python3
from pathlib import Path
import subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
# Performance remains a tracked weakness and is intentionally audited in the next gate phase.
checks=[('Accessibility','tool/accessibility_audit.py',True),('Architecture','tool/architecture_audit.py',False),('Content','tool/content_review_queue.py',False)]
results=[]
for name,script,critical in checks:
    p=subprocess.run([sys.executable,str(ROOT/script)],capture_output=True,text=True)
    results.append((name,p.returncode,critical,p.stdout,p.stderr))
print('WEAKNESS GATE')
for name,code,critical,out,err in results:
    status='PASS' if code==0 else ('CRITICAL' if critical else 'HIGH')
    print(f'{name}: {status}')
    print(out.strip())
    if err.strip(): print(err.strip())
failed=[r for r in results if r[1]!=0 and r[2]]
if failed:
    print('WEAKNESS GATE: FAIL')
    sys.exit(1)
print('WEAKNESS GATE: PASS')
