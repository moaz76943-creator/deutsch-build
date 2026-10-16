import os
import posixpath
from pathlib import Path
from typing import List, Optional, Union

try:
    from tools.agent_contract.guard import TaskLedger
except ImportError:
    TaskLedger = None


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
        self.ledger_path = (
            Path(ledger_path)
            if ledger_path is not None
            else self.repo_root / "docs" / "project-record" / "task_ledger.json"
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
        if TaskLedger is None or not self.ledger_path.exists():
            return False
        try:
            ledger = TaskLedger(str(self.ledger_path))
            return ledger.check_overlap(self.owner, [rel_path])
        except Exception:
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
