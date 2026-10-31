# V125 — Performance + Quality Gate + Release Hardening

- Bumped to `1.71.0+81` / Android `versionCode 81`.
- Fixed a root performance issue in `MasteryDashboard`: attempts are grouped once by `itemId` instead of scanning the full attempt list for every content item.
- Added `Mastery.forItemRows` for batch callers while preserving the existing API.
- Cached the immutable content-intelligence report so repeated dashboard rebuilds do not rerun duplicate/near-duplicate analysis.
- Added a Performance release gate and strengthened the privacy/security release note with an HTTPS-only external-integration requirement.
- Added 25 new A2 content entries (`w15965`–`w15989`) without changing existing IDs.
- Added two high-value A2 verbs (`sich entscheiden`, `vorbereiten`) with 9 learner-facing conjugation rows each.
- No public publishing or sharing was performed.
- No APK was built in this environment.
