# V239 — Content Engine Adapter

This stage introduces a stable runtime boundary between learning logic and the physical content source.

## Runtime policy

`ContentEngine` is the consumer-facing boundary. `LegacyContentSource` remains the runtime source in V239, so the application behavior is preserved while the editable JSON packs can evolve independently.

## Migration safety

- The existing `a1` Dart catalog remains intact.
- No bulk content rewrite occurs.
- Consumers migrate through `ContentEngine.instance.items` instead of importing the catalog directly.
- A future generated JSON source can implement `ContentSource` without changing learning consumers.

## Verification

The Python regression suite and all repository audits must pass before this version is packaged. Flutter/Android compilation remains an environment-gated check until a real Flutter + Android SDK environment is available.
