import json
import os
from pathlib import Path
from typing import Dict, Any, List, Optional
try:
    from tools.automation.scope_guard import ScopeGuard
except ImportError:
    from scope_guard import ScopeGuard

class RepairPlannerError(Exception):
    pass

class RepairPlanner:
    SUPPORTED_FAILURES = {
        "STALE_FTS5_INDEX": "stale generated FTS5 index",
        "CORRUPTED_BUILD_ARTIFACT": "corrupted disposable build artifact",
        "UNIQUELY_RESOLVABLE_IMPORT": "uniquely resolvable import path",
        "TEMPORARY_TOOLCHAIN_STATE": "temporary toolchain state",
        "KNOWN_MANIFEST_MISMATCH": "known manifest mismatch"
    }

    def __init__(self):
        self.guard = ScopeGuard(__file__)
        self.guard.add_allowed_path("tools/automation/**")

    def classify_failure(self, failure_signature: str) -> Optional[str]:
        for code, description in self.SUPPORTED_FAILURES.items():
            if description.lower() in failure_signature.lower():
                return code
        return None

    def plan_repair(self, failure_signature: str, target_path: str, previous_attempts: int = 0, is_new_condition: bool = False) -> Dict[str, Any]:
        failure_code = self.classify_failure(failure_signature)
        if not failure_code:
            return {"status": "BLOCKED_UNKNOWN_FAILURE"}

        if not self.guard.request_ownership(target_path):
            return {"status": "BLOCKED_UNSAFE_PATH"}

        if "dependency upgrade" in failure_signature.lower() or "security" in failure_signature.lower():
             return {"status": "BLOCKED_AMBIGUOUS_REPAIR"}

        if previous_attempts > 0 and not is_new_condition:
            return {"status": "BLOCKED_REPEATED_LOOP"}

        action_map = {
            "STALE_FTS5_INDEX": "REBUILD_FTS5",
            "CORRUPTED_BUILD_ARTIFACT": "CLEAN_BUILD",
            "UNIQUELY_RESOLVABLE_IMPORT": "FIX_IMPORT",
            "TEMPORARY_TOOLCHAIN_STATE": "RESET_TOOLCHAIN",
            "KNOWN_MANIFEST_MISMATCH": "SYNC_MANIFEST"
        }

        plan = {
            "status": "READY",
            "failure_code": failure_code,
            "target_path": target_path,
            "action": action_map.get(failure_code, "repair"),
            "expected_changed_paths": [target_path],
            "rollback_metadata": {"original_state": "unknown"}
        }
        return plan
