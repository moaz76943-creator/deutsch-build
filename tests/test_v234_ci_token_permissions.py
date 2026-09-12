from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _permissions_block(text: str) -> str:
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if line.strip() == 'permissions:':
            out = []
            for nxt in lines[i + 1:]:
                if nxt and not nxt.startswith(' '):
                    break
                out.append(nxt)
            return '\n'.join(out)
    return ''


def test_release_and_quality_workflows_explicitly_deny_unused_github_token_scopes():
    for name in ('build-apk.yml', 'quality.yml'):
        block = _permissions_block((ROOT / '.github' / 'workflows' / name).read_text())
        assert 'contents: read' in block
        assert 'actions: none' in block
        assert 'checks: none' in block
        assert 'id-token: none' in block
        assert 'pull-requests: none' in block
