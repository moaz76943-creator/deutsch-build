from dataclasses import dataclass
from pathlib import Path
import re

@dataclass(frozen=True)
class AuditReport:
    ok: bool
    errors: tuple[str, ...]
    cleanup_guaranteed: bool
    keystore_path: str | None

def audit_workflow(path: Path) -> AuditReport:
    text = path.read_text(encoding='utf-8')
    errors = []
    matches = re.findall(r'run:\s*rm\s+-f\s+([^\s]+)', text)
    keystore_path = matches[-1] if matches else None
    cleanup_guaranteed = bool(re.search(r'- name: Remove CI-owned signing material\s*\n\s*if:\s*always\(\)', text))
    if not cleanup_guaranteed:
        errors.append('CI signing-material cleanup must run with if: always().')
    if keystore_path != 'android/app/upload-keystore.jks':
        errors.append('Unexpected or missing CI keystore cleanup path.')
    if 'ANDROID_KEYSTORE_BASE64' not in text:
        errors.append('Release keystore must come from the CI secret.')
    if 'persist-credentials: false' not in text:
        errors.append('Checkout credentials must not persist.')
    if 'path: build/app/outputs/flutter-apk/app-release.apk' in text and keystore_path in text:
        pass
    return AuditReport(not errors, tuple(errors), cleanup_guaranteed, keystore_path)
