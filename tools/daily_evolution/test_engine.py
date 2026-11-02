from unittest.mock import patch
import os
import shutil
import tempfile
import unittest
from pathlib import Path

from tools.daily_evolution.engine import EvolutionEngine, TaskStatus

class TestEvolutionEnginePart1(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.temp_dir, "task_matrix.json")
        self.assets_dir = os.path.join(self.temp_dir, "assets", "content", "packs")
        os.makedirs(self.assets_dir)

        # Mock 100 languages for the engine
        self.mock_languages = [f"lang_{i}" for i in range(100)]

        # Create a mock engine, overriding _get_registered_languages
        class MockEvolutionEngine(EvolutionEngine):
            def _get_registered_languages(self):
                return [f"lang_{i}" for i in range(100)]

        self.EngineClass = MockEvolutionEngine

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_no_source_data(self, mock_check):
        engine = self.EngineClass(db_path=self.db_path, assets_dir=self.assets_dir)

        # No languages have asset packs created, so all new tasks should be BLOCKED
        dispatches = engine.schedule_tasks()
        self.assertEqual(len(dispatches), 0)

        tasks = engine.tasks
        self.assertTrue(len(tasks) > 0)
        self.assertTrue(all(t.status == TaskStatus.BLOCKED for t in tasks))

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_fair_rotation(self, mock_check):
        # Create asset packs for all 100 languages
        for lang in self.mock_languages:
            os.makedirs(os.path.join(self.assets_dir, lang))

        engine = self.EngineClass(db_path=self.db_path, max_jobs=2, assets_dir=self.assets_dir)

        dispatches_day1 = engine.schedule_tasks()
        self.assertEqual(len(dispatches_day1), 2)

        # Verify it dispatched lang_0 and lang_1
        dispatched_langs_day1 = [d["mutable_scope"][0].split("/")[-2] for d in dispatches_day1]
        self.assertIn("lang_0", dispatched_langs_day1)
        self.assertIn("lang_1", dispatched_langs_day1)

        # Mark tasks as complete to allow new dispatch
        for t in engine.tasks:
            t.status = TaskStatus.COMPLETE

        dispatches_day1_later = engine.schedule_tasks()
        self.assertEqual(len(dispatches_day1_later), 2)
        dispatched_langs_day1_later = [d["mutable_scope"][0].split("/")[-2] for d in dispatches_day1_later]
        self.assertIn("lang_2", dispatched_langs_day1_later)
        self.assertIn("lang_3", dispatched_langs_day1_later)

if __name__ == '__main__':
    unittest.main()

class TestEvolutionEnginePart2(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.temp_dir, "task_matrix.json")
        self.assets_dir = os.path.join(self.temp_dir, "assets", "content", "packs")
        os.makedirs(self.assets_dir)

        self.mock_languages = [f"lang_{i}" for i in range(100)]
        for lang in self.mock_languages:
            os.makedirs(os.path.join(self.assets_dir, lang))

        class MockEvolutionEngine(EvolutionEngine):
            def _get_registered_languages(self):
                return [f"lang_{i}" for i in range(100)]

        self.EngineClass = MockEvolutionEngine

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_failed_jobs_retries(self, mock_check):
        engine = self.EngineClass(db_path=self.db_path, max_jobs=1, max_retries=2, assets_dir=self.assets_dir)

        dispatches = engine.schedule_tasks()
        self.assertEqual(len(dispatches), 1)

        task = engine.tasks[0]
        self.assertEqual(task.status, TaskStatus.RUNNING)
        self.assertEqual(task.retries, 0)

        # Fail the task
        task.status = TaskStatus.FAILED

        # Schedule again, should retry
        dispatches_retry1 = engine.schedule_tasks()
        self.assertEqual(len(dispatches_retry1), 1)
        self.assertEqual(task.status, TaskStatus.RUNNING)
        self.assertEqual(task.retries, 1)

        # Fail again
        task.status = TaskStatus.FAILED

        # Schedule again, should retry
        dispatches_retry2 = engine.schedule_tasks()
        self.assertEqual(len(dispatches_retry2), 1)
        self.assertEqual(task.status, TaskStatus.RUNNING)
        self.assertEqual(task.retries, 2)

        # Fail again
        task.status = TaskStatus.FAILED

        # Schedule again, should EXHAUST retries and schedule a DIFFERENT language instead
        dispatches_next = engine.schedule_tasks()
        self.assertEqual(len(dispatches_next), 1)
        self.assertEqual(task.status, TaskStatus.FAILED)
        self.assertEqual(task.retries, 2)

        self.assertEqual(engine.tasks[1].status, TaskStatus.RUNNING)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_restart_recovery(self, mock_check):
        engine = self.EngineClass(db_path=self.db_path, max_jobs=2, assets_dir=self.assets_dir)
        engine.advance_cycle(2)
        engine.schedule_tasks()

        self.assertEqual(engine.state["current_day"], 2)
        self.assertTrue(len(engine.tasks) > 0)

        # Create a new instance, should load from file
        engine_restarted = self.EngineClass(db_path=self.db_path, max_jobs=2, assets_dir=self.assets_dir)
        self.assertEqual(engine_restarted.state["current_day"], 2)
        self.assertEqual(len(engine_restarted.tasks), len(engine.tasks))
        self.assertEqual(engine_restarted.tasks[0].task_id, engine.tasks[0].task_id)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_quota_exhaustion(self, mock_check):
        engine = self.EngineClass(db_path=self.db_path, max_jobs=2, assets_dir=self.assets_dir)

        dispatches = engine.schedule_tasks()
        self.assertEqual(len(dispatches), 2)

        # The engine is at max capacity (2 RUNNING tasks).
        # Scheduling again without advancing/completing should yield the SAME dispatches (re-dispatching the RUNNING ones).
        # Or it should just yield the same 2 things without creating new ones.
        dispatches_again = engine.schedule_tasks()
        self.assertEqual(len(dispatches_again), 2)
        self.assertEqual(len(engine.tasks), 2) # No new tasks created

        # Complete one task
        engine.tasks[0].status = TaskStatus.COMPLETE
        dispatches_after_complete = engine.schedule_tasks()

        # It should dispatch the 1 still RUNNING and 1 NEW one
        self.assertEqual(len(dispatches_after_complete), 2)
        self.assertEqual(len(engine.tasks), 3)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_repeated_days_offline(self, mock_check):
        engine = self.EngineClass(db_path=self.db_path, max_jobs=5, assets_dir=self.assets_dir)
        engine.advance_cycle(7) # Skip offline days
        self.assertEqual(engine.state["current_day"], 7)
        dispatches = engine.schedule_tasks()
        # Should be maintenance cycle according to logic
        self.assertEqual(len(dispatches), 5)
        self.assertTrue("maintenance" in engine.tasks[0].track)
