#!/usr/bin/env python3
"""QA audit: manifest/pack integrity + content non-emptiness.

Room 3 (Independent QA) regression harness. Verifies, with real evidence:

  1. Every language entry in content-factory/manifest.json references a
     pack file that exists, whose SHA-256 and size match the manifest.
  2. Pack payloads are valid gzip+JSON and internally consistent:
     a pack that claims N terms must not ship zero terms.

Exit codes: 0 = PASS, 1 = FAIL. Each check prints EVIDENCE lines.

Usage: python3 tools/qa_audit/qa_audit_manifest_packs.py [--allow-empty-packs]
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MANIFEST = os.path.join(ROOT, "content-factory", "manifest.json")
PACK_DIR = os.path.join(ROOT, "content-factory", "packs")


def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--allow-empty-packs", action="store_true",
                    help="Treat empty packs as W evidence, not hard failure")
    args = ap.parse_args()

    manifest = json.load(open(MANIFEST, encoding="utf-8"))
    langs = manifest.get("languages", [])
    print(f"EVIDENCE manifest languages={len(langs)} "
          f"store_version={manifest.get('store_version')} "
          f"release_status={manifest.get('release_status')}")

    ok = bad = missing = 0
    failures: list[str] = []
    for L in langs:
        fn = L.get("pack_file")
        full = os.path.join(PACK_DIR, fn or "")
        if not fn or not os.path.exists(full):
            missing += 1
            failures.append(f"MISSING pack file for {L.get('code')}: {fn}")
            continue
        digest = sha256_file(full)
        if digest != L.get("sha256"):
            bad += 1
            failures.append(f"SHA MISMATCH {fn}")
            continue
        if os.path.getsize(full) != L.get("size_bytes"):
            bad += 1
            failures.append(f"SIZE MISMATCH {fn}")
            continue
        ok += 1

    print(f"EVIDENCE sha/size ok={ok} bad={bad} missing={missing}")
    if bad or missing:
        for f in failures[:10]:
            print("FAIL", f)
        return 1

    # Content non-emptiness: decompress every pack and inspect payload.
    fake_terms: list[tuple[str, int]] = []
    empty_payload = 0
    unreadable = 0
    for L in langs:
        full = os.path.join(PACK_DIR, L["pack_file"])
        try:
            payload = json.loads(gzip.decompress(open(full, "rb").read()))
        except Exception as exc:  # noqa: BLE001
            unreadable += 1
            failures.append(f"UNREADABLE {L['pack_file']}: {exc}")
            continue
        claimed_terms = payload.get("terms_count", 0)
        present_terms = sum(len(v) for v in payload.values() if isinstance(v, list))
        if claimed_terms and present_terms == 0:
            fake_terms.append((L["pack_file"], claimed_terms))
        if present_terms == 0:
            empty_payload += 1

    print(f"EVIDENCE packs unreadable={unreadable} "
          f"empty_payload={empty_payload} "
          f"fake_terms_count={len(fake_terms)}")
    if unreadable:
        for f in failures[:10]:
            print("FAIL", f)
        return 1
    if fake_terms and not args.allow_empty_packs:
        print("FAIL pack metadata claims terms_count>0 while shipping zero terms")
        for fn, n in fake_terms[:10]:
            print(f"FAIL {fn} claims {n} terms, ships 0")
        return 1
    if empty_payload:
        print(f"W {empty_payload}/{len(langs)} packs ship zero content entries "
              f"(consistent with manifest release_status="
              f"{manifest.get('release_status')}); re-run with default settings "
              f"only after real content admission")
        return 0

    # Orphan packs on disk: present in packs/ but never referenced by the
    # manifest. Unanchored by SHA, so any silent content change is invisible.
    referenced = {L["pack_file"] for L in langs}
    orphans = sorted(f for f in os.listdir(PACK_DIR) if f not in referenced)
    print(f"EVIDENCE orphan packs (on disk, not in manifest): {len(orphans)}")
    fake_orphans = 0
    for fn in orphans:
        try:
            payload = json.loads(gzip.decompress(open(os.path.join(PACK_DIR, fn), "rb").read()))
        except Exception:  # noqa: BLE001
            continue
        claimed = payload.get("terms_count", 0)
        present = sum(len(v) for v in payload.values() if isinstance(v, list))
        if claimed and present == 0:
            fake_orphans += 1
            print(f"FAIL orphan {fn} claims terms_count={claimed}, ships 0 terms")
    if fake_orphans and not args.allow_empty_packs:
        print(f"FAIL {fake_orphans} orphan packs carry false terms_count metadata")
        return 1

    # Content depth: domain labels are navigation, not vocabulary.
    vocab_items = 0
    label_only = 0
    for L in langs:
        payload = json.loads(gzip.decompress(open(os.path.join(PACK_DIR, L["pack_file"]), "rb").read()))
        doms = payload.get("domains")
        if isinstance(doms, list) and doms and all(
            isinstance(d, dict) and not any(
                isinstance(v, list) and v for v in d.values()) for d in doms):
            label_only += 1
        elif isinstance(doms, dict):
            vocab_items += sum(
                len(v) for v in doms.values() if isinstance(v, list))
    print(f"EVIDENCE vocabulary items across manifest packs: {vocab_items}")
    if vocab_items == 0:
        print(f"W {label_only}/{len(langs)} packs contain only domain labels "
              f"(zero vocabulary). Registry/manifest do not claim production "
              f"content (release_status={manifest.get('release_status')}), "
              f"so this is W evidence, not a false claim — but it IS blocking "
              f"for any release that advertises working content.")
    else:
        print("PASS manifest packs carry real vocabulary content")
    return 0


if __name__ == "__main__":
    sys.exit(main())
