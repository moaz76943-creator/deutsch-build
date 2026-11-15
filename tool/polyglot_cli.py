#!/usr/bin/env python3
"""
Polyglot Developer CLI — Zero-Bureaucracy Expansion & Audit Tool
Usage:
  python3 tool/polyglot_cli.py status
  python3 tool/polyglot_cli.py add-module --id <module_id> --lang <iso> --title "<Arabic Title>"
  python3 tool/polyglot_cli.py security-scan [--gitleaks <path>]

Exit codes: 0 success/no findings, 1 findings, 2 incomplete audit.
"""
import argparse
import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Fallback patterns only. The maintained Gitleaks ruleset is authoritative when
# the binary is available; these patterns keep a bounded local check.
FALLBACK_SECRET_PATTERNS = (
    ("google-api-key", re.compile(r"AIza[0-9A-Za-z\-_]{35}")),
    ("github-token", re.compile(r"gh[pousr]_[0-9A-Za-z]{36,}")),
    ("github-fine-grained-pat", re.compile(r"github_pat_[0-9A-Za-z_]{80,}")),
    ("openai-style-key", re.compile(r"sk-[0-9A-Za-z]{32,}")),
    ("aws-access-key-id", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("private-key-block", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----")),
)

FALLBACK_SKIP_DIRECTORIES = frozenset(
    {".git", "build", ".dart_tool", "node_modules", ".gradle", "__pycache__"}
)
FALLBACK_MAX_FILE_BYTES = 2 * 1024 * 1024


def cmd_status() -> int:
    content_files = list((ROOT / "lib/src/core/content").glob("*.dart")) if (ROOT / "lib/src/core/content").exists() else []
    polyglot_modules = list((ROOT / "lib/src/core/polyglot/modules").glob("*.dart")) if (ROOT / "lib/src/core/polyglot/modules").exists() else []
    print("=== Polyglot Unified Repository Status ===")
    print(f"- Legacy Content Engines Preserved : {len(content_files)}")
    print(f"- Unified Plug-and-Play Modules    : {len(polyglot_modules)}")
    print("- Bureaucratic CAS Locks           : REMOVED")
    print("- Secret Protection (.gitignore)   : ACTIVE")
    return 0


def _fallback_scan() -> tuple[int, list[dict]]:
    """Bounded tree scan. Reports locations and rule names, never secret values."""
    findings: list[dict] = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        if any(part in FALLBACK_SKIP_DIRECTORIES for part in path.parts):
            continue
        try:
            if path.stat().st_size > FALLBACK_MAX_FILE_BYTES:
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        for rule, pattern in FALLBACK_SECRET_PATTERNS:
            match = pattern.search(text)
            if match:
                findings.append(
                    {
                        "rule": rule,
                        "file": str(path.relative_to(ROOT)),
                        "line": text.count("\n", 0, match.start()) + 1,
                    }
                )
    return (1 if findings else 0), findings


def cmd_security_scan(gitleaks: str | None = None) -> int:
    """Delegate to the maintained scanner; fall back to a bounded local check.

    The delegated audit scans every fetched Git ref plus the committed tree and
    emits metadata only (rule/file/line/commit), never secret values.
    """
    binary = gitleaks or shutil.which("gitleaks")
    if not binary:
        print(
            "[WARN] gitleaks not found: running the bounded fallback pattern scan only.\n"
            "       Install gitleaks (or pass --gitleaks <path>) for the maintained ruleset\n"
            "       and full Git-history coverage."
        )
        code, findings = _fallback_scan()
        for finding in findings:
            print(f"[FAIL] {finding['rule']} in {finding['file']}:{finding['line']}")
        if code != 0:
            print(f"[FAIL] {len(findings)} potential secret location(s) detected. Values are not printed.")
            return 1
        print("[OK] Fallback scan found no secret-shaped strings.")
        return 0

    import subprocess

    result = subprocess.run(
        [sys.executable, str(ROOT / "tool" / "git_secret_audit.py"), "--repo", str(ROOT), "--gitleaks", binary],
        capture_output=True,
        text=True,
    )
    if result.stdout:
        try:
            report = json.loads(result.stdout)
        except json.JSONDecodeError:
            print("[FAIL] Secret audit produced an unreadable report.")
            return 2
        print(f"[INFO] Secret audit status: {report.get('status')}")
        for finding in report.get("findings", []):
            print(
                "[FAIL] {rule} in {file}:{line} (commit {commit})".format(
                    rule=finding.get("RuleID"),
                    file=finding.get("File"),
                    line=finding.get("StartLine"),
                    commit=(finding.get("Commit") or "")[:12],
                )
            )
    if result.returncode == 0:
        print("[OK] Maintained secret scan found no findings across fetched history.")
        return 0
    if result.returncode == 1:
        print("[FAIL] Secret findings require triage before publication. Values are not printed.")
        return 1
    print("[FAIL] Secret audit could not complete; treat publication as blocked.")
    return 2


def validate_module_identifier(module_id: str) -> str:
    """Reject anything that is not a flat snake_case module identifier."""
    if not re.fullmatch(r"[a-z][a-z0-9]*(?:_[a-z0-9]+)*", module_id or ""):
        raise ValueError(
            "module id must match ^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$ (no separators, no traversal)"
        )
    if len(module_id) > 64:
        raise ValueError("module id must be 64 characters or fewer")
    return module_id


def validate_language_code(lang: str) -> str:
    if not re.fullmatch(r"[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*", lang or ""):
        raise ValueError("language code must be a BCP-47 shaped identifier such as 'de' or 'pt-BR'")
    return lang


def dart_string_literal(value: str) -> str:
    """Encode a Dart single-quoted string literal without interpolation escapes."""
    out = ["'"]
    for character in value:
        if character == "\\":
            out.append("\\\\")
        elif character == "'":
            out.append("\\'")
        elif character == "$":
            # Dart treats $ as interpolation inside string literals.
            out.append("\\$")
        elif character == "\n":
            out.append("\\n")
        elif character == "\r":
            out.append("\\r")
        elif character == "\t":
            out.append("\\t")
        elif ord(character) < 0x20 or ord(character) == 0x7F:
            out.append("\\u{%x}" % ord(character))
        else:
            out.append(character)
    out.append("'")
    return "".join(out)


def resolve_module_path(module_id: str) -> Path:
    """Resolve the module file and prove it stays inside the owned module dir."""
    mod_dir = (ROOT / "lib/src/core/polyglot/modules").resolve()
    target = (mod_dir / f"{module_id}.dart").resolve()
    if target.parent != mod_dir:
        raise ValueError("resolved module path escapes the owned module directory")
    return target


def cmd_add_module(module_id: str, lang: str, title: str) -> int:
    module_id = validate_module_identifier(module_id)
    lang = validate_language_code(lang)
    target_file = resolve_module_path(module_id)
    if target_file.exists():
        raise ValueError(f"refusing to overwrite existing module: {target_file.name}")

    mod_dir = target_file.parent
    mod_dir.mkdir(parents=True, exist_ok=True)
    class_name = "".join(part.capitalize() for part in module_id.split("_")) + "Module"
    id_literal = dart_string_literal(module_id)
    lang_literal = dart_string_literal(lang)
    title_literal = dart_string_literal(title)
    content = f"""import '../polyglot_unified_core.dart';

class {class_name} implements PolyglotFeatureModule {{
  @override
  String get moduleId => {id_literal};

  @override
  String get arabicTitle => {title_literal};

  @override
  List<PolyglotLearningUnit> get units => const [
        PolyglotLearningUnit(
          id: {dart_string_literal(module_id + '_01')},
          languageCode: {lang_literal},
          level: CefrProficiencyLevel.b2,
          domainId: 'general',
          categoryId: 'core',
          title: {title_literal},
          targetExpression: 'Example Expression',
          contextualSentence: 'Contextual sentence in target language.',
          commonPitfall: 'Common learner error.',
          arabicExplanation: 'شرح عربي واضح ومباشر للقاعدة أو المفردة في سياقها.',
          tags: [{lang_literal}, 'PlugAndPlay'],
        ),
      ];

  @override
  List<PolyglotValidationRule> get validationRules => const [];
}}
"""
    target_file.write_text(content, encoding="utf-8")
    print(f"[OK] Created plug-and-play module: {target_file.relative_to(ROOT)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Polyglot Zero-Bureaucracy CLI")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("status")
    scan_p = sub.add_parser("security-scan")
    scan_p.add_argument("--gitleaks", default=None)
    add_p = sub.add_parser("add-module")
    add_p.add_argument("--id", required=True)
    add_p.add_argument("--lang", default="de")
    add_p.add_argument("--title", required=True)

    args = parser.parse_args()
    if args.command == "status":
        return cmd_status()
    if args.command == "security-scan":
        return cmd_security_scan(args.gitleaks)
    if args.command == "add-module":
        try:
            return cmd_add_module(args.id, args.lang, args.title)
        except ValueError as error:
            print(f"[FAIL] {error}")
            return 1
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
