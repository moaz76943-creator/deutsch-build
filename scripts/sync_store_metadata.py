#!/usr/bin/env python3
"""Generate Fastlane Android metadata from the canonical Google Play CSV.

Generation is offline and deterministic. Google Play upload is opt-in and only
runs when --upload-to-play is supplied with an access token or service account.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
from pathlib import Path
import re
import sys
from typing import Iterable, NamedTuple
from urllib import error as urlerror
from urllib import parse as urlparse
from urllib import request as urlrequest

DEFAULT_CSV = Path("Google_Play_Console_86_Localizations_Only-1.csv")
DEFAULT_OUTPUT_ROOT = Path("fastlane/metadata/android")
DEFAULT_EXPECTED_LOCALES = 87
DEFAULT_API_BUNDLE = Path(".store-metadata/google_play_listings.json")
ANDROID_PUBLISHER_SCOPE = "https://www.googleapis.com/auth/androidpublisher"

PLAY_LIMITS = {
    "App Name": 30,
    "Short Description": 80,
    "Full Description": 4000,
}

HEADER_ALIASES = {
    "locale": ("Locale Code", "Locale", "Language Code", "BCP-47", "BCP47"),
    "title": ("App Name", "Title", "App Title"),
    "short": ("Short Description", "Short description"),
    "full": ("Full Description", "Full description"),
}

_LOCALE_RE = re.compile(r"^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$")


class MetadataValidationError(ValueError):
    """Raised when CSV metadata cannot be safely synchronized."""


class Listing(NamedTuple):
    locale: str
    title: str
    short_description: str
    full_description: str

    def api_payload(self) -> dict[str, str]:
        return {
            "language": self.locale,
            "title": self.title,
            "shortDescription": self.short_description,
            "fullDescription": self.full_description,
        }


def _normalize_header(value: str) -> str:
    return re.sub(r"[\s_-]+", " ", value.strip().casefold())


def _resolve_headers(fieldnames: list[str] | None) -> dict[str, str]:
    if not fieldnames:
        raise MetadataValidationError("CSV has no header row.")

    normalized = {_normalize_header(name): name for name in fieldnames if name}
    resolved: dict[str, str] = {}
    missing: list[str] = []

    for key, aliases in HEADER_ALIASES.items():
        match = next(
            (
                normalized[_normalize_header(alias)]
                for alias in aliases
                if _normalize_header(alias) in normalized
            ),
            None,
        )
        if match is None:
            missing.append(aliases[0])
        else:
            resolved[key] = match

    if missing:
        raise MetadataValidationError(
            "CSV is missing required column(s): " + ", ".join(missing)
        )
    return resolved


def _validate_locale(locale: str, row_number: int) -> None:
    if not locale:
        raise MetadataValidationError(f"Row {row_number}: Locale Code is empty.")
    if not _LOCALE_RE.fullmatch(locale):
        raise MetadataValidationError(
            f"Row {row_number}: invalid Locale Code {locale!r}; "
            "expected a BCP-47 style tag."
        )


def _validate_text(label: str, value: str, locale: str, row_number: int) -> None:
    if not value or not value.strip():
        raise MetadataValidationError(
            f"Row {row_number} ({locale}): {label} is empty."
        )
    if "\x00" in value:
        raise MetadataValidationError(
            f"Row {row_number} ({locale}): {label} contains a NUL character."
        )

    limit = PLAY_LIMITS[label]
    length = len(value)
    if length > limit:
        raise MetadataValidationError(
            f"Row {row_number} ({locale}): {label} has {length} characters; "
            f"Google Play limit is {limit}."
        )


def load_listings(
    csv_path: Path,
    *,
    expected_locales: int = DEFAULT_EXPECTED_LOCALES,
) -> list[Listing]:
    if not csv_path.is_file():
        raise MetadataValidationError(f"CSV file not found: {csv_path}")

    listings: list[Listing] = []
    seen: set[str] = set()

    with csv_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        headers = _resolve_headers(reader.fieldnames)

        for row_number, row in enumerate(reader, start=2):
            values = [value for value in row.values() if value is not None]
            if not values or all(value == "" for value in values):
                continue

            locale = (row.get(headers["locale"]) or "").strip()
            title = row.get(headers["title"])
            short_description = row.get(headers["short"])
            full_description = row.get(headers["full"])

            title = "" if title is None else title
            short_description = "" if short_description is None else short_description
            full_description = "" if full_description is None else full_description

            _validate_locale(locale, row_number)
            if locale in seen:
                raise MetadataValidationError(
                    f"Row {row_number}: Duplicate locale code {locale!r}."
                )
            seen.add(locale)

            _validate_text("App Name", title, locale, row_number)
            _validate_text("Short Description", short_description, locale, row_number)
            _validate_text("Full Description", full_description, locale, row_number)

            listings.append(
                Listing(
                    locale=locale,
                    title=title,
                    short_description=short_description,
                    full_description=full_description,
                )
            )

    if len(listings) != expected_locales:
        raise MetadataValidationError(
            f"Expected {expected_locales} unique locale rows, found {len(listings)}."
        )
    return listings


def _atomic_write_text(path: Path, value: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="") as handle:
        handle.write(value)
    tmp.replace(path)


def generate_fastlane_metadata(
    listings: Iterable[Listing],
    output_root: Path,
) -> None:
    for listing in listings:
        locale_root = output_root / listing.locale
        _atomic_write_text(locale_root / "title.txt", listing.title)
        _atomic_write_text(
            locale_root / "short_description.txt",
            listing.short_description,
        )
        _atomic_write_text(
            locale_root / "full_description.txt",
            listing.full_description,
        )


def write_api_bundle(listings: Iterable[Listing], path: Path) -> None:
    payload = {
        "schema_version": 1,
        "resource": "androidpublisher.edits.listings",
        "listings": [listing.api_payload() for listing in listings],
    }
    _atomic_write_text(
        path,
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=False) + "\n",
    )


def _request_json(
    method: str,
    url: str,
    *,
    access_token: str,
    payload: dict[str, str] | None = None,
) -> dict:
    data = None
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json",
    }

    if payload is not None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        headers["Content-Type"] = "application/json; charset=utf-8"
    elif method in {"POST", "PUT", "PATCH"}:
        data = b"{}"
        headers["Content-Type"] = "application/json; charset=utf-8"

    req = urlrequest.Request(url, data=data, headers=headers, method=method)

    try:
        with urlrequest.urlopen(req, timeout=60) as response:
            body = response.read().decode("utf-8")
    except urlerror.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(
            f"Google Play API request failed ({exc.code}) for {url}: {body}"
        ) from exc
    except urlerror.URLError as exc:
        raise RuntimeError(
            f"Google Play API request failed for {url}: {exc}"
        ) from exc

    return json.loads(body) if body else {}


def access_token_from_service_account_json(service_account_json: str) -> str:
    """Mint an Android Publisher OAuth token without persisting the JSON key."""
    try:
        from google.auth.transport.requests import Request as GoogleAuthRequest
        from google.oauth2 import service_account
    except ImportError as exc:
        raise MetadataValidationError(
            "Service-account upload requires google-auth[requests]. "
            "Install it only for the manual upload job."
        ) from exc

    try:
        info = json.loads(service_account_json)
        credentials = service_account.Credentials.from_service_account_info(
            info,
            scopes=[ANDROID_PUBLISHER_SCOPE],
        )
        credentials.refresh(GoogleAuthRequest())
    except Exception as exc:
        raise MetadataValidationError(
            f"Could not authenticate Google Play service account: {exc}"
        ) from exc

    token = credentials.token or ""
    if not token:
        raise MetadataValidationError(
            "Google service-account authentication returned an empty access token."
        )
    return token


def upload_to_google_play(
    listings: Iterable[Listing],
    *,
    package_name: str,
    access_token: str,
) -> str:
    if not package_name:
        raise MetadataValidationError(
            "Google Play upload requires GOOGLE_PLAY_PACKAGE_NAME or --package-name."
        )
    if not access_token:
        raise MetadataValidationError(
            "Google Play upload requires GOOGLE_PLAY_ACCESS_TOKEN or "
            "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON."
        )

    package = urlparse.quote(package_name, safe="")
    base = (
        "https://androidpublisher.googleapis.com/androidpublisher/v3/"
        f"applications/{package}"
    )

    edit = _request_json(
        "POST",
        f"{base}/edits",
        access_token=access_token,
        payload={},
    )
    edit_id = str(edit.get("id") or "")
    if not edit_id:
        raise RuntimeError("Google Play API did not return an edit id.")

    for listing in listings:
        language = urlparse.quote(listing.locale, safe="")
        _request_json(
            "PUT",
            f"{base}/edits/{urlparse.quote(edit_id, safe='')}/listings/{language}",
            access_token=access_token,
            payload=listing.api_payload(),
        )

    _request_json(
        "POST",
        f"{base}/edits/{urlparse.quote(edit_id, safe='')}:commit",
        access_token=access_token,
        payload={},
    )
    return edit_id


def sync_store_metadata(
    *,
    csv_path: Path,
    output_root: Path,
    expected_locales: int = DEFAULT_EXPECTED_LOCALES,
    api_bundle_path: Path | None = None,
) -> list[Listing]:
    listings = load_listings(
        csv_path,
        expected_locales=expected_locales,
    )
    generate_fastlane_metadata(listings, output_root)
    if api_bundle_path is not None:
        write_api_bundle(listings, api_bundle_path)
    return listings


def _parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate Google Play store metadata and generate Fastlane-compatible "
            "Android locale directories."
        )
    )
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_ROOT)
    parser.add_argument(
        "--expected-locales",
        type=int,
        default=DEFAULT_EXPECTED_LOCALES,
        help="Fail unless exactly this many unique locale rows are present.",
    )
    parser.add_argument(
        "--api-bundle",
        type=Path,
        default=DEFAULT_API_BUNDLE,
        help="Write a Google Play API-ready JSON bundle.",
    )
    parser.add_argument(
        "--upload-to-play",
        action="store_true",
        help=(
            "Create an Android Publisher edit, update every listing, "
            "then commit it."
        ),
    )
    parser.add_argument(
        "--package-name",
        default=os.environ.get("GOOGLE_PLAY_PACKAGE_NAME", ""),
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(sys.argv[1:] if argv is None else argv)

    if args.expected_locales < 1:
        print("--expected-locales must be >= 1", file=sys.stderr)
        return 2

    try:
        listings = sync_store_metadata(
            csv_path=args.csv,
            output_root=args.output,
            expected_locales=args.expected_locales,
            api_bundle_path=args.api_bundle,
        )
        print(
            f"Validated and generated {len(listings)} locale(s) "
            f"under {args.output}."
        )

        if args.upload_to_play:
            access_token = os.environ.get("GOOGLE_PLAY_ACCESS_TOKEN", "")
            if not access_token:
                service_account_json = os.environ.get(
                    "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON",
                    "",
                )
                if service_account_json:
                    access_token = access_token_from_service_account_json(
                        service_account_json
                    )

            edit_id = upload_to_google_play(
                listings,
                package_name=args.package_name,
                access_token=access_token,
            )
            print(
                f"Committed Google Play metadata edit {edit_id} "
                f"for {len(listings)} locale(s)."
            )
    except (MetadataValidationError, RuntimeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
