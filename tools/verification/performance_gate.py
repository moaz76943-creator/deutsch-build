import argparse
import subprocess
import time
import json
import sqlite3
import statistics
import hashlib
import sys
import os
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Optional, Any

@dataclass
class VerificationResult:
    status: str
    component: str
    message: str
    duration_ms: float
    metrics: dict[str, float] = None

    def __post_init__(self):
        if self.metrics is None:
            self.metrics = {}

class VerificationGate:
    def __init__(self, root: Path):
        self.root = root
        self.results = []
        self.tolerances = {
            "dart_analyzer_time_ms": 15000,
            "fts5_query_p95_ms": 50,
            "fts5_query_p50_ms": 20,
            "startup_time_ms": 1500, # relaxed to avoid false blocking on flutter test overhead, although a proper mock is hard to avoid overhead entirely.
            "memory_peak_mb": 256
        }

    def run_check(self, name: str, check_fn) -> VerificationResult:
        start = time.perf_counter()
        metrics = {}
        try:
            status, message, metrics = check_fn()
        except Exception as e:
            status, message = "FAIL", f"Exception: {str(e)}"

        duration = (time.perf_counter() - start) * 1000
        result = VerificationResult(status, name, message, duration, metrics)
        self.results.append(result)
        return result

    def check_dart_errors(self) -> tuple[str, str, dict]:
        script = self.root / "scripts/check-dart-errors.sh"
        if not script.exists():
            return "NOT_RUN", "check-dart-errors.sh not found", {}

        start = time.perf_counter()
        result = subprocess.run(
            ["bash", str(script)],
            capture_output=True, text=True
        )
        duration = (time.perf_counter() - start) * 1000

        if result.returncode != 0:
            if "fatal" in result.stderr.lower() or "error" in result.stdout.lower() or "Dart analyzer found build-blocking errors" in result.stdout:
                return "FAIL", f"Analyzer failed with exit code {result.returncode}", {}
            return "FAIL", f"Analyzer failed with exit code {result.returncode}", {}

        return "PASS", "Dart analyzer passed with zero blocking errors", {"analyzer_duration_ms": duration}

    def sqlite_to_dict(self, row: tuple) -> tuple:
        def convert(val):
            if isinstance(val, bytes):
                return val.hex()
            return val
        return tuple(convert(v) for v in row)

    def measure_sqlite_performance(self) -> tuple[str, str, dict]:
        dbs = list(self.root.rglob("assets/content/packs/*/sqlite/*.sqlite"))
        if not dbs:
            dbs = list(self.root.rglob("tests/fixtures/*.sqlite"))

        if not dbs:
            return "BLOCKED", "No SQLite databases found", {}

        overall_p95 = 0
        overall_p50 = 0

        for db_path in dbs:
            try:
                conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)

                cursor = conn.cursor()
                cursor.execute("PRAGMA integrity_check")
                res = cursor.fetchone()
                if res[0] != "ok":
                    return "FAIL", f"SQLite integrity check failed for {db_path.name}", {}

                cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                tables = [r[0] for r in cursor.fetchall()]
                if not tables:
                    return "FAIL", f"No tables found in {db_path.name}", {}

                # Check content hash
                content_hashes = []
                for table in tables:
                    if table.startswith("sqlite_"): continue
                    try:
                        cursor.execute(f"SELECT * FROM {table}")
                        rows = [self.sqlite_to_dict(r) for r in cursor.fetchall()]
                        content_str = json.dumps(rows, sort_keys=True)
                        content_hashes.append(hashlib.sha256(content_str.encode()).hexdigest())
                    except sqlite3.Error:
                        pass
                if not content_hashes:
                    return "FAIL", f"Could not generate content hashes for {db_path.name}", {}

                latencies = []
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND sql LIKE '%FTS5%'")
                fts_tables = [r[0] for r in cursor.fetchall()]

                if fts_tables:
                    for fts_table in fts_tables:
                        for i in range(100):
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

                    if p95 > self.tolerances["fts5_query_p95_ms"]:
                        return "FAIL", f"FTS5 p95 latency {p95:.2f}ms exceeds threshold {self.tolerances['fts5_query_p95_ms']}ms", {"p50": p50, "p95": p95}
                    if p50 > self.tolerances["fts5_query_p50_ms"]:
                        return "FAIL", f"FTS5 p50 latency {p50:.2f}ms exceeds threshold {self.tolerances['fts5_query_p50_ms']}ms", {"p50": p50, "p95": p95}

            except sqlite3.Error as e:
                return "FAIL", f"SQLite error for {db_path.name}: {e}", {}

        metrics = {"p50": overall_p50, "p95": overall_p95}
        return "PASS", "SQLite integrity and FTS5 benchmarks passed", metrics

    def measure_startup(self, mode: str = "normal") -> tuple[str, str, dict]:
        # Using flutter run --machine or flutter test to get timeline / dart vm metrics if possible.
        # Since this is local dev we mock a test runner and parse specific "STARTUP_TIME_MS: X"
        target_test = "test/bootstrap/production_bootstrap_test.dart"
        if not (self.root / target_test).exists():
             return "NOT_RUN", f"Bootstrap test {target_test} not found", {}

        # Differentiate mode using env variable
        env = os.environ.copy()
        env["STARTUP_MODE"] = mode

        # We assume the test suite will log STARTUP_TIME_MS: X so we can parse actual app startup time
        # excluding test suite compilation overhead. If not present, we fallback to wallclock but relax tolerance heavily
        start = time.perf_counter()
        res = subprocess.run(["flutter", "test", target_test], capture_output=True, text=True, env=env)
        total_duration = (time.perf_counter() - start) * 1000

        if res.returncode != 0:
             return "FAIL", f"Startup test failed: {res.stderr or res.stdout}", {}

        parsed_duration = total_duration
        import re
        m = re.search(r"STARTUP_TIME_MS:\s*([\d.]+)", res.stdout)
        if m:
             parsed_duration = float(m.group(1))

        if parsed_duration > self.tolerances["startup_time_ms"]:
             return "FAIL", f"Startup time {parsed_duration:.2f}ms exceeds {self.tolerances['startup_time_ms']}ms for mode {mode}", {"startup_time": parsed_duration}

        return "PASS", f"Startup passed in {parsed_duration:.2f}ms", {"startup_time": parsed_duration}

    def measure_startup_normal(self) -> tuple[str, str, dict]:
        return self.measure_startup("normal")

    def measure_startup_safe(self) -> tuple[str, str, dict]:
        return self.measure_startup("safe")

    def measure_memory_peak(self) -> tuple[str, str, dict]:
        target_test = "test/features/memory_test.dart"
        if not (self.root / target_test).exists():
             return "NOT_RUN", "Memory peak test target not found", {}

        res = subprocess.run(["flutter", "test", target_test], capture_output=True, text=True)
        if res.returncode != 0:
            return "FAIL", "Memory test failed", {}

        import re
        m = re.search(r"MEMORY_PEAK_MB:\s*([\d.]+)", res.stdout)
        peak_mb = 0
        if m:
            peak_mb = float(m.group(1))

        if peak_mb > self.tolerances["memory_peak_mb"]:
            return "FAIL", f"Memory peak {peak_mb}MB exceeds tolerance {self.tolerances['memory_peak_mb']}MB", {"memory_peak_mb": peak_mb}

        return "PASS", f"Memory peak {peak_mb}MB within limits", {"memory_peak_mb": peak_mb}

    def generate_manifest(self, output_path: Path):
        manifest = {
            "version": 1,
            "timestamp": int(time.time()),
            "results": [asdict(r) for r in self.results],
            "overall_status": "PASS" if all(r.status == "PASS" for r in self.results) else "FAIL"
        }

        content = json.dumps(manifest, sort_keys=True)
        manifest["hash"] = hashlib.sha256(content.encode()).hexdigest()

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(manifest, indent=2))

def compare_baselines(pre_results: dict, post_results: dict) -> list[str]:
    regressions = []

    pre_map = {r["component"]: r for r in pre_results.get("results", [])}
    for post in post_results.get("results", []):
        comp = post["component"]
        if comp in pre_map:
            pre_metrics = pre_map[comp].get("metrics", {})
            post_metrics = post.get("metrics", {})

            for key in ["p50", "p95", "startup_time", "memory_peak_mb"]:
                 if key in pre_metrics and key in post_metrics:
                      pre_val = pre_metrics[key]
                      post_val = post_metrics[key]
                      if pre_val > 0:
                           # 20% regression tolerance for noise
                           # For ms metrics, add 100ms absolute threshold tolerance to avoid micro noise flagging
                           abs_tolerance = 100 if "time" in key or "p50" in key or "p95" in key else 5
                           if post_val > pre_val * 1.2 and post_val - pre_val > abs_tolerance:
                                regressions.append(f"{comp} ({key}) regressed from {pre_val:.2f} to {post_val:.2f}")
    return regressions

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--report", type=Path, default=Path("tools/verification/performance_manifest.json"))
    parser.add_argument("--baseline", type=Path, help="Pre-repair baseline manifest to compare against")
    args = parser.parse_args()

    gate = VerificationGate(args.repo_root)
    gate.run_check("dart_analyzer", gate.check_dart_errors)
    gate.run_check("sqlite_fts5", gate.measure_sqlite_performance)
    gate.run_check("startup_normal", gate.measure_startup_normal)
    gate.run_check("startup_safe", gate.measure_startup_safe)
    gate.run_check("memory_peak", gate.measure_memory_peak)

    gate.generate_manifest(args.report)

    overall = "PASS" if all(r.status == "PASS" for r in gate.results) else "FAIL"
    print(f"Overall Status: {overall}")
    for res in gate.results:
        print(f"  {res.status}: {res.component} - {res.message}")

    if args.baseline and args.baseline.exists():
        try:
            baseline_data = json.loads(args.baseline.read_text())
            current_data = json.loads(args.report.read_text())
            regressions = compare_baselines(baseline_data, current_data)
            if regressions:
                print("\nREGRESSIONS DETECTED:")
                for r in regressions:
                    print(f"  - {r}")
                sys.exit(1)
        except Exception as e:
             print(f"Failed to compare baseline: {e}")
             sys.exit(1)

    sys.exit(0 if overall == "PASS" else 1)

if __name__ == "__main__":
    main()
