import unittest
import subprocess
import os
import shutil
import tempfile
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
  echo "network error" >&2
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
