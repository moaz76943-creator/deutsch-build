#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
MAX_UI_FILE_LINES = 1000


def run_audit(root: Path) -> list[str]:
    warnings = []
    for p in sorted((root / 'lib').rglob('*.dart')):
        lines = len(p.read_text(encoding='utf-8').splitlines())
        if lines > MAX_UI_FILE_LINES:
            warnings.append(f'WARN oversized: {p.relative_to(root).as_posix()} ({lines} lines)')
    from architecture_boundary_gate import scan_tree
    findings = scan_tree(root)
    warnings.extend(f'BOUNDARY: {f.file}:{f.line}: {f.reason}' for f in findings)
    from v381_ui_dependency_gate import scan as scan_ui_dependencies
    warnings.extend(f'UI_DEPENDENCY: {finding}' for finding in scan_ui_dependencies(root))
    return warnings


def main() -> int:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('root', nargs='?', default=str(ROOT))
    args = parser.parse_args()
    root = Path(args.root).resolve()
    warnings = run_audit(root)
    print('ARCHITECTURE AUDIT: ' + ('PASS' if not warnings else 'FAIL'))
    print(f'MAX_UI_FILE_LINES: {MAX_UI_FILE_LINES}')
    oversized = [w for w in warnings if w.startswith('WARN oversized:')]
    print(f'Oversized files: {len(oversized)}')
    for warning in warnings:
        print(warning)
    return 1 if warnings else 0


if __name__ == '__main__':
    raise SystemExit(main())
