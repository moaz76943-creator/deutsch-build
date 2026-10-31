# V384 Language Boundary Closure Implementation Plan

## Goal
Remove remaining German-specific behavior from generic services and route it through explicit language-owned contracts without changing German runtime behavior.

## Main Workstreams
- Language-owned content depth contract.
- Language-owned writing analyzer.
- Language-owned speech profile and lifecycle-safe TTS.
- Neutral search result identifiers.
- Isolation of legacy German compatibility facades.
- Release verification and explicit privacy/security boundary.

## Constraints
- No canonical content mutation.
- No secrets, learner data, signing material, or private configuration in source control.
- Preserve German runtime behavior.
- TDD for behavior changes.
- No Flutter/Android build claims without the SDK.
