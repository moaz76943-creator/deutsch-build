"""Supply-chain contract for active GitHub Actions workflows."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"
FULL_SHA = re.compile(r"^[0-9a-f]{40}$")


def test_active_third_party_actions_are_pinned_to_immutable_commit_shas():
    failures = []
    for path in sorted(WORKFLOWS.glob("*.y*ml")):
        if path.name.endswith(".disabled"):
            continue
        text = path.read_text(encoding="utf-8")
        for ref in re.findall(r"uses:\s*([^\s#]+)", text):
            if "@" not in ref:
                failures.append(f"{path.name}: missing ref: {ref}")
                continue
            _, target = ref.rsplit("@", 1)
            if not FULL_SHA.fullmatch(target):
                failures.append(f"{path.name}: mutable action ref: {ref}")
    assert not failures, "\n".join(failures)
