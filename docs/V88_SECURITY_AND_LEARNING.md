# V88 — Security & Learning Hardening

## Product boundary
Deutsch بالعربي remains a private, offline-first Android learning application. No general web backend, WebView, network API, or cloud sync was added.

## Security
- No Android INTERNET permission.
- Cleartext traffic disabled.
- Backup/device transfer excluded.
- FLAG_SECURE enabled on the main activity.
- Release R8/resource shrinking and Dart obfuscation are enforced by CI.
- Release signing requires explicit secrets; debug signing is not used for release.
- CI refuses to build from a public GitHub repository.
- Local learner input is bounded and writes are serialized.
- Premium entitlement is not trusted from a local boolean; billing is deliberately disabled until store verification exists.

## Learning
- ReviewCard stores repetitions, interval, lapses, last review, and due time.
- Legacy review lists migrate to due-now cards.
- LearningCore serves due cards first and quarantines content that fails quality checks.
- Skill selection uses recent weighted evidence and ignores unmeasured skills.
- Diagnostic placement does not alter learner mastery or XP.

## Verification
Run `python3 tool/security_audit.py` and `python3 tool/quality_audit.py`.
Flutter `analyze`, `test`, and signed Android release build remain CI checks and require a Flutter/Android environment.
