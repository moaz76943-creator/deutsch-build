# V243 — MasteryDashboard via ContentEngine

`MasteryDashboard` now obtains its default corpus through `ContentEngine` rather than importing `a1` directly.

The explicit `corpus:` override remains intact, so callers can still supply a bounded or specialized corpus.
`ContentEngine` still defaults to the legacy Dart source; JSON-generated content remains opt-in through
`DEUTSCH_JSON_CONTENT=true`.

No content rows were changed or removed.
