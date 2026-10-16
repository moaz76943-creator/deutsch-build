#!/usr/bin/env python3
"""Offline, read-only preflight for language-pack SQLite artifacts and builders.

Usage:
    python3 -B tools/verification/preflight_check.py \
        --db /path/to/de-1.0.0.sqlite \
        --golden-sha256 <64-character-reviewed-german-sqlite-digest>

All checks run locally; nothing is downloaded or sent to CI. A missing database,
test script, or trusted Golden SHA-256 is a failure, never an implicit PASS.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import re
import sqlite3
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[2]
DB_SUFFIXES = {".sqlite", ".sqlite3", ".db"}
HEX_256 = re.compile(r"^[0-9a-fA-F]{64}$")
LEXICON_COLUMNS = {
    "id", "surface", "part_of_speech", "direction", "fields_json",
}
CONCEPT_COLUMNS = {
    "concept_id", "sense_id", "lemma", "part_of_speech", "register",
    "cefr", "surface", "direction", "semantic_tags_json",
    "legacy_fields_json",
}
TEST_NAMES = (
    ("Morphology tests", "tools/morphology/tests/test_build_universal_verbs.py"),
    ("Ingestion tests", "tools/ingestion/test_build_canonical_lexicon.py"),
    ("Kaikki lexicon tests", "tools/ingestion/test_fetch_kaikki_lexicon.py"),
)


@dataclass(frozen=True)
class Check:
    name: str
    passed: bool
    details: str


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def discover_databases(root: Path) -> list[Path]:
    """Bounded discovery: no traversal of Git, caches, or build toolchains."""
    found: set[Path] = set()
    exclusions = {
        ".git", ".dart_tool", ".gradle", ".venv", "venv", "node_modules",
        "__pycache__", "flutter", "gradle", "android",
    }
    for item in root.iterdir():
        if item.is_file() and item.suffix.lower() in DB_SUFFIXES:
            found.add(item.resolve())
    for directory in ("assets", "packs", "content", "data", "output", "dist"):
        base = root / directory
        if not base.is_dir():
            continue
        visited = 0
        for current, subdirs, filenames in os.walk(base, followlinks=False):
            depth = len(Path(current).relative_to(base).parts)
            subdirs[:] = sorted(
                name for name in subdirs if name not in exclusions and depth < 5
            )
            for name in filenames:
                visited += 1
                if visited > 20000:
                    break
                file = Path(current) / name
                if file.suffix.lower() in DB_SUFFIXES and file.is_file():
                    found.add(file.resolve())
            if visited > 20000 or len(found) >= 100:
                break
    return sorted(found)


def check_inventory(paths: list[Path], minimum_bytes: int) -> Check:
    if not paths:
        return Check("Pack sizes", False, "No SQLite packs found; use --db PATH.")
    failures = []
    sizes = []
    for path in paths:
        try:
            if not path.is_file():
                failures.append(f"{path.name}: file missing")
                continue
            size = path.stat().st_size
            sizes.append(f"{path.name}={size:,}B")
            if size < minimum_bytes:
                failures.append(
                    f"{path.name}: {size:,} < required {minimum_bytes:,} bytes"
                )
            with path.open("rb") as stream:
                if stream.read(16) != b"SQLite format 3\x00":
                    failures.append(f"{path.name}: invalid SQLite header")
        except OSError as error:
            failures.append(f"{path.name}: {error}")
    if failures:
        return Check("Pack sizes", False, "; ".join(failures))
    return Check("Pack sizes", True, "; ".join(sizes))


def _check_one_schema(
    path: Path, min_lexicon_rows: int, min_concept_rows: int
) -> str:
    if not path.is_file():
        return "file missing"
    uri = "file:" + quote(path.as_posix(), safe="/") + "?mode=ro"
    try:
        with sqlite3.connect(uri, uri=True, timeout=5) as connection:
            quick = connection.execute("PRAGMA quick_check(1)").fetchone()
            if quick is None or quick[0] != "ok":
                return f"SQLite quick_check failed: {quick!r}"
            counts = {}
            for table, required, minimum in (
                ("lexicon", LEXICON_COLUMNS, min_lexicon_rows),
                ("concepts", CONCEPT_COLUMNS, min_concept_rows),
            ):
                rows = connection.execute(
                    f'PRAGMA table_info("{table}")'
                ).fetchall()
                if not rows:
                    return f"missing table: {table}"
                present = {str(row[1]): row for row in rows}
                missing = sorted(required - present.keys())
                if missing:
                    return f"{table}: missing columns {', '.join(missing)}"
                for column in required:
                    row = present[column]
                    if str(row[2]).upper() != "TEXT":
                        return f"{table}.{column}: expected TEXT column"
                    if column in ("id", "concept_id") and int(row[5]) != 1:
                        return f"{table}.{column}: expected primary key"
                count = connection.execute(
                    f'SELECT COUNT(*) FROM "{table}"'
                ).fetchone()[0]
                counts[table] = count
                if count < minimum:
                    return f"{table}: {count} rows; minimum is {minimum}"
            return f"ok; lexicon={counts['lexicon']:,}, concepts={counts['concepts']:,}"
    except (sqlite3.Error, OSError, ValueError) as error:
        return f"SQLite error: {error}"


def check_schemas(
    paths: list[Path], min_lexicon_rows: int, min_concept_rows: int
) -> Check:
    if not paths:
        return Check("SQLite schemas", False, "No SQLite packs to inspect.")
    failures = []
    successes = []
    for path in paths:
        result = _check_one_schema(path, min_lexicon_rows, min_concept_rows)
        if result.startswith("ok;"):
            successes.append(f"{path.name}: {result}")
        else:
            failures.append(f"{path.name}: {result}")
    return Check(
        "SQLite schemas",
        not failures,
        "; ".join(failures or successes),
    )


def expected_golden_digest(args: argparse.Namespace, root: Path) -> str:
    if args.golden_sha256:
        value = args.golden_sha256
    elif args.golden_hash_file:
        file = Path(args.golden_hash_file).expanduser()
        if not file.is_absolute():
            file = root / file
        value = file.read_text(encoding="utf-8").strip().split()[0]
    else:
        # This optional file is deliberately not generated by this tool.
        pinned = root / "tools/verification/golden_german.sha256"
        if pinned.is_file():
            value = pinned.read_text(encoding="utf-8").strip().split()[0]
        else:
            value = os.environ.get("DE_GOLDEN_SHA256", "")
    if not HEX_256.fullmatch(value):
        raise ValueError(
            "Missing/invalid reviewed Golden German SQLite SHA-256; "
            "pass --golden-sha256 HEX or --golden-hash-file PATH."
        )
    return value.lower()


def choose_german_db(paths: list[Path], option: str | None, root: Path) -> Path:
    if option:
        path = Path(option).expanduser()
        return (root / path).resolve() if not path.is_absolute() else path.resolve()
    matches = [
        path for path in paths
        if path.name.lower().startswith(("de-", "de_", "de.", "german"))
        or "german" in path.name.lower()
    ]
    if len(matches) == 1:
        return matches[0]
    if len(paths) == 1:
        return paths[0]
    raise ValueError(
        "Ambiguous German SQLite pack; specify --golden-db PATH."
    )


def check_golden(args: argparse.Namespace, root: Path, paths: list[Path]) -> Check:
    if not paths and not args.golden_db:
        return Check(
            "German SHA-256", False,
            "No SQLite pack available; specify --db and a reviewed Golden SHA-256.",
        )
    try:
        expected = expected_golden_digest(args, root)
        path = choose_german_db(paths, args.golden_db, root)
        if not path.is_file():
            raise FileNotFoundError(f"Golden SQLite pack absent: {path}")
        actual = sha256_file(path)
        if actual != expected:
            return Check(
                "German SHA-256", False,
                f"{path.name}: mismatch (expected {expected}, got {actual})",
            )
        return Check("German SHA-256", True, f"{path.name}: {actual}")
    except (ValueError, OSError, IndexError) as error:
        return Check("German SHA-256", False, str(error))


# Uses only stdlib: supports unittest.TestCase and plain zero-argument test_*
# functions (plus the standard tmp_path fixture). Unsupported pytest fixtures
# fail explicitly rather than producing a misleading "0 tests, PASS".
_TEST_HARNESS = r"""
import inspect
import runpy
import sys
import tempfile
import traceback
import unittest
from pathlib import Path

file = Path(sys.argv[1]).resolve()
# Mirror direct execution: sibling production modules must be importable.
sys.path.insert(0, str(file.parent))
namespace = runpy.run_path(str(file), run_name="_preflight_test_module")
suite = unittest.TestSuite()
loader = unittest.defaultTestLoader
for obj in namespace.values():
    if (inspect.isclass(obj) and issubclass(obj, unittest.TestCase)
            and obj is not unittest.TestCase):
        if Path(inspect.getsourcefile(obj) or "/").resolve() == file:
            suite.addTests(loader.loadTestsFromTestCase(obj))
counts = suite.countTestCases()
errors = 0
with tempfile.TemporaryDirectory(prefix="preflight_test_") as temp:
    for name, function in sorted(namespace.items()):
        if not name.startswith("test_") or not inspect.isfunction(function):
            continue
        if Path(inspect.getsourcefile(function) or "/").resolve() != file:
            continue
        counts += 1
        try:
            kwargs = {}
            for parameter in inspect.signature(function).parameters.values():
                if parameter.name == "tmp_path":
                    path = Path(temp) / str(counts)
                    path.mkdir(parents=True, exist_ok=True)
                    kwargs["tmp_path"] = path
                elif parameter.default is inspect.Parameter.empty:
                    raise RuntimeError(
                        "Unsupported fixture '" + parameter.name + "' in " + name
                    )
            function(**kwargs)
        except BaseException:
            errors += 1
            traceback.print_exc()
if suite.countTestCases():
    outcome = unittest.TextTestRunner(verbosity=1).run(suite)
    errors += len(outcome.errors) + len(outcome.failures)
if not counts:
    sys.exit("FAIL: no runnable tests discovered (no false PASS).")
print(f"Executed {counts} tests; failures={errors}")
sys.exit(0 if errors == 0 else 1)
"""


def resolve_test(root: Path, filename: str, override: str | None) -> Path:
    if override:
        candidate = Path(override).expanduser()
        return (root / candidate).resolve() if not candidate.is_absolute() else candidate.resolve()
    # Canonical test locations are repository-relative, not at tests/ root.
    if Path(filename).parts[:-1]:
        return (root / filename).resolve()
    for folder in ("tests", "tools/verification", "tools", "scripts", ""):
        candidate = root / folder / filename
        if candidate.is_file():
            return candidate.resolve()
    return root / "tests" / filename


def run_test(
    label: str, filename: str, override: str | None,
    root: Path, timeout: int
) -> Check:
    path = resolve_test(root, filename, override)
    if not path.is_file():
        return Check(label, False, f"Missing test file: {path}")
    try:
        # Only execute tests owned by the selected repository.
        path.relative_to(root)
    except ValueError:
        return Check(label, False, f"Test must be inside repository: {path}")
    try:
        env = os.environ.copy()
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        env["PYTHONPATH"] = (
            str(root) + os.pathsep + env["PYTHONPATH"]
            if env.get("PYTHONPATH") else str(root)
        )
        result = subprocess.run(
            [sys.executable, "-B", "-c", _TEST_HARNESS, str(path)],
            cwd=str(root),
            env=env,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        output = (result.stdout + "\n" + result.stderr).strip()
        snippet = " | ".join(output.splitlines()[-5:])
        return Check(
            label, result.returncode == 0,
            (f"{path.name}: " + (snippet or f"exit {result.returncode}"))[:600],
        )
    except subprocess.TimeoutExpired:
        return Check(label, False, f"{path.name}: timed out after {timeout}s")
    except OSError as error:
        return Check(label, False, f"{path.name}: {error}")


def render(checks: list[Check]) -> None:
    title_width = max(21, *(len(item.name) for item in checks))
    line = "+" + "-" * (title_width + 2) + "+" + "-" * 8 + "+" + "-" * 78 + "+"
    print("\nOFFLINE PREFLIGHT VERIFICATION (no CI, no network)")
    print(line)
    print(f"| {'Component':<{title_width}} | {'Status':<6} | {'Details':<76} |")
    print(line)
    for item in checks:
        message = item.details.replace("\n", " ")
        if len(message) > 76:
            message = message[:73] + "..."
        print(
            f"| {item.name:<{title_width}} | "
            f"{'PASS' if item.passed else 'FAIL':<6} | {message:<76} |"
        )
    print(line)
    passed = sum(item.passed for item in checks)
    print(f"SUMMARY: {passed}/{len(checks)} PASS; "
          f"{len(checks) - passed} FAIL\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root", type=Path, default=ROOT,
        help="Repository root; defaults to the script's repository.",
    )
    parser.add_argument(
        "--db", action="append", type=Path, default=[],
        help="Explicit SQLite pack path; repeat for multiple packs.",
    )
    parser.add_argument(
        "--min-db-bytes", type=int, default=1024 * 1024,
        help="Minimum bytes per SQLite pack (default: 1 MiB).",
    )
    parser.add_argument(
        "--min-lexicon-rows", type=int, default=1,
        help="Require populated lexicon (default: 1 row).",
    )
    parser.add_argument(
        "--min-concept-rows", type=int, default=0,
        help="Minimum canonical concepts rows (default: 0, schema only).",
    )
    parser.add_argument(
        "--golden-db", help="German SQLite file to compare with trusted SHA.",
    )
    parser.add_argument(
        "--golden-sha256", help="Reviewed 64-hex SHA-256 of Golden German SQLite.",
    )
    parser.add_argument(
        "--golden-hash-file",
        help="Local sha256sum-style reference file (never fetched).",
    )
    parser.add_argument(
        "--morphology-test", help="Override morphology test path.",
    )
    parser.add_argument(
        "--ingestion-test", help="Override ingestion test path.",
    )
    parser.add_argument(
        "--test-timeout", type=int, default=120,
        help="Seconds allowed per test script (default: 120).",
    )
    parser.add_argument(
        "--kaikki-test", help="Override Kaikki lexicon test path.",
    )
    args = parser.parse_args(argv)
    if (args.min_db_bytes < 1 or args.min_lexicon_rows < 0
            or args.min_concept_rows < 0 or args.test_timeout < 1):
        parser.error("Size and timeout must be positive; row minima nonnegative.")
    root = args.root.expanduser().resolve()
    if not root.is_dir():
        parser.error(f"Repository root does not exist: {root}")

    # Missing optional DB locations are reported by checks, not raised here.
    discovery_error = None
    if args.db:
        paths = [
            (root / db).resolve() if not db.is_absolute() else db.resolve()
            for db in args.db
        ]
    else:
        try:
            paths = discover_databases(root)
        except OSError as error:
            paths = []
            discovery_error = f"Unable to discover SQLite packs: {error}"
    if args.golden_db:
        candidate = Path(args.golden_db).expanduser()
        candidate = (
            (root / candidate).resolve()
            if not candidate.is_absolute() else candidate.resolve()
        )
        if candidate not in paths:
            paths.append(candidate)
    paths = sorted(set(paths))

    checks = [
        check_inventory(paths, args.min_db_bytes),
        check_schemas(paths, args.min_lexicon_rows, args.min_concept_rows),
        check_golden(args, root, paths),
        run_test(*TEST_NAMES[0], args.morphology_test, root, args.test_timeout),
        run_test(*TEST_NAMES[1], args.ingestion_test, root, args.test_timeout),
        run_test(*TEST_NAMES[2], args.kaikki_test, root, args.test_timeout),
    ]
    if discovery_error is not None:
        checks.insert(0, Check("SQLite discovery", False, discovery_error))
    render(checks)
    return 0 if all(item.passed for item in checks) else 1


if __name__ == "__main__":
    sys.exit(main())
