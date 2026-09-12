# V138 — TTS Concurrency & Instance Hardening

## Goal

Prevent TTS instability caused by short-lived `FlutterTts` instances, overlapping speech calls, and page transitions while speech operations are still pending.

## Changes

- Added `SafeTtsController` as the owned TTS lifecycle boundary.
- Reuses one TTS engine per owning state instead of constructing an engine inside individual `speak` calls.
- Serializes speech operations through a small future tail.
- Uses a generation token so queued speech becomes a no-op after a newer request, stop, or disposal.
- `stop()` invalidates pending speech and safely stops the native engine.
- `shutdown()` invalidates pending speech, waits for owned work, and safely shuts down the native engine.
- `dispose()` performs the same invalidation and cleanup without blocking Flutter's synchronous dispose callback.
- Migrated V35 learning, assessment, category, dictionary, conversation, progress, and verb flows to the controller.
- Migrated the legacy UI TTS owners to the same lifecycle boundary.
- Retained the older `safeSpeak`/`safeTtsStop`/`safeTtsShutdown` helpers for compatibility with any remaining callers.

## Verification

- V138 focused static tests: 4 passed.
- Full Python regression suite: 199 passed.
- Accessibility audit: PASS, 0 warnings.
- Architecture audit: PASS, 0 oversized files.
- Content quality audit: PASS, 14,793 entries with unique IDs and unique German entries.
- Security audit: PASS across all configured gates.

## Runtime limitation

Flutter/Android SDK and an Android runtime target are not available in this environment. Therefore Android build, emulator behavior, native TTS behavior, and device-level crash freedom remain unverified here.
