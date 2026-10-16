# Universal verb morphology builder (Track 7)

This **offline, standard-library-only** Python utility normalizes supplied conjugation
records into a reusable SQLite schema. It does **not** generate linguistic forms.
It neither reads nor modifies the app's existing `german_verbs` /
`german_verb_forms` tables.

## JSON input

Two equivalent input layouts are supported: a top-level verb list, or the
object shown below with nested forms. All identifiers are caller-provided,
non-empty, stable strings (namespacing by language is recommended).

```json
{
  "verbs": [
    {
      "verb_id": "de:gehen",
      "infinitive": "gehen",
      "translation_ar": "يذهب",
      "frequency_rank": 5,
      "conjugations": [
        {
          "conjugation_id": "de:gehen:present:ich",
          "tense": "present",
          "person": "ich",
          "conjugated_form": "gehe"
        }
      ]
    }
  ]
}
```

Alternatively, omit nested `conjugations` and provide a top-level
`"verb_conjugations"` array; each form must then include its `verb_id`.
Do not mix flat and nested forms. Required fields are `verb_id`, `infinitive`
and for each form `conjugation_id`, `tense`, `person`, and `conjugated_form`.
`translation_ar` and `frequency_rank` are optional; rank is a positive integer.
The `tense` and `person` values are opaque language-specific identifiers.

## Build and verify

```bash
python3 tools/morphology/build_universal_verbs.py \
  --input /path/to/verbs.json --output /path/to/verbs.sqlite
python3 -m unittest discover -s tools/morphology/tests -v
```

Existing destinations are protected; use `--overwrite` only when intentional.
Builds use batches of 1,000 rows, validate orphan forms and the
`(verb_id, tense)` index, and publish only after successful verification.
Failures do not replace a pre-existing output. The builder creates neither
remote requests nor any CI jobs.

The schema has no `language_code` field by design, matching the requested
contract. Use **separate databases per language**, or namespace every verb and
conjugation identifier when combining data. This is a normalized pack
preparation utility, not a live application integration or a 100-language
content population guarantee.
