#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKER_REPO="${BUILD_WORKER_REPO:-${1:-}}"
WORKER_BRANCH="${BUILD_WORKER_BRANCH:-main}"
SOURCE_BRANCH="${BUILD_WORKER_SOURCE_BRANCH:-main}"

log() { printf '[worker-export] %s\n' "$*"; }
fatal() { printf '[worker-export][ERROR] %s\n' "$*" >&2; exit 1; }

[[ -n "$WORKER_REPO" ]] || fatal "Usage: BUILD_WORKER_REPO=owner/repo ./scripts/export_build_worker.sh"
command -v git >/dev/null 2>&1 || fatal "git is required"
command -v gh >/dev/null 2>&1 || fatal "GitHub CLI (gh) is required"

cd "$ROOT"
git diff --quiet || fatal "Working tree has uncommitted changes"
git diff --cached --quiet || fatal "Index has staged but uncommitted changes"
gh auth status >/dev/null 2>&1 || fatal "gh is not authenticated"
gh auth setup-git >/dev/null 2>&1 || fatal "Unable to configure git authentication through gh"

log "Fetching origin/$SOURCE_BRANCH"
git fetch origin "$SOURCE_BRANCH" --quiet
SOURCE_SHA="$(git rev-parse "origin/$SOURCE_BRANCH")"
LOCAL_SHA="$(git rev-parse HEAD)"
[[ "$LOCAL_SHA" == "$SOURCE_SHA" ]] || fatal "Local HEAD ($LOCAL_SHA) must match origin/$SOURCE_BRANCH ($SOURCE_SHA) before export"

gh repo view "$WORKER_REPO" >/dev/null 2>&1 || fatal "Worker repository is not accessible: $WORKER_REPO"
WORKER_URL="https://github.com/$WORKER_REPO.git"

if git ls-remote --exit-code "$WORKER_URL" "refs/heads/$WORKER_BRANCH" >/dev/null 2>&1; then
  git fetch "$WORKER_URL" "$WORKER_BRANCH" --quiet
  WORKER_SHA="$(git rev-parse FETCH_HEAD)"
  git merge-base --is-ancestor "$WORKER_SHA" "$SOURCE_SHA" ||
    fatal "Worker branch has diverged. Refusing to force-push over $WORKER_REPO:$WORKER_BRANCH"
fi

ENABLED="$(gh variable get BUILD_WORKER_ENABLED --repo "$WORKER_REPO" 2>/dev/null || true)"
[[ "$ENABLED" == "true" ]] || fatal "Set BUILD_WORKER_ENABLED=true in the worker repository before export"

log "Pushing verified source SHA $SOURCE_SHA to $WORKER_REPO:$WORKER_BRANCH"
git push "$WORKER_URL" "$SOURCE_SHA:refs/heads/$WORKER_BRANCH"

printf '\nWorker push complete. Automatic signed APK workflow is now eligible to run.\n'
printf 'Stable release asset URL: https://github.com/%s/releases/download/worker-latest/app-release.apk\n' "$WORKER_REPO"
printf 'Authenticated Termux download: gh release download worker-latest --repo %s --pattern app-release.apk --clobber\n' "$WORKER_REPO"
