# V94 — Smart Mistake Coach

## What changed
- Restored the V90 memory model (difficulty, stability, successes/failures, memory state, queue and retention snapshot) on top of the V93 voice-conversation release.
- Added unified mistake aggregation across practice, assessment-derived attempts, voice conversation attempts, and writing feedback.
- Repeated mistakes are normalized into one prioritized record instead of being shown as disconnected failures.
- Added categories for vocabulary, Artikel, grammar, translation, word order, writing, production and listening.
- Added a three-step offline repair drill: recognize → correct → produce.
- Successful repair attempts feed the normal SRS for real content; conversation/free-writing identifiers do not create fake review cards.
- Daily LearningEngine now prioritizes memory due cards, then recurring mistakes, then weak/new content.
- Writing Coach now persists detected local writing issues so they can enter the same mistake loop.
- V93 voice conversation remains intact and its attempts are consumed by the mistake engine.

## Safety
- No new network dependency.
- Local state remains bounded and serialized through the existing repository queue.
- Repair drills only use content that passes the existing learnability quality gate.

## Verification limitation
Flutter/Dart is not installed in the execution environment, so focused Flutter tests cannot be executed here. Static source checks, security/quality audits, test-file presence, and ZIP integrity should be used as the available verification evidence; do not interpret these as a successful Flutter compile.
