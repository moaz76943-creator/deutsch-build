#!/usr/bin/env python3
"""Select a matching dispatch run from GitHub JSON without assuming a job started."""
import argparse
import json
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("sha")
parser.add_argument("--exclude", default="")
parser.add_argument("--active-only", action="store_true")
args = parser.parse_args()
excluded = set(args.exclude.split(","))
runs = json.load(sys.stdin)
active = {"queued", "in_progress", "requested", "pending", "waiting"}
candidates = [run for run in runs if run.get("headSha") == args.sha
              and str(run["databaseId"]) not in excluded
              and (not args.active_only or run.get("status") in active)]
if candidates:
    run = max(candidates, key=lambda entry: int(entry["databaseId"]))
    print("\t".join(str(run.get(name) or "-") for name in ("databaseId", "status", "conclusion", "url")))
