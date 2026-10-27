#!/data/data/com.termux/files/usr/bin/bash
# POLYGLOT_CLI_V1 — Termux controls from any working directory.
set -Eeuo pipefail
ROOT="$HOME/polyglot-rooms/hybrid-v3"
APP="moaz76943-creator/deutsch-build"
PACKS="moaz76943-creator/-offline-packs-store"
fail() { echo "POLYGLOT ERROR: $*" >&2; exit 1; }
lane_dir() {
  case "${1:-}" in
    private|public) printf '%s/%s\n' "$ROOT" "$1";;
    *) fail "Choose private or public";;
  esac
}
lane_repo() {
  case "$1" in
    private) echo "$APP";;
    public) echo "$PACKS";;
    *) fail "Invalid lane";;
  esac
}
verify_lane() {
  local lane="$1" dir remote repo
  dir="$(lane_dir "$lane")"
  [[ -d "$dir/.git" ]] || fail "Repository not found: $dir. No reset or deletion attempted."
  remote="$(git -C "$dir" remote get-url origin)"
  repo="$(lane_repo "$lane")"
  [[ "$remote" == *"$repo" || "$remote" == *"$repo.git" ]] || fail "Unexpected origin: $remote"
}
session() { printf 'polyglot-v3-%s\n' "$1"; }
status_lane() {
  local lane="$1" dir sess
  dir="$(lane_dir "$lane")"; sess="$(session "$lane")"
  echo "===== $lane ====="
  if tmux has-session -t "$sess" 2>/dev/null; then
    echo "WORKER=RUNNING $sess"
  else
    echo "WORKER=STOPPED $sess"
  fi
  if [[ -d "$dir/.git" ]]; then
    verify_lane "$lane"
    echo "REPO=$dir"
    echo "BRANCH=$(git -C "$dir" branch --show-current)"
    echo "HEAD=$(git -C "$dir" rev-parse --short HEAD)"
    echo "LOCAL_EDITS=$(git -C "$dir" status --porcelain --untracked-files=normal | wc -l | tr -d ' ')"
  else
    echo 'REPO=NOT_INSTALLED'
  fi
  file="$ROOT/logs/$lane/status.log"
  if [[ -f "$file" ]]; then tail -n 12 "$file"; else echo 'LOG=NOT_FOUND'; fi
}
logs_lane() {
  local lane="$1" file latest
  file="$ROOT/logs/$lane/status.log"
  if [[ -f "$file" ]]; then tail -n 35 "$file"; else echo "No status log for $lane"; fi
  latest="$(ls -t "$ROOT/logs/$lane"/pass-*.log 2>/dev/null | head -1 || true)"
  if [[ -n "$latest" ]]; then
    echo "===== RECENT $lane RUN ====="
    tail -n 30 "$latest"
  fi
}
enter_lane() {
  local lane="$1" dir
  verify_lane "$lane"
  dir="$(lane_dir "$lane")"
  cd "$dir"
  echo "Entered $lane: $PWD"
  bash -i
}
watch_lane() {
  local lane="$1" sess
  verify_lane "$lane"
  sess="$(session "$lane")"
  tmux has-session -t "$sess" 2>/dev/null || {
    echo "Worker $sess stopped. Showing last logs:"
    logs_lane "$lane"
    exit 1
  }
  tmux attach-session -t "$sess"
}
resume_lane() {
  local lane="$1" sess dir
  verify_lane "$lane"
  [[ ! -f "$ROOT/STOP" ]] || fail 'STOP marker present; not overriding.'
  [[ -f "$ROOT/worker.sh" ]] || fail 'Worker script missing; not reinstalling over work.'
  sess="$(session "$lane")"
  if tmux has-session -t "$sess" 2>/dev/null; then
    echo "ALREADY_RUNNING $sess"; return 0
  fi
  dir="$(lane_dir "$lane")"
  tmux new-session -d -s "$sess" -c "$dir" "bash '$ROOT/worker.sh' '$lane'"
  sleep 3
  if tmux has-session -t "$sess" 2>/dev/null; then
    echo "RUNNING $sess"
  else
    echo "STOPPED_EARLY $sess"; logs_lane "$lane"; return 1
  fi
}
help_text() {
  cat <<'HELP'
polyglot status          status of both tmux workers + repo paths + git
polyglot private         enter private Flutter repository from anywhere
polyglot public          enter public content-factory repository from anywhere
polyglot watch private   attach private tmux worker
polyglot watch public    attach public tmux worker
polyglot logs private    last private worker errors
polyglot logs public     last public worker errors
polyglot resume private  resume stopped worker, preserve worktree
polyglot resume public   resume stopped worker, preserve worktree
HELP
}
case "${1:-status}" in
  --install)
    [[ -n "${PREFIX:-}" ]] || fail 'Run inside Termux (PREFIX missing)'
    [[ -f "$0" ]] || fail 'Run installer from a downloaded file'
    mkdir -p "$PREFIX/bin"
    target="$PREFIX/bin/polyglot"
    if [[ -e "$target" ]] && ! grep -Fq 'POLYGLOT_CLI_V1' "$target"; then
      fail "$target belongs to another command; refusing overwrite."
    fi
    install -m 700 "$0" "$target"
    echo "INSTALLED: $target"
    echo 'Use: polyglot status'
    ;;
  --self-test)
    [[ "$(lane_dir private)" == "$ROOT/private" ]]
    [[ "$(lane_dir public)" == "$ROOT/public" ]]
    [[ "$(lane_repo private)" == "$APP" ]]
    [[ "$(lane_repo public)" == "$PACKS" ]]
    echo 'SELF_TEST PASS: absolute repo routing'
    ;;
  status) status_lane private; status_lane public ;;
  private|public) enter_lane "$1" ;;
  watch) watch_lane "${2:-}" ;;
  logs) logs_lane "${2:-}" ;;
  resume) resume_lane "${2:-}" ;;
  help|-h|--help) help_text ;;
  *) fail 'Unknown command: try polyglot help' ;;
esac
