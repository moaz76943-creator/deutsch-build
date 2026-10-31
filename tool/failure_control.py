#!/usr/bin/env python3
"""Deterministic failure fingerprinting and safe-path selection.

This tool is deliberately non-destructive. It classifies diagnostic text and
returns an allowlisted response path; execution remains with the existing
task/runner/recovery controls.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from typing import Any

PLAYBOOKS: tuple[dict[str, Any], ...] = (
    {"id":"ai-model-quota","class":"AI_MODEL_QUOTA","patterns":("quota","rate limit","too many requests","provider unavailable","model unavailable"),"path":"ROUTE_ALTERNATIVE_AND_RESUME","verify":"focused task verification + evidence"},
    {"id":"session-context","class":"SESSION_CONTEXT","patterns":("context overflow","context window","session crashed","session terminated","session lost"),"path":"RESUME_FROM_VERIFIED_CHECKPOINT","verify":"state/checkpoint integrity + focused verification"},
    {"id":"network-sync","class":"NETWORK_SYNC","patterns":("timeout","connection reset","network error","temporary failure","offline"),"path":"BOUNDED_RETRY_THEN_RESUME","verify":"replay/idempotency + final-state verification"},
    {"id":"dependency-toolchain","class":"DEPENDENCY_TOOLCHAIN","patterns":("dependency conflict","package conflict","gradle","ndk","java version","toolchain","setup-python"),"path":"RECONCILE_PINNED_TOOLCHAIN_AND_VERIFY","verify":"dependency/build verification"},
    {"id":"build-test","class":"BUILD_TEST","patterns":("build failed","compile error","flutter analyze","test failed","pytest failed","assertionerror"),"path":"CLASSIFY_IMPACTED_TESTS_THEN_REPAIR","verify":"impacted tests + regression verification"},
    {"id":"concurrency","class":"CONCURRENCY","patterns":("race condition","duplicate worker","already running","lock conflict","concurrent"),"path":"STOP_DUPLICATE_AND_RECONCILE_OWNERSHIP","verify":"ownership/idempotency verification"},
    {"id":"state-integrity","class":"STATE_INTEGRITY","patterns":("corrupt state","invalid state","jsondecodeerror","partial write","schema mismatch","checksum mismatch"),"path":"QUARANTINE_AND_RECOVER_KNOWN_GOOD","verify":"integrity + restore verification"},
    {"id":"security-privacy","class":"SECURITY_PRIVACY","patterns":("secret","token leak","permission denied","unauthorized","pii","credential"),"path":"CONTAIN_AND_REQUIRE_SECURITY_GATE","verify":"security/privacy evidence"},
    {"id":"scheduler-telemetry","class":"SCHEDULER_TELEMETRY","patterns":("last_run","scheduler","stale telemetry","workflow run missing","cadence"),"path":"RECONCILE_DURABLE_RUN_EVIDENCE","verify":"run-state reconciliation"},
    {"id":"no-progress","class":"NO_PROGRESS","patterns":("same failure","no progress","stalled","loop detected","repeated failure"),"path":"STOP_REASSESS_AND_SWITCH_PATH","verify":"new evidence or explicit escalation"},
    {"id":"unknown","class":"UNKNOWN","patterns":(),"path":"STOP_AND_RECONCILE","verify":"human/system diagnosis before mutation"},
)


def normalize(message: str) -> str:
    value = message.lower()
    value = re.sub(r"https?://\S+", "<url>", value)
    value = re.sub(r"[0-9a-f]{12,64}", "<id>", value)
    value = re.sub(r"\b\d+(?:\.\d+)?\b", "<n>", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value


def classify(message: str) -> dict[str, Any]:
    normalized = normalize(message)
    for item in PLAYBOOKS:
        if item["class"] == "UNKNOWN":
            continue
        if any(pattern in normalized for pattern in item["patterns"]):
            signature = f'{item["class"]}|{normalized[:1000]}'
            fingerprint = hashlib.sha256(signature.encode("utf-8")).hexdigest()
            return {**item, "fingerprint": fingerprint}
    signature = f"UNKNOWN|{normalized[:1000]}"
    return {**PLAYBOOKS[-1], "fingerprint": hashlib.sha256(signature.encode("utf-8")).hexdigest()}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("message", nargs="?", help="diagnostic/error text; stdin is used when omitted")
    parser.add_argument("--json", action="store_true", help="emit JSON")
    args = parser.parse_args()
    message = args.message if args.message is not None else sys.stdin.read()
    if not message.strip():
        parser.error("provide diagnostic text or pipe it on stdin")
    result = classify(message)
    if args.json:
        print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    else:
        print(f'CLASS={result["class"]}')
        print(f'FINGERPRINT={result["fingerprint"]}')
        print(f'PATH={result["path"]}')
        print(f'VERIFY={result["verify"]}')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
