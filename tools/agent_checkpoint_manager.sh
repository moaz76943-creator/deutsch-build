#!/bin/bash
CHECKPOINT_FILE="assets/index/agent_checkpoint.json"
mkdir -p assets/index

save_checkpoint() {
  local task_id="$1"
  local status="$2"
  echo "{\"last_task\": \"$task_id\", \"status\": \"$status\", \"timestamp\": $(date +%s)}" > "$CHECKPOINT_FILE"
  echo "💾 تم حفظ نقطة استئناف الوكيل: $task_id"
}

get_checkpoint() {
  if [ -f "$CHECKPOINT_FILE" ]; then
    cat "$CHECKPOINT_FILE"
  else
    echo "{\"last_task\": \"NONE\", \"status\": \"READY\"}"
  fi
}

case "$1" in
  save) save_checkpoint "$2" "$3" ;;
  get)  get_checkpoint ;;
  *)    echo "الاستخدام: $0 {save <task_id> <status> | get}" ;;
esac
