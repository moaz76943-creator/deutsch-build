import unittest
import subprocess
import tempfile
import os

class TestBuildPipeline(unittest.TestCase):
    def test_missing_flutter_environment(self):
        """Simulates an environment with no flutter in PATH and expects ERR_ENV (10)."""
        env = os.environ.copy()
        # Remove flutter from path
        env["PATH"] = "/bin:/usr/bin"
        process = subprocess.run(
            ["bash", "scripts/build_guard.sh"],
            env=env,
            capture_output=True,
            text=True
        )
        self.assertEqual(process.returncode, 10, msg=f"Expected code 10, got {process.returncode}\n{process.stderr}")

    def test_insufficient_disk_space(self):
        """Mocks df to simulate insufficient disk space and expects ERR_ENV (10)."""
        with tempfile.TemporaryDirectory() as d:
            mock_df_path = os.path.join(d, "df")
            with open(mock_df_path, "w") as f:
                f.write("#!/bin/sh\n")
                f.write('echo "Filesystem 1K-blocks Used Available Use% Mounted on"\n')
                f.write('echo "/dev/mock 1000000 900000 500 99% /"\n') # Only 500kb available, fails check
            os.chmod(mock_df_path, 0o755)

            env = os.environ.copy()
            env["PATH"] = d + ":" + env["PATH"]

            # The check_disk_space function is used in check-disk-space.sh
            process = subprocess.run(
                ["bash", "-c", "source scripts/common.sh && load_toolchain && check_disk_space /"],
                env=env,
                capture_output=True,
                text=True
            )
            self.assertEqual(process.returncode, 10, msg=f"Expected code 10, got {process.returncode}\n{process.stderr}")

    def test_redact_secrets(self):
        """Tests if the redact_secrets sed command properly masks passwords."""
        process = subprocess.run(
            ["bash", "-c", "source scripts/common.sh && echo 'storePassword=secret storeFile=key.jks --pass secret2 --pass=secret3' | redact_secrets"],
            capture_output=True,
            text=True
        )
        output = process.stdout.strip()
        self.assertEqual(output, "storePassword=[REDACTED] storeFile=key.jks --pass [REDACTED] --pass=[REDACTED]")

    def test_run_with_retry_transient_error(self):
        """Tests if run_with_retry handles transient errors."""
        script_content = '''#!/usr/bin/env bash
source scripts/common.sh

fail_then_succeed() {
    if [ ! -f /tmp/test_transient_marker ]; then
        touch /tmp/test_transient_marker
        echo "network error occurred" >&2
        return 1
    else
        rm /tmp/test_transient_marker
        echo "Success on retry"
        return 0
    fi
}
rm -f /tmp/test_transient_marker
with_retry fail_then_succeed
# We exit explicitly here to pass the exit code to python
sys_exit_code=$?
echo $sys_exit_code > /tmp/test_transient_code
'''
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(script_content)
            script_path = f.name

        try:
            subprocess.run(["bash", script_path], capture_output=True, text=True)
            with open("/tmp/test_transient_code", "r") as f:
                code = int(f.read().strip())
            self.assertEqual(code, 0, msg="Expected success on retry")
        finally:
            os.remove(script_path)
            if os.path.exists("/tmp/test_transient_code"):
                os.remove("/tmp/test_transient_code")

if __name__ == '__main__':
    unittest.main()
