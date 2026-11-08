#!/usr/bin/env bash
set -Eeuo pipefail

# Safe Non-Destructive Branch Inventory (SEC-003 Remediation)
ROOT="${HOME}/projects/.polyglot_merge_workspace"

for spec in 'deutsch-build:staging/v2-full-platform' 'offline-packs-store:main'; do
  repo="${spec%%:*}"
  target="${spec#*:}"
  path="${ROOT}/${repo}"

  [ -d "$path/.git" ] || continue
  git -C "$path" fetch origin --prune 2>/dev/null || true

  while IFS= read -r branch; do
    [ "$branch" = 'origin/HEAD' ] && continue
    [ "$branch" = "origin/$target" ] && continue
    if git -C "$path" merge-base --is-ancestor "$branch" "origin/$target" 2>/dev/null; then
      printf '[SAFE-AUDIT] Merged branch: %s\n' "$branch"
    else
      count="$(git -C "$path" rev-list --count "origin/$target..$branch" 2>/dev/null || echo "0")"
      printf '[REVIEW REQUIRED] %s: %s commits\n' "$branch" "$count"
    fi
  done < <(git -C "$path" for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null || true)
done
printf '[SAFE-AUDIT] Safe sweep inventory complete. Zero destructive operations executed.\n'
