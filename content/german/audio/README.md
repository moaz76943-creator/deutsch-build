# German Audio Assets

Place language-owned audio files here using paths referenced by `content/german/audio_manifest.json`.

Audio references are keyed by stable `contentId`; do not use list position as identity.

Before publishing an audio change, run:

```text
python3 tool/content_ingestion.py validate-audio
```

V358 validation requires every declared file to exist under this directory and rejects unreferenced audio files. The current catalog intentionally contains no migrated audio assets.
