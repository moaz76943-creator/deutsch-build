#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN = {
    'services/quality.dart': 'legacy German content-quality facade',
    'services/text_normalizer.dart': 'legacy German text-normalizer facade',
}


def scan(root: Path) -> list[str]:
    findings = []
    ui_root = root / 'lib' / 'ui_v35'
    for path in sorted(ui_root.rglob('*.dart')):
        text = path.read_text(encoding='utf-8')
        rel = path.relative_to(root).as_posix()
        for needle, reason in FORBIDDEN.items():
            if needle in text:
                findings.append(f'{rel}: legacy dependency: {needle} ({reason})')
        if 'PrivacySettings.' in text:
            findings.append(f'{rel}: global PrivacySettings facade usage')
        if 'ContentQuality.' in text:
            findings.append(f'{rel}: global ContentQuality facade usage')
    return findings


def main() -> int:
    findings = scan(ROOT)
    print('V381 UI DEPENDENCY GATE: ' + ('PASS' if not findings else 'FAIL'))
    print(f'findings={len(findings)}')
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == '__main__':
    raise SystemExit(main())
