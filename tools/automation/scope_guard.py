from typing import List, Union
from pathlib import Path
import os

class ScopeGuard:
    def __init__(self, owner: str):
        self.owner = owner
        self.allowed_paths: List[str] = []

    def add_allowed_path(self, path: str):
        self.allowed_paths.append(path)

    def request_ownership(self, target_path: Union[str, Path]) -> bool:
        path_str = str(target_path)
        for allowed in self.allowed_paths:
            if allowed.endswith("**"):
                prefix = allowed[:-2]
                if path_str.startswith(prefix):
                    return True
            elif path_str == allowed or path_str.startswith(allowed + "/"):
                return True
        return False

    def check(self, target_path: Union[str, Path]) -> bool:
        return self.request_ownership(target_path)
