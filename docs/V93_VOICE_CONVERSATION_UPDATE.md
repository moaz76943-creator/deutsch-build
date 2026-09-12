# Deutsch بالعربي V93 — Voice Conversation Lab

V93 adds a local-first spoken conversation lab for realistic daily situations.

- 5 bounded scenarios: restaurant, station, supermarket, work, doctor.
- Each scenario has short turn-by-turn German prompts with Arabic context.
- `speech_to_text` captures German speech using `de_DE`.
- A deterministic local evaluator scores keyword coverage from 0–100 and reports missing words.
- Completed turns are stored as bounded learner attempts; they do not create fake SRS cards.
- `flutter_tts` reads the other speaker's prompt aloud.
- No audio or transcript is sent to a cloud AI service by this feature.
- Device speech recognition may still require the Android speech engine or network depending on device configuration.

The existing optional AI text conversation remains available separately.
