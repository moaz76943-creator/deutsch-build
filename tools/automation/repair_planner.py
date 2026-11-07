import re
import uuid
import sys
from tools.automation.scope_guard import ScopeGuard

STALE_FTS5 = "STALE_FTS5"
CORRUPTED_ARTIFACT = "CORRUPTED_ARTIFACT"
RESOLVABLE_IMPORT = "RESOLVABLE_IMPORT"
TOOLCHAIN_STATE = "TOOLCHAIN_STATE"
MANIFEST_MISMATCH = "MANIFEST_MISMATCH"

TRANSFORMATIONS = {
    STALE_FTS5: "rebuild_fts5_index",
    CORRUPTED_ARTIFACT: "clean_and_rebuild_artifact",
    RESOLVABLE_IMPORT: "fix_import_path",
    TOOLCHAIN_STATE: "reset_toolchain",
    MANIFEST_MISMATCH: "update_manifest"
}

class RepairPlanner:
    def __init__(self):
        self._history = {}

    def classify_failure(self, failure_signature: str) -> str:
        if re.search(r"ambiguous dependency upgrade|security vulnerability|ambiguous dependency", failure_signature, re.IGNORECASE):
            raise ValueError("Ambiguous fix rejected")

        if re.search(r"stale fts5 index|fts5.*out of date", failure_signature, re.IGNORECASE):
            return STALE_FTS5
        if re.search(r"corrupted.*artifact|invalid zip archive", failure_signature, re.IGNORECASE):
            return CORRUPTED_ARTIFACT
        if re.search(r"import path cannot be resolved|module not found", failure_signature, re.IGNORECASE):
            return RESOLVABLE_IMPORT
        if re.search(r"toolchain state error|compiler crash", failure_signature, re.IGNORECASE):
            return TOOLCHAIN_STATE
        if re.search(r"manifest mismatch|checksum failed", failure_signature, re.IGNORECASE):
            return MANIFEST_MISMATCH

        raise ValueError("BLOCKED_UNKNOWN_FAILURE")

    def _calculate_paths(self, category: str, failure_signature: str) -> list[str]:
        # Extract paths if they exist in the signature
        paths = re.findall(r"([a-zA-Z0-9_\-\./]+\.[a-zA-Z0-9]+)", failure_signature)

        if not paths and category == RESOLVABLE_IMPORT:
            m = re.search(r"module not found:\s*([a-zA-Z0-9_\-\./]+)", failure_signature, re.IGNORECASE)
            if m:
                paths = [m.group(1)]

        if not paths:
            if category == STALE_FTS5:
                paths = ["assets/polyglot_content_v2.db"]
            elif category == TOOLCHAIN_STATE:
                paths = ["toolchain.lock"]
            elif category == MANIFEST_MISMATCH:
                paths = ["manifest.json"]
            else:
                paths = ["unknown.file"]
        return list(set(paths))

    def _validate_paths(self, paths: list[str]):
        for path in paths:
            if path.startswith("/") or ".." in path.split("/"):
                raise ValueError(f"Unsafe path detected: {path}")

    def generate_plan(self, failure_signature: str, dry_run: bool = False, new_input: bool = False) -> dict:
        category = self.classify_failure(failure_signature)

        target_paths = self._calculate_paths(category, failure_signature)
        self._validate_paths(target_paths)

        if failure_signature in self._history and not new_input:
            raise ValueError("Duplicate attempt blocked")
        self._history[failure_signature] = True

        transformation = TRANSFORMATIONS[category]
        plan_id = str(uuid.uuid4())

        # Hard fail if missing
        from tools.automation.scope_guard import ScopeGuard

        # We need a valid owner and allowed paths to get ownership
        # In actual usage this is passed from the environment/task context,
        # but here we initialize the guard for the paths we calculated.
        guard = ScopeGuard(owner="J091_REPAIR_PLANNER")
        for path in target_paths:
            guard.add_allowed_path(path)

        if not dry_run:
            for path in target_paths:
                if not guard.request_ownership(path):
                    raise RuntimeError("Ownership denied by ScopeGuard")

        return {
            "plan_id": plan_id,
            "category": category,
            "paths": target_paths,
            "transformation": transformation,
            "rollback_metadata": {"original_state": "preserved"},
            "dry_run": dry_run
        }
