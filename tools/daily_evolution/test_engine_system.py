import unittest
import tempfile
import shutil
import json
from pathlib import Path
from tools.daily_evolution.engine import DailyEvolutionEngine, ScopeGuard, generate_specification, Task

class TestEngineSystem(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp())
        self.state_file = self.temp_dir / "state.json"

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    def test_restart_recovery(self):
        engine1 = DailyEvolutionEngine(state_file=self.state_file)
        engine1.load_state()
        engine1.day_index = 3
        engine1.save_state()

        # Add a task
        engine1.state["task_matrix"] = {
            "test_task": {"status": "READY", "task_id": "test_task"}
        }
        engine1.save_state()

        engine2 = DailyEvolutionEngine(state_file=self.state_file)
        engine2.load_state()

        self.assertEqual(engine2.day_index, 3)
        self.assertIn("test_task", engine2.state["task_matrix"])

    def test_quota_exhaustion(self):
        engine = DailyEvolutionEngine(state_file=self.state_file, max_parallel=2)
        engine.load_state()

        import tools.daily_evolution.engine
        original_languages = tools.daily_evolution.engine.LANGUAGES

        class Lang:
            def __init__(self, code):
                self.code = code
        tools.daily_evolution.engine.LANGUAGES = [Lang("ar"), Lang("fr"), Lang("es")]

        # Run generate_tasks, should only produce up to max_parallel tasks
        tasks = engine.generate_tasks()
        self.assertEqual(len(tasks), 2)

        # Set them to RUNNING
        for t in tasks:
            engine.update_task_status(t.task_id, "RUNNING")

        # Try generating again, should return empty list because quota is exhausted
        tasks2 = engine.generate_tasks()
        self.assertEqual(len(tasks2), 0)

        tools.daily_evolution.engine.LANGUAGES = original_languages

    def test_scope_guard(self):
        task = Task('task_1', 'ar', 'A1', None, 'automation', 'READY')
        spec = generate_specification(task)

        sg = ScopeGuard([
            'content/multilingual/sources/',
            'packs/',
            'tools/polyglot_v2/',
            'tools/automation/'
        ])

        # Should be verified
        self.assertTrue(sg.verify(spec))

        # Change allowed path to something forbidden
        spec["allowed_paths"] = ["outside/path/"]
        self.assertFalse(sg.verify(spec))

if __name__ == '__main__':
    unittest.main()
