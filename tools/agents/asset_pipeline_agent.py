#!/usr/bin/env python3
"""Prepare licensed vocabulary images and emit a deterministic asset manifest.

Only CC0 and Public Domain sources are accepted. Images are normalized to WebP
and repeatedly resized/re-encoded until they fit the configured byte ceiling.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

MAX_IMAGE_BYTES = 30 * 1024
ALLOWED_LICENSES = frozenset({"CC0", "PUBLIC DOMAIN"})
_WORD_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$")


class AssetPipelineError(RuntimeError):
    """Raised when an asset violates the licensing or media contract."""


@dataclass(frozen=True)
class SourceAsset:
    word_id: str
    source_path: Path
    license_name: str
    source_url: str
    attribution: str | None = None


@dataclass(frozen=True)
class PreparedAsset:
    word_id: str
    asset_path: str
    license_name: str
    source_url: str
    attribution: str | None
    bytes: int
    sha256: str


def normalize_license(value: str) -> str:
    normalized = " ".join(value.strip().replace("_", " ").split()).upper()
    aliases = {
        "CC0 1.0": "CC0",
        "CC ZERO": "CC0",
        "PUBLIC-DOMAIN": "PUBLIC DOMAIN",
        "PUBLIC DOMAIN MARK": "PUBLIC DOMAIN",
    }
    return aliases.get(normalized, normalized)


def validate_license(value: str) -> str:
    normalized = normalize_license(value)
    if normalized not in ALLOWED_LICENSES:
        raise AssetPipelineError(
            f"license {value!r} is not allowed; only CC0 or Public Domain are accepted"
        )
    return normalized


def _text(record: dict[str, Any], key: str) -> str:
    value = record.get(key)
    if not isinstance(value, str) or not value.strip():
        raise AssetPipelineError(f"asset field {key!r} must be a non-empty string")
    return value.strip()


def load_source_manifest(path: Path) -> list[SourceAsset]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise AssetPipelineError(f"cannot read source manifest {path}: {exc}") from exc
    if not isinstance(payload, dict) or not isinstance(payload.get("assets"), list):
        raise AssetPipelineError("source manifest must be an object with an assets array")

    base = path.parent
    assets: list[SourceAsset] = []
    seen: set[str] = set()
    for index, item in enumerate(payload["assets"]):
        if not isinstance(item, dict):
            raise AssetPipelineError(f"assets[{index}] must be an object")
        word_id = _text(item, "word_id")
        if not _WORD_ID_RE.fullmatch(word_id):
            raise AssetPipelineError(f"invalid word_id {word_id!r}")
        if word_id in seen:
            raise AssetPipelineError(f"duplicate word_id {word_id!r}")
        seen.add(word_id)

        license_name = validate_license(_text(item, "license"))
        source_url = _text(item, "source_url")
        relative = Path(_text(item, "file"))
        if relative.is_absolute() or ".." in relative.parts:
            raise AssetPipelineError(f"unsafe source path for {word_id!r}: {relative}")
        source_path = (base / relative).resolve()
        try:
            source_path.relative_to(base.resolve())
        except ValueError as exc:
            raise AssetPipelineError(
                f"source path escapes manifest directory for {word_id!r}: {relative}"
            ) from exc
        if not source_path.is_file():
            raise AssetPipelineError(f"source image is missing for {word_id!r}: {relative}")
        attribution = item.get("attribution")
        if attribution is not None and not isinstance(attribution, str):
            raise AssetPipelineError(f"attribution for {word_id!r} must be a string")
        assets.append(
            SourceAsset(
                word_id=word_id,
                source_path=source_path,
                license_name=license_name,
                source_url=source_url,
                attribution=attribution.strip() if isinstance(attribution, str) else None,
            )
        )
    return assets


def _pillow_image_module():
    try:
        from PIL import Image
    except ImportError as exc:
        raise AssetPipelineError(
            "Pillow is required to convert source images to WebP"
        ) from exc
    return Image


def _encode_webp(image: Any, destination: Path, *, quality: int) -> int:
    image.save(
        destination,
        format="WEBP",
        quality=quality,
        method=6,
        optimize=True,
    )
    return destination.stat().st_size


def compress_to_webp(
    source: Path,
    destination: Path,
    *,
    max_bytes: int = MAX_IMAGE_BYTES,
    max_dimension: int = 720,
) -> int:
    if max_bytes <= 0:
        raise AssetPipelineError("max_bytes must be positive")
    if max_dimension < 64:
        raise AssetPipelineError("max_dimension must be at least 64 pixels")

    Image = _pillow_image_module()
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        with Image.open(source) as original:
            image = original.convert("RGB")
            image.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
            with tempfile.TemporaryDirectory(prefix="asset-pipeline-") as tmp:
                candidate = Path(tmp) / "candidate.webp"
                current = image
                for scale_round in range(6):
                    for quality in (82, 74, 66, 58, 50, 42, 34, 28):
                        size = _encode_webp(current, candidate, quality=quality)
                        if size <= max_bytes:
                            os.replace(candidate, destination)
                            return size
                    next_width = max(64, int(current.width * 0.82))
                    next_height = max(64, int(current.height * 0.82))
                    if (next_width, next_height) == current.size:
                        break
                    current = current.resize(
                        (next_width, next_height),
                        Image.Resampling.LANCZOS,
                    )
                    if scale_round == 5:
                        break
    except AssetPipelineError:
        raise
    except Exception as exc:
        raise AssetPipelineError(f"cannot convert {source} to WebP: {exc}") from exc

    raise AssetPipelineError(
        f"cannot compress {source.name} below {max_bytes} bytes without violating minimum dimensions"
    )


def _digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(64 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def prepare_assets(
    source_manifest: Path,
    output_dir: Path,
    *,
    asset_prefix: str = "assets/media/images",
    max_bytes: int = MAX_IMAGE_BYTES,
) -> list[PreparedAsset]:
    prepared: list[PreparedAsset] = []
    for source in load_source_manifest(source_manifest):
        destination = output_dir / f"{source.word_id}.webp"
        size = compress_to_webp(source.source_path, destination, max_bytes=max_bytes)
        prepared.append(
            PreparedAsset(
                word_id=source.word_id,
                asset_path=f"{asset_prefix.rstrip('/')}/{destination.name}",
                license_name=source.license_name,
                source_url=source.source_url,
                attribution=source.attribution,
                bytes=size,
                sha256=_digest(destination),
            )
        )
    return prepared


def manifest_payload(assets: Iterable[PreparedAsset]) -> dict[str, Any]:
    ordered = sorted(assets, key=lambda item: item.word_id)
    return {
        "schema_version": 1,
        "max_image_bytes": MAX_IMAGE_BYTES,
        "assets": [
            {
                "word_id": item.word_id,
                "asset_path": item.asset_path,
                "license": item.license_name,
                "source_url": item.source_url,
                "attribution": item.attribution,
                "bytes": item.bytes,
                "sha256": item.sha256,
            }
            for item in ordered
        ],
    }


def write_manifest(path: Path, assets: Iterable[PreparedAsset]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(manifest_payload(assets), ensure_ascii=False, indent=2, sort_keys=True)
        + "\n",
        encoding="utf-8",
    )


def verify_output_manifest(path: Path, root: Path) -> list[str]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"manifest unreadable: {exc}"]
    assets = payload.get("assets") if isinstance(payload, dict) else None
    if not isinstance(assets, list):
        return ["manifest assets must be an array"]

    errors: list[str] = []
    if payload.get("schema_version") != 1:
        errors.append("manifest schema_version must be 1")
    if payload.get("max_image_bytes") != MAX_IMAGE_BYTES:
        errors.append(f"manifest max_image_bytes must be {MAX_IMAGE_BYTES}")
    seen: set[str] = set()
    for index, item in enumerate(assets):
        if not isinstance(item, dict):
            errors.append(f"assets[{index}] is not an object")
            continue
        try:
            word_id = _text(item, "word_id")
            if not _WORD_ID_RE.fullmatch(word_id):
                raise AssetPipelineError(f"invalid word_id {word_id!r}")
            raw_license = _text(item, "license")
            license_name = validate_license(raw_license)
            if raw_license != license_name:
                raise AssetPipelineError(
                    f"license for {word_id!r} must use canonical label {license_name!r}"
                )
            _text(item, "source_url")
            asset_path = Path(_text(item, "asset_path"))
        except AssetPipelineError as exc:
            errors.append(f"assets[{index}]: {exc}")
            continue
        if word_id in seen:
            errors.append(f"duplicate word_id: {word_id}")
        seen.add(word_id)
        if license_name not in ALLOWED_LICENSES:
            errors.append(f"invalid license for {word_id}")
        if asset_path.is_absolute() or ".." in asset_path.parts:
            errors.append(f"unsafe asset_path for {word_id}")
            continue
        image = root / asset_path
        if not image.is_file():
            errors.append(f"missing image for {word_id}: {asset_path.as_posix()}")
            continue
        if image.suffix.lower() != ".webp":
            errors.append(f"non-WebP image for {word_id}: {asset_path.as_posix()}")
        actual_size = image.stat().st_size
        if actual_size > MAX_IMAGE_BYTES:
            errors.append(f"oversized image for {word_id}: {actual_size} bytes")
        expected_size = item.get("bytes")
        if expected_size != actual_size:
            errors.append(f"size drift for {word_id}: manifest={expected_size} actual={actual_size}")
        expected_digest = item.get("sha256")
        if expected_digest != _digest(image):
            errors.append(f"sha256 drift for {word_id}")
    return errors


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-manifest", type=Path)
    parser.add_argument("--output-dir", type=Path, default=Path("assets/media/images"))
    parser.add_argument("--manifest", type=Path, default=Path("assets/media/assets_manifest.json"))
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--max-bytes", type=int, default=MAX_IMAGE_BYTES)
    parser.add_argument("--verify-only", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    root = args.repo_root.resolve()
    manifest = args.manifest if args.manifest.is_absolute() else root / args.manifest
    try:
        if args.verify_only:
            errors = verify_output_manifest(manifest, root)
            if errors:
                for error in errors:
                    print(f"ASSET PIPELINE: FAIL: {error}")
                return 2
            print("ASSET PIPELINE: PASS")
            return 0
        if args.source_manifest is None:
            raise AssetPipelineError("--source-manifest is required unless --verify-only is used")
        source_manifest = (
            args.source_manifest
            if args.source_manifest.is_absolute()
            else root / args.source_manifest
        )
        output_dir = args.output_dir if args.output_dir.is_absolute() else root / args.output_dir
        assets = prepare_assets(
            source_manifest,
            output_dir,
            max_bytes=args.max_bytes,
        )
        write_manifest(manifest, assets)
        print(f"ASSET PIPELINE: PASS ({len(assets)} asset(s))")
        return 0
    except AssetPipelineError as exc:
        print(f"ASSET PIPELINE: FAIL: {exc}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
