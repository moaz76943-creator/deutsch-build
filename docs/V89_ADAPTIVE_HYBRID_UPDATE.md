# V89 — Adaptive Hybrid Learning Update

Version: 1.37.0+47

## Added
- Adaptive teacher with due-review priority and weighted recent skill scoring.
- Daily learning plan with bounded review/repair/new-content allocation.
- Mastery evidence combining four learning skills with retention.
- Mistake analysis by skill and item.
- Indexed local dictionary search.
- German speech/shadowing practice through device speech recognition.
- Privacy center with separate cloud-AI and speech opt-ins.
- Optional HTTPS AI gateway for writing review and conversation.
- Offline fallback when AI is unavailable.

## Privacy
Cloud AI is off by default. The app contains no embedded API key or secret. The optional endpoint is supplied externally through `DEUTSCH_AI_BASE_URL`; only user-selected bounded text is sent to the configured HTTPS endpoint.

## Security
Existing backup restrictions, cleartext blocking, release signing, R8 shrinking, screen capture protection, local-state bounds, and CI private-repository checks remain enabled.

## Verification
- Quality audit: PASS
- Security audit: PASS
- XML validation: PASS
- Upload script shell syntax: PASS
- Flutter analyze/test/build: must be executed by CI because Flutter/Dart are not installed in the current host.
