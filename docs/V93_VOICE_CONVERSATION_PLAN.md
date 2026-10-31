# V93 Voice Conversation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an offline-first German conversation lab where the learner speaks, receives deterministic local feedback, and the result feeds the existing learner history.

**Architecture:** Add a small pure conversation domain model/evaluator, then connect it to the existing `speech_to_text` and `flutter_tts` services through one focused UI flow. No cloud dependency is required; the existing optional AI path remains separate.

**Tech Stack:** Dart/Flutter, existing `speech_to_text`, existing `flutter_tts`, local `LearnerRepository`.

**Spec:** V93 Voice Conversation design is captured here because the user explicitly approved the next development step.

## Global Constraints
- Offline-first: speech recognition may use the device recognition engine; scoring must remain local.
- No API keys or secrets.
- Keep the existing V92 learning engine and assessment history intact.
- Score spoken German by meaningful phrase/keyword coverage, not character equality.
- Bound scenario and turn counts.
- Persist conversation attempts through the existing repository only.

### Task 1: Conversation domain and evaluator
**Files:** Create `lib/models/conversation.dart`, `lib/services/conversation_engine.dart`, Test `test/v93_conversation_test.dart`.
- [ ] Write failing tests for exact/accepted phrase scoring, partial keyword coverage, empty speech, and deterministic scenario ordering.
- [ ] Run focused Flutter test and record the environment result.
- [ ] Implement `ConversationScenario`, `ConversationTurn`, `ConversationScore`, normalization, and deterministic scoring.
- [ ] Re-run focused test; when Flutter is unavailable, use static Python checks and report the blocked Dart test honestly.

### Task 2: Voice conversation UI integration
**Files:** Modify `lib/ui_v35/app.dart`, `lib/services/speech_service.dart` only if lifecycle/state handling needs it.
- [ ] Add a home entry and scenario picker.
- [ ] Add turn-by-turn German prompt playback, microphone start/stop, transcript, score, missing-keyword feedback, and next-turn progression.
- [ ] Record each completed turn as an `Attempt` using the scenario turn skill.
- [ ] Add a final session summary and graceful microphone/TTS failure states.

### Task 3: Release quality
**Files:** Modify `pubspec.yaml`, create `docs/V93_VOICE_CONVERSATION_UPDATE.md`.
- [ ] Bump version to `1.41.0+51`.
- [ ] Document local scoring, permissions, and privacy behavior.
- [ ] Run quality/security audits, Python syntax checks, ZIP integrity, and Flutter/Dart checks if available.
