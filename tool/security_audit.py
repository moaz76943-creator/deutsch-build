#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
errors=[]
def read(path):
    p=ROOT/path
    return p.read_text(encoding='utf-8') if p.exists() else ''
manifest=read(Path('android/app/src/main/AndroidManifest.xml')); gradle=read(Path('android/app/build.gradle')); workflow=read(Path('.github/workflows/build-apk.yml')); quality=read(Path('.github/workflows/quality.yml')); build_script=read(Path('scripts/build.sh')); source='\n'.join(p.read_text(encoding='utf-8',errors='ignore') for p in (ROOT/'lib').rglob('*.dart'))
checks=[
('android.permission.INTERNET' in manifest,'Optional network permission is missing.'),
('android.permission.RECORD_AUDIO' in manifest,'Speech permission is missing.'),
('android:allowBackup="false"' in manifest,'Android backup is not disabled.'),
('android:usesCleartextTraffic="false"' in manifest,'Cleartext traffic is not explicitly disabled.'),
'dataExtractionRules' in manifest,
('fullBackupContent' in manifest,'Android fullBackupContent is missing.'),
('minifyEnabled true' in gradle and 'shrinkResources true' in gradle,'Release R8/resource shrinking is not enabled.'),
('proguard-android-optimize.txt' in gradle,'Release optimized R8 rules are missing.'),
('native <methods>' in read(Path('android/app/proguard-rules.pro')),'JNI/native keep rule is missing.'),
('-assumenosideeffects class android.util.Log' in read(Path('android/app/proguard-rules.pro')),'Release Android log stripping is missing.'),
('secureRelease' in gradle and 'releaseStoreFile' in gradle,'Dedicated release signing is not configured.'),
('signingConfig signingConfigs.secureRelease' in gradle,'Release build is not strictly bound to secureRelease signing.'),
('--obfuscate' in build_script and '--split-debug-info' in build_script,'Dart obfuscation is missing from the central release build.'),
('isPrivate' in workflow,'CI has no private-repository gate.'),
("github.event_name != 'workflow_dispatch' || github.ref_name == 'main' || github.ref_name == 'master'" in workflow,'Release workflow manual dispatch is not restricted to main/master.'),
("github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository" in quality,'Private quality workflow lacks an external-PR execution boundary.'),
('persist-credentials: false' in workflow and 'persist-credentials: false' in quality,'Checkout persists credentials.'),
('permissions:\n  contents: read\n  actions: none\n  checks: none\n  id-token: none\n  pull-requests: none' in workflow and 'permissions:\n  contents: read\n  actions: none\n  checks: none\n  id-token: none\n  pull-requests: none' in quality,'CI token permissions are not explicitly minimized.'),
('cache: false' in quality and 'pub-cache: false' in quality,'Quality workflow must disable Flutter and pub caches on PR/test surface.'),
('cache-disabled: true' in quality,'Quality workflow must disable Gradle User Home cache on PR/test surface.'),

('retention-days:' in workflow,'Artifact retention is not bounded.'),
('GRADLE_WRAPPER_JAR_SHA256=' in read(Path('toolchain.lock')) and 'gradle_wrapper_integrity.py' in read(Path('scripts/build_guard.sh')),'Gradle Wrapper integrity is not pinned.'),
('GRADLE_DISTRIBUTION_SHA256=' in read(Path('toolchain.lock')) and 'verify_distribution_properties' in read(Path('tool/gradle_wrapper_integrity.py')),'Gradle distribution integrity is not pinned.'),
('gradle_wrapper_bootstrap.py' in workflow and 'Materialize verified Gradle wrapper' in workflow,'CI does not safely materialize a missing Gradle Wrapper.'),
('FLAG_SECURE' in read(Path('android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt')),'Screen-capture protection is missing.'),
(
    'ReviewCard' in source
    and 'UnifiedSrsScheduler' in source
    and 'unifiedSrsScheduler.schedule' in read(Path('lib/services/repository.dart')),
    'Spaced repetition is not persisted through the unified review-card scheduler.',
),
('clearLocalData' in read(Path('lib/services/repository.dart')),'Local data management is missing.'),
('static const hasPublicLocalEntitlementMutation = false' in read(Path('lib/services/subscription.dart')),'Local premium entitlement mutation remains possible.'),
]
for c in checks:
    if isinstance(c, tuple): ok,msg=c
    else: ok,msg=c, 'Security requirement failed.'
    if not ok: errors.append(msg)

# CI/CD supply-chain gate: every third-party action used by release/quality workflows
# must be pinned to an immutable full commit SHA, not a mutable tag/branch.
for workflow in (ROOT/'.github/workflows').glob('*.y*ml'):
    text = workflow.read_text(encoding='utf-8', errors='ignore')
    for ref in re.findall(r'uses:\s*([^\s#]+)', text):
        if '@' not in ref:
            continue
        owner, target = ref.rsplit('@', 1)
        if not re.fullmatch(r'[0-9a-f]{40}', target):
            errors.append(f'Workflow action is not pinned to a full commit SHA: {workflow.name}: {ref}')

for pattern,label in [(r'\bhttp://','plaintext URL'),(r'\bhttps://','network URL'),(r'\bAuthorization\s*:','authorization header'),(r'(?:api[_-]?key|client_secret)\s*=\s*[\'\"]','embedded secret')]:
    if re.search(pattern,source,re.I): errors.append(f'Application source contains {label}.')
if 'signingConfigs.debug' in gradle: errors.append('Release configuration references debug signing.')
if re.search(r'android:exported="true"[^>]*>\s*<intent-filter', manifest, re.S) and 'android.intent.action.MAIN' not in manifest: errors.append('Exported activity has no launcher contract.')
if errors:
    print('SECURITY AUDIT: FAIL')
    for e in errors: print('ERROR:',e)
    sys.exit(1)
print('SECURITY AUDIT: PASS')
for label in ['Optional network surface with HTTPS-only gateway','Android backup hardening','Release R8/shrinking','Dedicated signing configuration','CI private-repository gate','Dart obfuscation gate','Screen-capture hardening','Persistent SRS state','Local data management','Premium entitlement hardening']:
    print(label+': PASS')
