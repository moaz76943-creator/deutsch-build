import json
import os
import subprocess
import sys
import textwrap


TASK_ID = "task-event-concurrency-atomicity-test"


def test_concurrent_task_started_allows_exactly_one_writer(tmp_path):
    events = tmp_path / "events.ndjson"
    markers = tmp_path / "markers"
    markers.mkdir()

    worker = textwrap.dedent(
        """
        import os
        import pathlib
        import sys
        import time

        import tool.project_record_event as record

        events = pathlib.Path(os.environ["EVENTS_PATH"])
        marker_dir = pathlib.Path(os.environ["MARKER_DIR"])
        worker_id = os.environ["WORKER_ID"]

        record.EVENTS = events
        original_validate = record.validate_task_transition

        def synchronized_validate(*args, **kwargs):
            original_validate(*args, **kwargs)
            (marker_dir / worker_id).write_text("validated", encoding="utf-8")
            deadline = time.monotonic() + 10
            while len(list(marker_dir.iterdir())) < 2:
                if time.monotonic() >= deadline:
                    raise RuntimeError("peer did not reach pre-append barrier")
                time.sleep(0.01)

        record.validate_task_transition = synchronized_validate
        sys.argv = [
            "project_record_event.py",
            "--type", "task_started",
            "--status", "started",
            "--task-id", os.environ["TASK_ID"],
            "--evidence", "concurrency-regression",
        ]
        raise SystemExit(record.main())
        """
    )

    processes = []
    for worker_id in ("a", "b"):
        env = os.environ.copy()
        env.update(
            {
                "EVENTS_PATH": str(events),
                "MARKER_DIR": str(markers),
                "WORKER_ID": worker_id,
                "TASK_ID": TASK_ID,
            }
        )
        processes.append(
            subprocess.Popen(
                [sys.executable, "-c", worker],
                cwd=os.getcwd(),
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
        )

    results = [process.communicate(timeout=20) for process in processes]
    returncodes = [process.returncode for process in processes]

    assert sorted(returncodes) == [0, 2], results

    rows = [
        json.loads(line)
        for line in events.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    starts = [
        row
        for row in rows
        if row.get("task_id") == TASK_ID and row.get("type") == "task_started"
    ]
    assert len(starts) == 1, rows
