from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from PIL import Image

from tools.agents.asset_pipeline_agent import (
    MAX_IMAGE_BYTES,
    AssetPipelineError,
    compress_to_webp,
    load_source_manifest,
    prepare_assets,
    verify_output_manifest,
    write_manifest,
)


class AssetPipelineAgentTest(unittest.TestCase):
    def setUp(self) -> None:
        self.root = Path(tempfile.mkdtemp(prefix="asset-pipeline-test-"))
        self.sources = self.root / "sources"
        self.sources.mkdir(parents=True)

    def _image(self, name: str = "source.png", *, size: tuple[int, int] = (720, 720)) -> Path:
        path = self.sources / name
        image = Image.new("RGB", size)
        pixels = image.load()
        for y in range(size[1]):
            for x in range(size[0]):
                pixels[x, y] = ((x * 13 + y * 7) % 256, (x * 5) % 256, (y * 11) % 256)
        image.save(path, format="PNG")
        return path

    def _manifest(self, *, license_name: str = "CC0", word_id: str = "haus") -> Path:
        image = self._image()
        path = self.sources / "source_manifest.json"
        path.write_text(
            json.dumps(
                {
                    "assets": [
                        {
                            "word_id": word_id,
                            "file": image.name,
                            "license": license_name,
                            "source_url": "https://example.invalid/source",
                        }
                    ]
                }
            ),
            encoding="utf-8",
        )
        return path

    def test_rejects_non_public_license(self) -> None:
        manifest = self._manifest(license_name="CC BY 4.0")
        with self.assertRaises(AssetPipelineError):
            load_source_manifest(manifest)

    def test_accepts_public_domain_alias(self) -> None:
        manifest = self._manifest(license_name="Public Domain")
        assets = load_source_manifest(manifest)
        self.assertEqual("PUBLIC DOMAIN", assets[0].license_name)

    def test_compresses_to_webp_below_strict_size_cap(self) -> None:
        source = self._image(size=(900, 900))
        destination = self.root / "out" / "image.webp"
        size = compress_to_webp(source, destination)
        self.assertLessEqual(size, MAX_IMAGE_BYTES)
        self.assertEqual(b"RIFF", destination.read_bytes()[:4])
        self.assertEqual(b"WEBP", destination.read_bytes()[8:12])

    def test_pipeline_links_word_id_and_emits_hash(self) -> None:
        manifest = self._manifest(word_id="brot")
        output = self.root / "assets" / "media" / "images"
        prepared = prepare_assets(manifest, output)
        self.assertEqual("brot", prepared[0].word_id)
        self.assertEqual("assets/media/images/brot.webp", prepared[0].asset_path)
        self.assertEqual(64, len(prepared[0].sha256))

    def test_verify_rejects_oversized_or_drifted_asset(self) -> None:
        manifest = self._manifest(word_id="wasser")
        output = self.root / "assets" / "media" / "images"
        prepared = prepare_assets(manifest, output)
        output_manifest = self.root / "assets" / "media" / "assets_manifest.json"
        write_manifest(output_manifest, prepared)
        image_path = output / "wasser.webp"
        image_path.write_bytes(image_path.read_bytes() + b"x" * MAX_IMAGE_BYTES)
        errors = verify_output_manifest(output_manifest, self.root)
        self.assertTrue(any("oversized image" in error for error in errors))
        self.assertTrue(any("sha256 drift" in error for error in errors))

    def test_duplicate_word_id_fails_closed(self) -> None:
        image = self._image()
        path = self.sources / "source_manifest.json"
        record = {
            "word_id": "dup",
            "file": image.name,
            "license": "CC0",
            "source_url": "https://example.invalid/source",
        }
        path.write_text(json.dumps({"assets": [record, record]}), encoding="utf-8")
        with self.assertRaises(AssetPipelineError):
            load_source_manifest(path)


if __name__ == "__main__":
    unittest.main()
