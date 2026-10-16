import unittest
import tempfile
import shutil
import json
from pathlib import Path
from tools.daily_evolution.engine import DailyEvolutionEngine, Task

class TestEngineTasks(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp())
        self.state_file = self.temp_dir / "state.json"
        self.sources_dir = self.temp_dir / "sources"
        self.sources_dir.mkdir(parents=True, exist_ok=True)

        # Create dummy source for Arabic (ar), but not for French (fr)
        (self.sources_dir / "ar.json").write_text("{}")

        self.engine = DailyEvolutionEngine(
            state_file=self.state_file,
            sources_dir=self.sources_dir,
            max_parallel=2,
            max_retries=2
        )
        self.engine.load_state()

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    def test_offline_execution_and_no_source_data(self):
        # We need to test how it acts with the real languages module when possible
        # However, for isolated testing, we mock the LANGUAGES inside the engine
        import tools.daily_evolution.engine
        original_languages = tools.daily_evolution.engine.LANGUAGES

        # Mock with two languages: one has a source file, one doesn't
        class Lang:
            def __init__(self, code):
                self.code = code
        tools.daily_evolution.engine.LANGUAGES = [Lang("ar"), Lang("fr")]

        tasks = self.engine.generate_tasks()

        tools.daily_evolution.engine.LANGUAGES = original_languages

        self.assertEqual(len(tasks), 2)

        ar_task = next(t for t in tasks if t.language_id == "ar")
        fr_task = next(t for t in tasks if t.language_id == "fr")

        # Arabic should be READY because ar.json exists
        self.assertEqual(ar_task.status, "READY")

        # French should be BLOCKED because fr.json does NOT exist
        self.assertEqual(fr_task.status, "BLOCKED")

    def test_failed_jobs(self):
        # Add a running task to matrix
        task_id = "A1_ar_0"
        self.engine.state["task_matrix"] = {
            task_id: {
                "task_id": task_id,
                "language_id": "ar",
                "track": "A1",
                "dependency": None,
                "ownership": "automation",
                "status": "RUNNING",
                "retries": 0
            }
        }

        # First failure -> READY, 1 retry
        self.engine.update_task_status(task_id, "FAILED")
        t = self.engine.state["task_matrix"][task_id]
        self.assertEqual(t["status"], "READY")
        self.assertEqual(t["retries"], 1)

        # Second failure -> FAILED (max_retries is 2)
        self.engine.update_task_status(task_id, "FAILED")
        t = self.engine.state["task_matrix"][task_id]
        self.assertEqual(t["status"], "FAILED")
        self.assertEqual(t["retries"], 2)

if __name__ == '__main__':
    unittest.main()
