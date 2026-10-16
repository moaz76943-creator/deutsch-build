import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch


QUEUE_PATH = Path(__file__).resolve().parents[2] / 'tools/automation/deutsch_task_queue.py'
spec = importlib.util.spec_from_file_location('deutsch_task_queue', QUEUE_PATH)
queue = importlib.util.module_from_spec(spec)
spec.loader.exec_module(queue)


class RetryBudgetTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        for name, value in {
            'QUEUE_DIR': root, 'LOG_FILE': root / 'execution.log',
            'PAUSE_FLAG_FILE': root / 'paused',
        }.items():
            p = patch.object(queue, name, value)
            p.start()
            self.addCleanup(p.stop)
        for name in ('_acquire_wake_lock', '_release_wake_lock', '_send_notification'):
            p = patch.object(queue, name)
            p.start()
            self.addCleanup(p.stop)
        p = patch.object(queue.time, 'sleep')
        p.start()
        self.addCleanup(p.stop)
        self.manager = queue.TaskQueueManager(root / 'queue.json')
        self.manager.add_task('retry-test', 'test', 'unused', str(root))
        self.executor = queue.QueueExecutor(self.manager)
        self.executor.lock = Mock()
        self.executor.lock.acquire.return_value = True

    def task(self):
        return self.manager.load_queue()['tasks'][0]

    def test_permanent_failure_stops_at_budget(self):
        with patch.object(self.executor, '_execute_task', return_value=False) as run:
            self.executor.run_loop(max_tasks=5)
        self.assertEqual(run.call_count, 2)
        self.assertEqual(self.task()['state'], queue.STATE_FAILED)
        self.assertEqual(self.task()['retries'], 2)

    def test_attempt_count_survives_new_manager_and_worker(self):
        with patch.object(self.executor, '_execute_task', return_value=False):
            self.executor.run_loop(max_tasks=1)
        reloaded = queue.TaskQueueManager(self.manager.queue_path)
        self.assertEqual(reloaded.load_queue()['tasks'][0]['retries'], 1)
        second = queue.QueueExecutor(reloaded)
        second.lock = Mock()
        second.lock.acquire.return_value = True
        with patch.object(second, '_execute_task', return_value=False) as run:
            second.run_loop(max_tasks=5)
        self.assertEqual(run.call_count, 1)
        self.assertEqual(self.task()['state'], queue.STATE_FAILED)
        self.assertEqual(self.task()['retries'], 2)

    def test_successful_retry_preserves_failure_count(self):
        with patch.object(self.executor, '_execute_task', side_effect=[False, True]) as run:
            self.executor.run_loop(max_tasks=3)
        self.assertEqual(run.call_count, 2)
        self.assertEqual(self.task()['state'], queue.STATE_COMPLETED)
        self.assertEqual(self.task()['retries'], 1)


if __name__ == '__main__':
    unittest.main()
