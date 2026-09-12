# V363 — Content Review Queue

V363 turns the content quality gate output into a structured, reviewable queue. Each issue carries severity, category, code, field, contentId when known, and a human-readable message.

The queue is read-only and does not mutate canonical content. CLI reports can be filtered by `--severity`, `--category`, and `--content-id`.

Missing audio remains a warning because editorial review may precede recording.
