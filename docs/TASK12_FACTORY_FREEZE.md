# TASK 12 — Factory Freeze / Safe-Capacity Scaling

Baseline: `main@6d908b989b01b1eee4adb74fd4b00dcc4f84291f`.

## Roadmap scope

TASK 12 freezes the shared language/factory interfaces after **Core Touch Zero**.
Language-pack mutation stays serial by default. Parallel mutation may increase only
when a pack-specific measurement proves the requested safe capacity against the
same interface-freeze fingerprint.

## Enforced contract

- Shared Core, shared services, bootstrap, shared models, directed-pair
  machinery, and mandatory-quality machinery are zero-touch for language
  mutation workers.
- Shared language/factory interfaces are pinned by Git blob SHA in
  `tool/task12_factory_freeze.json`. Drift fails closed.
- Current German pack-owned mutation namespaces are
  `lib/language/german/` and `content/german/`.
- Unknown packs and cross-pack scopes fail closed.
- Serial mutation capacity is exactly 1 without measurement evidence.
- Any requested parallelism above 1 requires a `VERIFIED` measurement bound to
  the current freeze fingerprint, at least three samples, zero failures, zero
  ownership conflicts, and an observed peak at least as high as the claimed
  safe capacity.
- The global hard ceiling remains 25 physical parallel mutations; measurements
  cannot raise it.
- No capacity record is fabricated in TASK 12. The checked-in measurement set is
  intentionally empty until real pack-level evidence exists.

## Gate

`python3 tool/task12_factory_freeze.py check` validates the freeze and capacity
policy. The active `tests/quality_gate/` contract exercises serial admission,
unmeasured parallel denial, measured-capacity ceilings, Core Touch Zero,
unknown-pack denial, namespace ownership, and the 1000-line ceiling.

Example pre-admission check:

```bash
python3 tool/task12_factory_freeze.py admit \
  --pack-id de \
  --requested 1 \
  --active 0 \
  --scope content/german/
```

A future capacity increase must supply a measurement JSON matching the schema
consumed by `CapacityMeasurement.from_mapping`; changing a frozen interface
invalidates that evidence automatically through the freeze fingerprint.
