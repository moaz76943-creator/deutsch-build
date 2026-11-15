#!/usr/bin/env python3
"""Single-source-of-truth tooling for the canonical 100-language registry.

The Dart catalog (lib/core/i18n/canonical_language_catalog.dart) is the
executable source. This tool mirrors it into a machine-readable JSON artifact
(assets/registry/languages_100.json) and enforces the owner language policy:

* exactly 100 distinct registered language ids;
* Hebrew ('he' and its legacy alias 'iw') permanently excluded;
* every id is a valid lower-case BCP-47 primary subtag;
* every profile has a known ISO-15924 script with a consistent text direction;
* no duplicate ids and no Hebrew script (Hebr) inside the supported registry.

Usage:
    python3 tools/polyglot/registry_sync.py --check   # verify, exit 1 on drift/policy breach
    python3 tools/polyglot/registry_sync.py --write   # regenerate the JSON artifact + readiness report
    python3 tools/polyglot/registry_sync.py --report  # print the readiness report summary

The readiness report (assets/registry/readiness_report.json) reports
registration, content completeness and production readiness as strictly
separate sections; content completeness is not derivable from the registry
and is reported as such rather than inferred from registration.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DART_CATALOG = REPO_ROOT / "lib/core/i18n/canonical_language_catalog.dart"
JSON_REGISTRY = REPO_ROOT / "assets/registry/languages_100.json"
READINESS_REPORT = REPO_ROOT / "assets/registry/readiness_report.json"

EXPECTED_COUNT = 100
EXCLUDED_IDS = {"he", "iw"}
READINESS_STATES = ("registered", "sourceApproved", "productionReady")
ALLOWED_SCRIPTS = {
    "Latn", "Arab", "Hebr", "Cyrl", "Grek", "Hans", "Hant", "Jpan", "Kore",
    "Deva", "Beng", "Taml", "Telu", "Mlym", "Gujr", "Guru", "Knda", "Sinh",
    "Thai", "Laoo", "Mymr", "Khmr", "Geor", "Armn", "Ethi",
}
RTL_SCRIPTS = {"Arab", "Hebr"}

_PROFILE_RE = re.compile(r"^    '([a-z]{2,3})': CanonicalLanguageProfile\($")
_FIELD_RE = re.compile(r"^\s{6}(bcp47|nativeName|nameAr|flag): '(.*)',$")
_SCRIPT_RE = re.compile(r"^\s{6}script: scripts\['(\w+)'\]!,$")
_READINESS_RE = re.compile(r"^\s{6}readiness: LanguageReadiness\.(\w+),$")
_CAPABILITY_RE = re.compile(r"^\s{8}(has\w+): (true|false),$")
_ID_RE = re.compile(r"^[a-z]{2,3}$")


class RegistryError(Exception):
    pass


def parse_dart_catalog(path: Path = DART_CATALOG) -> dict[str, dict]:
    """Extract registered language profiles from the Dart catalog literal."""
    profiles: dict[str, dict] = {}
    current: dict | None = None
    key: str | None = None

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        match = _PROFILE_RE.match(raw_line)
        if match:
            key = match.group(1)
            current = {"id": key, "capabilities": {}}
            continue
        if current is None:
            continue

        field = _FIELD_RE.match(raw_line)
        if field:
            current[field.group(1)] = field.group(2)
            continue
        script = _SCRIPT_RE.match(raw_line)
        if script:
            current["script"] = script.group(1)
            continue
        readiness = _READINESS_RE.match(raw_line)
        if readiness:
            current["readiness"] = readiness.group(1)
            continue
        capability = _CAPABILITY_RE.match(raw_line)
        if capability:
            current["capabilities"][capability.group(1)] = (
                capability.group(2) == "true"
            )
            continue
        if raw_line.strip() == ")," and current.get("bcp47"):
            profiles[key] = current  # type: ignore[index]
            current, key = None, None

    if not profiles:
        raise RegistryError(f"no language profiles parsed from {path}")
    return profiles


def validate(profiles: dict[str, dict]) -> list[str]:
    """Return policy violations; an empty list means the registry is valid."""
    problems: list[str] = []

    if len(profiles) != EXPECTED_COUNT:
        problems.append(
            f"registry must contain exactly {EXPECTED_COUNT} languages, found {len(profiles)}"
        )

    seen_bcp47: dict[str, str] = {}
    for key, profile in sorted(profiles.items()):
        bcp47 = profile.get("bcp47", "")
        if not _ID_RE.match(key):
            problems.append(f"{key}: malformed language id")
        if key in EXCLUDED_IDS or bcp47 in EXCLUDED_IDS:
            problems.append(f"{key}: excluded language id must not be registered")
        if bcp47 != key:
            problems.append(f"{key}: bcp47 '{bcp47}' must match its registry key")
        if bcp47 in seen_bcp47:
            problems.append(f"duplicate bcp47 '{bcp47}' ({seen_bcp47[bcp47]}, {key})")
        seen_bcp47[bcp47] = key

        for field in ("nativeName", "nameAr", "flag"):
            if not profile.get(field):
                problems.append(f"{key}: missing {field}")

        script = profile.get("script")
        if script not in ALLOWED_SCRIPTS:
            problems.append(f"{key}: unknown ISO-15924 script '{script}'")
        if script == "Hebr" and key != "yi":
            # Yiddish legitimately uses the Hebrew script; the exclusion policy is
            # about the Hebrew *language*, not the writing system.
            problems.append(f"{key}: Hebrew script is only accepted for Yiddish (yi)")
        if script == "Arab" and profile.get("nativeName", "").strip() == "עברית":
            problems.append(f"{key}: detected Hebrew text in an Arabic-script slot")
        if profile.get("readiness") not in READINESS_STATES:
            problems.append(f"{key}: invalid readiness '{profile.get('readiness')}'")

    return problems


def build_artifact(profiles: dict[str, dict]) -> dict:
    languages = []
    for key in sorted(profiles):
        profile = profiles[key]
        script = profile["script"]
        languages.append(
            {
                "id": key,
                "bcp47": profile["bcp47"],
                "nativeName": profile["nativeName"],
                "nameAr": profile["nameAr"],
                "flag": profile["flag"],
                "script": script,
                "direction": "rtl" if script in RTL_SCRIPTS else "ltr",
                "readiness": profile.get("readiness", "registered"),
                "capabilities": dict(sorted(profile.get("capabilities", {}).items())),
            }
        )

    payload = {
        "schemaVersion": 1,
        "registryId": "polyglot-languages-100",
        "policy": {
            "registeredLanguageCount": EXPECTED_COUNT,
            "excludedLanguageIds": sorted(EXCLUDED_IDS),
            "hebrewExcluded": True,
            "sourceOfTruth": "lib/core/i18n/canonical_language_catalog.dart",
            "generated": True,
            "retiredPlaceholderStubs": [
                "fil", "ny", "om", "rw", "st", "ti", "tk", "ug", "wo",
            ],
            "retiredPlaceholderNote": (
                "Empty content-pack placeholders that were not part of the canonical "
                "registry. No vocabulary was lost; files remain recoverable from Git "
                "history and stay reserved as legacy identities."
            ),
        },
        "languageCount": len(languages),
        "languages": languages,
    }
    canonical = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    payload["checksum"] = {
        "algorithm": "sha256",
        "scope": "payload-without-checksum",
        "value": hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
    }
    return payload


def build_readiness_report(artifact: dict) -> dict:
    """Derive the registration-vs-content-vs-production readiness report.

    Registration, content completeness and production readiness are reported
    as separate sections and are never inferred from one another:

    * registration reflects presence in the canonical registry;
    * content completeness is NOT derivable from the registry (it needs
      pack-level rights/provenance/content evidence), so the report records
      it as not derivable rather than guessing;
    * production readiness reflects only an explicit readiness field.
    """
    by_state: dict[str, list[str]] = {state: [] for state in READINESS_STATES}
    for language in artifact["languages"]:
        by_state[language["readiness"]].append(language["id"])
    for state in READINESS_STATES:
        by_state[state] = sorted(by_state[state])

    return {
        "schemaVersion": 1,
        "reportId": "polyglot-registry-readiness",
        "derivedFrom": "lib/core/i18n/canonical_language_catalog.dart",
        "registration": {
            "registeredLanguageCount": artifact["languageCount"],
            "expectedLanguageCount": EXPECTED_COUNT,
            "excludedLanguageIds": sorted(EXCLUDED_IDS),
            "languages": sorted(language["id"] for language in artifact["languages"]),
        },
        "contentComplete": {
            "derived": False,
            "reason": (
                "content completeness requires pack-level rights/provenance/"
                "content evidence and is not tracked by the canonical "
                "registry; it must not be inferred from registration"
            ),
            "languages": [],
        },
        "productionReady": {
            "derived": True,
            "count": len(by_state["productionReady"]),
            "languages": by_state["productionReady"],
        },
        "sourceApproved": {
            "derived": True,
            "count": len(by_state["sourceApproved"]),
            "languages": by_state["sourceApproved"],
        },
        "readinessCounts": {state: len(by_state[state]) for state in READINESS_STATES},
    }


def _report_serialized(report: dict) -> str:
    return json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def _display(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def _sync_pack_stubs(artifact: dict, write: bool) -> bool:
    """Keep the content-pack stub directory in lockstep with the registry.

    Catches generated-catalog divergence: a language added to the registry
    without a pack slot, or an excluded language left behind as an asset.
    Stubs are empty placeholders, so they are regenerated deterministically;
    only empty placeholders are ever removed and content-bearing packs abort.
    """
    stubs_dir = REPO_ROOT / "assets/languages"
    if not stubs_dir.is_dir():
        print("FAIL: assets/languages content-pack directory is missing")
        return False

    registered = {language["id"] for language in artifact["languages"]}
    present = {path.stem for path in stubs_dir.glob("*.json") if path.is_file()}

    missing = sorted(registered - present)
    orphaned = sorted(present - registered)

    if write:
        for language_id in missing:
            (stubs_dir / f"{language_id}.json").write_text(
                json.dumps(
                    {"languageCode": language_id, "version": 1, "vocabulary": []},
                    ensure_ascii=False,
                )
                + "\n",
                encoding="utf-8",
            )
        for language_id in orphaned:
            path = stubs_dir / f"{language_id}.json"
            payload = json.loads(path.read_text(encoding="utf-8"))
            if payload.get("vocabulary"):
                print(f"FAIL: refusing to delete content-bearing pack {path.name}")
                return False
            path.unlink()
        if missing or orphaned:
            print(
                "SYNC pack stubs:"
                f" +{len(missing)} ({', '.join(missing) or '-'})"
                f" -{len(orphaned)} ({', '.join(orphaned) or '-'})"
            )
        missing, orphaned = [], []

    problems = []
    if missing:
        problems.append(f"registered languages without a pack stub: {', '.join(missing)}")
    if orphaned:
        problems.append(f"pack stubs outside the registry: {', '.join(orphaned)}")
    for excluded in sorted(EXCLUDED_IDS & present):
        problems.append(f"excluded language still shipped as an asset: {excluded}")

    for problem in problems:
        print(f"FAIL: {problem}")
    return not problems


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--check", action="store_true", help="verify registry + artifact + readiness report")
    group.add_argument("--write", action="store_true", help="regenerate the JSON artifact + readiness report")
    group.add_argument("--report", action="store_true", help="print the readiness report summary (no writes)")
    args = parser.parse_args(argv)

    try:
        profiles = parse_dart_catalog()
    except (OSError, RegistryError) as error:
        print(f"FAIL: {error}")
        return 1

    problems = validate(profiles)
    if problems:
        for problem in problems:
            print(f"FAIL: {problem}")
        return 1

    artifact = build_artifact(profiles)
    serialized = json.dumps(artifact, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    report = build_readiness_report(artifact)
    report_serialized = _report_serialized(report)

    if args.report:
        counts = report["readinessCounts"]
        print(
            f"registered={report['registration']['registeredLanguageCount']}"
            f" (expected {report['registration']['expectedLanguageCount']})"
        )
        for state in READINESS_STATES:
            print(f"readiness:{state}={counts[state]}")
        print("contentComplete=not-derivable (pack-level rights/provenance evidence required)")
        return 0

    if args.write:
        JSON_REGISTRY.parent.mkdir(parents=True, exist_ok=True)
        JSON_REGISTRY.write_text(serialized, encoding="utf-8")
        READINESS_REPORT.write_text(report_serialized, encoding="utf-8")
        print(f"WROTE {_display(JSON_REGISTRY)} ({artifact['languageCount']} languages)")
        print(f"WROTE {_display(READINESS_REPORT)}")
        return 0 if _sync_pack_stubs(artifact, write=True) else 1

    if not JSON_REGISTRY.exists():
        print(f"FAIL: missing generated artifact {_display(JSON_REGISTRY)}")
        return 1
    if JSON_REGISTRY.read_text(encoding="utf-8") != serialized:
        print(
            "FAIL: "
            f"{_display(JSON_REGISTRY)} is out of sync with the Dart catalog;"
            " run python3 tools/polyglot/registry_sync.py --write"
        )
        return 1
    if not READINESS_REPORT.exists():
        print(
            f"FAIL: missing readiness report {_display(READINESS_REPORT)};"
            " run python3 tools/polyglot/registry_sync.py --write"
        )
        return 1
    if READINESS_REPORT.read_text(encoding="utf-8") != report_serialized:
        print(
            "FAIL: "
            f"{_display(READINESS_REPORT)} is out of sync with the Dart catalog;"
            " run python3 tools/polyglot/registry_sync.py --write"
        )
        return 1

    if not _sync_pack_stubs(artifact, write=False):
        return 1

    print(
        f"OK: {artifact['languageCount']} registered languages, Hebrew excluded,"
        f" checksum {artifact['checksum']['value'][:16]}…"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
