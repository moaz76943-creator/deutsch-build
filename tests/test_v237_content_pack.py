from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tool" / "content_pack.py"
CONTENT = ROOT / "content" / "content_items.json"
VERBS = ROOT / "content" / "verb_conjugations.json"


def test_content_pack_export_preserves_current_catalog_shape():
    result = subprocess.run(
        [sys.executable, str(TOOL), "export"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    content = json.loads(CONTENT.read_text(encoding="utf-8"))
    verbs = json.loads(VERBS.read_text(encoding="utf-8"))
    assert content
    assert len({row["id"] for row in content}) == len(content)
    assert all(isinstance(row["id"], str) and row["id"] for row in content)
    assert isinstance(verbs, list)


def test_content_pack_validation_accepts_valid_cardinality_changes():
    subprocess.run([sys.executable, str(TOOL), "export"], cwd=ROOT, check=True)
    original = json.loads(CONTENT.read_text(encoding="utf-8"))
    try:
        added = dict(original[-1])
        added["id"] = "dynamic.contract.added"
        CONTENT.write_text(
            json.dumps(original + [added], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        result = subprocess.run(
            [sys.executable, str(TOOL), "validate"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr

        CONTENT.write_text(
            json.dumps(original[:-1], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        result = subprocess.run(
            [sys.executable, str(TOOL), "validate"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
    finally:
        CONTENT.write_text(
            json.dumps(original, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def test_content_pack_validation_rejects_duplicate_ids():
    subprocess.run([sys.executable, str(TOOL), "export"], cwd=ROOT, check=True)
    original = json.loads(CONTENT.read_text(encoding="utf-8"))
    try:
        CONTENT.write_text(
            json.dumps(original + [dict(original[0])], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        result = subprocess.run(
            [sys.executable, str(TOOL), "validate"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode != 0
        assert "duplicate" in result.stderr.lower()
    finally:
        CONTENT.write_text(
            json.dumps(original, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def test_ci_workflows_validate_editable_content_packs():
    build_workflow = (ROOT / ".github/workflows/build-apk.yml").read_text(encoding="utf-8")
    quality_workflow = (ROOT / ".github/workflows/quality.yml").read_text(encoding="utf-8")
    gate = (ROOT / "scripts/local_quality_gate.sh").read_text(encoding="utf-8")
    for workflow in (build_workflow, quality_workflow):
        assert "bash scripts/local_quality_gate.sh" in workflow
    assert "python3 tool/content_pack.py validate" in gate
