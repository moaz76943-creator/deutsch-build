#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "tool" / "task11_release_contract.json"
ANDROID_NS = "http://schemas.android.com/apk/res/android"
TOOLS_NS = "http://schemas.android.com/tools"
ANDROID_NAME = f"{{{ANDROID_NS}}}name"
ANDROID_CLEARTEXT = f"{{{ANDROID_NS}}}usesCleartextTraffic"
ANDROID_ALLOW_BACKUP = f"{{{ANDROID_NS}}}allowBackup"
TOOLS_NODE = f"{{{TOOLS_NS}}}node"

NETWORK_IMPORT_TOKENS = (
    "package:http/",
    "package:web_socket_channel/",
    "dart:html",
)
NETWORK_API_PATTERNS = (
    re.compile(r"\bHttpClient\s*\("),
    re.compile(r"\bSocket\.connect\s*\("),
    re.compile(r"\bWebSocket\.connect\s*\("),
    re.compile(r"\bUri\.http\s*\("),
    re.compile(r"\bUri\.https\s*\("),
)
PRODUCTION_BOUNDARY_FILES = (
    "lib/main.dart",
    "lib/bootstrap/production_bootstrap.dart",
    "lib/bootstrap/production_runtime.dart",
)
REQUIRED_LOCAL_GATE_TOKENS = (
    "tests/quality_gate",
    "tool/gradle_wrapper_integrity.py",
    "tool/content_pack.py validate",
    "tool/content_ingestion.py validate",
    "asset_pipeline_agent.py",
    "tool/content_compiler.py compile",
    "tool/content_compiler.py parity",
    "scripts/check-dart-errors.sh",
)


class Task11Violation(RuntimeError):
    pass


def _load_contract() -> dict[str, object]:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("schema_version") != 1:
        raise Task11Violation("invalid_task11_contract")
    return data


def _text(relative_path: str) -> str:
    path = ROOT / relative_path
    if not path.is_file():
        raise Task11Violation(f"missing_required_file:{relative_path}")
    return path.read_text(encoding="utf-8")


def _manifest(path: str) -> ET.Element:
    try:
        return ET.fromstring(_text(path))
    except ET.ParseError as exc:
        raise Task11Violation(f"invalid_android_manifest:{path}") from exc


def _permissions(root: ET.Element) -> set[str]:
    return {
        node.attrib[ANDROID_NAME]
        for node in root.findall("uses-permission")
        if ANDROID_NAME in node.attrib and node.attrib.get(TOOLS_NODE) != "remove"
    }


def _verify_offline_boundary(contract: dict[str, object]) -> None:
    main = _manifest("android/app/src/main/AndroidManifest.xml")
    allowed = set(contract["allowed_main_permissions"])
    declared = _permissions(main)
    if declared != allowed:
        raise Task11Violation(
            f"main_permission_drift:expected={sorted(allowed)}:actual={sorted(declared)}"
        )

    application = main.find("application")
    if application is None:
        raise Task11Violation("android_application_missing")
    if application.attrib.get(ANDROID_CLEARTEXT) != "false":
        raise Task11Violation("cleartext_traffic_must_be_false")
    if application.attrib.get(ANDROID_ALLOW_BACKUP) != "false":
        raise Task11Violation("android_backup_must_be_false")

    forbidden = set(contract["forbidden_release_permissions"])
    release = _manifest("android/app/src/release/AndroidManifest.xml")
    release_permissions = _permissions(release)
    if release_permissions & (forbidden - {"android.permission.POST_NOTIFICATIONS"}):
        raise Task11Violation("release_manifest_declares_network_permission")
    notification_nodes = [
        node
        for node in release.findall("uses-permission")
        if node.attrib.get(ANDROID_NAME) == "android.permission.POST_NOTIFICATIONS"
    ]
    if not notification_nodes or any(
        node.attrib.get(TOOLS_NODE) != "remove" for node in notification_nodes
    ):
        raise Task11Violation("release_notification_permission_must_be_removed")

    for relative_path in PRODUCTION_BOUNDARY_FILES:
        source = _text(relative_path)
        for token in NETWORK_IMPORT_TOKENS:
            if token in source:
                raise Task11Violation(
                    f"network_import_in_production_boundary:{relative_path}:{token}"
                )
        for pattern in NETWORK_API_PATTERNS:
            if pattern.search(source):
                raise Task11Violation(
                    f"network_api_in_production_boundary:{relative_path}:{pattern.pattern}"
                )


def _schema_version(source: str, relative_path: str) -> int:
    match = re.search(
        r"static\s+const\s+int\s+schemaVersion\s*=\s*(\d+)\s*;",
        source,
    )
    if match is None:
        raise Task11Violation(f"schema_version_missing:{relative_path}")
    return int(match.group(1))


def _require_tokens(
    source: str,
    relative_path: str,
    tokens: tuple[str, ...],
) -> None:
    for token in tokens:
        if token not in source:
            raise Task11Violation(
                f"required_contract_missing:{relative_path}:{token}"
            )


def _verify_schema_integrity(contract: dict[str, object]) -> None:
    schemas = contract["database_schemas"]
    if not isinstance(schemas, dict):
        raise Task11Violation("database_schema_contract_invalid")
    for relative_path, expected in schemas.items():
        if not isinstance(relative_path, str) or not isinstance(expected, int):
            raise Task11Violation("database_schema_contract_invalid")
        source = _text(relative_path)
        actual = _schema_version(source, relative_path)
        if actual != expected:
            raise Task11Violation(
                f"schema_version_drift:{relative_path}:"
                f"expected={expected}:actual={actual}"
            )

    learner_path = "lib/core/storage/local_db/learner_state_database.dart"
    learner = _text(learner_path)
    _require_tokens(
        learner,
        learner_path,
        (
            "await _verifySchema(database);",
            "storedVersion != schemaVersion",
            "unsupported_learner_store_schema",
            "source_payload_sha256",
            "imported_snapshot_sha256",
        ),
    )

    gamification_path = (
        "lib/features/gamification/sqlite_gamification_repository.dart"
    )
    gamification = _text(gamification_path)
    _require_tokens(
        gamification,
        gamification_path,
        (
            "version: SqliteGamificationRepository.schemaVersion",
            "if (oldVersion < 2)",
            "if (oldVersion < 3)",
            "if (oldVersion < 4)",
            "version.toInt() != SqliteGamificationRepository.schemaVersion",
            "PRAGMA foreign_keys = ON",
        ),
    )


def _verify_release_gates(contract: dict[str, object]) -> None:
    local_release = _text("scripts/local-release.sh")
    _require_tokens(
        local_release,
        "scripts/local-release.sh",
        (
            'if [[ "$MODE" == "release" || "$VERIFY" == true ]]; then',
            'bash "$ROOT/scripts/local_quality_gate.sh"',
            'bash "$ROOT/scripts/signing_guard.sh"',
            'bash "$ROOT/scripts/apk_verify.sh" "$APK" "$MODE"',
        ),
    )

    apk_verify = _text("scripts/apk_verify.sh")
    forbidden_permissions = contract["forbidden_release_permissions"]
    if not isinstance(forbidden_permissions, list):
        raise Task11Violation("forbidden_permission_contract_invalid")
    for permission in forbidden_permissions:
        if not isinstance(permission, str) or permission not in apk_verify:
            raise Task11Violation(f"apk_permission_guard_missing:{permission}")
    _require_tokens(
        apk_verify,
        "scripts/apk_verify.sh",
        (
            'APK_ABI="arm64-v8a"',
            "apksigner verify --verbose --print-certs",
            "certificate SHA-256 digest:",
            "Release APK signature verification failed",
        ),
    )

    local_gate = _text("scripts/local_quality_gate.sh")
    _require_tokens(
        local_gate,
        "scripts/local_quality_gate.sh",
        REQUIRED_LOCAL_GATE_TOKENS,
    )

    bounded_files = contract["bounded_files"]
    if not isinstance(bounded_files, list):
        raise Task11Violation("bounded_file_contract_invalid")
    for relative_path in bounded_files:
        if not isinstance(relative_path, str):
            raise Task11Violation("bounded_file_contract_invalid")
        line_count = len(_text(relative_path).splitlines())
        if line_count > 1000:
            raise Task11Violation(
                f"file_line_ceiling_exceeded:{relative_path}:{line_count}"
            )


def check() -> None:
    contract = _load_contract()
    _verify_offline_boundary(contract)
    _verify_schema_integrity(contract)
    _verify_release_gates(contract)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("check",))
    parser.parse_args()
    try:
        check()
    except (
        OSError,
        KeyError,
        TypeError,
        ValueError,
        json.JSONDecodeError,
        Task11Violation,
    ) as exc:
        print(f"TASK 11 RELEASE HARDENING: FAIL — {exc}", file=sys.stderr)
        return 1
    print("TASK 11 RELEASE HARDENING: PASS")
    print("OFFLINE_BOUNDARY: PASS")
    print("SCHEMA_INTEGRITY: PASS")
    print("RELEASE_GATES: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
