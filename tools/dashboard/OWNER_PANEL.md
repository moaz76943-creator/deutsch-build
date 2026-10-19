# DEUTSCH owner operations panel (read-only)

This module **extends** `tools/dashboard`; it does not replace Lexicon Coverage Dashboard or the historical Termux Control Center V17. The archived Control Hub v0.7 bootstrap was not available to reconcile. This is not a claim that v0.7 functionality was migrated.

## Run on owner-authenticated Termux or another device with `gh`

```bash
gh auth status
python3 tools/dashboard/owner_panel.py --live --output "$HOME/deutsch-reports/owner-panel.html"
```

Open the local HTML with the device browser. The generator reads four GitHub API resource types for the **private** `moaz76943-creator/deutsch-build` repository: integration HEAD, paginated open PRs (at most 20 pages of 100), up to 100 workflow runs, and up to 100 workflows. The panel has **30 navigable sections**, a cross-lane/PR search, PR review links, workflow-run links, and direct file navigation. It intentionally never embeds GitHub tokens, starts a server, dispatches workflows, merges PRs, or changes app data. GitHub links allow the owner to perform authenticated actions on GitHub itself.

Offline re-render from a previously captured and user-controlled JSON snapshot:

```bash
python3 tools/dashboard/owner_panel.py --snapshot /path/to/snapshot.json --output "$HOME/deutsch-reports/owner-panel.html"
```

Missing authorization, connection issues and API errors show **UNAVAILABLE**, not zero or PASS. The panel does not claim an opened PR is mergeable or that a completed workflow produced useful work. PR checks, agent permissions, app screen settings, production pack status, and Android tests remain unverified until examined at their source. PRs are paginated with a 2,000-item safety cap; a full final page is shown with `+` rather than an exact total. Runs and workflows remain capped at 100. Each PR includes its exact observed head and a WRONG_BASE warning when applicable. Captures include UTC time and per-resource status. `--snapshot` always relabels saved LIVE observations as CACHED; it never performs a GitHub read. The 30 sections navigate existing sources; they do not claim operational metrics or write capabilities for unconnected subsystems. Rendered files are private (`0600`); store them outside the repository because even PR titles can be private.

Run focused tests with `python3 -m pytest -q tests/test_owner_panel.py`. The panel is an owner-facing lens over the existing architecture, **not** another orchestration service. Any future write capability requires separate explicit authorization, authenticated plan verification, CSRF/origin protection, exact HEAD pinning and targeted tests.
