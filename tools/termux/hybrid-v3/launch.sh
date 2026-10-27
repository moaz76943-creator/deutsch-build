#!/data/data/com.termux/files/usr/bin/bash
# Polyglot hybrid room v3: two isolated repo workers, restartable, zero paid fallback.
set -Eeuo pipefail
umask 077

ROOT="$HOME/polyglot-rooms/hybrid-v3"
PRIVATE='moaz76943-creator/deutsch-build'
PUBLIC='moaz76943-creator/-offline-packs-store'

fatal() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '[POLYGLOT] %s\n' "$*"; }

models_from() {
  local file="$1" item
  # Never route to a model whose id is not explicitly marked free.
  for item in opencode/glm-5.3-flash-free opencode/deepseek-v4.1-flash-free \
    opencode/mimo-v2.6-flash-free opencode/nemotron-3.5-lightning-free \
    opencode/nemotron-3-ultra-free opencode/mimo-v2.5-free \
    opencode/exo-free opencode/ling-3.0-flash-fin-free; do
    grep -Fqx -- "$item" "$file" && printf '%s\n' "$item" || true
  done
  # Fallback for newer providers: only actually listed opencode/*-free IDs.
  grep -E '^opencode/[A-Za-z0-9._/-]+-free$' "$file" | grep -Fvx -f <(
    for item in opencode/glm-5.3-flash-free opencode/deepseek-v4.1-flash-free \
      opencode/mimo-v2.6-flash-free opencode/nemotron-3.5-lightning-free \
      opencode/nemotron-3-ultra-free opencode/mimo-v2.5-free opencode/exo-free \
      opencode/ling-3.0-flash-fin-free; do printf '%s\n' "$item"; done
  ) || true
}

if [[ "${1:-}" == '--self-test' ]]; then
  f="$(mktemp)"; trap 'rm -f "$f"' EXIT
  printf '%s\n' opencode/paid opencode/mimo-v2.6-flash-free opencode/new-model-free \
    opencode/glm-5.3-flash-free > "$f"
  [[ "$(models_from "$f" | wc -l | tr -d ' ')" == '3' ]]
  [[ "$(models_from "$f" | head -1)" == 'opencode/glm-5.3-flash-free' ]]
  ! models_from "$f" | grep -q 'opencode/paid'
  # Exercise the exact provider-error classifier extracted from the worker
  # template. These checks do not call an API or spend model quota.
  fn="$(mktemp)"; trap 'rm -f "$f" "$fn"' EXIT
  sed -n '/^model_terminal_error() {/,/^}/p' "$0" > "$fn"
  bash -n "$fn"
  source "$fn"
  printf '%s\n' 'Error: Upstream request failed: Model is unavailable.' > "$f"
  model_terminal_error "$f" 1
  model_terminal_error "$f" 0
  printf '%s\n' 'Error: rate limit exceeded (429)' > "$f"
  model_terminal_error "$f" 0
  printf '%s\n' 'The quota may be exhausted but code is valid.' > "$f"
  if model_terminal_error "$f" 0; then echo 'SELF_TEST FAIL: ordinary prose misclassified' >&2; exit 1; fi
  printf '%s\n' 'Error: syntax failed in code, unrelated to provider' > "$f"
  if model_terminal_error "$f" 1; then echo 'SELF_TEST FAIL: code error misclassified' >&2; exit 1; fi
  echo 'SELF_TEST PASS: free models and terminal provider-error failover'
  exit 0
fi

for dep in git gh tmux jq opencode timeout base64; do
  command -v "$dep" >/dev/null 2>&1 || fatal "Missing $dep. Install existing Termux tools/OpenCode; not installing paid services."
done
gh auth status >/dev/null 2>&1 || fatal 'GitHub login required: gh auth login'

# Never damage or steal a running pre-v3 session.
for legacy in polyglot-r01-worker polyglot-r01; do
  tmux has-session -t "$legacy" 2>/dev/null && fatal "Legacy worker '$legacy' still active. Inspect/detach it first; no competing GitHub edits."
done

mkdir -p "$ROOT" "$ROOT/logs"
chmod 700 "$ROOT" "$ROOT/logs"

ensure_repo() {
  local repo="$1" base="$2" dir="$3" remote
  if [[ ! -e "$dir" ]]; then
    log "Cloning $repo ($base) into a new isolated workspace"
    gh repo clone "$repo" "$dir" -- --branch "$base" --single-branch || fatal "Clone failed: $repo"
  fi
  [[ -d "$dir/.git" ]] || fatal "Not a git worktree: $dir; preserving files"
  remote="$(git -C "$dir" remote get-url origin)"
  [[ "$remote" == *"$repo" || "$remote" == *"$repo.git" ]] || fatal "Unexpected origin for $dir"
  log "Using preserved workspace: $dir"
}
ensure_repo "$PRIVATE" 'staging/v2-full-platform' "$ROOT/private"
ensure_repo "$PUBLIC" 'main' "$ROOT/public"

# Do not discard existing agent work. Before restart, save tracked diffs
# locally for recovery; untracked files remain untouched in their worktrees.
for lane in private public; do
  dir="$ROOT/$lane"
  if [[ -n "$(git -C "$dir" status --porcelain --untracked-files=normal)" ]]; then
    stamp="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$ROOT/recovery/$lane"
    git -C "$dir" status --porcelain --untracked-files=all > "$ROOT/recovery/$lane/status-$stamp.txt"
    git -C "$dir" diff --binary > "$ROOT/recovery/$lane/unstaged-$stamp.patch"
    git -C "$dir" diff --cached --binary > "$ROOT/recovery/$lane/staged-$stamp.patch"
    log "PRESERVED existing $lane edits, tracked diff receipts at recovery/$lane/$stamp"
  fi
done

version="$(opencode --version 2>&1 | head -1)"
if [[ "$version" =~ ^v?1\. ]]; then
  cat > "$ROOT/opencode.json" <<'CFG'
{"$schema":"https://opencode.ai/config.json","permission":{"read":{"*":"allow","*.env":"deny","*.env.*":"deny"},"edit":"allow","bash":{"*":"allow","git push --force*":"deny","git reset --hard*":"deny","git clean -fd*":"deny","gh pr merge --admin*":"deny","gh repo edit *":"deny","rm -rf*":"deny"},"external_directory":"deny"}}
CFG
elif [[ "$version" =~ ^v?2\. ]]; then
  cat > "$ROOT/opencode.json" <<'CFG'
{"$schema":"https://opencode.ai/config.json","permissions":[{"action":"*","resource":"*","effect":"allow"},{"action":"read","resource":"*.env","effect":"deny"},{"action":"read","resource":"*.env.*","effect":"deny"},{"action":"external_directory","resource":"*","effect":"deny"},{"action":"shell","resource":"git push --force*","effect":"deny"},{"action":"shell","resource":"git reset --hard*","effect":"deny"},{"action":"shell","resource":"git clean -fd*","effect":"deny"},{"action":"shell","resource":"gh pr merge --admin*","effect":"deny"},{"action":"shell","resource":"gh repo edit *","effect":"deny"},{"action":"shell","resource":"rm -rf*","effect":"deny"}]}
CFG
else
  fatal "Unrecognized OpenCode version '$version'. No guessed config."
fi
chmod 600 "$ROOT/opencode.json"
jq -e . "$ROOT/opencode.json" >/dev/null || fatal 'Invalid OpenCode config JSON'

export OPENCODE_CONFIG="$ROOT/opencode.json"
log "OpenCode=$version; checking actual available models"
timeout 40s opencode models > "$ROOT/logs/available-models.txt" 2> "$ROOT/logs/model-errors.txt" || fatal "Model discovery failed; see $ROOT/logs/model-errors.txt"
models_from "$ROOT/logs/available-models.txt" > "$ROOT/free-models.txt"
[[ -s "$ROOT/free-models.txt" ]] || fatal 'No verified free models available; never switching to a paid model.'
chmod 600 "$ROOT/free-models.txt"
log "Verified free models: $(wc -l < "$ROOT/free-models.txt" | tr -d ' ')"

cat > "$ROOT/worker.sh" <<'WORKER'
#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
lane="$1"
ROOT="$HOME/polyglot-rooms/hybrid-v3"
case "$lane" in
  private) repo='moaz76943-creator/deutsch-build'; target='staging/v2-full-platform';;
  public) repo='moaz76943-creator/-offline-packs-store'; target='main';;
  *) echo 'Invalid lane' >&2; exit 1;;
esac
cd "$ROOT/$lane"
export OPENCODE_CONFIG="$ROOT/opencode.json"
mapfile -t models < "$ROOT/free-models.txt"
(( ${#models[@]} > 0 )) || exit 1
logdir="$ROOT/logs/$lane"
mkdir -p "$logdir"; chmod 700 "$logdir"
status="$logdir/status.log"
printf 'START %s lane=%s\n' "$(date -Is)" "$lane" >> "$status"
trap 'rc=$?; printf "END %s exit=%s pass=%s\n" "$(date -Is)" "$rc" "${pass:-0}" >> "$status"' EXIT

progress() {
  git rev-parse HEAD
  git branch --show-current
  git status --porcelain --untracked-files=normal
  # Do not count unrelated agents' PR movements as this worker's progress.
  gh pr list -R "$repo" --head "$(git branch --show-current)" --state all --limit 10 --json number,state,headRefOid,mergedAt 2>/dev/null || true
}

read -r -d '' instructions <<PROMPT || true
POLYGLOT HYBRID V3 -- $lane lane; official repo $repo; target $target.
You are working INSIDE THIS repository, not the sibling lane. This session is an autonomous repair batch, not a report.
FIRST read AGENTS.md and relevant official repo instructions, live HEAD and open PR/CI status; then check preserved local git status before editing. Reuse existing PR branches when authorized. Do not assume another task owner surrendered a file. No unknown destructive reset, clean, branch delete, force push, bypass, publishing private code or secrets, or paid services. Protect learner SQLite/SRS progress; legally approved source data only.
$(if [[ "$lane" == private ]]; then cat <<'PRIVATE'
Priority P0/P1: fix CI/merge blockers (#541 if still open), SRS same-tick review loss (#529 if unowned), preserve SQLite progress and offline boot, core worker/audio lifecycle, targeted regression tests. For existing occupied files or unverified security risks, inspect READ-ONLY and continue an independent safe task. Target staging/v2-full-platform, not main.
PRIVATE
else cat <<'PUBLIC'
Priority P0/P1: existing merge coordinator and PR gates, factory dispatcher/queue workers, SQLite v2 FTS5/Unicode QA, license evidence/source admission and SHA256 receipts. Never fabricate license approvals or publish unverified packs. Target main. Existing public content factory ONLY, never private source.
PUBLIC
fi)
In this pass process up to FOUR independent verified fixes/PR resolutions. Within the pass, for each 1-3 coherent fixes: diagnose, implement minimum diff, relevant tests, commit and push immediately to an existing authorized PR branch or open a scoped non-Draft PR; squash merge only if required checks, independent reviews and GitHub branch protection genuinely pass. Verify target SHA and merged=true. If blocked, record a precise blocker in existing PR and switch to another independent eligible issue. Close historical/superseded PRs only after comparing evidence. Do not create new coordinators, ledgers, fake PASS, or generic reports. Finish with TASK_ID/STATUS, PR/SHA, actual tests, next action. Do not stop after a plan.
PROMPT

model_terminal_error() {
  local file="$1" exit_code="$2"
  local regex='(quota.{0,100}(exceeded|reached)|rate.?limit|429|resource_exhausted|payment required|insufficient credits|model.{0,60}not.{0,20}found|model[[:space:]]+(is[[:space:]]+)?unavailable|upstream request failed.{0,120}unavailable|provider.{0,80}unavailable|api.?key.{0,30}missing|unauthorized|authentication.{0,40}failed|503|overloaded)'
  # Nonzero exits: allow the next free model if any provider/quota signature exists.
  if (( exit_code != 0 )); then
    grep -Eiq "$regex" "$file"
    return $?
  fi
  # OpenCode v1 may exit zero after a provider failure. Treat only a TERMINAL
  # explicit error line as fatal; normal agent prose mentioning 'quota' is not.
  tail -n 24 "$file" | grep -Ei '^[[:space:]]*(Error:|ProviderError:|APIError:)' | grep -Eiq "$regex"
}
start="$(date +%s)"
no_progress=0
for (( pass=1; pass<=20; pass++ )); do
  [[ ! -f "$ROOT/STOP" ]] || { echo "STOP requested" >> "$status"; break; }
  [[ $(( $(date +%s) - start )) -lt 28800 ]] || { echo "8h max reached" >> "$status"; break; }
  before="$(progress | sha256sum | awk '{print $1}')"
  done_pass=0
  for (( i=0; i<${#models[@]}; i++ )); do
    idx=$(( (pass - 1 + i) % ${#models[@]} ))
    model="${models[$idx]}"
    file="$logdir/pass-${pass}-model-${idx}-$(date +%Y%m%d-%H%M%S).log"
    printf 'TRY pass=%s model=%s at=%s\n' "$pass" "$model" "$(date -Is)" | tee -a "$status"
    help_text="$(opencode run --help 2>&1 || true)"
    flags=(--model "$model")
    [[ "$help_text" != *'--auto'* ]] || flags+=(--auto)
    set +e
    timeout --signal=TERM --kill-after=15s 40m opencode run "${flags[@]}" "$instructions" > "$file" 2>&1
    rc=$?
    set -e
    printf 'EXIT pass=%s model=%s rc=%s\n' "$pass" "$model" "$rc" >> "$status"
    if (( rc == 124 )); then
      echo 'PASS_TIMEOUT: worktree preserved for next pass' >> "$status"
      done_pass=1
      break
    fi
    if model_terminal_error "$file" "$rc"; then
      printf 'MODEL_ERROR terminal_provider_error; try_next_free=%s\n' "$model" >> "$status"
      continue
    fi
    if (( rc != 0 )); then
      printf 'FATAL rc=%s; recent output:\n' "$rc" >> "$status"
      tail -n 35 "$file" >> "$status"
      exit "$rc"
    fi
    if [[ ! -s "$file" ]]; then
      echo 'EMPTY_OUTPUT: stopping to diagnose' >> "$status"
      exit 1
    fi
    done_pass=1
    break
  done
  (( done_pass == 1 )) || { echo 'FREE_MODELS_EXHAUSTED: no paid fallback' >> "$status"; break; }
  after="$(progress | sha256sum | awk '{print $1}')"
  if [[ "$before" == "$after" ]]; then
    no_progress=$((no_progress + 1))
    echo "NO_GIT_PR_CHANGE pass=$pass count=$no_progress" >> "$status"
    if (( no_progress >= 2 )); then
      echo 'STOP: two passes without verified Git/PR change' >> "$status"
      break
    fi
  else
    no_progress=0
    echo "GIT_OR_PR_CHANGED pass=$pass: inspect receipts to confirm actual merge" >> "$status"
  fi
  sleep 10
done
WORKER
chmod 700 "$ROOT/worker.sh"

if command -v termux-wake-lock >/dev/null 2>&1; then termux-wake-lock || true; fi
started=0
for lane in private public; do
  session="polyglot-v3-$lane"
  if tmux has-session -t "$session" 2>/dev/null; then
    log "EXISTING $session (no duplicate)"
  else
    tmux new-session -d -s "$session" -c "$ROOT/$lane" "bash '$ROOT/worker.sh' '$lane'"
    log "LAUNCHED $session"
    started=1
  fi
done
sleep 4
for lane in private public; do
  session="polyglot-v3-$lane"
  if tmux has-session -t "$session" 2>/dev/null; then
    log "RUNNING $session"
  else
    log "STOPPED_EARLY $session:"
    if [[ -f "$ROOT/logs/$lane/status.log" ]]; then
      tail -n 35 "$ROOT/logs/$lane/status.log"
    else
      log 'No worker status recorded'
    fi
  fi
done
log "STATUS: tail -n 50 '$ROOT/logs/private/status.log' '$ROOT/logs/public/status.log'"
log 'REATTACH: tmux attach -t polyglot-v3-private  (or polyglot-v3-public)'
log "SAFE STOP (after current pass): touch '$ROOT/STOP'"
