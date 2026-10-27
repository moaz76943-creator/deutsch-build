#!/data/data/com.termux/files/usr/bin/bash
# DEUTSCH / Polyglot Room 01 — OpenCode hybrid Termux launcher.
set -Eeuo pipefail

ROOT="$HOME/polyglot-rooms/room01"
APP_REPO='moaz76943-creator/deutsch-build'
PACK_REPO='moaz76943-creator/-offline-packs-store'
WORKER='polyglot-r01-worker'

free_models() {
  local list="$1" candidate
  for candidate in \
    opencode/glm-5.3-flash-free \
    opencode/deepseek-v4.1-flash-free \
    opencode/mimo-v2.6-flash-free \
    opencode/nemotron-3.5-lightning-free \
    opencode/nemotron-3-ultra-free \
    opencode/mimo-v2.5-free \
    opencode/exo-free \
    opencode/ling-3.0-flash-fin-free; do
    grep -Fqx -- "$candidate" "$list" && printf '%s\n' "$candidate" || true
  done
}

quota_error() {
  grep -Eiq 'rate.?limit|quota.?exceeded|HTTP[ :]+429|error[ :]+429|payment.?required|insufficient.?credits|model.?unavailable|usage.?limit|context.?length.?exceeded' "$1"
}

if [[ "${1:-}" == '--self-test' ]]; then
  file="$(mktemp)"; trap 'rm -f "$file"' EXIT
  printf '%s\n' opencode/paid-model opencode/deepseek-v4.1-flash-free opencode/glm-5.3-flash-free > "$file"
  [[ "$(free_models "$file" | wc -l | tr -d ' ')" == 2 ]]
  [[ "$(free_models "$file" | head -1)" == 'opencode/glm-5.3-flash-free' ]]
  printf '%s\n' 'Error 429 rate limit exceeded' > "$file"; quota_error "$file"
  printf '%s\n' 'All selected regression tests PASSED' > "$file"; ! quota_error "$file"
  echo 'SELF_TEST PASS: free-only priority + quota recognition'
  exit 0
fi

command -v pkg >/dev/null 2>&1 || { echo 'ERROR: run this script inside Termux.' >&2; exit 1; }
for cmd in git gh tmux jq timeout base64; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: missing $cmd. Run: pkg install -y git gh tmux jq coreutils" >&2
    exit 1
  fi
done
command -v opencode >/dev/null 2>&1 || { echo 'ERROR: OpenCode absent. Install a verified Termux-compatible build first.' >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo 'ERROR: run gh auth login to access the private app repository.' >&2; exit 1; }

if tmux has-session -t polyglot-r01 2>/dev/null; then
  echo 'ERROR: legacy tmux session polyglot-r01 is still running. Stop it safely before starting the hybrid worker in the same workspace.' >&2
  exit 1
fi

mkdir -p "$ROOT/logs"
chmod 700 "$ROOT" "$ROOT/logs"
check_repo() {
  local name="$1" branch="$2" dir="$3" origin current
  if [[ ! -e "$dir" ]]; then
    gh repo clone "$name" "$dir" -- --branch "$branch" --single-branch
  fi
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null || exit 1
  origin="$(git -C "$dir" remote get-url origin)"
  [[ "$origin" == *"$name" || "$origin" == *"$name.git" ]] || { echo "ERROR: unexpected origin at $dir" >&2; exit 1; }
  current="$(git -C "$dir" branch --show-current)"
  [[ "$current" == "$branch" ]] || { echo "ERROR: $dir on $current, expected $branch. No checkout performed." >&2; exit 1; }
}
check_repo "$APP_REPO" 'staging/v2-full-platform' "$ROOT/private"
check_repo "$PACK_REPO" 'main' "$ROOT/public"

cat > "$ROOT/ROOM.md" <<'PROMPT'
# POLYGLOT R01 — ROOT-CAUSE CI AND MERGE RECOVERY
You are an autonomous software-repair agent, not a planner. TARGETS:
- private: moaz76943-creator/deutsch-build, base staging/v2-full-platform
- public: moaz76943-creator/-offline-packs-store, base main
Workspace ROOT is NOT a git repository. Work only under ./private and ./public.

Read live HEAD, relevant AGENTS.md, SESSION_OPERATING_CONTRACT, relevant PRs and checks. Never edit another worker's owned files or branch. Respect MASTER CONSTITUTION v9, data safety, legal rights, real branch protections, exact-head checks and independent approvals. No force pushes, deleting work, paid resources, secret exposure, or unauthorized changes to repository visibility.

In this pass complete up to THREE coherent, independent real repairs/PR resolutions, not three new documents:
1. Find and repair actual private CI merge blockers (notably PR #541, if still open). Distinguish no-runner infrastructure failure from source/test errors. Do not bypass existing checks to fabricate green.
2. Diagnose/fix existing public merge coordinator and PR gate problems, respecting one-writer/approved.json. Advance ready open PRs through authorized existing merger. For superseded PRs compare replacement code/tests and close with evidence only.
3. If CI blocks that lane, complete independent public Python/SQLite factory QA/dispatcher issues. Source ledger, licenses, pack SHA256 and PRAGMA integrity/foreign-key checks remain required; never manufacture approved content.
4. Assess private critical SRS #529, offline boot, data retention, and security read-only if another owner holds scope; implement only if unowned and verified, with focused regression tests.

For EACH coherent 1–3 fix batch: identify exact task/PR, reproduce/diagnose, edit smallest source diff, run affected checks, commit and PUSH promptly to existing PR branch when authorized (otherwise new scoped PR), request or perform authorized squash merge only when reviews/checks/branch protection are satisfied, and verify merged=true, merge SHA and target HEAD. A draft or CI failure is not a success. If merging is not authorized, leave pushed PR and precise blocker, then continue a separate eligible task. Do not create new bureaucracy or coordinators. If same hypothesis fails twice, get new evidence and switch.

Respect existing repo owners, never run Flutter/Android on Termux unless actually available and safe. Do not copy private source to public repo or public runners. Maintain brief evidence on GitHub for meaningful changes; local session logs are for recovery only. Do not touch Deep Focus. Read only relevant Notion docs; NEVER open pages containing محادثة or المحادثة الألمانية.
End each pass:
TASK_ID & STATUS: ...
PR & SHA: ...
Analyze & Tests: ...
NEXT ACTION: ...
PROMPT

ver="$(opencode --version 2>&1 | head -1)"
case "$ver" in
  *'2.'*|*'v2.'*) oc_major=2;;
  *'1.'*|*'v1.'*) oc_major=1;;
  *) echo "ERROR: Unknown OpenCode version: $ver; not guessing permission syntax." >&2; exit 1;;
esac

if (( oc_major == 1 )); then
  cat > "$ROOT/opencode.json" <<'JSON'
{
  "$schema":"https://opencode.ai/config.json",
  "permission":{
    "read":{"*":"allow","*.env":"deny","*.env.*":"deny"},
    "edit":"allow",
    "bash":{"*":"allow","git push --force*":"deny","git reset --hard*":"deny","git clean -fd*":"deny","gh pr merge --admin*":"deny","gh repo edit *":"deny","rm -rf*":"deny"},
    "external_directory":"deny"
  }
}
JSON
else
  cat > "$ROOT/opencode.json" <<'JSON'
{
  "$schema":"https://opencode.ai/config.json",
  "permissions":[
    {"action":"*","resource":"*","effect":"allow"},
    {"action":"read","resource":"*.env","effect":"deny"},
    {"action":"read","resource":"*.env.*","effect":"deny"},
    {"action":"external_directory","resource":"*","effect":"deny"},
    {"action":"shell","resource":"git push --force*","effect":"deny"},
    {"action":"shell","resource":"git reset --hard*","effect":"deny"},
    {"action":"shell","resource":"git clean -fd*","effect":"deny"},
    {"action":"shell","resource":"gh pr merge --admin*","effect":"deny"},
    {"action":"shell","resource":"gh repo edit *","effect":"deny"},
    {"action":"shell","resource":"rm -rf*","effect":"deny"}
  ]
}
JSON
fi

opencode models > "$ROOT/logs/models.txt" 2> "$ROOT/logs/model-errors.txt" || { echo 'ERROR: opencode models failed; see logs/model-errors.txt' >&2; exit 1; }
free_models "$ROOT/logs/models.txt" > "$ROOT/free-models.txt"
[[ -s "$ROOT/free-models.txt" ]] || { echo 'ERROR: no approved free OpenCode models in account. No paid fallback.' >&2; exit 1; }
first="$(head -1 "$ROOT/free-models.txt")"
# Force incidental small-model tasks onto the same free model in OpenCode v1.
if (( oc_major == 1 )); then
  jq --arg m "$first" '. + {model:$m,small_model:$m}' "$ROOT/opencode.json" > "$ROOT/opencode.tmp"
else
  jq --arg m "$first" '. + {model:$m}' "$ROOT/opencode.json" > "$ROOT/opencode.tmp"
fi
mv "$ROOT/opencode.tmp" "$ROOT/opencode.json"
chmod 600 "$ROOT/opencode.json"

cat > "$ROOT/worker.sh" <<'WORKER_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
ROOT="$HOME/polyglot-rooms/room01"
cd "$ROOT"
export OPENCODE_CONFIG="$ROOT/opencode.json"
mapfile -t models < "$ROOT/free-models.txt"
count="${#models[@]}"
[[ "$count" -gt 0 ]] || exit 1
# Repeat the same source task with a fresh live-state inspection each pass; never share a session with the TUI.
for (( pass=1; pass<=12; pass++ )); do
  [[ ! -f "$ROOT/STOP" ]] || break
  completed=0
  for (( offset=0; offset<count; offset++ )); do
    index=$(( (pass - 1 + offset) % count ))
    model="${models[$index]}"
    stamp="$(date +%Y%m%d-%H%M%S)"
    log="$ROOT/logs/pass-${pass}-${stamp}-model-${index}.log"
    echo "PASS=$pass MODEL=$model START=$(date -Is)" | tee -a "$log"
    set +e
    timeout --signal=TERM --kill-after=20s 50m opencode run --model "$model" --file "$ROOT/ROOM.md" \
      "Execute the next unowned, high-value batch of 1-3 repairs and authorized PR merges from ROOM.md. Inspect live GitHub state and the local worktree first; resume any partial work. Push verified work as soon as a batch is complete. End with exact receipts. Do not stop at a plan." 2>&1 | tee -a "$log"
    code=${PIPESTATUS[0]}
    set -e
    echo "EXIT_CODE=$code" | tee -a "$log"
    if (( code == 124 || code == 137 )); then
      echo 'Execution timed out/killed. Preserve work; stop and inspect.' | tee -a "$log"
      exit "$code"
    fi
    if grep -Eiq 'rate.?limit|quota.?exceeded|HTTP[ :]+429|error[ :]+429|payment.?required|insufficient.?credits|model.?unavailable|usage.?limit|context.?length.?exceeded' "$log"; then
      echo 'Free model quota or context exhausted; trying next free model.' | tee -a "$log"
      continue
    fi
    if (( code != 0 )); then
      echo 'Non-quota error. Stop to avoid repeat loops; preserve work.' | tee -a "$log"
      exit "$code"
    fi
    completed=1
    break
  done
  if (( ! completed )); then
    echo 'All discovered free models exhausted; stopping without paid fallback.'
    break
  fi
  sleep 15
done
WORKER_SCRIPT
chmod 700 "$ROOT/worker.sh"

cat > "$ROOT/control.sh" <<'CONTROL'
#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
ROOT="$HOME/polyglot-rooms/room01"
cd "$ROOT"
export OPENCODE_CONFIG="$ROOT/opencode.json"
model="$(head -1 "$ROOT/free-models.txt")"
exec opencode --model "$model"
CONTROL
chmod 700 "$ROOT/control.sh"
if command -v termux-wake-lock >/dev/null 2>&1; then termux-wake-lock || true; fi
if tmux has-session -t "$WORKER" 2>/dev/null; then
  echo "Worker already running: tmux attach -t $WORKER"
else
  tmux new-session -d -s "$WORKER" -c "$ROOT" "$ROOT/worker.sh"
  echo "STARTED: $WORKER"
fi
printf '%s\n' \
  "WATCH: tmux attach -t $WORKER" \
  "HYBRID TUI (read-only while worker edits): $ROOT/control.sh" \
  "STOP after current pass: touch $ROOT/STOP" \
  "LOGS: $ROOT/logs" \
  "No paid models; no automatic bypass of GitHub branch protection."
