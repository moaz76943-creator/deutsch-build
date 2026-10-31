# Adaptive Hybrid Learning Upgrade Implementation Plan

> **For agentic workers:** Use the host's available task-by-task implementation workflow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade Deutsch بالعربي into an adaptive Offline-first learning app with optional HTTPS AI and device speech capabilities.

**Architecture:** Keep content, learner state, SRS, mastery, error analysis, and daily planning local. Isolate optional network functionality behind `AiGateway`; enable it only after user opt-in and only for an HTTPS endpoint supplied at build/runtime. Use device speech recognition for short German shadowing sessions.

**Tech Stack:** Flutter/Dart, SharedPreferences, flutter_tts, `http`, `speech_to_text`, Material 3.

## Global Constraints

- Core learning must continue without Internet.
- Cloud AI is opt-in and disabled by default.
- No API key or client secret may be embedded in the APK.
- Remote AI endpoints must be HTTPS.
- Inputs and outputs are bounded.
- Speech recognition is short-session practice, not continuous recording.
- Existing SRS/local state and security hardening must remain intact.
- CI remains responsible for `flutter analyze`, `flutter test`, and release build verification.

---

### Task 1: Adaptive learning engine

**Files:**
- Create: `lib/services/adaptive_teacher.dart`
- Create: `lib/services/daily_plan.dart`
- Create: `lib/services/mastery.dart`
- Create: `lib/services/mistake_analysis.dart`
- Test: `test/v89_adaptive_test.dart`, `test/v89_plan_test.dart`

**Interfaces:**
- Consumes: `LearnerState`, `Attempt`, `ReviewCard`.
- Produces: `AdaptiveTeacher.next`, `DailyPlan.from`, `Mastery.forItem`, `MistakeAnalysis.from`.

- [x] Add focused tests for due-review priority, weakest-skill selection, mastery breadth/retention, bounded daily plans, and error grouping.
- [x] Implement bounded weighted scoring and explicit action types.
- [x] Keep unmeasured skills from being falsely treated as weak.
- [x] Integrate dashboard entry points in `lib/ui_v35/app.dart`.

### Task 2: Search, speech, and privacy controls

**Files:**
- Create: `lib/services/search_index.dart`
- Create: `lib/services/speech_service.dart`
- Create: `lib/services/privacy_settings.dart`
- Modify: `lib/ui_v35/app.dart`
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Consumes: `ContentItem`, local learner state, user privacy toggles.
- Produces: indexed local search, short-session German recognition, cloud/speech opt-in state.

- [x] Replace repeated full-field search with a reusable local index.
- [x] Add device speech practice using German locale and safe stop/dispose behavior.
- [x] Add privacy controls for cloud AI and speech.
- [x] Add required Android permissions.

### Task 3: Optional AI gateway

**Files:**
- Create: `lib/services/ai_gateway.dart`
- Modify: `lib/services/ai_contract.dart`
- Modify: `lib/ui_v35/app.dart`
- Test: `test/v89_ai_contract_test.dart`

**Interfaces:**
- Consumes: bounded learner-selected text and scenario messages.
- Produces: structured writing review and conversation replies.

- [x] Add `AiGateway` abstraction with offline fallback.
- [x] Add `HttpsAiGateway` with HTTPS-only enforcement, bounded payloads, timeout, and response validation.
- [x] Use `DEUTSCH_AI_BASE_URL` as an external build/runtime configuration seam rather than embedding a URL or secret.
- [x] Make cloud writing/conversation gracefully fall back to local behavior on network failure.

### Task 4: Security, quality, and release integration

**Files:**
- Modify: `tool/security_audit.py`
- Modify: `tool/quality_audit.py`
- Create: `docs/specs/2026-09-09-adaptive-learning-hybrid-design.md`
- Create: `docs/V89_ADAPTIVE_HYBRID_UPDATE.md`
- Modify: `pubspec.yaml`, Android version metadata

**Interfaces:**
- Consumes: source tree, Android manifest, CI configuration.
- Produces: deterministic static gates and release documentation.

- [x] Update security gates for explicitly optional network and microphone surfaces.
- [x] Keep hardcoded endpoints, authorization headers, and embedded secrets prohibited.
- [x] Run Python syntax checks, quality audit, security audit, shell syntax check, and XML parsing.
- [ ] CI must run Flutter package resolution, analyze, tests, and release APK build on a Flutter-enabled runner.

## Verification outcome

Local host verification must not claim Flutter success when Flutter/Dart are unavailable. The current host completed static quality/security/XML/shell checks; the CI workflow remains the authoritative Flutter verification path.

## Unresolved externally observable decisions

- The production AI backend contract beyond `/v1/review` and `/v1/conversation` is intentionally a deployment seam; the app does not invent a provider or secret-management scheme.
- Cloud sync is not enabled by this upgrade because it would require an account/authentication and conflict-resolution design.
