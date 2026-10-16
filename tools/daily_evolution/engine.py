import json
import os
import sys
import random
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Any, Set
import logging

try:
    from tools.generate_100_language_factory import LANGUAGES
except ImportError:
    # Dummy for tests without real modules available or isolated path
    LANGUAGES = [type("Lang", (), {"code": "ar", "name": "Arabic"})]

CYCLE_DAYS = [
    "A1", "A2", "B1", "B2", "C1", "C2", "compact_vectors", "maintenance"
]

@dataclass
class Task:
    task_id: str
    language_id: str
    track: str
    dependency: Optional[str]
    ownership: str
    status: str
    retries: int = 0

    def to_dict(self):
        return asdict(self)


class ScopeGuard:
    def __init__(self, global_allowed_paths: List[str]):
        self.global_allowed_paths = global_allowed_paths

    def verify(self, spec: Dict[str, Any]) -> bool:
        paths = spec.get("allowed_paths", [])
        for path in paths:
            is_allowed = False
            for allowed in self.global_allowed_paths:
                if path.startswith(allowed.replace('**', '')):
                    is_allowed = True
                    break
            if not is_allowed:
                return False

        forbidden = spec.get("forbidden_changes", [])
        for f in forbidden:
            if "CI" in f or "CD" in f or "credential" in f or "paid service" in f:
                return False

        return True


def generate_specification(task: Task) -> Dict[str, Any]:
    allowed_paths = []
    if task.track in ["compact_vectors", "maintenance"]:
        allowed_paths = ["tools/polyglot_v2/", "tools/automation/"]
    else:
        allowed_paths = [
            f"content/multilingual/sources/{task.language_id}.json",
            f"packs/{task.language_id}/"
        ]

    return {
        "task_id": task.task_id,
        "domain": "daily_evolution",
        "language_id": task.language_id,
        "allowed_paths": allowed_paths,
        "forbidden_changes": [],
        "rules": [
            "Never fabricate unavailable vocabulary or CEFR labels.",
            "Do not modify files outside allowed boundaries.",
            "No source-code auto-modification from this scheduler.",
            "No CI/CD changes, credentials or paid services."
        ]
    }


@dataclass
class DailyEvolutionEngine:
    state_file: Path = Path("tools/daily_evolution/state.json")
    sources_dir: Path = Path("content/multilingual/sources")
    max_parallel: int = 5
    max_retries: int = 3
    day_index: int = 0
    state: Dict[str, Any] = field(default_factory=dict)

    # Allowed paths across all daily tasks globally
    global_allowed_paths: List[str] = field(default_factory=lambda: [
        "content/multilingual/sources/",
        "packs/",
        "tools/polyglot_v2/",
        "tools/automation/"
    ])

    def load_state(self):
        if self.state_file.exists():
            try:
                self.state = json.loads(self.state_file.read_text())
                self.day_index = self.state.get("day_index", 0)
            except Exception:
                self.state = {}
        else:
            self.state = {}
            self.day_index = 0

    def save_state(self):
        self.state["day_index"] = self.day_index
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        # atomic save
        tmp = self.state_file.with_suffix(".tmp")
        tmp.write_text(json.dumps(self.state, indent=2))
        os.replace(tmp, self.state_file)

    def get_current_phase(self) -> str:
        return CYCLE_DAYS[self.day_index % len(CYCLE_DAYS)]

    def advance_day(self):
        self.day_index += 1
        self.save_state()

    def is_source_available(self, lang_code: str) -> bool:
        return (self.sources_dir / f"{lang_code}.json").exists()

    def generate_tasks(self) -> List[Task]:
        phase = self.get_current_phase()
        tasks = []

        task_matrix = self.state.setdefault("task_matrix", {})

        running_tasks = [t for t in task_matrix.values() if t["status"] == "RUNNING"]
        if len(running_tasks) >= self.max_parallel:
            return []

        guard = ScopeGuard(self.global_allowed_paths)

        # Rotate starting index for fairness based on day_index
        if len(LANGUAGES) > 0:
            start_idx = self.day_index % len(LANGUAGES)
            langs_rotated = list(LANGUAGES)[start_idx:] + list(LANGUAGES)[:start_idx]
        else:
            langs_rotated = []

        for lang in langs_rotated:
            if hasattr(lang, "code"):
                lang_code = lang.code
            else:
                lang_code = lang["code"]

            task_id = f"{phase}_{lang_code}_{self.day_index}"

            if task_id in task_matrix:
                continue # Duplicate prevention

            available = self.is_source_available(lang_code)
            status = "READY" if available else "BLOCKED"
            if phase in ["compact_vectors", "maintenance"]:
                 status = "READY" # independent of source

            task = Task(
                task_id=task_id,
                language_id=lang_code,
                track=phase,
                dependency=None,
                ownership="automation",
                status=status
            )

            spec = generate_specification(task)
            if not guard.verify(spec):
                task.status = "BLOCKED" # Fails scope guard

            task_matrix[task_id] = task.to_dict()
            tasks.append(task)

            if len([t for t in task_matrix.values() if t["status"] in ["READY", "RUNNING"]]) >= self.max_parallel:
                break

        self.save_state()
        return tasks

    def update_task_status(self, task_id: str, status: str):
        if task_id in self.state.get("task_matrix", {}):
            task = self.state["task_matrix"][task_id]

            if status == "FAILED":
                retries = task.get("retries", 0) + 1
                task["retries"] = retries
                if retries >= self.max_retries:
                    task["status"] = "FAILED"
                else:
                    task["status"] = "READY"
            else:
                task["status"] = status

            self.save_state()

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Daily Evolution Orchestrator")
    parser.add_argument("--trigger", action="store_true", help="Trigger task generation for the current day")
    parser.add_argument("--advance", action="store_true", help="Advance to the next day in the cycle")
    args = parser.parse_args()

    engine = DailyEvolutionEngine()
    engine.load_state()

    if args.advance:
        engine.advance_day()
        print(f"Advanced day. New phase: {engine.get_current_phase()}")

    if args.trigger:
        tasks = engine.generate_tasks()
        print(f"Generated {len(tasks)} new tasks.")
        for t in tasks:
            print(f"  - {t.task_id} [{t.status}]")
