# Architecture Review & Continuous Improvement Plan

## Current Strengths
- Offline-first, privacy-focused design with strong integrity and crash-loop protections.
- Riverpod for state management and dependency injection.
- Repository pattern and layered structure (core, domain, data, features).
- Extensive CI/CD (quality gates, security audits, performance guards, signed AAB builds).
- Asset bundling carefully managed to avoid bloat.

## Areas for Improvement
- High cognitive complexity from dozens of granular feature folders and system "agents".
- Overlapping presentation layers (screens/, ui/, ui_v35/, features/).
- Opportunity to strengthen Clean Architecture with explicit Use Cases.
- Testing coverage can be expanded systematically.
- Feature modularization can make development faster and more enjoyable.

## Prioritized Action Plan
1. **[High] Standardize Feature Modules**  
   Adopt consistent feature structure: `features/<feature>/domain|data|presentation/`. Add barrel files (`<feature>.dart`).

2. **[High] Consolidate UI Layers**  
   Migrate screens/ and ui_v35 into features or a unified presentation layer.

3. **[Medium] Introduce Use Cases**  
   Extract business logic from Notifiers into domain use cases for better testability and reuse.

4. **[Medium] Enhance Testing Strategy**  
   - Unit tests for domain/use cases.  
   - Widget tests per feature.  
   - Integration tests for critical flows.  
   - Aim for >70% coverage on core + features.  
   - Use golden tests for design system.

5. **[Medium] CI/CD for Google Play**  
   Add Fastlane or dedicated workflow for automated upload to internal/closed testing, with version bumping and staged rollout support. Keep signing secrets secure.

6. **[Low] Performance Deep-Dive**  
   Profile startup and heavy features with DevTools. Ensure deferred loading for non-critical features. Verify baseline profiles.

7. **[Ongoing] Security**  
   All changes must preserve integrity checks, ProGuard, no sensitive logging, and offline-first principles. Consider encrypted SQLite for learner progress if threat model requires.

## Concrete Refactoring Example
See updated `lib/providers/vocabulary_provider.dart` — migrated to `AsyncNotifier` for superior loading/error states, non-blocking UI, and easier testing.

## Continuous Improvement
- Weekly architecture review in CI (already partially present).
- Prefer small, focused PRs.
- Document decisions in ADRs under `docs/adr/`.

This plan keeps the app fast, high-quality, secure, and a joy to develop.
