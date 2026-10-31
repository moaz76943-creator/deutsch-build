from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
LIB = ROOT / "lib"

ENTRYPOINT = LIB / ("main" + ".dart")
GENERATED_ROOT = LIB / "data" / "generated"
CONTENT_FACADE = LIB / "data" / "content_a1.dart"
VERB_FACADE = LIB / "data" / "verb_conjugations.dart"
VERB_INDEX = LIB / "services" / "verb_index.dart"
GERMAN_CONTENT_PACK = LIB / "language" / "german" / "german_content_pack.dart"
CONTENT_COMPILER = ROOT / "tool" / "content_compiler.py"
LOCAL_GATE = ROOT / "scripts" / "local_quality_gate.sh"

_DIRECTIVE_RE = re.compile(
    r"""^\s*(?:import|export|part)\s+([^;]+);""",
    re.MULTILINE,
)
_URI_RE = re.compile(r"""['"]([^'"]+)['"]""")


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _repo_dart_dependency(source: Path, uri: str) -> Path | None:
    if uri.startswith("package:deutsch_bilarabi/"):
        candidate = (LIB / uri.removeprefix("package:deutsch_bilarabi/")).resolve()
    elif uri.startswith("dart:") or uri.startswith("package:"):
        return None
    else:
        candidate = (source.parent / uri).resolve()

    try:
        candidate.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise AssertionError(
            f"dependency escapes repository: {source} -> {uri}"
        ) from exc
    return candidate if candidate.suffix == ".dart" else None


def _production_closure() -> set[Path]:
    pending = [ENTRYPOINT.resolve()]
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


def _inside(path: Path, root: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except ValueError:
        return False


def test_task9_production_closure_excludes_generated_corpus_and_facades():
    closure = _production_closure()
    forbidden = {
        CONTENT_FACADE.resolve(),
        VERB_FACADE.resolve(),
    }
    offenders = sorted(
        str(path.relative_to(ROOT))
        for path in closure
        if path in forbidden or _inside(path, GENERATED_ROOT)
    )
    assert offenders == []


def test_verb_index_requires_explicit_rows_and_has_no_embedded_corpus_import():
    source = _read(VERB_INDEX)

    assert "import '../models/verb_conjugation.dart';" in source
    assert "VerbIndex.fromRows({" in source

    for legacy_token in (
        "../data/verb_conjugations.dart",
        "verbConjugations",
        "v126VerbExpansion",
        "v126AdditionalVerbExpansion",
        "v128VerbExpansion",
        "_embeddedRows",
    ):
        assert legacy_token not in source


def test_german_content_pack_remains_metadata_only_and_fail_closed():
    source = _read(GERMAN_CONTENT_PACK)

    assert "List<ContentItem> get items => const <ContentItem>[];" in source
    assert "VerbIndex.fromRows(" in source
    assert "rows: const <VerbConjugation>[]," in source
    assert "data/content_a1.dart" not in source
    assert "data/verb_conjugations.dart" not in source
    assert "data/generated/" not in source


def test_canonical_content_pipeline_and_parity_remain_intact():
    compiler = _read(CONTENT_COMPILER)
    gate = _read(LOCAL_GATE)

    for token in (
        'CONTENT_JSON = ROOT / "content" / "content_items.json"',
        'VERB_JSON = ROOT / "content" / "verb_conjugations.json"',
        "def compile_to(",
        "def parity(",
        '"content_items_generated.dart"',
        '"verb_conjugations_generated.dart"',
    ):
        assert token in compiler

    assert 'compile --output-dir "$TMP_DIR/generated"' in gate
    assert 'parity --output-dir "$TMP_DIR/generated"' in gate
    assert GENERATED_ROOT.exists()
    assert (GENERATED_ROOT / "content_items_generated.dart").exists()
    assert (GENERATED_ROOT / "verb_conjugations_generated.dart").exists()


def test_task9_surfaces_respect_file_ceiling():
    for path in (
        VERB_INDEX,
        GERMAN_CONTENT_PACK,
        CONTENT_FACADE,
        VERB_FACADE,
    ):
        assert len(_read(path).splitlines()) <= 1000, path
