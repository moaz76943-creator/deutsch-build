import unittest
import tempfile
import shutil
from pathlib import Path
from tools.daily_evolution.engine import DailyEvolutionEngine, CYCLE_DAYS

class TestEngineCycle(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.state_file = Path(self.temp_dir) / "state.json"
        self.engine = DailyEvolutionEngine(state_file=self.state_file)
        self.engine.load_state()

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    def test_repeated_days(self):
        # Test that 8-day cycle correctly rolls over
        phases_seen = []
        for _ in range(10):
            phases_seen.append(self.engine.get_current_phase())
            self.engine.advance_day()

        expected_phases = CYCLE_DAYS + [CYCLE_DAYS[0], CYCLE_DAYS[1]]
        self.assertEqual(phases_seen, expected_phases)

if __name__ == '__main__':
    unittest.main()
