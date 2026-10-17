import unittest
import subprocess
import os
import shutil
import tempfile
<<<<<<< HEAD
from pathlib import Path

class TestBuildPipeline(unittest.TestCase):
    def test_scripts_syntax(self):
        scripts = ["build.sh", "build_guard.sh", "local-release.sh", "termux_release.sh", "signing_guard.sh", "common.sh", "doctor.sh"]
        for script in scripts:
            script_path = Path("scripts") / script
            if script_path.exists():
                res = subprocess.run(["bash", "-n", str(script_path)], capture_output=True)
                self.assertEqual(res.returncode, 0, f"{script} syntax error: {res.stderr.decode()}")

    def test_missing_tools(self):
        env = os.environ.copy()
        # Keep bash and coreutils, but missing flutter/dart
        # Assuming bash is in /bin
        env["PATH"] = "/bin:/usr/bin"
        res = subprocess.run(
            ["bash", "scripts/build_guard.sh"],
            env=env,
            capture_output=True
        )
        self.assertEqual(res.returncode, 10, f"Expected 10 (ERR_ENV), got {res.returncode}. Stderr: {res.stderr.decode()}")

    def test_insufficient_disk(self):
        with tempfile.TemporaryDirectory() as d:
            script = Path(d) / "test.sh"
            script.write_text("""#!/bin/bash
source scripts/common.sh
MIN_FREE_KB=1048576
check_disk_space "$1"
""")
            # Create a mock df script
            mock_df = Path(d) / "df"
            mock_df.write_text("""#!/bin/bash\necho "Filesystem 1K-blocks Used Available Use% Mounted on"\necho "/dev/mock 10000 1000 10 90% /" """)
            mock_df.chmod(0o755)

            env = os.environ.copy()
            env["PATH"] = f"{d}:{env.get('PATH', '')}"

            res = subprocess.run(["bash", str(script), d], env=env, capture_output=True)
            self.assertEqual(res.returncode, 10, f"Expected 10 (ERR_ENV), got {res.returncode}. Stderr: {res.stderr.decode()}")

    def test_failure_propagation(self):
        with tempfile.TemporaryDirectory() as d:
            script = Path(d) / "test.sh"
            script.write_text("""#!/bin/bash
source scripts/common.sh
fatal --code "$ERR_SIGN" "Signing failed"
""")
            res = subprocess.run(["bash", str(script)], capture_output=True)
            self.assertEqual(res.returncode, 13, f"Expected 13 (ERR_SIGN), got {res.returncode}. Stderr: {res.stderr.decode()}")

    def test_with_retry(self):
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "target.sh"
            state = Path(d) / "state.txt"
            state.write_text("0")

            target.write_text(f"""#!/bin/bash
count=$(cat "{state}")
count=$((count+1))
echo $count > "{state}"
if [ $count -lt 3 ]; then
  exit 1
fi
exit 0
""")
            target.chmod(0o755)

            script = Path(d) / "test.sh"
            script.write_text(f"""#!/bin/bash
source scripts/common.sh
with_retry {target}
""")
            res = subprocess.run(["bash", str(script)], capture_output=True)
            self.assertEqual(res.returncode, 0, f"Expected successful retry (return 0), got {res.returncode}")
            self.assertEqual(state.read_text().strip(), "3")
=======

class TestPipeline(unittest.TestCase):
    def setUp(self):
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.root_dir = os.path.dirname(self.script_dir)
        self.env = os.environ.copy()

    def run_script(self, script_name, env=None, cwd=None):
        script_path = os.path.join(self.script_dir, script_name)
        if env is None:
            env = self.env
        if cwd is None:
            cwd = self.root_dir
        # Run using an explicit bash path if we altered PATH heavily
        return subprocess.run(['/bin/bash', script_path], env=env, cwd=cwd, capture_output=True, text=True)

    def test_missing_java_environment_failure(self):
        temp_bin = tempfile.mkdtemp()
        try:
            # We mock common.sh to isolate the test to just the EXIT_ENV check.
            test_script = f"""
            source {os.path.join(self.script_dir, 'common.sh')}
            # Mock java check failure
            command -v missing_java >/dev/null 2>&1 || fatal "Java is not in PATH" "$EXIT_ENV"
            """
            result = subprocess.run(['/bin/bash', '-c', test_script], env=self.env, cwd=self.root_dir, capture_output=True, text=True)
            self.assertEqual(result.returncode, 10, msg=result.stderr)
            self.assertIn("Java is not in PATH", result.stderr)
        finally:
            shutil.rmtree(temp_bin)

    def test_insufficient_disk_space_failure(self):
        temp_bin = tempfile.mkdtemp()
        try:
            with open(os.path.join(temp_bin, 'df'), 'w') as f:
                f.write("#!/usr/bin/env bash\n")
                f.write("echo 'Filesystem 1024-blocks Used Available Capacity Mounted on'\n")
                f.write("echo '/dev/mock 1000 1000 10 99% /'\n") # 10 KiB available
            os.chmod(os.path.join(temp_bin, 'df'), 0o755)

            env = self.env.copy()
            # Insert temp_bin first, keeping standard paths to ensure basic tools exist
            env['PATH'] = temp_bin + os.pathsep + env.get('PATH', '/bin:/usr/bin')

            test_script = f"""
            source {os.path.join(self.script_dir, 'common.sh')}
            # Needs load_toolchain for MIN_FREE_KB
            load_toolchain
            check_disk_space /
            """

            result = subprocess.run(['/bin/bash', '-c', test_script], env=env, cwd=self.root_dir, capture_output=True, text=True)

            self.assertEqual(result.returncode, 10, msg=f"Out: {result.stdout}, Err: {result.stderr}")
            self.assertIn("Free space manually before building", result.stderr)
        finally:
            shutil.rmtree(temp_bin)

    def test_failure_propagation(self):
        temp_bin = tempfile.mkdtemp()
        try:
            with open(os.path.join(temp_bin, 'flutter'), 'w') as f:
                f.write("#!/usr/bin/env bash\n")
                f.write("if [[ \"$*\" == *\"build apk\"* ]]; then\n")
                f.write("  exit 1\n")
                f.write("fi\n")
                f.write("exit 0\n")
            os.chmod(os.path.join(temp_bin, 'flutter'), 0o755)

            test_script = f"""
            source {os.path.join(self.script_dir, 'common.sh')}
            DART_DEFINE=()
            flutter build apk --debug --target-platform android-arm64 || fatal "Flutter build apk (debug) failed" "$EXIT_COMP"
            """
            env = self.env.copy()
            env['PATH'] = temp_bin + os.pathsep + env.get('PATH', '/bin:/usr/bin')

            result = subprocess.run(['/bin/bash', '-c', test_script], env=env, cwd=self.root_dir, capture_output=True, text=True)
            self.assertEqual(result.returncode, 12, msg=result.stderr)
            self.assertIn("Flutter build apk (debug) failed", result.stderr)
        finally:
            shutil.rmtree(temp_bin)

    def test_cancellation_graceful_stop(self):
        # We test that exit code stops execution properly.
        test_script = f"""
        source {os.path.join(self.script_dir, 'common.sh')}
        fatal "Unrecoverable error" "$EXIT_COMP"
        echo "Should not reach here"
        """
        result = subprocess.run(['/bin/bash', '-c', test_script], env=self.env, cwd=self.root_dir, capture_output=True, text=True)
        self.assertEqual(result.returncode, 12, msg=result.stderr)
        self.assertIn("Unrecoverable error", result.stderr)
        self.assertNotIn("Should not reach here", result.stdout)

if __name__ == '__main__':
    unittest.main()
>>>>>>> pr-188
