import argparse
import json
import logging
import os
import re
import shutil
import statistics
import sqlite3
import subprocess
import sys
import time
import hashlib
from dataclasses import dataclass, asdict
from typing import Any, Dict, List, Optional, Tuple
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)

STATUS_PASS = "PASS"
STATUS_FAIL = "FAIL"
STATUS_BLOCKED = "BLOCKED"
STATUS_NOT_RUN = "NOT_RUN"

@dataclass
class GateResult:
    status: str
    message: str
    details: Optional[Dict[str, Any]] = None

    def to_dict(self):
        return {
            "status": self.status,
            "message": self.message,
            "details": self.details or {}
        }

def run_command(command: List[str], cwd: str = ".", env: Optional[Dict[str, str]] = None) -> Tuple[int, str, str]:
    try:
        process = subprocess.Popen(
            command,
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env
        )
        stdout, stderr = process.communicate()
        return process.returncode, stdout, stderr
    except Exception as e:
        return -1, "", str(e)

def _parse_analyzer_output(stdout: str, stderr: str) -> bool:
    if "error •" in stdout.lower() or "error •" in stderr.lower():
        return False
    return True

def run_dart_analyzer() -> GateResult:
    logger.info("Running Dart Analyzer...")
    returncode, stdout, stderr = run_command(["flutter", "analyze", "lib/"])
    if returncode == -1:
         return GateResult(STATUS_BLOCKED, "Failed to execute analyzer", {"error": stderr})

    if returncode != 0:
        if not _parse_analyzer_output(stdout, stderr):
            return GateResult(STATUS_FAIL, "Analyzer found blocking errors", {"stdout": stdout, "stderr": stderr})
        return GateResult(STATUS_FAIL, "Analyzer found non-blocking issues but exited non-zero", {"stdout": stdout, "stderr": stderr})

    return GateResult(STATUS_PASS, "Analyzer passed")

def sqlite_to_dict(row: tuple) -> tuple:
    def convert(val):
        if isinstance(val, bytes):
            return val.hex()
        return val
    return tuple(convert(v) for v in row)

def run_sqlite_check(repo_root: Path) -> GateResult:
    logger.info("Checking SQLite corruption/schema and content hashes...")
    dbs = list(repo_root.rglob("assets/content/packs/*/sqlite/*.sqlite"))
    if not dbs:
        dbs = list(repo_root.rglob("tests/fixtures/*.sqlite"))

    if not dbs:
        return GateResult(STATUS_BLOCKED, "No SQLite databases found")

    overall_details = {"checked_dbs": len(dbs)}
    for db_path in dbs:
        try:
            conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
            cursor = conn.cursor()

            # Integrity
            cursor.execute("PRAGMA integrity_check")
            res = cursor.fetchone()
            if res[0] != "ok":
                conn.close()
                return GateResult(STATUS_FAIL, f"SQLite integrity check failed for {db_path.name}", overall_details)

            # Schema validation
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = [r[0] for r in cursor.fetchall()]
            if not tables:
                conn.close()
                return GateResult(STATUS_FAIL, f"No tables found in {db_path.name}", overall_details)

            # Content hash
            content_hashes = []
            for table in tables:
                if table.startswith("sqlite_"): continue
                try:
                    cursor.execute(f"SELECT * FROM {table}")
                    rows = [sqlite_to_dict(r) for r in cursor.fetchall()]
                    content_str = json.dumps(rows, sort_keys=True)
                    content_hashes.append(hashlib.sha256(content_str.encode()).hexdigest())
                except sqlite3.Error:
                    pass

            if not content_hashes:
                conn.close()
                return GateResult(STATUS_FAIL, f"Could not generate content hashes for {db_path.name}", overall_details)

            conn.close()
        except sqlite3.Error as e:
            return GateResult(STATUS_FAIL, f"SQLite error for {db_path.name}: {e}", overall_details)

    return GateResult(STATUS_PASS, "SQLite checks passed", overall_details)

def run_benchmark_fts5(repo_root: Path, threshold_p50: float = 20.0, threshold_p95: float = 50.0) -> GateResult:
    logger.info("Checking FTS5 latencies directly via Python...")
    dbs = list(repo_root.rglob("assets/content/packs/*/sqlite/*.sqlite"))
    if not dbs:
        dbs = list(repo_root.rglob("tests/fixtures/*.sqlite"))

    if not dbs:
        return GateResult(STATUS_BLOCKED, "No SQLite databases found for FTS5 benchmarking")

    overall_p95 = 0.0
    overall_p50 = 0.0

    for db_path in dbs:
        try:
            conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND sql LIKE '%FTS5%'")
            fts_tables = [r[0] for r in cursor.fetchall()]

            latencies = []
            if fts_tables:
                for fts_table in fts_tables:
                    for _ in range(100):
                        start = time.perf_counter()
                        cursor.execute(f"SELECT * FROM {fts_table} WHERE {fts_table} MATCH 'a*' LIMIT 10")
                        cursor.fetchall()
                        latencies.append((time.perf_counter() - start) * 1000)

            conn.close()

            if latencies:
                latencies.sort()
                p50 = statistics.median(latencies)
                p95 = statistics.quantiles(latencies, n=20)[18]
                overall_p50 = max(overall_p50, p50)
                overall_p95 = max(overall_p95, p95)
        except sqlite3.Error as e:
            return GateResult(STATUS_FAIL, f"SQLite FTS5 query error on {db_path.name}: {e}")

    details = {
        "p50_latency_ms": overall_p50,
        "p95_latency_ms": overall_p95
    }

    if overall_p50 > threshold_p50:
         return GateResult(STATUS_FAIL, f"FTS5 p50 latency {overall_p50:.2f}ms exceeds threshold {threshold_p50}ms", details)
    if overall_p95 > threshold_p95:
         return GateResult(STATUS_FAIL, f"FTS5 p95 latency {overall_p95:.2f}ms exceeds threshold {threshold_p95}ms", details)

    return GateResult(STATUS_PASS, "FTS5 benchmarks passed", details)

def run_benchmark_memory(repo_root: Path, limit_mb: float = 256.0) -> GateResult:
    logger.info("Checking peak memory...")
    target_test = "test/benchmark_test.dart"
    if not (repo_root / target_test).exists():
        return GateResult(STATUS_BLOCKED, "Missing memory benchmark test script")

    if not shutil.which("time") and not os.path.exists("/usr/bin/time"):
        return GateResult(STATUS_BLOCKED, "Missing time toolchain")

    # In a real environment, we'd use GNU time, or parse memory output from the test
    # We will simulate memory profiling with /usr/bin/time -v for now
    cmd = ["/usr/bin/time", "-v", "flutter", "test", target_test]
    if not os.path.exists("/usr/bin/time"):
        # fallback for environments where time is not in /usr/bin but in PATH
        cmd = ["time", "-v", "flutter", "test", target_test]

    returncode, stdout, stderr = run_command(cmd, cwd=str(repo_root))

    if returncode != 0:
        return GateResult(STATUS_FAIL, "Memory test execution failed", {"stderr": stderr})

    max_rss = 0.0
    for line in stderr.splitlines():
        if "Maximum resident set size" in line:
            # Memory in KB usually
            try:
                max_rss_kb = int(line.split(":")[-1].strip())
                max_rss = max_rss_kb / 1024.0
            except ValueError:
                pass
            break

    # If time -v is not available or doesn't output, try to parse from test output as fallback
    if max_rss == 0.0:
        match = re.search(r"MEMORY_PEAK_MB:\s*([\d.]+)", stdout)
        if match:
            max_rss = float(match.group(1))

    if max_rss == 0.0:
        return GateResult(STATUS_BLOCKED, "Could not extract memory peak metrics")

    details = {"peak_memory_mb": max_rss}
    if max_rss > limit_mb:
        return GateResult(STATUS_FAIL, f"Memory peak {max_rss:.2f}MB exceeds limit {limit_mb}MB", details)

    return GateResult(STATUS_PASS, "Memory check passed", details)

def run_startup_tests(repo_root: Path, mode: str = "normal", threshold_ms: float = 1500.0) -> GateResult:
    logger.info(f"Checking startup in {mode} mode...")
    target_test = "test/bootstrap/production_bootstrap_test.dart"
    if not (repo_root / target_test).exists():
         # Fallback to general test if specific one is missing
         target_test = "test/benchmark_test.dart"
         if not (repo_root / target_test).exists():
            return GateResult(STATUS_BLOCKED, f"Missing startup tests for {mode} mode")

    env = os.environ.copy()
    env["STARTUP_MODE"] = mode
    if mode == "safe":
        env["SAFE_MODE"] = "1"

    start = time.perf_counter()
    returncode, stdout, stderr = run_command(["flutter", "test", target_test], cwd=str(repo_root), env=env)
    elapsed_ms = (time.perf_counter() - start) * 1000

    if returncode != 0:
        return GateResult(STATUS_FAIL, f"Startup tests failed in {mode} mode", {"stdout": stdout, "stderr": stderr})

    # Check if test outputs specific STARTUP_TIME_MS:
    match = re.search(r"STARTUP_TIME_MS:\s*([\d.]+)", stdout)
    if not match:
        return GateResult(STATUS_BLOCKED, "Could not extract STARTUP_TIME_MS metrics")
    parsed_duration = float(match.group(1))

    details = {"latency_ms": parsed_duration}
    if parsed_duration > threshold_ms:
        return GateResult(STATUS_FAIL, f"Startup time {parsed_duration:.2f}ms exceeds threshold {threshold_ms}ms in {mode} mode", details)

    return GateResult(STATUS_PASS, f"Startup test passed in {mode} mode", details)

def compare_baselines(manifest_current: str, manifest_baseline: str) -> GateResult:
    logger.info("Performing pre-repair and post-repair baseline comparison...")
    if not os.path.exists(manifest_baseline):
        return GateResult(STATUS_NOT_RUN, "Baseline manifest not found")

    try:
        with open(manifest_baseline, 'r') as f:
            baseline = json.load(f)
        with open(manifest_current, 'r') as f:
            current = json.load(f)

        b_res = baseline.get("results", {})
        c_res = current.get("results", {})

        # Check if Dart analyzer degraded
        if c_res.get("dart_analyzer", {}).get("status") == STATUS_FAIL and b_res.get("dart_analyzer", {}).get("status") == STATUS_PASS:
             return GateResult(STATUS_FAIL, "Dart analyzer degraded from PASS to FAIL")

        # Function to compare metrics with tolerance
        def compare_metric(name: str, baseline_val: float, current_val: float, abs_tol: float, pct_tol: float) -> Optional[str]:
            if baseline_val > 0:
                if current_val > baseline_val * (1 + pct_tol) and current_val - baseline_val > abs_tol:
                    return f"{name} regressed: {current_val:.2f} > {baseline_val:.2f} (beyond tolerances)"
            return None

        regressions = []

        # Benchmarks FTS5
        b_fts5 = b_res.get("benchmark_fts5", {}).get("details", {})
        c_fts5 = c_res.get("benchmark_fts5", {}).get("details", {})
        if b_fts5 and c_fts5:
            res = compare_metric("FTS5 p50", b_fts5.get("p50_latency_ms", 0), c_fts5.get("p50_latency_ms", 0), 100, 0.20)
            if res: regressions.append(res)
            res = compare_metric("FTS5 p95", b_fts5.get("p95_latency_ms", 0), c_fts5.get("p95_latency_ms", 0), 100, 0.20)
            if res: regressions.append(res)

        # Memory Peak
        b_mem = b_res.get("benchmark_memory", {}).get("details", {})
        c_mem = c_res.get("benchmark_memory", {}).get("details", {})
        if b_mem and c_mem:
             res = compare_metric("Memory Peak", b_mem.get("peak_memory_mb", 0), c_mem.get("peak_memory_mb", 0), 5, 0.20)
             if res: regressions.append(res)

        # Startup latencies
        for mode in ["normal", "safe"]:
            key = f"startup_{mode}"
            b_start = b_res.get(key, {}).get("details", {})
            c_start = c_res.get(key, {}).get("details", {})
            if b_start and c_start:
                 res = compare_metric(f"Startup {mode}", b_start.get("latency_ms", 0), c_start.get("latency_ms", 0), 100, 0.20)
                 if res: regressions.append(res)

        if regressions:
            return GateResult(STATUS_FAIL, "Regressions detected compared to baseline", {"regressions": regressions})

        return GateResult(STATUS_PASS, "No regressions detected compared to baseline")

    except Exception as e:
         return GateResult(STATUS_BLOCKED, f"Failed to compare baselines: {e}")

def generate_manifest(results: Dict[str, GateResult], output_file: str) -> str:
    overall_status = STATUS_PASS
    if any(res.status == STATUS_FAIL for res in results.values()):
        overall_status = STATUS_FAIL
    elif any(res.status == STATUS_BLOCKED for res in results.values()):
         overall_status = STATUS_BLOCKED
    elif any(res.status == STATUS_NOT_RUN for res in results.values()):
         overall_status = STATUS_NOT_RUN

    manifest = {
        "timestamp": time.time(),
        "overall_status": overall_status,
        "results": {k: v.to_dict() for k, v in results.items()}
    }

    content_str = json.dumps(manifest, sort_keys=True)
    manifest["hash"] = hashlib.sha256(content_str.encode()).hexdigest()

    os.makedirs(os.path.dirname(output_file) or ".", exist_ok=True)
    with open(output_file, 'w') as f:
         json.dump(manifest, f, indent=2)
    logger.info(f"Manifest written to {output_file}")

    return overall_status

def main():
    parser = argparse.ArgumentParser(description="Zero-Regression Performance & Compilation Gate")
    parser.add_argument("--repo-root", type=str, default=".", help="Path to repository root")
    parser.add_argument("--output", type=str, default="reports/zero_regression_gate_manifest.json")
    parser.add_argument("--baseline", type=str, default="reports/baseline_manifest.json", help="Path to baseline manifest for comparison")
    args = parser.parse_args()

    root = Path(args.repo_root).resolve()
    results = {}

    results["dart_analyzer"] = run_dart_analyzer()
    results["sqlite_integrity"] = run_sqlite_check(root)
    results["benchmark_fts5"] = run_benchmark_fts5(root)
    results["benchmark_memory"] = run_benchmark_memory(root)
    results["startup_normal"] = run_startup_tests(root, mode="normal")
    results["startup_safe"] = run_startup_tests(root, mode="safe")

    # Generate the current manifest first before comparison
    overall = generate_manifest(results, args.output)

    # Implement pre-repair and post-repair baseline comparison.
    results["baseline_comparison"] = compare_baselines(args.output, args.baseline)

    # Re-evaluate overall after baseline comparison
    overall = generate_manifest(results, args.output)

    if overall != STATUS_PASS:
         logger.error(f"Gatekeeper failed with status: {overall}")
         sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    sys.exit(main())
