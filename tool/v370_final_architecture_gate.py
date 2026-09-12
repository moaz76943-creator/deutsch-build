from dataclasses import dataclass
from pathlib import Path
import re

@dataclass(frozen=True)
class Finding:
    file: str
    line: int
    reason: str

_PATTERNS = (
    (re.compile(r'\b(ContentItem|\.german|\.arabic|\.sentenceAr|\.plural)\b'), 'German-shaped content dependency'),
    (re.compile(r'\bTextNormalizer\b'), 'legacy normalization dependency'),
    (re.compile(r'\bContentQuality\b'), 'legacy content-quality dependency'),
)

_PROTECTED = (Path('lib/core'), Path('lib/services'), Path('lib/widgets'))
_IGNORED = ('lib/language/', 'lib/data/', 'test/', 'tests/', 'lib/services/quality.dart', 'lib/services/text_normalizer.dart')

def scan_tree(root: Path) -> list[Finding]:
    findings: list[Finding] = []
    for base in _PROTECTED:
        directory = root / base
        if not directory.exists():
            continue
        for path in sorted(directory.rglob('*.dart')):
            rel = path.relative_to(root).as_posix()
            if any(rel.startswith(prefix) for prefix in _IGNORED):
                continue
            for number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
                for pattern, reason in _PATTERNS:
                    if pattern.search(line):
                        findings.append(Finding(rel, number, reason))
                        break
    return findings

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('root', nargs='?', default='.')
    args = parser.parse_args()
    findings = scan_tree(Path(args.root).resolve())
    print(f'findings={len(findings)}')
    for finding in findings:
        print(f'{finding.file}:{finding.line}: {finding.reason}')
    raise SystemExit(1 if findings else 0)
