#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
MAX_UI_FILE_LINES = 1000
UI_PRESENTATION_ROOTS = ('lib/ui', 'lib/ui_v35')
GENERATED_DATA_ROOT = 'lib/data/generated'


def _is_within(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def run_audit(root: Path) -> list[str]:
    warnings = []
    lib_root = root / 'lib'
    generated_root = root / GENERATED_DATA_ROOT
    ui_roots = tuple(root / rel for rel in UI_PRESENTATION_ROOTS)

    # File-size policy is a presentation-layer maintainability rule. Compiler
    # generated data remains subject to architecture/dependency gates below,
    # but is explicitly exempt from this UI source line limit.
    for p in sorted(lib_root.rglob('*.dart')):
        if _is_within(p, generated_root):
            continue
        if not any(_is_within(p, ui_root) for ui_root in ui_roots):
            continue
        lines = len(p.read_text(encoding='utf-8').splitlines())
        if lines > MAX_UI_FILE_LINES:
            warnings.append(
                f'WARN oversized: {p.relative_to(root).as_posix()} ({lines} lines)'
            )

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
    print(f'Oversized UI files: {len(oversized)}')
    for warning in warnings:
        print(warning)
    return 1 if warnings else 0


if __name__ == '__main__':
    raise SystemExit(main())
