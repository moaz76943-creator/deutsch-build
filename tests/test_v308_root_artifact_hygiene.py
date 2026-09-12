from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_root_has_no_stray_release_notes_files():
    stray = sorted(ROOT.glob('V*_RELEASE_NOTES.md'))
    assert stray == [], f'stray root release notes: {[p.name for p in stray]}'
