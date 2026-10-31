"""Typed structural helpers for the canonical current-topology security gate."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"

ANDROID_NS = "http://schemas.android.com/apk/res/android"
TOOLS_NS = "http://schemas.android.com/tools"
ANDROID_NAME = f"{{{ANDROID_NS}}}name"
TOOLS_NODE = f"{{{TOOLS_NS}}}node"


@dataclass(frozen=True)
class WorkflowStep:
    name: str
    uses: str | None
    run: str
    with_values: dict[str, str]
    raw: str


@dataclass(frozen=True)
class WorkflowJob:
    key: str
    condition: str
    runs_on: str
    permissions: dict[str, str]
    steps: tuple[WorkflowStep, ...]
    raw: str


@dataclass(frozen=True)
class WorkflowModel:
    path: Path
    triggers: frozenset[str]
    permissions: dict[str, str]
    jobs: tuple[WorkflowJob, ...]
    action_refs: tuple[str, ...]


def _indent(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def _scalar(lines: list[str], index: int, indent: int) -> tuple[str, int]:
    _, value = lines[index].split(":", 1)
    value = value.strip()
    if value not in {"|", "|-", ">", ">-"}:
        return value.strip("'\""), index + 1
    parts: list[str] = []
    cursor = index + 1
    while cursor < len(lines):
        line = lines[cursor]
        if line.strip() and _indent(line) <= indent:
            break
        if line.strip():
            parts.append(line.strip())
        cursor += 1
    return ("\n".join(parts) if value.startswith("|") else " ".join(parts)), cursor


def _mapping(lines: list[str], start: int, indent: int) -> tuple[dict[str, str], int]:
    header = lines[start].split(":", 1)[1].strip()
    if header == "{}":
        return {}, start + 1
    values: dict[str, str] = {}
    cursor = start + 1
    while cursor < len(lines):
        line = lines[cursor]
        if line.strip() and _indent(line) <= indent:
            break
        if line.strip() and _indent(line) == indent + 2 and ":" in line:
            key, raw = line.strip().split(":", 1)
            values[key] = raw.strip().strip("'\"")
        cursor += 1
    return values, cursor


def _step_models(job_lines: list[str]) -> tuple[WorkflowStep, ...]:
    steps: list[WorkflowStep] = []
    cursor = 0
    while cursor < len(job_lines):
        line = job_lines[cursor]
        if _indent(line) == 6 and line.lstrip().startswith("- "):
            start = cursor
            cursor += 1
            while cursor < len(job_lines):
                candidate = job_lines[cursor]
                if _indent(candidate) == 6 and candidate.lstrip().startswith("- "):
                    break
                cursor += 1
            block = job_lines[start:cursor]
            name = ""
            uses: str | None = None
            run = ""
            with_values: dict[str, str] = {}
            index = 0
            while index < len(block):
                current = block[index]
                stripped = current.strip()
                if stripped.startswith("- name:"):
                    name = stripped.split(":", 1)[1].strip().strip("'\"")
                elif stripped.startswith("- uses:"):
                    uses = stripped.split(":", 1)[1].strip().split("#", 1)[0].strip()
                elif _indent(current) == 8 and stripped.startswith("name:"):
                    name = stripped.split(":", 1)[1].strip().strip("'\"")
                elif _indent(current) == 8 and stripped.startswith("uses:"):
                    uses = stripped.split(":", 1)[1].strip().split("#", 1)[0].strip()
                elif _indent(current) == 8 and stripped.startswith("run:"):
                    run, next_index = _scalar(block, index, 8)
                    index = next_index
                    continue
                elif _indent(current) == 8 and stripped == "with:":
                    with_values, next_index = _mapping(block, index, 8)
                    index = next_index
                    continue
                index += 1
            steps.append(
                WorkflowStep(
                    name=name,
                    uses=uses,
                    run=run,
                    with_values=with_values,
                    raw="\n".join(block),
                )
            )
            continue
        cursor += 1
    return tuple(steps)


def parse_workflow(path: Path) -> WorkflowModel:
    lines = path.read_text(encoding="utf-8").splitlines()
    triggers: set[str] = set()
    permissions: dict[str, str] = {}

    for index, line in enumerate(lines):
        if line == "on:":
            cursor = index + 1
            while cursor < len(lines):
                candidate = lines[cursor]
                if candidate.strip() and _indent(candidate) == 0:
                    break
                if candidate.strip() and _indent(candidate) == 2 and ":" in candidate:
                    triggers.add(candidate.strip().split(":", 1)[0])
                cursor += 1
        elif line == "permissions:" or line == "permissions: {}":
            permissions, _ = _mapping(lines, index, 0)

    try:
        jobs_start = lines.index("jobs:") + 1
    except ValueError as exc:
        raise AssertionError(f"{path.name}: missing jobs mapping") from exc

    jobs: list[WorkflowJob] = []
    cursor = jobs_start
    while cursor < len(lines):
        line = lines[cursor]
        if (
            line.strip()
            and _indent(line) == 2
            and re.fullmatch(r"[A-Za-z0-9_-]+:", line.strip())
        ):
            key = line.strip()[:-1]
            start = cursor
            cursor += 1
            while cursor < len(lines):
                candidate = lines[cursor]
                if (
                    candidate.strip()
                    and _indent(candidate) == 2
                    and re.fullmatch(r"[A-Za-z0-9_-]+:", candidate.strip())
                ):
                    break
                cursor += 1
            block = lines[start:cursor]
            condition = ""
            runs_on = ""
            job_permissions: dict[str, str] = {}
            index = 1
            while index < len(block):
                candidate = block[index]
                stripped = candidate.strip()
                if _indent(candidate) == 4 and stripped.startswith("if:"):
                    condition, next_index = _scalar(block, index, 4)
                    index = next_index
                    continue
                if _indent(candidate) == 4 and stripped.startswith("runs-on:"):
                    runs_on = stripped.split(":", 1)[1].strip().strip("'\"")
                if _indent(candidate) == 4 and stripped.startswith("permissions:"):
                    job_permissions, next_index = _mapping(block, index, 4)
                    index = next_index
                    continue
                index += 1
            jobs.append(
                WorkflowJob(
                    key=key,
                    condition=condition,
                    runs_on=runs_on,
                    permissions=job_permissions,
                    steps=_step_models(block),
                    raw="\n".join(block),
                )
            )
            continue
        cursor += 1

    refs = tuple(
        match.group(1)
        for line in lines
        if (match := re.match(r"^\s*(?:-\s*)?uses:\s*([^\s#]+)", line))
    )
    return WorkflowModel(
        path=path,
        triggers=frozenset(triggers),
        permissions=permissions,
        jobs=tuple(jobs),
        action_refs=refs,
    )


def active_workflows() -> dict[str, WorkflowModel]:
    return {
        path.name: parse_workflow(path)
        for path in sorted(WORKFLOWS.glob("*.y*ml"))
        if not path.name.endswith(".disabled")
    }



def assert_active_build_delivery_boundaries(root: Path = ROOT) -> None:
    workflows = root / ".github" / "workflows"

    worker = parse_workflow(workflows / "worker_release_apk.yml")
    worker_job = next(job for job in worker.jobs if job.key == "build-release")
    assert "github.event.repository.private == true" in worker_job.condition
    assert "github.repository == 'sali97m-cpu/deutsch-bilarabi-worker'" in worker_job.condition
    assert "github.ref_name == 'main'" in worker_job.condition

    quality = parse_workflow(workflows / "quality_gate_ci.yml")
    quality_job = next(job for job in quality.jobs if job.key == "quality-gate-ci")
    setup_flutter = next(
        step for step in quality_job.steps
        if step.name == "Set up locked Flutter SDK"
    )
    assert setup_flutter.with_values.get("cache") == "false"
    assert setup_flutter.with_values.get("pub-cache") == "false"

def effective_permissions(
    workflow: WorkflowModel,
    job: WorkflowJob,
) -> dict[str, str]:
    return job.permissions if job.permissions else workflow.permissions


def manifest_root(path: Path) -> ET.Element:
    return ET.parse(path).getroot()


def manifest_permissions(path: Path) -> dict[str, str | None]:
    result: dict[str, str | None] = {}
    for node in manifest_root(path).findall("uses-permission"):
        name = node.attrib.get(ANDROID_NAME)
        if name:
            result[name] = node.attrib.get(TOOLS_NODE)
    return result


def extract_braced_block(source: str, marker: str) -> str:
    start = source.find(marker)
    if start < 0:
        raise AssertionError(f"Missing structural marker: {marker}")
    brace = source.find("{", start)
    if brace < 0:
        raise AssertionError(f"Missing block after marker: {marker}")
    depth = 0
    for index in range(brace, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[brace + 1:index]
    raise AssertionError(f"Unterminated block after marker: {marker}")
