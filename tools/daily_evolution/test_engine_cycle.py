from unittest.mock import patch
import unittest
import tempfile
import shutil
from pathlib import Path
from tools.daily_evolution.engine import EvolutionEngine as DailyEvolutionEngine, CYCLE_TRACKS as CYCLE_DAYS

class TestEngineCycle(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.state_file = Path(self.temp_dir) / "state.json"
        self.engine = DailyEvolutionEngine(db_path=self.state_file.as_posix())


    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch("tools.automation.scope_guard.ScopeGuard.check", return_value=True)
    def test_repeated_days(self, mock_check):
        # Test that 8-day cycle correctly rolls over
        phases_seen = []
        for _ in range(10):
            phases_seen.append(CYCLE_DAYS[self.engine.state["current_day"] % len(CYCLE_DAYS)])
            self.engine.advance_cycle(1)

        expected_phases = list(CYCLE_DAYS) + [CYCLE_DAYS[0], CYCLE_DAYS[1]]
        phases_seen = list(phases_seen)
        self.assertEqual(phases_seen, expected_phases)

if __name__ == '__main__':
    unittest.main()
