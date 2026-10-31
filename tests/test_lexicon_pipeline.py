import json
from pathlib import Path

import pytest

from tools.data_generator.run_data_pipeline import (
    PipelineCoverageError,
    PipelineValidationError,
    run_pipeline,
)


def _entry(*, source="de", target="ar", key="concept.forward", audio=True):
    item = {
        "canonical_key": key,
        "cefr_level": "A1",
        "source_text": "Hallo" if source == "de" else "مرحبا",
        "target_text": "مرحبا" if target == "ar" else "Hallo",
        "pair_identity": {
            "id": f"{source}->{target}",
            "source_language": source,
            "target_language": target,
            "source_direction": "rtl" if source == "ar" else "ltr",
            "target_direction": "rtl" if target == "ar" else "ltr",
        },
        "phonetics": {"source": "x", "target": "y"},
        "part_of_speech": "phrase",
        "bidirectional_flag": True,
        "rtl_flag": source == "ar" or target == "ar",
        "concept_id": "concept",
    }
    if audio:
        item["audioMarker"] = {"source": f"{source}-VOICE", "target": f"{target}-VOICE"}
    return item


def _dataset(*, audio=True):
    return {
        "schema_version": "1.0.0",
        "entries": [
            _entry(source="de", target="ar", key="concept.forward", audio=audio),
            _entry(source="ar", target="de", key="concept.reverse", audio=audio),
        ],
    }


def _write(path: Path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")


def test_full_pipeline_validates_core_and_skeletons_and_writes_health_report(tmp_path):
    core = tmp_path / "fixtures" / "de_ar_a1_core.json"
    skeleton_dir = tmp_path / "output" / "matrix_skeletons"
    report = tmp_path / "reports" / "data_health_summary.json"
    schema = tmp_path / "schema.json"
    _write(core, _dataset(audio=True))
    _write(skeleton_dir / "de-en.json", _dataset(audio=False))
    _write(schema, {"schema_version": "test-stub"})

    result = run_pipeline(
        core_path=core,
        skeleton_dir=skeleton_dir,
        schema_path=schema,
        report_path=report,
    )

    assert result["status"] == "healthy"
    assert result["schemaValidation"]["validFiles"] == 2
    assert result["crossLanguageExpansion"]["skeletonFiles"] == 1
    assert result["audioCoverage"]["totalRecords"] == 4
    assert result["audioCoverage"]["coveredRecords"] == 2
    assert result["audioCoverage"]["coveragePercent"] == 50.0
    assert json.loads(report.read_text(encoding="utf-8")) == result


def test_invalid_schema_or_malformed_record_triggers_pipeline_failure_and_unhealthy_report(tmp_path):
    core = tmp_path / "fixtures" / "de_ar_a1_core.json"
    report = tmp_path / "reports" / "data_health_summary.json"
    schema = tmp_path / "schema.json"
    invalid = _dataset()
    del invalid["entries"][0]["pair_identity"]
    _write(core, invalid)
    _write(schema, {"schema_version": "test-stub"})

    with pytest.raises(PipelineValidationError):
        run_pipeline(
            core_path=core,
            skeleton_dir=tmp_path / "missing-skeletons",
            schema_path=schema,
            report_path=report,
        )

    written = json.loads(report.read_text(encoding="utf-8"))
    assert written["status"] == "unhealthy"
    assert written["schemaValidation"]["invalidFiles"] == 1
    assert written["errors"]


def test_fail_under_coverage_triggers_when_audio_coverage_is_below_threshold(tmp_path):
    core = tmp_path / "fixtures" / "de_ar_a1_core.json"
    report = tmp_path / "reports" / "data_health_summary.json"
    schema = tmp_path / "schema.json"
    _write(core, _dataset(audio=False))
    _write(schema, {"schema_version": "test-stub"})

    with pytest.raises(PipelineCoverageError):
        run_pipeline(
            core_path=core,
            skeleton_dir=tmp_path / "matrix_skeletons",
            schema_path=schema,
            report_path=report,
            fail_under_coverage=1.0,
        )

    written = json.loads(report.read_text(encoding="utf-8"))
    assert written["audioCoverage"]["coveragePercent"] == 0.0
    assert written["status"] == "unhealthy"


def test_matrix_skeleton_rejects_reverse_records_with_different_concept_ids(tmp_path):
    core = tmp_path / "fixtures" / "de_ar_a1_core.json"
    skeleton_dir = tmp_path / "output" / "matrix_skeletons"
    report = tmp_path / "reports" / "data_health_summary.json"
    schema = tmp_path / "schema.json"
    skeleton = _dataset(audio=False)
    skeleton["entries"][1]["concept_id"] = "different-concept"
    _write(core, _dataset())
    _write(skeleton_dir / "de-ar.json", skeleton)
    _write(schema, {"schema_version": "test-stub"})

    with pytest.raises(PipelineValidationError):
        run_pipeline(
            core_path=core,
            skeleton_dir=skeleton_dir,
            schema_path=schema,
            report_path=report,
        )

    written = json.loads(report.read_text(encoding="utf-8"))
    assert written["schemaValidation"]["invalidFiles"] == 1
    assert "concept_id" in written["errors"][0]["error"]


def test_cli_validate_all_summary_and_coverage_threshold_use_default_paths(tmp_path, monkeypatch, capsys):
    from tools.data_generator import run_data_pipeline as pipeline

    core = tmp_path / "fixtures" / "de_ar_a1_core.json"
    skeleton_dir = tmp_path / "output" / "matrix_skeletons"
    report = tmp_path / "reports" / "data_health_summary.json"
    schema = tmp_path / "schema.json"
    _write(core, _dataset(audio=True))
    _write(schema, {"schema_version": "test-stub"})

    monkeypatch.setattr(pipeline, "DEFAULT_CORE_PATH", core)
    monkeypatch.setattr(pipeline, "DEFAULT_SKELETON_DIR", skeleton_dir)
    monkeypatch.setattr(pipeline, "DEFAULT_REPORT_PATH", report)
    monkeypatch.setattr(pipeline, "DEFAULT_SCHEMA_PATH", schema)

    assert pipeline.main(["--validate-all", "--summary", "--fail-under-coverage", "100"]) == 0
    output = json.loads(capsys.readouterr().out)
    assert output["status"] == "healthy"
    assert output["audioCoveragePercent"] == 100.0
    assert report.exists()
