#!/usr/bin/env python3
"""Generate deterministic Google Play screenshot assets from captured app screens.

The script never stretches screenshots. It uses high-quality Lanczos resampling,
centers the fitted image on a canvas, and writes 24-bit RGB PNGs (no alpha), so
text stays lossless. Outputs are staged under fastlane/metadata/android/images.
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Sequence

DEFAULT_INPUT_DIR = Path("store_assets/screenshots")
DEFAULT_OUTPUT_DIR = Path("fastlane/metadata/android/images")
SUPPORTED_INPUT_SUFFIXES = frozenset({".png", ".jpg", ".jpeg", ".webp"})


class StoreAssetError(RuntimeError):
    """Raised when store screenshot generation cannot satisfy its contract."""


@dataclass(frozen=True)
class Target:
    key: str
    directory: str
    width: int
    height: int


TARGETS: tuple[Target, ...] = (
    Target("phone", "phoneScreenshots", 1080, 2400),
    Target("tablet7", "sevenInchScreenshots", 1200, 1920),
    Target("tablet10", "tenInchScreenshots", 1600, 2560),
)


def _pillow_image_module():
    try:
        from PIL import Image, ImageOps
    except ImportError as exc:
        raise StoreAssetError(
            "Pillow is required to generate store screenshots; install it with 'python3 -m pip install Pillow'."
        ) from exc
    return Image, ImageOps


def _safe_stem(path: Path) -> str:
    stem = re.sub(r"[^A-Za-z0-9._-]+", "-", path.stem).strip("-._")
    return stem or "screenshot"


def discover_sources(input_dir: Path) -> list[Path]:
    if not input_dir.is_dir():
        raise StoreAssetError(f"input directory does not exist: {input_dir}")
    files = [
        path
        for path in input_dir.iterdir()
        if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_SUFFIXES
    ]
    files.sort(key=lambda path: path.name.casefold())
    if not files:
        raise StoreAssetError(
            f"no screenshots found in {input_dir}; supported: PNG, JPG/JPEG, WebP"
        )
    return files


def _rgb_background(image: Any) -> tuple[int, int, int]:
    rgb = image.convert("RGB")
    corners = (
        rgb.getpixel((0, 0)),
        rgb.getpixel((max(0, rgb.width - 1), 0)),
        rgb.getpixel((0, max(0, rgb.height - 1))),
        rgb.getpixel((max(0, rgb.width - 1), max(0, rgb.height - 1))),
    )
    return tuple(
        sum(pixel[channel] for pixel in corners) // len(corners)
        for channel in range(3)
    )


def render_png(source: Path, destination: Path, target: Target) -> None:
    Image, ImageOps = _pillow_image_module()
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        with Image.open(source) as original:
            original.load()
            rgb = original.convert("RGB")
            fitted = ImageOps.contain(
                rgb,
                (target.width, target.height),
                method=Image.Resampling.LANCZOS,
            )
            canvas = Image.new(
                "RGB",
                (target.width, target.height),
                _rgb_background(rgb),
            )
            left = (target.width - fitted.width) // 2
            top = (target.height - fitted.height) // 2
            canvas.paste(fitted, (left, top))
            canvas.save(
                destination,
                format="PNG",
                optimize=True,
                compress_level=6,
            )
    except StoreAssetError:
        raise
    except Exception as exc:
        raise StoreAssetError(f"cannot render {source}: {exc}") from exc


def generate_assets(input_dir: Path, output_dir: Path) -> list[Path]:
    sources = discover_sources(input_dir)
    outputs: list[Path] = []
    for target in TARGETS:
        target_dir = output_dir / target.directory
        for index, source in enumerate(sources, start=1):
            destination = target_dir / f"{index:02d}_{_safe_stem(source)}.png"
            render_png(source, destination, target)
            outputs.append(destination)
    return outputs


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=DEFAULT_INPUT_DIR,
        help=f"Directory containing base screenshots (default: {DEFAULT_INPUT_DIR})",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"Fastlane staging directory (default: {DEFAULT_OUTPUT_DIR})",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        outputs = generate_assets(args.input_dir, args.output_dir)
    except StoreAssetError as exc:
        print(f"STORE ASSETS: FAIL: {exc}")
        return 2
    print(f"STORE ASSETS: PASS ({len(outputs)} PNG file(s))")
    for output in outputs:
        print(output.as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
