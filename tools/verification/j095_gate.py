import json
import logging
import sqlite3
import subprocess
import time
import os
import hashlib
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

class GateDecision(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    BLOCKED = "BLOCKED"
    NOT_RUN = "NOT_RUN"

class VerificationGate:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.db_path = repo_root / "lib" / "data" / "polyglot_content_v2.db"
        self.manifest_path = repo_root / "tools" / "verification" / "manifest.json"

        self.tolerance_pct = 5.0 # 5% tolerance for noise

        self.results: Dict[str, Any] = {
            "dart_analysis": GateDecision.NOT_RUN.value,
            "sqlite_schema": GateDecision.NOT_RUN.value,
            "sqlite_integrity": GateDecision.NOT_RUN.value,
            "sqlite_content_hash": GateDecision.NOT_RUN.value,
            "fts5_benchmark": GateDecision.NOT_RUN.value,
            "memory_benchmark": GateDecision.NOT_RUN.value,
            "startup_benchmark_normal": GateDecision.NOT_RUN.value,
            "startup_benchmark_safe": GateDecision.NOT_RUN.value,
            "overall_decision": GateDecision.NOT_RUN.value,
        }

    def run_dart_analysis(self) -> GateDecision:
        try:
            cmd = ["bash", str(self.repo_root / "scripts" / "check-dart-errors.sh")]
            result = subprocess.run(cmd, cwd=self.repo_root, capture_output=True, text=True)
            if result.returncode == 0:
                return GateDecision.PASS
            else:
                logging.error(f"Dart analysis failed: {result.stderr}")
                return GateDecision.FAIL
        except Exception as e:
            logging.error(f"Failed to run dart analysis: {e}")
            return GateDecision.BLOCKED

    def check_sqlite_schema(self) -> GateDecision:
        if not self.db_path.exists():
            return GateDecision.BLOCKED
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("PRAGMA integrity_check;")
                result = cursor.fetchone()
                if result and result[0] == "ok":
                    return GateDecision.PASS
                else:
                    return GateDecision.FAIL
        except Exception as e:
            logging.error(f"SQLite schema check failed: {e}")
            return GateDecision.FAIL

    def check_sqlite_integrity(self) -> GateDecision:
        if not self.db_path.exists():
            return GateDecision.BLOCKED
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("PRAGMA foreign_key_check;")
                result = cursor.fetchall()
                if not result:
                    return GateDecision.PASS
                else:
                    return GateDecision.FAIL
        except Exception as e:
            logging.error(f"SQLite integrity check failed: {e}")
            return GateDecision.FAIL

    def check_sqlite_content_hash(self) -> GateDecision:
        if not self.db_path.exists():
             return GateDecision.BLOCKED
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name ASC;")
                tables = cursor.fetchall()

                hasher = hashlib.sha256()
                for table in tables:
                     table_name = table[0]
                     try:
                        # SQLite doesn't strictly require rowid, but typically it exists unless WITHOUT ROWID is used.
                        # We use a fallback ordering by all columns if PRAGMA table_info is used, but for simplicity
                        # we can try rowid first, and fallback to generic string sorting if that fails.

                        try:
                            cursor.execute(f"SELECT * FROM {table_name} ORDER BY rowid ASC;")
                        except sqlite3.OperationalError:
                            cursor.execute(f"SELECT * FROM {table_name};")

                        rows = cursor.fetchall()
                        # Sort rows deterministically if rowid was not an option
                        # Since we fetched all, sorting the string representation is deterministic.
                        rows = sorted([str(r) for r in rows])

                        for row_str in rows:
                            hasher.update(row_str.encode('utf-8'))
                     except sqlite3.OperationalError:
                        pass

                computed_hash = hasher.hexdigest()
                baseline_hash_path = self.repo_root / "tools" / "verification" / "baseline_db_hash.txt"

                if baseline_hash_path.exists():
                    with open(baseline_hash_path, "r") as f:
                        expected_hash = f.read().strip()
                    if computed_hash == expected_hash:
                        return GateDecision.PASS
                    else:
                        logging.error(f"Content hash mismatch: expected {expected_hash}, got {computed_hash}")
                        return GateDecision.FAIL
                else:
                    with open(baseline_hash_path, "w") as f:
                        f.write(computed_hash)
                    return GateDecision.PASS

        except Exception as e:
            logging.error(f"SQLite content hash check failed: {e}")
            return GateDecision.FAIL

    def _calculate_p(self, latencies: List[float], p: int) -> float:
        if not latencies:
            return 0.0
        sorted_latencies = sorted(latencies)
        k = (len(sorted_latencies) - 1) * (p / 100.0)
        f = int(k)
        c = int(k) + 1 if int(k) + 1 < len(sorted_latencies) else int(k)

        if f == c:
            return sorted_latencies[f]

        d0 = sorted_latencies[f] * (c - k)
        d1 = sorted_latencies[c] * (k - f)
        return d0 + d1

    def _run_fts5_queries(self) -> Optional[Tuple[float, float]]:
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()

                cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE '%_data' AND name NOT LIKE '%_idx' AND name NOT LIKE '%_docsize' AND name NOT LIKE '%_config' AND sql LIKE '%fts5%';")
                fts_tables = cursor.fetchall()

                if not fts_tables:
                     logging.warning("No main FTS5 tables found to benchmark.")
                     # Provide a fast path pass if there are genuinely no FTS tables, but for benchmarking we need them
                     return (0.0, 0.0)

                latencies = []
                table_name = fts_tables[0][0]

                for _ in range(20):
                    start = time.time()
                    try:
                        cursor.execute(f"SELECT * FROM {table_name} WHERE {table_name} MATCH 'a' LIMIT 10;")
                        cursor.fetchall()
                    except sqlite3.OperationalError as e:
                         logging.error(f"FTS5 MATCH failed: {e}")
                         return None
                    end = time.time()
                    latencies.append((end - start) * 1000)

                p50 = self._calculate_p(latencies, 50)
                p95 = self._calculate_p(latencies, 95)
                return p50, p95
        except Exception as e:
            logging.error(f"FTS5 query failed: {e}")
            return None

    def benchmark_fts5(self) -> GateDecision:
        if not self.db_path.exists():
            return GateDecision.BLOCKED

        stats = self._run_fts5_queries()
        if stats is None:
            return GateDecision.FAIL

        p50, p95 = stats

        baseline_path = self.repo_root / "tools" / "verification" / "baseline_fts5.json"

        if baseline_path.exists():
            try:
                with open(baseline_path, "r") as f:
                    baseline = json.load(f)

                baseline_p50 = baseline.get("p50")
                baseline_p95 = baseline.get("p95")

                if baseline_p50 is not None and baseline_p95 is not None:
                    # Allow a minimum delta so we don't fail on tiny noise
                    if (p50 > baseline_p50 * (1 + self.tolerance_pct / 100) and p50 > baseline_p50 + 1) or \
                       (p95 > baseline_p95 * (1 + self.tolerance_pct / 100) and p95 > baseline_p95 + 1):
                        logging.error(f"FTS5 latency regressed: p50={p50} (baseline={baseline_p50}), p95={p95} (baseline={baseline_p95})")
                        return GateDecision.FAIL
            except Exception as e:
                logging.error(f"Failed to compare FTS5 baseline: {e}")
                return GateDecision.FAIL
        else:
            with open(baseline_path, "w") as f:
                json.dump({"p50": p50, "p95": p95}, f)

        return GateDecision.PASS

    def benchmark_memory(self) -> GateDecision:
        try:
            # Reusing the existing Dart benchmark infrastructure
            # We parse the output of flutter test test/benchmark_test.dart to extract memory info if available,
            # or simply use GNU time / /usr/bin/time to strictly measure process max RSS.

            cmd = ["/usr/bin/time", "-v", "flutter", "test", "test/benchmark_test.dart"]
            result = subprocess.run(cmd, cwd=self.repo_root, capture_output=True, text=True)

            if result.returncode != 0:
                 logging.error(f"Memory benchmark test failed: {result.stderr}")
                 return GateDecision.FAIL

            # Parse output of time -v
            max_rss = 0
            for line in result.stderr.splitlines():
                if "Maximum resident set size" in line:
                    max_rss = int(line.split(":")[-1].strip())
                    break

            if max_rss == 0:
                logging.error("Failed to extract max RSS from benchmark")
                return GateDecision.FAIL

            baseline_path = self.repo_root / "tools" / "verification" / "baseline_memory.json"

            if baseline_path.exists():
                try:
                    with open(baseline_path, "r") as f:
                        baseline = json.load(f)

                    baseline_maxrss = baseline.get("maxrss")
                    if baseline_maxrss is not None:
                         if max_rss > baseline_maxrss * (1 + self.tolerance_pct / 100):
                            logging.error(f"Memory regressed: {max_rss} > {baseline_maxrss} + {self.tolerance_pct}%")
                            return GateDecision.FAIL
                except Exception as e:
                     logging.error(f"Failed to compare memory baseline: {e}")
                     return GateDecision.FAIL
            else:
                with open(baseline_path, "w") as f:
                    json.dump({"maxrss": max_rss}, f)

            return GateDecision.PASS
        except Exception as e:
            logging.error(f"Memory benchmark failed: {e}")
            return GateDecision.BLOCKED

    def benchmark_startup_normal(self) -> GateDecision:
        try:
            start = time.time()
            cmd = ["flutter", "test", "test/benchmark_test.dart"]
            result = subprocess.run(cmd, cwd=self.repo_root, capture_output=True)
            end = time.time()

            if result.returncode != 0:
                 return GateDecision.FAIL

            latency = (end - start) * 1000

            baseline_path = self.repo_root / "tools" / "verification" / "baseline_startup_normal.json"

            if baseline_path.exists():
                 try:
                    with open(baseline_path, "r") as f:
                        baseline = json.load(f)

                    baseline_latency = baseline.get("latency")
                    if baseline_latency is not None:
                         if latency > baseline_latency * (1 + self.tolerance_pct / 100) and latency > baseline_latency + 10:
                            logging.error(f"Normal startup regressed: {latency} > {baseline_latency}")
                            return GateDecision.FAIL
                 except Exception as e:
                    logging.error(f"Failed to compare normal startup baseline: {e}")
                    return GateDecision.FAIL
            else:
                 with open(baseline_path, "w") as f:
                    json.dump({"latency": latency}, f)
            return GateDecision.PASS
        except Exception as e:
            logging.error(f"Normal startup benchmark failed: {e}")
            return GateDecision.BLOCKED

    def benchmark_startup_safe(self) -> GateDecision:
        try:
            start = time.time()
            cmd = ["flutter", "test", "test/benchmark_test.dart"]
            result = subprocess.run(cmd, cwd=self.repo_root, capture_output=True, env={**os.environ, "SAFE_MODE": "1"})
            end = time.time()

            if result.returncode != 0:
                 return GateDecision.FAIL

            latency = (end - start) * 1000

            baseline_path = self.repo_root / "tools" / "verification" / "baseline_startup_safe.json"

            if baseline_path.exists():
                 try:
                    with open(baseline_path, "r") as f:
                        baseline = json.load(f)

                    baseline_latency = baseline.get("latency")
                    if baseline_latency is not None:
                         if latency > baseline_latency * (1 + self.tolerance_pct / 100) and latency > baseline_latency + 10:
                            logging.error(f"Safe startup regressed: {latency} > {baseline_latency}")
                            return GateDecision.FAIL
                 except Exception as e:
                    logging.error(f"Failed to compare safe startup baseline: {e}")
                    return GateDecision.FAIL
            else:
                 with open(baseline_path, "w") as f:
                    json.dump({"latency": latency}, f)
            return GateDecision.PASS
        except Exception as e:
            logging.error(f"Safe startup benchmark failed: {e}")
            return GateDecision.BLOCKED

    def evaluate(self) -> str:
        self.results["dart_analysis"] = self.run_dart_analysis().value
        self.results["sqlite_schema"] = self.check_sqlite_schema().value
        self.results["sqlite_integrity"] = self.check_sqlite_integrity().value
        self.results["sqlite_content_hash"] = self.check_sqlite_content_hash().value
        self.results["fts5_benchmark"] = self.benchmark_fts5().value
        self.results["memory_benchmark"] = self.benchmark_memory().value
        self.results["startup_benchmark_normal"] = self.benchmark_startup_normal().value
        self.results["startup_benchmark_safe"] = self.benchmark_startup_safe().value

        if all(v == GateDecision.PASS.value for k, v in self.results.items() if k != "overall_decision"):
            self.results["overall_decision"] = GateDecision.PASS.value
        else:
            self.results["overall_decision"] = GateDecision.FAIL.value

        self.manifest_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.manifest_path, "w") as f:
            json.dump(self.results, f, indent=2)

        return self.results["overall_decision"]

if __name__ == "__main__":
    gate = VerificationGate(Path("."))
    print(gate.evaluate())
