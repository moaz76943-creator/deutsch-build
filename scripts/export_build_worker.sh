#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKER_OWNER="${BUILD_WORKER_OWNER:-sali97m-cpu}"
WORKER_NAME="${BUILD_WORKER_NAME:-deutsch-bilarabi-worker}"
WORKER_REPO="${BUILD_WORKER_REPO:-$WORKER_OWNER/$WORKER_NAME}"
WORKER_BRANCH="${BUILD_WORKER_BRANCH:-main}"
SOURCE_BRANCH="${BUILD_WORKER_SOURCE_BRANCH:-main}"
GRADLE_PROPS="${GRADLE_USER_HOME:-$HOME/.gradle}/gradle.properties"

log() { printf '[worker-export] %s\n' "$*"; }
fatal() { printf '[worker-export][ERROR] %s\n' "$*" >&2; exit 1; }

read_gradle_property() {
  local key="$1"
  [[ -f "$GRADLE_PROPS" ]] || return 0
  sed -nE "s/^${key}=(.*)$/\\1/p" "$GRADLE_PROPS" | tail -n 1
}

resolve_keystore_path() {
  local candidate="$1"
  [[ -n "$candidate" ]] || return 1
  if [[ -f "$candidate" ]]; then
    (cd "$(dirname "$candidate")" && printf '%s/%s\n' "$PWD" "$(basename "$candidate")")
    return 0
  fi
  for base in "$ROOT/android/app" "$ROOT/android" "$ROOT"; do
    if [[ -f "$base/$candidate" ]]; then
      (cd "$base/$(dirname "$candidate")" && printf '%s/%s\n' "$PWD" "$(basename "$candidate")")
      return 0
    fi
  done
  return 1
}

ensure_auth() {
  command -v gh >/dev/null 2>&1 || fatal "GitHub CLI (gh) is required"
  command -v git >/dev/null 2>&1 || fatal "git is required"
  command -v base64 >/dev/null 2>&1 || fatal "base64 is required"

  if [[ -n "${GITHUB_PAT:-}" && -z "${GH_TOKEN:-}" ]]; then
    export GH_TOKEN="$GITHUB_PAT"
  fi

  gh auth status >/dev/null 2>&1 || fatal "Authenticate first with 'gh auth login' or export GH_TOKEN/GITHUB_PAT."
  gh auth setup-git >/dev/null 2>&1 || fatal "Unable to configure git authentication through gh"
}

ensure_worker_repo() {
  if gh repo view "$WORKER_REPO" >/dev/null 2>&1; then
    log "Worker repository exists: $WORKER_REPO"
  else
    log "Creating private worker repository: $WORKER_REPO"
    gh repo create "$WORKER_REPO" \
      --private \
      --description "Private build worker mirror for Deutsch بالعربي" \
      --disable-issues \
      --disable-wiki
  fi

  gh api --method PUT "repos/$WORKER_REPO/actions/permissions" \
    -F enabled=true \
    -f allowed_actions=all >/dev/null
  gh api --method PUT "repos/$WORKER_REPO/actions/permissions/workflow" \
    -f default_workflow_permissions=write \
    -F can_approve_pull_request_reviews=false >/dev/null

  gh variable set BUILD_WORKER_ENABLED \
    --repo "$WORKER_REPO" \
    --body "true"
}

sync_signing_secrets() {
  local store_file store_password key_alias key_password resolved_store

  store_file="${RELEASE_KEYSTORE_PATH:-${RELEASE_STORE_FILE:-$(read_gradle_property releaseStoreFile)}}"
  store_password="${RELEASE_STORE_PASSWORD:-$(read_gradle_property releaseStorePassword)}"
  key_alias="${RELEASE_KEY_ALIAS:-$(read_gradle_property releaseKeyAlias)}"
  key_password="${RELEASE_KEY_PASSWORD:-$(read_gradle_property releaseKeyPassword)}"

  resolved_store="$(resolve_keystore_path "$store_file" || true)"
  [[ -n "$resolved_store" ]] || fatal "Release keystore was not found. Set RELEASE_KEYSTORE_PATH or configure releaseStoreFile in $GRADLE_PROPS."
  [[ -n "$store_password" ]] || fatal "Missing RELEASE_STORE_PASSWORD/releaseStorePassword."
  [[ -n "$key_alias" ]] || fatal "Missing RELEASE_KEY_ALIAS/releaseKeyAlias."
  [[ -n "$key_password" ]] || fatal "Missing RELEASE_KEY_PASSWORD/releaseKeyPassword."

  log "Synchronizing release-signing secrets to $WORKER_REPO"
  base64 -w 0 "$resolved_store" | gh secret set RELEASE_KEYSTORE_BASE64 --repo "$WORKER_REPO"
  printf '%s' "$store_password" | gh secret set RELEASE_STORE_PASSWORD --repo "$WORKER_REPO"
  printf '%s' "$key_alias" | gh secret set RELEASE_KEY_ALIAS --repo "$WORKER_REPO"
  printf '%s' "$key_password" | gh secret set RELEASE_KEY_PASSWORD --repo "$WORKER_REPO"
}

push_source() {
  local source_sha local_sha worker_url worker_sha

  cd "$ROOT"
  git diff --quiet || fatal "Working tree has uncommitted changes"
  git diff --cached --quiet || fatal "Index has staged but uncommitted changes"

  log "Fetching origin/$SOURCE_BRANCH"
  git fetch origin "$SOURCE_BRANCH" --quiet
  source_sha="$(git rev-parse "origin/$SOURCE_BRANCH")"
  local_sha="$(git rev-parse HEAD)"
  [[ "$local_sha" == "$source_sha" ]] || fatal "Local HEAD ($local_sha) must match origin/$SOURCE_BRANCH ($source_sha) before export"

  worker_url="https://github.com/$WORKER_REPO.git"
  if git ls-remote --exit-code "$worker_url" "refs/heads/$WORKER_BRANCH" >/dev/null 2>&1; then
    git fetch "$worker_url" "$WORKER_BRANCH" --quiet
    worker_sha="$(git rev-parse FETCH_HEAD)"
    git merge-base --is-ancestor "$worker_sha" "$source_sha" ||
      fatal "Worker branch has diverged. Refusing to force-push over $WORKER_REPO:$WORKER_BRANCH"
  fi

  log "Pushing verified source SHA $source_sha to $WORKER_REPO:$WORKER_BRANCH"
  git push "$worker_url" "$source_sha:refs/heads/$WORKER_BRANCH"
  gh repo edit "$WORKER_REPO" --default-branch "$WORKER_BRANCH" >/dev/null
}

dispatch_build() {
  local attempt
  log "Dispatching worker_release_apk.yml (workflow_dispatch avoids [skip ci] suppression)"
  for attempt in 1 2 3 4 5; do
    if gh workflow run worker_release_apk.yml --repo "$WORKER_REPO" --ref "$WORKER_BRANCH"; then
      return 0
    fi
    [[ "$attempt" -lt 5 ]] || break
    sleep 2
  done
  fatal "Worker source was pushed, but workflow dispatch failed."
}

main() {
  ensure_auth
  ensure_worker_repo
  sync_signing_secrets
  push_source
  dispatch_build

  printf '\nWorker export and build dispatch completed.\n'
  printf 'Repository: https://github.com/%s\n' "$WORKER_REPO"
  printf 'Actions: https://github.com/%s/actions/workflows/worker_release_apk.yml\n' "$WORKER_REPO"
  printf 'Release: https://github.com/%s/releases/tag/worker-latest\n' "$WORKER_REPO"
  printf 'Download after the run succeeds:\n'
  printf 'mkdir -p /sdcard/Download && gh release download worker-latest --repo %s --pattern app-release.apk --dir /sdcard/Download --clobber\n' "$WORKER_REPO"
}

main "$@"
