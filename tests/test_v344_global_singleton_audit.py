from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_singletons_are_classified():
    refs = []
    for path in (ROOT / 'lib').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        for m in re.finditer(r'([A-Za-z0-9_]+)\.instance', text):
            refs.append((str(path.relative_to(ROOT)), m.group(0)))
    audit_path = ROOT / 'docs/ARCHITECTURE_SINGLETON_AUDIT_V344.md'
    assert audit_path.exists()
    audit = audit_path.read_text(encoding='utf-8')
    for path, ref in refs:
        assert ref in audit, f'unclassified singleton: {path} {ref}'
        assert path in audit, f'unclassified singleton location: {path}'
