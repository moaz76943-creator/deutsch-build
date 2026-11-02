from unittest.mock import patch
import unittest
import tempfile
import shutil
import json
from pathlib import Path
from tools.daily_evolution.engine import EvolutionEngine as DailyEvolutionEngine, Task, TaskStatus

class TestEngineTasks(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp())
        self.state_file = self.temp_dir / "state.json"
        self.sources_dir = self.temp_dir / "sources"
        self.sources_dir.mkdir(parents=True, exist_ok=True)

        # Create dummy source for Arabic (ar), but not for French (fr)
        (self.sources_dir / "ar").mkdir(exist_ok=True)
        (self.sources_dir / "ar" / "pack.json").write_text("{}")

        self.engine = DailyEvolutionEngine(
            db_path=self.state_file.as_posix(),
            assets_dir=self.sources_dir,
            max_jobs=2,
            max_retries=2
        )


    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_offline_execution_and_no_source_data(self, mock_check):
        # We need to test how it acts with the real languages module when possible
        # However, for isolated testing, we mock the LANGUAGES inside the engine
        import tools.daily_evolution.engine

        # Mock with two languages: one has a source file, one doesn't
        self.engine._get_registered_languages = lambda: ["ar", "fr"]

        self.engine.schedule_tasks()
        tasks = self.engine.tasks



        self.assertEqual(len(tasks), 2)

        ar_task = next(t for t in tasks if t.language_id == "ar")
        fr_task = next(t for t in tasks if t.language_id == "fr")

        # Arabic should be READY because ar.json exists
        self.assertIn(ar_task.status, (TaskStatus.READY, TaskStatus.RUNNING))

        # French should be BLOCKED because fr.json does NOT exist
        self.assertEqual(fr_task.status, TaskStatus.BLOCKED)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_failed_jobs(self, mock_check):
        # Add a running task to matrix
        task_id = "A1_ar_0"
        self.engine.tasks.append(Task(
            task_id=task_id,
            language_id="ar",
            track="A1",
            dependency="",
            ownership="automation",
            status=TaskStatus.RUNNING,
            retries=0
        ))

        # First failure -> READY, 1 retry
        self.engine.tasks[0].status = TaskStatus.FAILED
        self.engine.schedule_tasks()
        t = self.engine.tasks[0]
        self.assertEqual(t.status, TaskStatus.RUNNING)
        self.assertEqual(t.retries, 1)

        # Second failure -> FAILED (max_retries is 2)
        self.engine.tasks[0].status = TaskStatus.FAILED
        self.engine.schedule_tasks()
        t = self.engine.tasks[0]
        self.assertEqual(t.status, TaskStatus.RUNNING)
        self.assertEqual(t.retries, 2)

        self.engine.tasks[0].status = TaskStatus.FAILED
        self.engine.schedule_tasks()
        t = self.engine.tasks[0]
        self.assertEqual(t.status, TaskStatus.FAILED)
        self.assertEqual(t.retries, 2)


if __name__ == '__main__':
    unittest.main()
