#!/usr/bin/env bash
# Validate aapt dump permissions from standard input. No extra Android privilege.
set -Eeuo pipefail
mode="${1:-}"
if [[ $# -ne 1 || ( "$mode" != release && "$mode" != debug ) ]]; then
  printf '[PERMISSION_ERROR] expected debug or release mode\n' >&2
  exit 16
fi
if [[ "$mode" == debug ]]; then
  cat >/dev/null
  exit 0
fi
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[[:space:]]*uses-permission(-sdk-[[:digit:]]+)?[[:space:]]*: ]]; then
    printf '[PERMISSION_ERROR] Release APK requests Android permissions\n' >&2
    exit 16
  fi
done
printf '[PERMISSION_OK] Release APK requests no Android permissions\n'
