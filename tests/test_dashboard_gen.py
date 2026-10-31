import json
from pathlib import Path

from tools.dashboard.generate_lexicon_dashboard import (
    collect_metrics,
    generate_dashboard,
    render_dashboard,
)

ROOT = Path(__file__).resolve().parents[1]
CORE_FIXTURE = ROOT / "tools" / "data_generator" / "fixtures" / "de_ar_a1_core.json"


def _write_dataset(path: Path, entries: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps({"schema_version": "1.0.0", "entries": entries}, ensure_ascii=False),
        encoding="utf-8",
    )


def _entry(*, key: str, pair: str, pos: str = "noun", audio: bool = False) -> dict:
    source, target = pair.split("->", 1)
    entry = {
        "canonical_key": key,
        "concept_id": key.rsplit(".", 1)[0],
        "pair_identity": {
            "id": pair,
            "source_language": source,
            "target_language": target,
        },
        "part_of_speech": pos,
    }
    if audio:
        entry["audioMarker"] = {"source": f"{source}-audio", "target": f"{target}-audio"}
    return entry


def test_dashboard_generation_against_existing_de_ar_a1_core_fixture(tmp_path):
    metrics = collect_metrics([CORE_FIXTURE])

    assert metrics["dataset_files"] == 1
    assert set(metrics["pairs"]) == {"ar->de", "de->ar"}
    for pair_metrics in metrics["pairs"].values():
        assert pair_metrics["total_concepts"] > 0
        assert pair_metrics["directional_records"] > 0
        assert sum(pair_metrics["pos_distribution"].values()) == pair_metrics["directional_records"]
        assert 0.0 <= pair_metrics["audio_marker_coverage_pct"] <= 100.0

    markdown = render_dashboard(metrics)
    assert "# Lexicon Coverage Dashboard" in markdown
    assert "Directional Records" in markdown
    assert "POS Distribution" in markdown
    assert "Audio Coverage" in markdown
    assert "ar→de" in markdown
    assert "de→ar" in markdown
    assert "█" in markdown or "░" in markdown

    output = tmp_path / "docs" / "dataset" / "LEXICON_COVERAGE.md"
    generated = generate_dashboard(dataset_paths=[CORE_FIXTURE], output_path=output)
    assert generated == metrics
    assert output.read_text(encoding="utf-8") == markdown


def test_empty_directories_generate_dashboard_without_crashing(tmp_path):
    output_dir = tmp_path / "output"
    fixtures_dir = tmp_path / "fixtures"
    output_dir.mkdir()
    fixtures_dir.mkdir()
    destination = tmp_path / "LEXICON_COVERAGE.md"

    metrics = generate_dashboard(
        dataset_paths=[output_dir, fixtures_dir],
        output_path=destination,
    )

    assert metrics == {"dataset_files": 0, "pairs": {}}
    text = destination.read_text(encoding="utf-8")
    assert "No dataset records found." in text


def test_updated_dataset_is_re_scanned_and_metrics_refresh(tmp_path):
    dataset = tmp_path / "output" / "de_ar_a1.json"
    destination = tmp_path / "LEXICON_COVERAGE.md"
    _write_dataset(dataset, [_entry(key="c1.forward", pair="de->ar", audio=False)])

    first = generate_dashboard(dataset_paths=[dataset.parent], output_path=destination)
    assert first["pairs"]["de->ar"]["directional_records"] == 1
    assert first["pairs"]["de->ar"]["audio_marker_coverage_pct"] == 0.0

    _write_dataset(
        dataset,
        [
            _entry(key="c1.forward", pair="de->ar", audio=False),
            _entry(key="c2.forward", pair="de->ar", pos="verb", audio=True),
        ],
    )

    second = generate_dashboard(dataset_paths=[dataset.parent], output_path=destination)
    pair = second["pairs"]["de->ar"]
    assert pair["directional_records"] == 2
    assert pair["total_concepts"] == 2
    assert pair["pos_distribution"] == {"noun": 1, "verb": 1}
    assert pair["audio_marker_coverage_pct"] == 50.0
    assert "50.0%" in destination.read_text(encoding="utf-8")
