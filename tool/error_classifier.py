#!/usr/bin/env python3
"""Classify local Flutter/Android build failures without mutating the project."""
from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
import argparse
import json
import re

MAX_READ_BYTES = 2_000_000
MAX_EVIDENCE = 12


@dataclass(frozen=True)
class Rule:
    category: str
    severity: str
    auto_retry: bool
    recommended_action: str
    allowed_scopes: tuple[str, ...]
    patterns: tuple[str, ...]


RULES: tuple[Rule, ...] = (
    Rule(
        "disk_space",
        "environment",
        False,
        "Free storage space before retrying. Do not change application source to hide this failure.",
        (),
        (r"no space left on device", r"enospc", r"not enough space"),
    ),
    Rule(
        "java_oom",
        "environment",
        False,
        "Reduce concurrent memory pressure or adjust the local Gradle JVM memory budget deliberately.",
        (),
        (r"outofmemoryerror", r"java heap space", r"gc overhead limit exceeded"),
    ),
    Rule(
        "android_toolchain",
        "environment",
        False,
        "Repair the pinned local Android/Java/AAPT2 toolchain; application source edits are not authorized.",
        (),
        (
            r"sdk location not found",
            r"failed to find target with hash string",
            r"build tools revision .* could not be found",
            r"aapt2.*(not found|cannot|failed)",
            r"android sdk was not found",
            r"gradle wrapper.*missing",
        ),
    ),
    Rule(
        "transient_io",
        "transient",
        True,
        "Retry the same build without changing source. Escalate if the bounded retry still fails.",
        (),
        (
            r"connection reset by peer",
            r"connection timed out",
            r"read timed out",
            r"temporary failure in name resolution",
            r"could not resolve host",
            r"connection closed unexpectedly",
        ),
    ),
    Rule(
        "dependency_resolution",
        "dependency",
        False,
        "Dependency or lockfile changes require an explicit deliberate task; do not auto-upgrade packages.",
        (),
        (
            r"version solving failed",
            r"because .* depends on .* version solving failed",
            r"pub get failed",
            r"could not resolve all files for configuration",
        ),
    ),
    Rule(
        "dart_compile",
        "code",
        False,
        "Fix the reported Dart/Flutter source error inside lib/ and rerun the bounded build loop.",
        ("lib/",),
        (
            r"error\s*[•-]",
            r"target kernel_snapshot failed",
            r"compilation failed",
            r"lib/[^\n]+\.dart[^\n]+(?:error|undefined|isn't defined|not defined)",
        ),
    ),
    Rule(
        "runtime_crash",
        "runtime",
        False,
        "Fix the startup/runtime failure in lib/ without adding network access or new permissions.",
        ("lib/",),
        (
            r"fatal exception",
            r"process:\s*com\.deutschbilarabi\.app",
            r"fatal signal",
            r"anr in com\.deutschbilarabi\.app",
        ),
    ),
    Rule(
        "gradle_build",
        "build",
        False,
        "Fix only the Android build configuration implicated by the log; do not touch CI/CD or tests.",
        ("android/",),
        (
            r"execution failed for task",
            r"failure: build failed with an exception",
            r"could not compile settings file",
            r"could not compile build file",
        ),
    ),
)

SECRET_ASSIGNMENT = re.compile(
    r"(?i)\b(token|secret|password|authorization|api[_-]?key|key[_-]?password|store[_-]?password)"
    r"\s*[:=]\s*([^\s]+)"
)
SECRET_TOKEN = re.compile(r"\b(?:sk-[A-Za-z0-9_-]{12,}|gh[pousr]_[A-Za-z0-9_]{12,})\b")


def redact(text: str) -> str:
    text = SECRET_ASSIGNMENT.sub(lambda m: f"{m.group(1)}=<redacted>", text)
    return SECRET_TOKEN.sub("<redacted-token>", text)


def _evidence(text: str, patterns: tuple[str, ...]) -> list[str]:
    compiled = [re.compile(pattern, re.IGNORECASE) for pattern in patterns]
    found: list[str] = []
    seen: set[str] = set()
    for raw_line in text.splitlines():
        if not any(pattern.search(raw_line) for pattern in compiled):
            continue
        line = redact(raw_line.strip())[:360]
        if line and line not in seen:
            seen.add(line)
            found.append(line)
        if len(found) >= MAX_EVIDENCE:
            break
    return found


def classify_text(text: str) -> dict[str, object]:
    for rule in RULES:
        evidence = _evidence(text, rule.patterns)
        if evidence:
            return {
                "category": rule.category,
                "severity": rule.severity,
                "auto_retry": rule.auto_retry,
                "recommended_action": rule.recommended_action,
                "allowed_scopes": list(rule.allowed_scopes),
                "evidence": evidence,
            }
    tail = [redact(line.strip())[:360] for line in text.splitlines()[-6:] if line.strip()]
    return {
        "category": "unknown",
        "severity": "unknown",
        "auto_retry": False,
        "recommended_action": "Stop automatic mutation and inspect the diagnostic package before changing source.",
        "allowed_scopes": [],
        "evidence": tail[-MAX_EVIDENCE:],
    }


def read_tail(path: Path) -> bytes:
    with path.open("rb") as handle:
        size = path.stat().st_size
        if size > MAX_READ_BYTES:
            handle.seek(size - MAX_READ_BYTES)
        return handle.read()


def classify_file(path: Path) -> dict[str, object]:
    raw = read_tail(path)
    text = raw.decode("utf-8", errors="replace")
    report = classify_text(text)
    report["log_path"] = str(path)
    report["log_sha256"] = sha256(raw).hexdigest()
    report["bytes_examined"] = len(raw)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not args.log.is_file():
        parser.error(f"log file does not exist: {args.log}")
    report = classify_file(args.log)
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
