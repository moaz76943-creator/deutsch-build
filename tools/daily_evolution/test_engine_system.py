from unittest.mock import patch
import unittest
import tempfile
import shutil
import json
from pathlib import Path
from tools.daily_evolution.engine import EvolutionEngine as DailyEvolutionEngine, Task, TaskStatus
from tools.automation.scope_guard import ScopeGuard

class TestEngineSystem(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp())
        self.state_file = self.temp_dir / "state.json"

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_restart_recovery(self, mock_check):
        engine1 = DailyEvolutionEngine(db_path=self.state_file.as_posix())

        engine1.state["current_day"] = 3
        engine1._save_checkpoint_atomic()

        # Add a task
        engine1.tasks.append(Task(task_id="test_task", language_id="ar", track="A1", dependency="", ownership="", status=TaskStatus.READY))
        engine1._save_checkpoint_atomic()

        engine2 = DailyEvolutionEngine(db_path=self.state_file.as_posix())


        self.assertEqual(engine2.state["current_day"], 3)
        self.assertEqual(engine2.tasks[0].task_id, "test_task")

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_quota_exhaustion(self, mock_check):
        engine = DailyEvolutionEngine(db_path=self.state_file.as_posix(), max_jobs=2)


        engine._get_registered_languages = lambda: ["ar", "fr", "es"]

        # Run generate_tasks, should only produce up to max_parallel tasks
        tasks = engine.schedule_tasks()
        self.assertEqual(len(tasks), 2)

        # Set them to RUNNING
        for t in tasks:
            engine.tasks[0].status = TaskStatus.RUNNING
        engine.tasks[1].status = TaskStatus.RUNNING

        # Try generating again, should return empty list because quota is exhausted
        tasks2 = engine.schedule_tasks()
        self.assertEqual(len(tasks2), 2)



    @patch("tools.automation.scope_guard.ScopeGuard.check")
    def test_scope_guard(self, mock_check):
        task = Task('task_1', 'ar', 'A1', "", 'automation', TaskStatus.READY)
        engine = DailyEvolutionEngine()
        spec = engine._create_dispatch_spec(task)

        # Scenario 1: ScopeGuard returns True, but we have a running task.
        mock_check.return_value = True
        engine.tasks.append(Task('task_2', 'ar', 'A1', "", 'automation', TaskStatus.RUNNING))
        self.assertFalse(engine._enforce_scope_guard('ar'))

        # Scenario 2: ScopeGuard returns True, no running tasks.
        engine.tasks[0].status = TaskStatus.READY
        self.assertTrue(engine._enforce_scope_guard('ar'))

        # Scenario 3: ScopeGuard returns False.
        mock_check.return_value = False
        self.assertFalse(engine._enforce_scope_guard('ar'))
