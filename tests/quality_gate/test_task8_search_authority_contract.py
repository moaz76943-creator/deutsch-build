from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
LIB = ROOT / "lib"

AUTHORITY_DOC = ROOT / "docs" / "SEARCH_AUTHORITY_MAP.md"
PRODUCTION_ROOT = LIB / ("main" + ".dart")
CANONICAL_ADAPTER = (
    LIB
    / "features"
    / "lexicon_search"
    / "data"
    / "offline_lexicon_search_repository.dart"
)
SQLITE_REPOSITORY = LIB / "features" / "srs" / "corpus_sqlite_repository.dart"
LEGACY_SEARCH_INDEX = LIB / "services" / "search_index.dart"
LEGACY_SEARCH_ADAPTER = (
    LIB / "features" / "search" / "data" / "lexicon_search_repository.dart"
)

_DIRECTIVE_RE = re.compile(
    r"""^\s*(?:import|export|part)\s+([^;]+);""",
    re.MULTILINE,
)
_URI_RE = re.compile(r"""['"]([^'"]+)['"]""")


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _repo_dart_dependency(source: Path, uri: str) -> Path | None:
    if uri.startswith("package:deutsch_bilarabi/"):
        relative = uri.removeprefix("package:deutsch_bilarabi/")
        candidate = (LIB / relative).resolve()
    elif uri.startswith("dart:") or uri.startswith("package:"):
        return None
    else:
        candidate = (source.parent / uri).resolve()

    try:
        candidate.relative_to(ROOT.resolve())
    except ValueError:
        raise AssertionError(f"dependency escapes repository: {source} -> {uri}")
    return candidate if candidate.suffix == ".dart" else None


def _production_closure() -> set[Path]:
    pending = [PRODUCTION_ROOT.resolve()]
    visited: set[Path] = set()

    while pending:
        current = pending.pop()
        if current in visited:
            continue
        assert current.exists(), f"missing production dependency: {current}"
        visited.add(current)
        source = _read(current)
        for directive in _DIRECTIVE_RE.findall(source):
            for uri in _URI_RE.findall(directive):
                dependency = _repo_dart_dependency(current, uri)
                if dependency is not None and dependency not in visited:
                    pending.append(dependency)

    return visited


def _method_slice(source: str, start: str, end: str) -> str:
    start_index = source.index(start)
    end_index = source.index(end, start_index)
    return source[start_index:end_index]


def test_task8_authority_map_declares_one_production_search_owner():
    assert AUTHORITY_DOC.exists(), "TASK 8 authority map is required"
    text = _read(AUTHORITY_DOC)

    for token in (
        "TASK 8 — Search Authority Consolidation",
        "main@11ece8cecd0dd7b4f085de8339849e567e8d3bfc",
        "CANONICAL PRODUCTION SEARCH AUTHORITY",
        "IndexedSrsCorpusRepository.searchContent",
        "OfflineLexiconSearchRepository",
        "LEGACY_COMPATIBILITY",
        "NOT PRODUCTION AUTHORITY",
    ):
        assert token in text


def test_production_closure_cannot_reach_resident_search_index():
    closure = _production_closure()

    assert LEGACY_SEARCH_INDEX.resolve() not in closure
    assert LEGACY_SEARCH_ADAPTER.resolve() not in closure

    for path in closure:
        source = _read(path)
        assert "services/search_index.dart" not in source, path
        assert "SearchIndex<" not in source, path


def test_canonical_adapter_delegates_to_bounded_sqlite_without_corpus_mirror():
    source = _read(CANONICAL_ADAPTER)

    assert "IndexedSrsCorpusRepository" in source
    assert "_corpusRepository.searchContent(" in source
    assert "services/search_index.dart" not in source
    assert "SearchIndex<" not in source
    assert "Iterable<LearningContent>" not in source
    assert "Map<String, LearningContent>" not in source


def test_sqlite_search_contract_is_resource_bounded_and_fail_closed():
    source = _read(SQLITE_REPOSITORY)
    method = _method_slice(
        source,
        "Future<List<SrsCorpusItem>> searchContent({",
        "Future<List<SrsVerbRow>> fetchVerbRows({",
    )

    assert "limit.clamp(1, 200)" in method
    assert "value.length <= 200" in method
    assert ".take(6)" in method
    assert "LIMIT ?" in method
    assert "const <String>{'A1', 'A2', 'B1', 'B2'}" in method
    assert "const <String>{'der', 'die', 'das'}" in method


def test_language_specific_legacy_match_labels_never_enter_production_closure():
    closure = _production_closure()
    production_text = "\n".join(_read(path) for path in sorted(closure))

    # These are legacy SearchIndex match-type string literals. Match the
    # literal symbols themselves rather than identifier substrings so valid
    # presentation helpers such as _containsArabic(...) do not collide.
    for legacy_match_type in (
        "exactGerman",
        "exactArabic",
        "containsGerman",
        "containsArabic",
        "tokenGerman",
        "tokenArabic",
    ):
        quoted_symbol = re.compile(
            rf"""['"]{re.escape(legacy_match_type)}['"]"""
        )
        assert quoted_symbol.search(production_text) is None


def test_task8_contract_and_authority_surfaces_respect_file_ceiling():
    for path in (
        CANONICAL_ADAPTER,
        SQLITE_REPOSITORY,
        LEGACY_SEARCH_INDEX,
        LEGACY_SEARCH_ADAPTER,
    ):
        assert len(_read(path).splitlines()) <= 1000, path
