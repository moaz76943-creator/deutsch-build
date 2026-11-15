from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TRIE = (ROOT / "lib/services/trie_search_engine.dart").read_text(encoding="utf-8")

# Increment 21 (PR #1172, merged as 565457eff): TrieSearchEngine declared
# `maxInputCodeUnits` and `maxIdCodeUnits` twice (once as bare finals and once
# constructor-bound finals), a hard Dart compile error blocking the app's
# search index build. Pin fail-closed: exactly one declaration each, bound by
# the constructor, with no bare duplicates.


def _class_body(source: str, class_name: str) -> str:
    match = re.search(rf"class {re.escape(class_name)}\s*\{{", source)
    assert match, f"class {class_name} not found"
    depth = 1
    i = match.end()
    start = i
    while depth:
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
        i += 1
    return source[start:i - 1]


def test_trie_bounds_declared_exactly_once():
    body = _class_body(TRIE, "TrieSearchEngine")
    for field in ("maxInputCodeUnits", "maxIdCodeUnits"):
        declarations = len(re.findall(rf"^\s*final int {field}\s*;", body, re.M))
        assert declarations == 1, (
            f"TrieSearchEngine declares '{field}' {declarations} times "
            "(externally verified fix: exactly one, constructor-bound)"
        )


def test_trie_bounds_are_constructor_bound():
    body = _class_body(TRIE, "TrieSearchEngine")
    assert "this.maxInputCodeUnits" in body
    assert "this.maxIdCodeUnits" in body


def test_trie_bounds_defaults_preserved():
    body = _class_body(TRIE, "TrieSearchEngine")
    assert re.search(r"this\.maxInputCodeUnits\s*=\s*\d+", body)
    assert re.search(r"this\.maxIdCodeUnits\s*=\s*\d+", body)


def test_trie_bounds_guard_code_paths_present():
    body = _class_body(TRIE, "TrieSearchEngine")
    assert "maxInputCodeUnits" in body
    assert "maxIdCodeUnits" in body
    assert "word.length > maxInputCodeUnits" in body
