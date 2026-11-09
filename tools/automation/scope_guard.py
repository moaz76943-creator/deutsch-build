import os
import json
import time
import posixpath
from pathlib import Path
from typing import List, Optional, Union

try:
    from tools.agent_contract.guard import paths_overlap, LOCK_TTL_SECONDS
except ImportError:
    paths_overlap = None # type: ignore


class ScopeGuard:
    """Fail-closed canonical path and ledger ownership verifier for tools/automation."""

    def __init__(
        self,
        owner: str,
        repo_root: Optional[Union[str, Path]] = None,
        ledger_path: Optional[Union[str, Path]] = None,
    ):
        self.owner = owner
        self.repo_root = (
            Path(repo_root).resolve()
            if repo_root is not None
            else Path(__file__).resolve().parents[2]
        )
        state_root = os.environ.get("XDG_STATE_HOME")
        default_root = Path(state_root) if state_root else Path.home() / ".local" / "state"
        self.ledger_path = (
            Path(ledger_path) if ledger_path is not None
            else default_root / "deutsch-agent-contract" / "task_ledger.json"
        )
        self.allowed_paths: List[str] = []

    def add_allowed_path(self, path: str) -> None:
        self.allowed_paths.append(path)

    @staticmethod
    def _canonicalize_relative_posix(raw_path: str) -> Optional[str]:
        if not raw_path or "\x00" in raw_path or "\\" in raw_path or ":" in raw_path:
            return None
        if raw_path.startswith("/") or "//" in raw_path:
            return None
        parts = raw_path.split("/")
        if any(p in ("", ".", "..") for p in parts):
            return None
        normalized = posixpath.normpath(raw_path)
        if normalized != raw_path or normalized in (".", "..") or normalized.startswith("../"):
            return None
        return normalized

    def _resolves_within_subtree(self, rel_path: str, allowed_prefix: str) -> bool:
        try:
            root_real = self.repo_root.resolve()
            prefix_clean = allowed_prefix.rstrip("/")
            subtree_real = (root_real / prefix_clean).resolve()
            target_real = (root_real / rel_path).resolve()
            return (
                target_real.is_relative_to(root_real)
                and target_real.is_relative_to(subtree_real)
            )
        except Exception:
            return False

    def _conflicts_with_ledger(self, rel_path: str) -> bool:
        """Read-only check of an existing claim; never mistake access for a lock."""
        if paths_overlap is None or not self.ledger_path.is_file():
            return True
        try:
            with self.ledger_path.open("r", encoding="utf-8") as source:
                ledger = json.load(source)
            if not isinstance(ledger, dict):
                return True
            own = ledger.get(self.owner)
            if not isinstance(own, dict) or own.get("state") not in ("CLAIM", "ACTIVE"):
                return True
            stamp = own.get("timestamp")
            if (not isinstance(stamp, (int, float)) or
                    time.time() - stamp > LOCK_TTL_SECONDS):
                return True
            paths = own.get("paths")
            if not isinstance(paths, list) or not paths or any(not isinstance(p, str) for p in paths):
                return True
            if not any(paths_overlap(rel_path, path) for path in paths):
                return True
            for owner, entry in ledger.items():
                if owner == "_metadata":
                    continue
                if not isinstance(entry, dict) or entry.get("state") not in (
                    "CLAIM", "ACTIVE", "BLOCKED", "COMPLETE", "CANCELLED"
                ):
                    return True
                claimed = entry.get("paths", [])
                if not isinstance(claimed, list) or any(not isinstance(p, str) for p in claimed):
                    return True
                if (owner != self.owner and entry["state"] in ("CLAIM", "ACTIVE") and
                        any(paths_overlap(rel_path, path) for path in claimed)):
                    return True
            return False
        except (OSError, ValueError, TypeError, AttributeError):
            return True

    def request_ownership(self, target_path: Union[str, Path]) -> bool:
        if not isinstance(target_path, (str, Path)):
            return False
        raw = str(target_path)
        rel = self._canonicalize_relative_posix(raw)
        if rel is None:
            return False

        matched = False
        for allowed in self.allowed_paths:
            if allowed.endswith("/**"):
                prefix = allowed[:-3]
                if (rel == prefix or rel.startswith(prefix + "/")) and self._resolves_within_subtree(
                    rel, prefix
                ):
                    matched = True
                    break
            elif allowed.endswith("**"):
                prefix = allowed[:-2].rstrip("/")
                if (rel == prefix or rel.startswith(prefix + "/")) and self._resolves_within_subtree(
                    rel, prefix
                ):
                    matched = True
                    break
            else:
                clean = allowed.rstrip("/")
                if (rel == clean or rel.startswith(clean + "/")) and self._resolves_within_subtree(
                    rel, clean
                ):
                    matched = True
                    break

        if not matched:
            return False
        if self._conflicts_with_ledger(rel):
            return False
        return True

    def check(self, target_path: Union[str, Path]) -> bool:
        return self.request_ownership(target_path)
