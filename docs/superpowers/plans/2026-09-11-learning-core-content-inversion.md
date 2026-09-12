# Plan — V303 Learning Core Content Dependency Inversion

## Checklist

- [x] Add failing architecture tests first.
- [ ] Remove LearningCore's direct dependency on ContentEngine singleton.
- [ ] Require corpus explicitly for content-dependent operations.
- [ ] Update callers to pass the content boundary.
- [ ] Run focused tests.
- [ ] Run full regression.
- [ ] Run security/privacy/language-boundary audits.
- [ ] Archive a clean verified snapshot.

## Scope

Keep learning algorithms and learner state ownership unchanged. No persistence-schema, authentication, subscription, or content-data changes.
