import base64
import gzip
import hashlib
import json
import sqlite3
import subprocess
from pathlib import Path

import pytest

from tools.language_pack_factory import (
    BUNDLE_FORMAT,
    PackFactoryValidationError,
    build_catalog,
    main,
    validate_source_document,
)



def _signing_key(tmp_path: Path) -> Path:
    path = tmp_path / "manifest-test-key.pem"
    generated = subprocess.run(
        ["openssl", "genpkey", "-algorithm", "ED25519", "-out", str(path)],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert generated.returncode == 0, generated.stderr.decode(errors="replace")
    return path

def _source(*, direction="ltr"):
    text = "Deutsch lernen" if direction == "ltr" else "تعلم الألمانية"
    title = "Basic rule" if direction == "ltr" else "قاعدة أساسية"
    surface = "Haus" if direction == "ltr" else "بيت"
    return {
        "schemaVersion": 1,
        "pack": {
            "id": "sample-core",
            "languageCode": "de" if direction == "ltr" else "ar",
            "displayName": "Sample Core",
            "version": "1.0.0",
            "contractVersion": "1.0.0",
            "textDirection": direction,
        },
        "requiredLocalizationKeys": ["app.title", "grammar.basic"],
        "localization": {
            "app.title": {"text": text, "direction": direction},
            "grammar.basic": {"text": title, "direction": direction},
        },
        "lexicon": [
            {
                "id": "home.house",
                "surface": surface,
                "partOfSpeech": "noun",
                "direction": direction,
                "fields": {"cefr": "A1"},
            }
        ],
        "grammar": [
            {
                "id": "grammar.basic",
                "titleKey": "grammar.basic",
                "tree": {
                    "type": "sequence",
                    "children": [
                        {"type": "token", "value": surface},
                        {"type": "reference", "value": "home.house"},
                    ],
                },
            }
        ],
    }


def _write_source(path: Path, payload):
    path.write_text(
        json.dumps(payload, ensure_ascii=False),
        encoding="utf-8",
    )


def test_factory_builds_runtime_bundle_sqlite_checksum_and_catalog(tmp_path):
    source = tmp_path / "source.json"
    _write_source(source, _source())

    compiled, catalog_path = build_catalog(
        [source],
        tmp_path / "out",
        base_url="https://packs.example.test/v1",
        manifest_revision=9,
        signing_key_path=_signing_key(tmp_path),
        key_id="test-rfc8032",
    )
    pack = compiled.single if hasattr(compiled, "single") else compiled[0]
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    descriptor = catalog["packs"][0]

    assert catalog["schemaVersion"] == 2
    assert catalog["algorithm"] == "Ed25519"
    assert catalog["keyId"] == "test-rfc8032"
    assert len(base64.b64decode(catalog["signature"])) == 64
    assert descriptor == pack.descriptor
    assert descriptor["bundleFormat"] == BUNDLE_FORMAT
    assert descriptor["archiveUrl"].startswith("https://")
    assert descriptor["sha256"] == hashlib.sha256(
        pack.archive_path.read_bytes()
    ).hexdigest()
    assert descriptor["archiveSizeBytes"] == pack.archive_path.stat().st_size

    envelope = json.loads(
        gzip.decompress(pack.archive_path.read_bytes()).decode("utf-8")
    )
    assert envelope["packId"] == "sample-core"
    assert envelope["version"] == "1.0.0"
    assert envelope["contractVersion"] == "1.0.0"
    files = {
        item["path"]: base64.b64decode(item["contentBase64"])
        for item in envelope["files"]
    }
    assert set(files) == {
        "content/content.json",
        "content/content.sqlite",
        "metadata/pack.json",
    }
    assert descriptor["installedSizeBytes"] == sum(map(len, files.values()))

    pack_metadata = json.loads(files["metadata/pack.json"].decode("utf-8"))
    assert pack_metadata["contentRows"] == 1
    assert pack_metadata["verbRows"] == 0

    sqlite_path = tmp_path / "runtime.sqlite"
    sqlite_path.write_bytes(files["content/content.sqlite"])
    connection = sqlite3.connect(sqlite_path)
    try:
        assert connection.execute(
            "SELECT value FROM metadata WHERE key='packId'"
        ).fetchone() == ("sample-core",)
        assert connection.execute(
            "SELECT value FROM metadata WHERE key='contentRows'"
        ).fetchone() == ("1",)
        assert connection.execute(
            "SELECT value FROM metadata WHERE key='verbRows'"
        ).fetchone() == ("0",)
        assert connection.execute(
            "SELECT surface, direction FROM lexicon WHERE id='home.house'"
        ).fetchone() == ("Haus", "ltr")
        assert connection.execute(
            "SELECT COUNT(*) FROM grammar"
        ).fetchone() == (1,)
    finally:
        connection.close()


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (
            lambda payload: payload["localization"].pop("app.title"),
            "missing required keys",
        ),
        (
            lambda payload: payload["localization"]["app.title"].update(
                {"text": "__TEMPLATE_TEXT__:de:app.title"}
            ),
            "fallback",
        ),
        (
            lambda payload: payload["grammar"][0]["tree"].update(
                {
                    "type": "token",
                    "value": "Haus",
                    "children": [{"type": "token", "value": "x"}],
                }
            ),
            "leaf nodes",
        ),
        (
            lambda payload: payload["localization"]["app.title"].update(
                {"direction": "rtl"}
            ),
            "textDirection",
        ),
    ],
)
def test_localization_linter_fails_closed(mutate, message):
    payload = _source()
    mutate(payload)

    with pytest.raises(PackFactoryValidationError, match=message):
        validate_source_document(payload)


def test_rtl_language_pack_passes_without_german_specific_schema():
    validated = validate_source_document(_source(direction="rtl"))

    assert validated["pack"]["languageCode"] == "ar"
    assert validated["pack"]["textDirection"] == "rtl"
    assert validated["lexicon"][0]["direction"] == "rtl"


def test_cli_validate_only_and_multi_pack_catalog(tmp_path, capsys):
    first = tmp_path / "de.json"
    second = tmp_path / "ar.json"
    _write_source(first, _source(direction="ltr"))
    arabic = _source(direction="rtl")
    arabic["pack"]["id"] = "sample-ar-core"
    _write_source(second, arabic)

    assert main(
        [
            "--input",
            str(first),
            "--input",
            str(second),
            "--output-dir",
            str(tmp_path / "out"),
            "--base-url",
            "https://packs.example.test/v1",
            "--manifest-revision",
            "10",
            "--signing-key",
            str(_signing_key(tmp_path)),
            "--key-id",
            "test-rfc8032",
        ]
    ) == 0

    result = json.loads(capsys.readouterr().out)
    assert result["status"] == "built"
    catalog = json.loads(
        (tmp_path / "out" / "catalog.json").read_text(encoding="utf-8")
    )
    assert catalog["manifestRevision"] == 10
    assert [pack["id"] for pack in catalog["packs"]] == [
        "sample-ar-core",
        "sample-core",
    ]
