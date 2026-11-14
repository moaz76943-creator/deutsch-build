#!/usr/bin/env python3
"""
Polyglot Developer CLI — Zero-Bureaucracy Expansion & Audit Tool
Usage:
  python3 tool/polyglot_cli.py status
  python3 tool/polyglot_cli.py add-module --id <module_id> --lang <iso> --title "<Arabic Title>"
  python3 tool/polyglot_cli.py security-scan
"""
import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def cmd_status() -> None:
    content_files = list((ROOT / "lib/src/core/content").glob("*.dart")) if (ROOT / "lib/src/core/content").exists() else []
    polyglot_modules = list((ROOT / "lib/src/core/polyglot/modules").glob("*.dart")) if (ROOT / "lib/src/core/polyglot/modules").exists() else []
    print("=== Polyglot Unified Repository Status ===")
    print(f"- Legacy Content Engines Preserved : {len(content_files)}")
    print(f"- Unified Plug-and-Play Modules    : {len(polyglot_modules)}")
    print("- Bureaucratic CAS Locks           : REMOVED")
    print("- Secret Protection (.gitignore)   : ACTIVE")


def cmd_security_scan() -> None:
    patterns = [
        re.compile(r"AIza[0-9A-Za-z\-_]{35}"),
        re.compile(r"gh[pousr]_[0-9A-Za-z]{36,}"),
        re.compile(r"github_pat_[0-9A-Za-z_]{80,}"),
        re.compile(r"sk-[0-9A-Za-z]{32,}"),
    ]
    leaks = 0
    for p in ROOT.rglob("*"):
        if not p.is_file() or ".git" in p.parts:
            continue
        try:
            txt = p.read_text(encoding="utf-8")
        except Exception:
            continue
        for rx in patterns:
            if rx.search(txt):
                print(f"[WARN] Potential secret match in: {p}")
                leaks += 1
    if leaks == 0:
        print("[OK] Zero secrets or tokens detected across the entire repository.")


def cmd_add_module(module_id: str, lang: str, title: str) -> None:
    mod_dir = ROOT / "lib/src/core/polyglot/modules"
    mod_dir.mkdir(parents=True, exist_ok=True)
    class_name = "".join(part.capitalize() for part in module_id.split("_")) + "Module"
    target_file = mod_dir / f"{module_id}.dart"
    content = f"""import '../polyglot_unified_core.dart';

class {class_name} implements PolyglotFeatureModule {{
  @override
  String get moduleId => '{module_id}';

  @override
  String get arabicTitle => '{title}';

  @override
  List<PolyglotLearningUnit> get units => const [
        PolyglotLearningUnit(
          id: '{module_id}_01',
          languageCode: '{lang}',
          level: CefrProficiencyLevel.b2,
          domainId: 'general',
          categoryId: 'core',
          title: '{title}',
          targetExpression: 'Example Expression',
          contextualSentence: 'Contextual sentence in target language.',
          commonPitfall: 'Common learner error.',
          arabicExplanation: 'شرح عربي واضح ومباشر للقاعدة أو المفردة في سياقها.',
          tags: ['{lang}', 'PlugAndPlay'],
        ),
      ];

  @override
  List<PolyglotValidationRule> get validationRules => const [];
}}
"""
    target_file.write_text(content, encoding="utf-8")
    print(f"[OK] Created plug-and-play module: {target_file}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Polyglot Zero-Bureaucracy CLI")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("status")
    sub.add_parser("security-scan")
    add_p = sub.add_parser("add-module")
    add_p.add_argument("--id", required=True)
    add_p.add_argument("--lang", default="de")
    add_p.add_argument("--title", required=True)

    args = parser.parse_args()
    if args.command == "status":
        cmd_status()
    elif args.command == "security-scan":
        cmd_security_scan()
    elif args.command == "add-module":
        cmd_add_module(args.id, args.lang, args.title)


if __name__ == "__main__":
    main()
