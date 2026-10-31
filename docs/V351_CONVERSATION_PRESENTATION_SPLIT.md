# V351 — Conversation Language Presentation Split

## Scope

V351 is the first bounded slice of the language-aware presentation split.
The shared conversation UI now consumes language-aware presentation data through
`LanguagePresentation`; German-specific conversation copy and the safe fallback
scenario live under `lib/language/german/`.

## Architecture

- `LanguagePresentation` is a language-neutral presentation contract.
- `ConversationPresentation` owns only conversation-learning presentation data.
- `GermanLanguagePresentation` supplies the German implementation.
- `LanguagePack.presentation` exposes the selected implementation from the
  Composition Root.
- `ConversationPage` and `VoiceConversationPage` consume the contract instead
  of embedding conversation-specific German wording or fallback data.

## Preservation

Learning algorithms, SRS/mastery state, content IDs, authentication,
subscription authority, secure storage, backend transport, and exercise
strategy behavior are unchanged.

The German corpus remains under `content/german/`; this slice does not rewrite
or regenerate learning content.

## Verification

Focused V351 architecture tests: 6 passed.

Flutter/Dart analysis and APK build were not run because the Flutter/Dart
 toolchain is not available in the execution environment.
