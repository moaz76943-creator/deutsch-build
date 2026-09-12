from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from tool.ci_secret_hygiene import audit_workflow

p = ROOT / '.github/workflows/build-apk.yml'
report = audit_workflow(p)
assert report.ok, report.errors
assert report.cleanup_guaranteed
assert report.keystore_path == 'android/app/upload-keystore.jks'
