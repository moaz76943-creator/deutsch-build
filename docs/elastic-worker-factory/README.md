# Elastic Worker Factory — bounded contract primitives

Status: BRANCH IMPLEMENTATION / NON-PRODUCTION until normal PR verification and Executor-B integration.

This surface implements the reusable fail-closed primitives for Issue #80 under the existing Central Orchestrator. It is not a sixth scheduler, does not add paid API access, does not activate production, and does not take implementation ownership from Factory Issues #62–#66. Executor B remains the integration lane.

## Authority boundary

Central remains responsible for admission, current dependency and ownership checks, integration pressure, priority, and the durable replay/dispatch ledger. The worker factory consumes those decisions; it does not replace them.

A worker result is EVIDENCE ONLY. EVIDENCE_PASS is not READY_TO_INTEGRATE, merge authority, or production readiness.

Hard exclusions remain:
- Factory #62–#66 implementation scopes and contracts.
- .github/workflows/engineering-ci.yml and .github/workflows/quality.yml mutation.
- production, signing, secrets, deployment, billing, or other human-gated operations.
- any scheduled ChatGPT task or sixth persistent controller.
- paid API calls.

## EWF-A — versioned dispatch and validation

tool/elastic_worker_factory.py validates a complete versioned dispatch envelope. Every dispatch binds program/task/worker identity, worker class, owner, exact BASE_SHA, exactly one mutable or read-only scope, scope fingerprint, dependencies, acceptance, budget class, evidence target, next action, priority, Central admission, schema/profile versions, contract/toolchain revisions, input revision and output evidence revision.

Validation fails closed for stale base SHA, missing/malformed metadata, mismatched scope fingerprint, replayed dispatch ID, unknown budget/worker class, mutation without Central admission, or protected/human-gated mutation.

The Python validator is authoritative for semantic checks such as exact-base freshness and scope-fingerprint equality.

## EWF-B — Artifact-First, evidence fingerprints, logical sharding

ArtifactRecord binds worker evidence to dispatch/task/worker, exact BASE/HEAD SHA, profile, artifact path, evidence fingerprint and output revision. It forbids merge_ready=true and labels worker success semantics as EVIDENCE_ONLY.

evidence_fingerprint hashes exact dependency revisions plus normalized input so changed dependencies invalidate the dependent evidence.

shard_logical_workers multiplexes up to 100 logical workers into no more than 25 physical shards, with deterministic assignment and duplicate logical-ID rejection. This avoids one job per microtask.

Artifact aggregation rejects duplicate/replayed dispatch evidence.

## EWF-C — neutral manifest/profile/risk/pair primitives

The implementation exposes neutral coordinates only; it does not define missing Factory contracts:
- ManifestCoordinate keeps content_namespace_id separate from artifact version/digest.
- DirectedPairKey makes A→B and B→A distinct.
- route_risk sends ambiguity/high risk to deep review or quarantine.
- profiles include deterministic validator, standards precompute, pair derivation, Pack Self-Test, Semantic Benchmark, Incremental-CI selector and optional AI read-only analysis.

Pack Self-Test, Semantic Benchmark, pair derivation and Incremental-CI profiles require a stable upstream contract. That prevents Issue #80 from manufacturing an interface owned by Factory #62–#66.

## EWF-D — optional AI profile without paid activation

Issue #80 permits AI read-only analysis only when existing plan/free capacity is available. This change supplies an AI_READ_ONLY profile and EXISTING_PLAN_AI_READ_ONLY budget vocabulary, but adds no provider client, key, paid fallback, production dispatcher or billing path.

Unavailable AI capacity therefore remains a capability wait/blocker; acceptance is never weakened silently.

## EWF-E — stale CI, incremental-CI guard, budget/backpressure

classify_ci_freshness never treats evidence from another HEAD as current. It distinguishes stale replaceable work from stale evidence that requires review.

plan_incremental_ci consumes caller-supplied, already-verified machine-readable language boundaries and pair dependencies. It returns FULL for:
- unverified boundaries;
- shared-contract paths;
- unknown paths;
- ambiguous ownership.

It never infers a Factory-owned boundary.

assess_admission models the circuit breaker/backpressure contract:
- PAUSED and STOP_THE_LINE deny new dispatch.
- THROTTLED permits deterministic read-only work but not ordinary AI work.
- mutation remains scarce and bounded.
- HIGH integration pressure blocks new P2–P4 mutation.
- safe read-only evidence work can continue.

## Workflow harness

.github/workflows/elastic-worker-factory.yml is event-driven only through workflow_call or manual workflow_dispatch. It has read-only repository permissions, exact-SHA validation, and an optional caller-supplied durable replay snapshot.

There is deliberately no schedule, physical worker fan-out, production action, or persistence authority. Cross-run duplicate authority belongs to Central/Project Record; the workflow does not create a parallel state store.

## Verification

Focused regression command:

    python -m pytest -q tests/test_elastic_worker_factory.py

The focused suite covers versioned dispatch validation, stale/malformed/replayed rejection, protected scopes, zero-additional-billing allowlists, Artifact-First semantics, fingerprint invalidation, sharding, namespace/artifact separation, directed-pair asymmetry, risk routing, stale-CI classification, conservative incremental-CI fallback, Pack Self-Test/Semantic Benchmark profiles, circuit breaker/backpressure, JSON-schema shape and replay-state rejection.

Normal repository CI on the PR exact HEAD remains mandatory before any Executor-B handoff.
