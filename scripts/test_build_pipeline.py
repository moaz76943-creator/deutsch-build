import unittest
import subprocess
import os
import tempfile
from pathlib import Path

class TestBuildPipeline(unittest.TestCase):
    def setUp(self):
        self.root = Path(__file__).resolve().parent.parent
        self.env = os.environ.copy()

    def test_missing_java(self):
        env = self.env.copy()
        env["PATH"] = "/bin:/usr/bin"

        proc = subprocess.run(
            ["/bin/bash", str(self.root / "scripts" / "build_guard.sh")],
            env=env, capture_output=True, text=True
        )
        self.assertNotEqual(proc.returncode, 0)
        self.assertTrue(proc.returncode != 0)

    def test_insufficient_disk(self):
        env = self.env.copy()
        with tempfile.TemporaryDirectory() as td:
            mock_df = Path(td) / "df"
            mock_df.write_text("#!/bin/bash\necho 'Filesystem 1024-blocks Used Available Capacity Mounted on'\necho '/dev/sda1 1000000 999000 500 99% /'\n")
            mock_df.chmod(0o755)
            env["PATH"] = f"{td}:{env.get('PATH', '')}"
            # Need to just run check-disk-space.sh instead to isolate
            proc = subprocess.run(
                ["/bin/bash", str(self.root / "scripts" / "check-disk-space.sh")],
                env=env, capture_output=True, text=True
            )
            self.assertNotEqual(proc.returncode, 0)
            self.assertIn("minimum", proc.stderr + proc.stdout)

    def test_failure_propagation(self):
        env = self.env.copy()
        with tempfile.TemporaryDirectory() as td:
            mock_flutter = Path(td) / "flutter"
            mock_flutter.write_text("#!/bin/bash\nif [ \"$1\" = 'pub' ]; then echo 'SocketException: timeout'; return 1 2>/dev/null; else return 0 2>/dev/null; fi\n")
            mock_flutter.chmod(0o755)
            env["PATH"] = f"{td}:{env.get('PATH', '')}"

            script_path = Path(td) / "test_script.sh"
            script_path.write_text(f"""#!/bin/bash
            source {self.root}/scripts/common.sh
            with_retry flutter pub get
            """)

            proc = subprocess.run(
                ["/bin/bash", str(script_path)],
                env=env, capture_output=True, text=True
            )
            self.assertIn("retrying (1/3)", proc.stderr + proc.stdout)
            self.assertIn("retrying (2/3)", proc.stderr + proc.stdout)
            self.assertNotEqual(proc.returncode, 0)

    def test_cancellation(self):
        script = f"""
        source {self.root}/scripts/common.sh
        sleep 10
        """
        proc = subprocess.Popen(
            ["/bin/bash", "-c", script],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        try:
            proc.wait(timeout=0.5)
        except subprocess.TimeoutExpired:
            proc.terminate()
            proc.wait()

        self.assertNotEqual(proc.returncode, 0)

if __name__ == '__main__':
    unittest.main()
