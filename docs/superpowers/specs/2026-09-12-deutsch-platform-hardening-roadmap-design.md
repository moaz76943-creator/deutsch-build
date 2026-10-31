# Deutsch بالعربي Platform Hardening Roadmap Design

## Goal
Continue Deutsch بالعربي from V383 with a security-first, language-neutral, persistence-safe, performance-aware architecture while keeping the canonical German corpus stable and keeping all private source code in the private GitHub repository.

## Design Principles
1. Canonical content remains the source of truth; generated/runtime mirrors are derived artifacts.
2. Language-specific behavior belongs under `lib/language/german/` and is selected through `LanguagePack`/composition-root dependencies.
3. Persistence owns serialization, normalization, migration, and failure translation; repository owns orchestration and cache/queue semantics.
4. Security-sensitive configuration, credentials, entitlement decisions, and release signing material remain server/CI controlled and never enter source or generated client content.
5. Private repository access is minimized to the Deutsch بالعربي GitHub repository; third-party services are not given source-code access unless their privacy boundary is verified first.
6. Every bulk content mutation is reviewable, minimal, reversible, and followed by parity/quality/regression verification.
7. Fast verification may cache only proven-safe checks; release verification remains full and fail-closed.
8. Flutter/Android build results are reported honestly; when the SDK is unavailable, CI is authoritative.

## Release Phases
- V384: language-boundary closure.
- V385: persistence operation/result semantics, queue recovery, clear-data behavior, migration failure handling, stale-cache prevention.
- V386: change-aware verification, risk policy, cache isolation, deterministic parallel scheduling, slow-test diagnostics.
- V387: repository/CI privacy and supply-chain hardening.
- V388: security threat-model pass over authentication, secure storage, entitlement boundaries, network configuration, local persistence, and premium content exposure.
- V389: content intelligence and repair pipeline.
- V390: runtime performance hardening.
- V391: Android/Flutter release verification.
- V392: release automation and observability.
- Continuous: architecture, privacy, security, and dependency-boundary regression gates.

## Data/Privacy Boundary
The repository remains private. No project archive, source file, credentials, signing material, learner data, or paid-content export is sent to third-party plugins by default. External plugins may be used only when their data handling is compatible with this boundary and the specific task materially benefits from them.
