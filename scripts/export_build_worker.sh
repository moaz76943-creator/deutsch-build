#!/usr/bin/env bash
# Never trace interactive signing values, even when invoked with bash -x.
set +x
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKER_OWNER="${BUILD_WORKER_OWNER:-sali97m-cpu}"
WORKER_NAME="${BUILD_WORKER_NAME:-deutsch-bilarabi-worker}"
WORKER_REPO="${BUILD_WORKER_REPO:-$WORKER_OWNER/$WORKER_NAME}"
WORKER_BRANCH="${BUILD_WORKER_BRANCH:-main}"
SOURCE_BRANCH="${BUILD_WORKER_SOURCE_BRANCH:-main}"
SIGNING_SECRETS=(
  RELEASE_KEYSTORE_BASE64
  RELEASE_STORE_PASSWORD
  RELEASE_KEY_ALIAS
  RELEASE_KEY_PASSWORD
)
REQUIRED_SECRETS=("${SIGNING_SECRETS[@]}" TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID)

log() { printf '[worker-export] %s\n' "$*"; }
fatal() { printf '[worker-export][ERROR] %s\n' "$*" >&2; exit 1; }

ensure_auth() {
  command -v gh >/dev/null 2>&1 || fatal "GitHub CLI (gh) is required"
  command -v git >/dev/null 2>&1 || fatal "git is required"
  command -v python3 >/dev/null 2>&1 || fatal "python3 is required for bounded Worker status observation"

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
    # Bootstrap a new repository; preserve an existing repository's enable gate.
    gh variable set BUILD_WORKER_ENABLED --repo "$WORKER_REPO" --body "true"
  fi

  gh api --method PUT "repos/$WORKER_REPO/actions/permissions" \
    -F enabled=true \
    -f allowed_actions=all >/dev/null
  gh api --method PUT "repos/$WORKER_REPO/actions/permissions/workflow" \
    -f default_workflow_permissions=write \
    -F can_approve_pull_request_reviews=false >/dev/null

}

sync_signing_secrets() {
  local secret_names secret_name secret_value
  local -a missing=()
  secret_names="$(gh secret list --repo "$WORKER_REPO" --json name --jq '.[].name')" ||
    fatal "Unable to list worker secrets; check repository permissions."
  for secret_name in "${SIGNING_SECRETS[@]}"; do
    if ! grep -Fxq "$secret_name" <<<"$secret_names"; then
      missing+=("$secret_name")
    fi
  done
  if [[ "${#missing[@]}" -eq 0 ]]; then
    log "Signing secrets already exist; skipping bootstrap"
    return 0
  fi

  [[ -t 0 ]] || fatal "Missing signing secrets: ${missing[*]}. Run interactively to bootstrap them once."
  log "One-time signing bootstrap: enter only the missing secrets (input is hidden)."
  log "Paste RELEASE_KEYSTORE_BASE64 as a single line; it is never decoded or saved locally."
  for secret_name in "${missing[@]}"; do
    secret_value=''
    if ! IFS= read -r -s -p "$secret_name: " secret_value; then
      unset secret_value
      printf '\n' >&2
      fatal "Signing bootstrap interrupted; no build dispatched."
    fi
    printf '\n' >&2
    [[ -n "$secret_value" ]] || fatal "Empty value for $secret_name; no build dispatched."
    if ! printf '%s' "$secret_value" | gh secret set "$secret_name" --repo "$WORKER_REPO"; then
      unset secret_value
      fatal "Unable to set $secret_name; no build dispatched."
    fi
    unset secret_value
  done
}

preflight_check() {
  local enabled secret_names secret_name
  local -a missing=()
  enabled="$(gh variable list --repo "$WORKER_REPO" --json name,value \
    --jq '.[] | select(.name == "BUILD_WORKER_ENABLED") | .value')" ||
    fatal "Preflight: unable to read BUILD_WORKER_ENABLED in $WORKER_REPO."
  [[ "$enabled" == true ]] || fatal "Preflight: BUILD_WORKER_ENABLED must be true in $WORKER_REPO."
  secret_names="$(gh secret list --repo "$WORKER_REPO" --json name --jq '.[].name')" ||
    fatal "Preflight: unable to list secrets in $WORKER_REPO."
  for secret_name in "${REQUIRED_SECRETS[@]}"; do
    if ! grep -Fxq "$secret_name" <<<"$secret_names"; then
      missing+=("$secret_name")
    fi
  done
  [[ "${#missing[@]}" -eq 0 ]] || fatal "Preflight: missing worker secrets: ${missing[*]}. Set them with gh secret set before dispatch."
  log "Preflight passed: worker enabled and all required secrets present"
}

push_source() {
  local source_sha local_sha worker_url worker_sha

  cd "$ROOT"
  local origin_url
  origin_url="$(git remote get-url origin)"
  case "${origin_url,,}" in
    https://github.com/sali97m-cpu/deutsch-bilarabi|https://github.com/sali97m-cpu/deutsch-bilarabi.git|git@github.com:sali97m-cpu/deutsch-bilarabi.git) ;;
    *) fatal "Export must start from canonical sali97m-cpu/deutsch-bilarabi origin" ;;
  esac
  git diff --quiet || fatal "Working tree has uncommitted changes"
  git diff --cached --quiet || fatal "Index has staged but uncommitted changes"

  log "Fetching origin/$SOURCE_BRANCH"
  git fetch origin "$SOURCE_BRANCH" --quiet
  source_sha="$(git rev-parse "origin/$SOURCE_BRANCH")"
  SOURCE_SHA="$source_sha"
  local_sha="$(git rev-parse HEAD)"
  [[ "$local_sha" == "$source_sha" ]] || fatal "Local HEAD ($local_sha) must match origin/$SOURCE_BRANCH ($source_sha) before export"

  worker_url="https://github.com/$WORKER_REPO.git"
  if git ls-remote --exit-code "$worker_url" "refs/heads/$WORKER_BRANCH" >/dev/null 2>&1; then
    git fetch "$worker_url" "$WORKER_BRANCH" --quiet
    worker_sha="$(git rev-parse FETCH_HEAD)"
    git merge-base --is-ancestor "$worker_sha" "$source_sha" ||
      fatal "Worker branch has diverged. Refusing to force-push over $WORKER_REPO:$WORKER_BRANCH"
  else
    local lookup_status=$?
    [[ "$lookup_status" == 2 ]] || fatal "Worker ref lookup failed; refusing export while remote state is unknown"
  fi

  log "Pushing verified source SHA $source_sha to $WORKER_REPO:$WORKER_BRANCH"
  git push "$worker_url" "$source_sha:refs/heads/$WORKER_BRANCH"
  gh repo edit "$WORKER_REPO" --default-branch "$WORKER_BRANCH" >/dev/null
  printf 'Source export succeeded.\nSource SHA: %s\nWorker: https://github.com/%s\n' "$SOURCE_SHA" "$WORKER_REPO"
}

list_matching_runs() {
  gh run list --repo "$WORKER_REPO" --workflow worker_release_apk.yml \
    --branch "$WORKER_BRANCH" --event workflow_dispatch --commit "$SOURCE_SHA" \
    --limit 10 --json databaseId,headSha,url,status,conclusion
}

local_fallback() {
  printf 'Termux fallback: cd ~/deutsch-bilarabi && ./scripts/termux_release.sh\n' >&2
}

quota_rejected() {
  local run_id="$1" suite check_id annotations
  suite="$(gh api "repos/$WORKER_REPO/actions/runs/$run_id" --jq '.check_suite_id')" || return 1
  local check_ids
  check_ids="$(gh api "repos/$WORKER_REPO/check-suites/$suite/check-runs" --jq '.check_runs[:3][].id')" || return 1
  while IFS= read -r check_id; do
    [[ "$check_id" =~ ^[0-9]+$ ]] || continue
    annotations="$(gh api "repos/$WORKER_REPO/check-runs/$check_id/annotations" --jq '.[].message')" || continue
    if grep -Eiq 'billing|spending limit|payments.*failed|minutes.*(exhaust|limit)|quota' <<< "$annotations"; then
      return 0
    fi
  done <<< "$check_ids"
  return 1
}

report_run() {
  local selected="$1" run_id status conclusion url
  IFS=$'\t' read -r run_id status conclusion url <<< "$selected"
  printf 'Actions run: %s\nStatus: %s / %s\n' "$url" "$status" "$conclusion"
  if [[ "$status" == completed && "$conclusion" != success ]]; then
    if quota_rejected "$run_id"; then
      printf 'Source export succeeded, but GitHub-hosted compute is unavailable due to quota/billing. No further dispatch will be sent.\n' >&2
    else
      printf 'Worker did not succeed. Inspect the run URL for runner availability or build errors; no automatic redispatch.\n' >&2
    fi
    local_fallback
    return 2
  fi
  if [[ "$status" != completed ]]; then
    printf 'Dispatch accepted; a successful build is not yet confirmed.\n'
    local_fallback
  fi
}

dispatch_build() {
  local before active excluded selected attempt
  local attempts="${BUILD_WORKER_STATUS_ATTEMPTS:-4}" interval="${BUILD_WORKER_STATUS_INTERVAL:-5}"
  [[ "$attempts" =~ ^[1-9][0-9]*$ && "$interval" =~ ^[0-9]+$ ]] || fatal "Worker status limits must be integers"
  (( attempts <= 6 && interval <= 10 )) || fatal "Status observation is bounded to 6 checks / 10-second intervals"
  preflight_check
  before="$(list_matching_runs)" || { local_fallback; fatal "Export succeeded but active runs could not be inspected; no dispatch sent."; }
  active="$(python3 "$ROOT/tool/worker_run_status.py" "$SOURCE_SHA" --active-only <<< "$before")"
  if [[ -n "$active" ]]; then
    log "Matching active run already exists; reusing it without duplicate dispatch"
    report_run "$active"
    return
  fi
  excluded="$(python3 -c 'import json,sys; print(",".join(str(run["databaseId"]) for run in json.load(sys.stdin)))' <<< "$before")"
  log "Dispatching worker_release_apk.yml (workflow_dispatch avoids [skip ci] suppression)"
  # Do not retry an ambiguous dispatch response: GitHub may have accepted it.
  if ! gh workflow run worker_release_apk.yml --repo "$WORKER_REPO" --ref "$WORKER_BRANCH"; then
    local_fallback
    fatal "Source export succeeded; cloud dispatch was rejected or its result is ambiguous. Inspect Worker Actions before any retry."
  fi
  for (( attempt=1; attempt<=attempts; attempt++ )); do
    if before="$(list_matching_runs)"; then
      selected="$(python3 "$ROOT/tool/worker_run_status.py" "$SOURCE_SHA" --exclude "$excluded" <<< "$before")"
      if [[ -n "$selected" ]]; then
        if [[ "$selected" == *$'\tcompleted\t'* ]]; then report_run "$selected"; return; fi
      fi
    else
      log "Status API unavailable; stopping observation without redispatch"
      break
    fi
    if (( attempt < attempts )); then sleep "$interval"; fi
  done
  if [[ -n "${selected:-}" ]]; then
    report_run "$selected"
  else
    printf 'Dispatch sent once; no matching run visible yet. Cloud execution remains unverified.\n'
    printf 'Actions: https://github.com/%s/actions/workflows/worker_release_apk.yml\n' "$WORKER_REPO"
    local_fallback
  fi
}

main() {
  ensure_auth
  ensure_worker_repo
  sync_signing_secrets
  preflight_check
  push_source
  dispatch_build

  printf '\nWorker export/status observation finished.\n'
  printf 'Repository: https://github.com/%s\n' "$WORKER_REPO"
  printf 'Actions: https://github.com/%s/actions/workflows/worker_release_apk.yml\n' "$WORKER_REPO"
  printf 'Release: https://github.com/%s/releases/tag/worker-latest\n' "$WORKER_REPO"
  printf 'Download after the run succeeds:\n'
  printf 'mkdir -p /sdcard/Download && gh release download worker-latest --repo %s --pattern app-release.apk --dir /sdcard/Download --clobber\n' "$WORKER_REPO"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
