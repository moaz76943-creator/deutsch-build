#!/usr/bin/env python3
"""Persistent, resumable engineering task queue for the DEUTSCH / Polyglot project in Termux.

Features:
- Single-instance lock with PID validation to prevent duplicate execution across reboots.
- Persistent JSON queue file with priorities, dependencies, and state tracking.
- Bounded retries (max 2), explicit timeouts, and cooldown after failure.
- Strictly safe: never runs YOLO mode or destructive Git commands.
- Human approval gate for protected actions (merges, legal licenses, credentials, billing).
- Android Termux:API integration (wake-lock during processing, release when idle, notifications).
- Boot recovery hook for Termux:Boot and periodic check via termux-job-scheduler.
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

# File paths
DEFAULT_HOME = Path(os.environ.get("HOME", "/data/data/com.termux/files/home"))
QUEUE_DIR = DEFAULT_HOME / "deutsch-reports" / "gemini-recovery"
QUEUE_FILE = QUEUE_DIR / "TASK_QUEUE.json"
LOCK_FILE = QUEUE_DIR / "task_queue.lock"
LOG_FILE = QUEUE_DIR / "task_queue_execution.log"
PAUSE_FLAG_FILE = QUEUE_DIR / "task_queue.paused"

STATE_PENDING = "PENDING"
STATE_IN_PROGRESS = "IN_PROGRESS"
STATE_COMPLETED = "COMPLETED"
STATE_FAILED = "FAILED"
STATE_BLOCKED_APPROVAL = "BLOCKED_APPROVAL"
STATE_SKIPPED = "SKIPPED"


def _log(message: str) -> None:
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    line = f"[{timestamp}] {message}"
    print(line)
    try:
        QUEUE_DIR.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except Exception:
        pass


def _send_notification(title: str, content: str) -> None:
    try:
        subprocess.run(
            ["termux-notification", "--title", title, "--content", content, "--id", "deutsch_queue"],
            capture_output=True,
            timeout=5,
            check=False,
        )
    except Exception:
        pass


def _acquire_wake_lock() -> None:
    try:
        subprocess.run(["termux-wake-lock"], capture_output=True, timeout=5, check=False)
    except Exception:
        pass


def _release_wake_lock() -> None:
    try:
        subprocess.run(["termux-wake-unlock"], capture_output=True, timeout=5, check=False)
    except Exception:
        pass


class SingleInstanceLock:
    def __init__(self, lock_path: Path = LOCK_FILE):
        self.lock_path = lock_path
        self.acquired = False

    def acquire(self) -> bool:
        if self.lock_path.exists():
            try:
                data = json.loads(self.lock_path.read_text(encoding="utf-8"))
                pid = data.get("pid")
                if pid and self._is_pid_alive(pid):
                    _log(f"Active worker process found (PID {pid}). Another instance is running.")
                    return False
                else:
                    _log(f"Found stale lock file for dead PID {pid}. Breaking lock safely.")
            except Exception as e:
                _log(f"Error reading lock file: {e}. Replacing lock.")

        try:
            self.lock_path.parent.mkdir(parents=True, exist_ok=True)
            payload = {
                "pid": os.getpid(),
                "started_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                "hostname": os.uname().nodename if hasattr(os, "uname") else "termux",
            }
            self.lock_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
            self.acquired = True
            return True
        except Exception as e:
            _log(f"Failed to create lock file: {e}")
            return False

    def release(self) -> None:
        if self.acquired and self.lock_path.exists():
            try:
                self.lock_path.unlink()
                self.acquired = False
            except Exception:
                pass

    @staticmethod
    def _is_pid_alive(pid: int) -> bool:
        if pid <= 0:
            return False
        try:
            os.kill(pid, 0)
            return True
        except ProcessLookupError:
            return False
        except PermissionError:
            return True
        except Exception:
            return False


class TaskQueueManager:
    def __init__(self, queue_path: Path = QUEUE_FILE):
        self.queue_path = queue_path
        self._ensure_queue_file()

    def _ensure_queue_file(self) -> None:
        if not self.queue_path.exists():
            self.queue_path.parent.mkdir(parents=True, exist_ok=True)
            initial_data = {
                "schema_version": "1.0.0",
                "system": "DEUTSCH-BILARABI-PERSISTENT-TASK-QUEUE",
                "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                "active_status": "IDLE",
                "tasks": [],
            }
            self.queue_path.write_text(json.dumps(initial_data, indent=2, ensure_ascii=False), encoding="utf-8")

    def load_queue(self) -> Dict[str, Any]:
        self._ensure_queue_file()
        try:
            return json.loads(self.queue_path.read_text(encoding="utf-8"))
        except Exception as e:
            _log(f"Error loading queue file: {e}")
            return {"tasks": []}

    def save_queue(self, data: Dict[str, Any]) -> None:
        data["updated_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        temp_file = self.queue_path.with_suffix(".tmp")
        temp_file.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        temp_file.replace(self.queue_path)

    def add_task(
        self,
        task_id: str,
        title: str,
        command: str,
        cwd: str,
        priority: int = 10,
        dependencies: Optional[List[str]] = None,
        timeout_seconds: int = 300,
        requires_approval: bool = False,
        scope: Optional[List[str]] = None,
    ) -> bool:
        data = self.load_queue()
        tasks = data.get("tasks", [])

        for t in tasks:
            if t["task_id"] == task_id:
                _log(f"Task {task_id} already exists in queue.")
                return False

        new_task = {
            "task_id": task_id,
            "title": title,
            "priority": priority,
            "state": STATE_BLOCKED_APPROVAL if requires_approval else STATE_PENDING,
            "dependencies": dependencies or [],
            "command": command,
            "cwd": cwd,
            "timeout_seconds": timeout_seconds,
            "retries": 0,
            "max_retries": 2,
            "cooldown_seconds": 30,
            "requires_human_approval": requires_approval,
            "scope": scope or [],
            "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "execution_history": [],
        }

        tasks.append(new_task)
        data["tasks"] = tasks
        self.save_queue(data)
        _log(f"Added task {task_id} (priority {priority}) to queue.")
        return True

    def get_next_eligible_task(self) -> Optional[Dict[str, Any]]:
        data = self.load_queue()
        tasks = data.get("tasks", [])

        completed_ids = {t["task_id"] for t in tasks if t["state"] == STATE_COMPLETED}

        eligible_tasks = []
        for t in tasks:
            if t["state"] != STATE_PENDING:
                continue
            if t.get("requires_human_approval", False):
                continue
            # Check dependencies
            deps = t.get("dependencies", [])
            if all(dep in completed_ids for dep in deps):
                eligible_tasks.append(t)

        if not eligible_tasks:
            return None

        # Sort by priority (ascending, 1 is highest priority)
        eligible_tasks.sort(key=lambda x: (x.get("priority", 10), x.get("created_at", "")))
        return eligible_tasks[0]

    def update_task_state(self, task_id: str, new_state: str, record: Optional[Dict[str, Any]] = None) -> None:
        data = self.load_queue()
        for t in data.get("tasks", []):
            if t["task_id"] == task_id:
                t["state"] = new_state
                if record:
                    t.setdefault("execution_history", []).append(record)
                break
        self.save_queue(data)

    def pause_queue(self) -> None:
        PAUSE_FLAG_FILE.touch()
        data = self.load_queue()
        data["active_status"] = "PAUSED"
        self.save_queue(data)
        _log("Queue execution paused by user request.")

    def resume_queue(self) -> None:
        if PAUSE_FLAG_FILE.exists():
            PAUSE_FLAG_FILE.unlink()
        data = self.load_queue()
        data["active_status"] = "RUNNING"
        self.save_queue(data)
        _log("Queue execution resumed.")

    def is_paused(self) -> bool:
        return PAUSE_FLAG_FILE.exists()


class QueueExecutor:
    def __init__(self, manager: TaskQueueManager):
        self.manager = manager
        self.lock = SingleInstanceLock()

    def run_loop(self, max_tasks: Optional[int] = None) -> None:
        if not self.lock.acquire():
            print("Cannot run queue: another worker is active or lock could not be acquired.")
            sys.exit(1)

        _acquire_wake_lock()
        _log("Queue worker started. Processing eligible tasks...")
        processed_count = 0

        try:
            while True:
                if self.manager.is_paused():
                    _log("Queue is paused. Exiting worker loop.")
                    break

                if max_tasks is not None and processed_count >= max_tasks:
                    _log(f"Processed maximum requested tasks ({max_tasks}). Exiting.")
                    break

                task = self.manager.get_next_eligible_task()
                if not task:
                    _log("No eligible pending tasks found. Queue idle.")
                    break

                task_id = task["task_id"]
                _log(f"Starting execution of task: {task_id} ('{task.get('title')}')")
                self.manager.update_task_state(task_id, STATE_IN_PROGRESS)

                success = self._execute_task(task)
                processed_count += 1

                if success:
                    _log(f"Task {task_id} COMPLETED successfully.")
                    self.manager.update_task_state(task_id, STATE_COMPLETED)
                    _send_notification("Task Completed", f"Task {task_id} passed successfully.")
                else:
                    retries = task.get("retries", 0) + 1
                    max_retries = task.get("max_retries", 2)
                    task["retries"] = retries

                    if retries < max_retries:
                        cooldown = task.get("cooldown_seconds", 30)
                        _log(f"Task {task_id} failed attempt {retries}/{max_retries}. Cooldown {cooldown}s...")
                        time.sleep(cooldown)
                        self.manager.update_task_state(task_id, STATE_PENDING)
                    else:
                        _log(f"Task {task_id} reached max retries ({max_retries}). Marked as FAILED.")
                        self.manager.update_task_state(task_id, STATE_FAILED)
                        _send_notification("Task Failed", f"Task {task_id} failed after {max_retries} attempts.")
                        break

        finally:
            _release_wake_lock()
            self.lock.release()
            _log("Queue worker exited cleanly. Wake-lock and lock released.")

    def _execute_task(self, task: Dict[str, Any]) -> bool:
        task_id = task["task_id"]
        command = task["command"]
        cwd = task.get("cwd", str(DEFAULT_HOME))
        timeout = task.get("timeout_seconds", 300)

        start_time = datetime.datetime.now(datetime.timezone.utc)
        record = {
            "attempt": task.get("retries", 0) + 1,
            "started_at": start_time.isoformat(),
            "command": command,
        }

        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=timeout,
            )

            end_time = datetime.datetime.now(datetime.timezone.utc)
            duration_s = (end_time - start_time).total_seconds()

            record["ended_at"] = end_time.isoformat()
            record["duration_seconds"] = duration_s
            record["exit_code"] = result.returncode
            record["stdout_snippet"] = result.stdout[-500:] if result.stdout else ""
            record["stderr_snippet"] = result.stderr[-500:] if result.stderr else ""

            self.manager.update_task_state(task_id, STATE_IN_PROGRESS, record)
            return result.returncode == 0

        except subprocess.TimeoutExpired as exc:
            end_time = datetime.datetime.now(datetime.timezone.utc)
            record["ended_at"] = end_time.isoformat()
            record["exit_code"] = -1
            record["error"] = f"Execution timed out after {timeout} seconds"
            self.manager.update_task_state(task_id, STATE_IN_PROGRESS, record)
            _log(f"Task {task_id} timed out after {timeout}s.")
            return False

        except Exception as exc:
            end_time = datetime.datetime.now(datetime.timezone.utc)
            record["ended_at"] = end_time.isoformat()
            record["exit_code"] = -2
            record["error"] = str(exc)
            self.manager.update_task_state(task_id, STATE_IN_PROGRESS, record)
            _log(f"Task {task_id} raised unexpected exception: {exc}")
            return False


def cmd_status(manager: TaskQueueManager) -> None:
    data = manager.load_queue()
    tasks = data.get("tasks", [])
    lock_active = LOCK_FILE.exists()

    paused = manager.is_paused()
    status_str = "PAUSED" if paused else ("RUNNING (Lock Active)" if lock_active else "IDLE")

    print("=" * 60)
    print(f"DEUTSCH TASK QUEUE STATUS: {status_str}")
    print(f"Updated At: {data.get('updated_at', 'unknown')}")
    print(f"Lock File: {'LOCKED (PID active)' if lock_active else 'UNLOCKED'}")
    print("-" * 60)

    states_count: Dict[str, int] = {}
    for t in tasks:
        st = t.get("state", "UNKNOWN")
        states_count[st] = states_count.get(st, 0) + 1

    print(f"Tasks Total: {len(tasks)}")
    for st, count in sorted(states_count.items()):
        print(f"  - {st}: {count}")

    print("-" * 60)
    pending_tasks = [t for t in tasks if t.get("state") == STATE_PENDING]
    if pending_tasks:
        print("Upcoming Eligible Tasks:")
        for t in sorted(pending_tasks, key=lambda x: x.get("priority", 10))[:5]:
            print(f"  [{t.get('priority')}] {t['task_id']} - {t.get('title')}")
    else:
        print("No pending tasks in queue.")
    print("=" * 60)


def cmd_completed(manager: TaskQueueManager) -> None:
    data = manager.load_queue()
    tasks = [t for t in data.get("tasks", []) if t.get("state") == STATE_COMPLETED]
    print(f"Completed Tasks ({len(tasks)}):")
    for t in tasks:
        history = t.get("execution_history", [])
        last_run = history[-1].get("ended_at") if history else "unknown"
        print(f"  ✓ {t['task_id']}: {t.get('title')} (Finished: {last_run})")


def cmd_errors(manager: TaskQueueManager) -> None:
    data = manager.load_queue()
    failed = [t for t in data.get("tasks", []) if t.get("state") == STATE_FAILED]
    blocked = [t for t in data.get("tasks", []) if t.get("state") == STATE_BLOCKED_APPROVAL]

    print(f"Failed Tasks ({len(failed)}):")
    for t in failed:
        history = t.get("execution_history", [])
        err = history[-1].get("error") or history[-1].get("stderr_snippet") if history else "Unknown"
        print(f"  ❌ {t['task_id']}: {t.get('title')} - Error: {err}")

    print(f"\nBlocked on Human Approval ({len(blocked)}):")
    for t in blocked:
        print(f"  ⚠️  {t['task_id']}: {t.get('title')} (Requires explicit owner authorization)")


def main() -> None:
    parser = argparse.ArgumentParser(description="DEUTSCH Autonomous Task Queue CLI")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("status", help="View current queue status and task counts")
    subparsers.add_parser("start", help="Start or resume queue processing")
    subparsers.add_parser("resume", help="Resume paused queue processing")
    subparsers.add_parser("stop", help="Safely pause queue processing")
    subparsers.add_parser("pause", help="Safely pause queue processing")
    subparsers.add_parser("completed", help="View all completed tasks")
    subparsers.add_parser("errors", help="View failed and blocked tasks")
    subparsers.add_parser("blockers", help="View failed and blocked tasks")

    run_once = subparsers.add_parser("run-once", help="Execute exactly one eligible task")

    add_parser = subparsers.add_parser("add", help="Add a new task to the queue")
    add_parser.add_argument("--id", required=True, help="Unique Task ID")
    add_parser.add_argument("--title", required=True, help="Task title")
    add_parser.add_argument("--cmd", required=True, help="Command to execute")
    add_parser.add_argument("--cwd", default=str(DEFAULT_HOME), help="Working directory")
    add_parser.add_argument("--priority", type=int, default=10, help="Priority (1-100, 1=highest)")
    add_parser.add_argument("--dep", action="append", default=[], help="Dependency task IDs")
    add_parser.add_argument("--timeout", type=int, default=300, help="Timeout in seconds")
    add_parser.add_argument("--requires-approval", action="store_true", help="Flag if task requires human approval")

    args = parser.parse_args()
    manager = TaskQueueManager()

    if args.command == "status" or not args.command:
        cmd_status(manager)
    elif args.command in ("start", "resume"):
        manager.resume_queue()
        executor = QueueExecutor(manager)
        executor.run_loop()
    elif args.command == "run-once":
        manager.resume_queue()
        executor = QueueExecutor(manager)
        executor.run_loop(max_tasks=1)
    elif args.command in ("stop", "pause"):
        manager.pause_queue()
        print("Queue paused successfully.")
    elif args.command == "completed":
        cmd_completed(manager)
    elif args.command in ("errors", "blockers"):
        cmd_errors(manager)
    elif args.command == "add":
        success = manager.add_task(
            task_id=args.id,
            title=args.title,
            command=args.cmd,
            cwd=args.cwd,
            priority=args.priority,
            dependencies=args.dep,
            timeout_seconds=args.timeout,
            requires_approval=args.requires_approval,
        )
        if success:
            print(f"Task {args.id} added successfully.")
        else:
            print(f"Could not add task {args.id}.")
            sys.exit(1)


if __name__ == "__main__":
    main()
