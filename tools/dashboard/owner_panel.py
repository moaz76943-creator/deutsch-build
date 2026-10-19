#!/usr/bin/env python3
"""Generate an offline, read-only DEUTSCH owner dashboard from GitHub evidence.

No HTTP server, tokens in output, GitHub mutations, or shell evaluation.
"""
from __future__ import annotations

import argparse
import html
import json
import os
import re
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable
from urllib.parse import quote

REPOSITORY = "moaz76943-creator/deutsch-build"
INTEGRATION_BRANCH = "staging/v2-full-platform"
MAX_ITEMS = 100
MAX_PR_PAGES = 20
DATA_STATES = ("LIVE", "CACHED")
LANES = (
    ("01 نظرة عامة", "docs/project-record/PROJECT_INTENT.md", "Overview · current approved goal"),
    ("02 صحة المستودع", "docs/project-record", "Repository health · evidence records"),
    ("03 الفروع وHEAD", "", "Branch & HEAD explorer · pinned integration SHA"),
    ("04 طلبات الدمج", "", "PR backlog · draft and target branch"),
    ("05 تعارضات الدمج", "tools/coordination", "Merge conflicts · source investigation required"),
    ("06 جاهزية الدمج", "tools/gatekeeper", "Merge readiness · checks not inferred"),
    ("07 سجل الوكلاء", "tools/agents", "Agent registry · registration does not grant permissions"),
    ("08 ملكية الملفات", "tools/agent_contract", "Agent scope ownership · current guard"),
    ("09 مركز الأتمتة", "tools/automation", "Automation center · existing implementation"),
    ("10 تشغيلات Workflows", ".github/workflows", "Workflow runs · actual status and conclusion"),
    ("11 الوظائف الفاشلة", ".github/workflows", "Failed jobs · inspect linked runs"),
    ("12 مركز الاستعادة", "lib/core/recovery", "Recovery center · learner session recovery"),
    ("13 جودة Flutter", "test", "Flutter quality · tests and regression"),
    ("14 SQLite وSRS", "lib/core/srs", "SQLite/SRS health · progress isolation"),
    ("15 مصنع الحزم", "tools/ingestion", "Pack factory · candidate compilation"),
    ("16 تغطية اللغات", "lib/core/catalog", "Language coverage · registry is not readiness"),
    ("17 أدلة الترخيص", "docs", "License evidence · rights require source verification"),
    ("18 مستكشف الشاشات", "lib/screens", "UI screen explorer · routing source"),
    ("19 إعداد الميزات", "lib/core/registry", "Feature configuration · source inspection only"),
    ("20 الأمن والصلاحيات", "android/app/src/main/AndroidManifest.xml", "Security & permissions · Android manifest"),
    ("21 مؤشرات الأداء", "lib/core/worker", "Performance metrics · CPU worker source"),
    ("22 نقاط الاستعادة", "docs/project-record", "Checkpoints & rollbacks · verified evidence required"),
    ("23 الميزات التعليمية", "lib/features", "Learning features · existing modules"),
    ("24 البحث والصوت", "lib/services", "Search & audio health · optional capabilities"),
    ("25 تبعيات المهام", "tools/agent_contract", "Task dependencies · existing contract"),
    ("26 تكامل Linear", "docs/project-record", "Linear task integration · NOT_VERIFIED in this panel"),
    ("27 السجلات والتشخيص", "docs/project-record", "Logs & diagnostics · durable evidence"),
    ("28 التكلفة والحصص", ".github/workflows", "Cost & quota guard · billing UNKNOWN until authorized provider read"),
    ("29 جاهزية الإصدار", "tools/release_safety", "Release readiness · independent required gates"),
    ("30 إجراءات المالك", "tools/dashboard", "Owner actions · authenticated GitHub links only"),
)


class SnapshotError(ValueError):
    pass


def github_api(path: str, *, timeout: int = 12) -> Any:
    """Fixed argv; never route user-supplied commands to the shell."""
    try:
        result = subprocess.run(
            ["gh", "api", path], capture_output=True, text=True,
            timeout=timeout, check=True,
        )
    except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        raise SnapshotError(f"GitHub read failed at {path.split('?')[0]}: {type(exc).__name__}") from exc
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise SnapshotError("GitHub returned invalid JSON") from exc


def collect_snapshot(api: Callable[[str], Any] = github_api) -> dict[str, Any]:
    base = f"/repos/{REPOSITORY}"
    calls = {
        "head": f"{base}/git/ref/heads/{INTEGRATION_BRANCH}",
        "pulls": f"{base}/pulls?state=open&per_page={MAX_ITEMS}",
        "runs": f"{base}/actions/runs?per_page={MAX_ITEMS}",
        "workflows": f"{base}/actions/workflows?per_page={MAX_ITEMS}",
    }
    snapshot: dict[str, Any] = {"repository": REPOSITORY, "branch": INTEGRATION_BRANCH,
                                      "captured_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                                      "observations": {}, "errors": {}}
    for key, path in calls.items():
        try:
            truncated = False
            if key == "pulls":
                value = []
                seen = set()
                for page in range(1, MAX_PR_PAGES + 1):
                    batch = api(path + f"&page={page}")
                    if not isinstance(batch, list) or len(batch) > MAX_ITEMS:
                        raise SnapshotError("Unexpected pull request page")
                    for row in batch:
                        number = row.get("number") if isinstance(row, dict) else None
                        if type(number) is not int or number <= 0 or number in seen:
                            raise SnapshotError("Malformed or duplicate pull request row")
                        seen.add(number)
                    value.extend(batch)
                    if len(batch) < MAX_ITEMS:
                        break
                else:
                    truncated = True
            else:
                value = api(path)
            if key == "head":
                sha = value.get("object", {}).get("sha") if isinstance(value, dict) else None
                if not isinstance(sha, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", sha):
                    raise SnapshotError("Missing exact HEAD SHA")
                normalized: Any = {"sha": sha}
            elif key == "pulls":
                if not isinstance(value, list):
                    raise SnapshotError("Unexpected pull request shape")
                if any(not isinstance(item, dict) or type(item.get("number")) is not int
                       or item["number"] <= 0 for item in value):
                    raise SnapshotError("Malformed pull request row")
                normalized = [{"number": item["number"], "title": str(item.get("title", ""))[:240],
                               "draft": item.get("draft") is True,
                               "mergeable": item.get("mergeable"),
                               "base": (item.get("base") or {}).get("ref", "UNKNOWN"),
                               "head_sha": (item.get("head") or {}).get("sha", "UNKNOWN")}
                              for item in value]
            else:
                field = "workflow_runs" if key == "runs" else "workflows"
                if not isinstance(value, dict) or not isinstance(value.get(field), list):
                    raise SnapshotError(f"Unexpected {key} shape")
                records = value[field]
                if any(not isinstance(x, dict) or type(x.get("id")) is not int
                       or x["id"] <= 0 for x in records):
                    raise SnapshotError(f"Malformed {key} row")
                normalized = ([{"name": str(x.get("name") or x.get("display_title") or "")[:120],
                                "id": x.get("id"), "status": x.get("status", "UNKNOWN"),
                                "conclusion": x.get("conclusion") or "NOT_RUN"} for x in records
                               ])
            snapshot["observations"][key] = {"status": "LIVE", "items": normalized,
                                                  "truncated": (truncated if key == "pulls" else
                                                                len(normalized) >= MAX_ITEMS if key != "head" else False)}
        except (SnapshotError, ValueError, KeyError, TypeError, AttributeError) as exc:
            snapshot["observations"][key] = {"status": "UNAVAILABLE", "items": None,
                                                  "truncated": False}
            snapshot["errors"][key] = str(exc)[:300]
    return snapshot


def validate_snapshot(snapshot: Any) -> dict[str, Any]:
    if not isinstance(snapshot, dict) or snapshot.get("repository") != REPOSITORY or snapshot.get("branch") != INTEGRATION_BRANCH:
        raise SnapshotError("Snapshot repository or integration branch mismatch")
    observations = snapshot.get("observations")
    if not isinstance(observations, dict):
        raise SnapshotError("Missing observation states")
    for key in ("head", "pulls", "runs", "workflows"):
        item = observations.get(key)
        if not isinstance(item, dict) or item.get("status") not in ("LIVE", "CACHED", "UNAVAILABLE", "NOT_RUN"):
            raise SnapshotError(f"Missing or invalid status for {key}")
        if item["status"] in DATA_STATES:
            if key == "head":
                head = item.get("items")
                if (not isinstance(head, dict) or not isinstance(head.get("sha"), str)
                        or not re.fullmatch(r"[0-9a-fA-F]{40}", head["sha"])):
                    raise SnapshotError("Invalid LIVE HEAD SHA")
            elif not isinstance(item.get("items"), list):
                raise SnapshotError(f"Missing live data for {key}")
    return snapshot


def _e(value: Any) -> str:
    return html.escape(str(value), quote=True)


def _count(snapshot: dict[str, Any], name: str) -> str:
    item = snapshot["observations"][name]
    if item["status"] not in DATA_STATES:
        return item["status"]
    if name == "head":
        return _e((item["items"] or {}).get("sha", "UNKNOWN")[:12])
    return f"{len(item['items'])}{'+' if item.get('truncated') else ''}"


def render(snapshot: dict[str, Any]) -> str:
    snapshot = validate_snapshot(snapshot)
    base_url = f"https://github.com/{REPOSITORY}"
    head = snapshot["observations"]["head"]
    sha = head.get("items", {}).get("sha", "") if head["status"] in DATA_STATES else ""
    # Only a validated SHA enters the content URL; the UI is non-executable.
    if not isinstance(sha, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", sha):
        sha = ""
    browse_ref = sha or INTEGRATION_BRANCH
    lanes = "".join(
        f'<article class="lane" data-filter="{_e(name + " " + detail)}">'
        f'<h3>{_e(name)}</h3><p>{_e(detail)}</p>'
        f'<a target="_blank" rel="noopener noreferrer" href="{base_url}/tree/{quote(browse_ref, safe="/")}/{quote(path, safe="/")}">فتح الملفات في GitHub ↗</a>'
        f'</article>' for name, path, detail in LANES
    )
    pulls = snapshot["observations"]["pulls"]
    prs_html = ""
    if pulls["status"] in DATA_STATES:
        for pr in pulls["items"]:
            if type(pr.get("number")) is not int:
                continue
            n = pr["number"]
            # A draft and an unverified check never imply merge-ready.
            state = "DRAFT" if pr.get("draft") else "OPEN · CHECKS NOT VERIFIED"
            if pr.get("base") != INTEGRATION_BRANCH:
                state += " · WRONG_BASE"
            prs_html += (f'<article class="pr" data-filter="{_e(pr.get("title", ""))} {n}">'
                         f'<a target="_blank" rel="noopener noreferrer" href="{base_url}/pull/{n}">#{n} {_e(pr.get("title", ""))}</a>'
                         f'<small>{state} · base: {_e(pr.get("base", "UNKNOWN"))} · HEAD: {_e(pr.get("head_sha", "UNKNOWN"))}</small></article>')
        if not prs_html:
            prs_html = "<p>لا توجد طلبات مفتوحة في هذه اللقطة.</p>"
    else:
        prs_html = f"<p>طلبات الدمج: {_e(pulls['status'])} — لا تعتبرها صفرًا.</p>"
    runs = snapshot["observations"]["runs"]
    runs_html = ""
    if runs["status"] in DATA_STATES:
        for run in runs["items"][:30]:
            rid = run.get("id")
            if type(rid) is not int:
                continue
            runs_html += f'<li><a href="{base_url}/actions/runs/{rid}" target="_blank" rel="noopener noreferrer">{_e(run.get("name", "run"))}</a> — {_e(run.get("status", "UNKNOWN"))} / {_e(run.get("conclusion", "NOT_RUN"))}</li>'
    else:
        runs_html = f"<li>{_e(runs['status'])} — لا دليل على نجاح CI.</li>"
    errors = "".join(f"<li>{_e(key)}: {_e(value)}</li>" for key, value in snapshot.get("errors", {}).items())
    provenance = " ".join(
        f'<span data-observation="{_e(item["status"])}">{_e(key)}: {_e(item["status"])}</span>'
        for key, item in snapshot["observations"].items()
    )
    return f'''<!doctype html>
<html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>DEUTSCH — مركز إدارة المالك</title>
<style>
:root{{--bg:#f6f8fc;--fg:#1c263b;--muted:#546279;--border:#dae2ef;--accent:#205ac4}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--fg);font:16px system-ui,sans-serif}}
header{{background:#fff;border-bottom:1px solid var(--border);padding:24px max(18px,calc((100vw - 1100px)/2))}}
main{{max-width:1100px;margin:auto;padding:18px}}h1{{margin:0 0 8px;font-size:1.5rem}}h2{{font-size:1.2rem;margin-top:28px}}
p,small{{color:var(--muted)}}small,code,bdi{{overflow-wrap:anywhere}}[hidden]{{display:none!important}}a{{color:var(--accent);overflow-wrap:anywhere}}
.stats{{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px}}
.stat,.lane,.pr,.panel{{background:#fff;border:1px solid var(--border);border-radius:14px;padding:14px}}
.stat strong{{display:block;font-size:1.12rem;overflow-wrap:anywhere}}.cards{{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:12px}}
.lane h3{{margin:2px 0 4px}}.lane p{{min-height:2.8em}}.pr{{margin:8px 0}}.pr small{{display:block;margin-top:6px}}
input{{width:100%;padding:14px;border:1px solid var(--border);border-radius:12px;font:inherit}}
a:focus-visible,input:focus-visible{{outline:3px solid var(--accent);outline-offset:2px}}
nav{{display:flex;gap:12px;flex-wrap:wrap;margin-top:14px}}.warning{{padding:12px 14px;border-inline-start:4px solid #c07711;background:#fff7e8}}
</style></head><body>
<header><h1>مركز إدارة DEUTSCH بالعربي</h1><p>لوحة مراقبة محلية للمالك — لا ترسل أوامر دمج أو تعدّل بيانات التطبيق.</p>
<nav><a href="#lanes">المسارات</a><a href="#prs">طلبات الدمج</a><a href="#ci">التشغيلات</a><a href="{base_url}/actions" target="_blank" rel="noopener noreferrer">إدارة الأتمتة في GitHub ↗</a></nav></header>
<main><p>وقت الالتقاط: <bdi>{_e(snapshot.get("captured_at", "UNKNOWN"))}</bdi> · {provenance}</p><p class="warning">الحالات LIVE ملاحظات وقت توليد الملف فقط. SKIPPED وNOT_RUN ونجاح التشغيل لا يثبت إنجاز المهام. المحتوى المحلي للوحة ليس إثباتًا لسلامة التطبيق.</p>
<div class="stats"><div class="stat">HEAD<strong dir="ltr">{_count(snapshot,"head")}</strong></div>
<div class="stat">طلبات مفتوحة<strong>{_count(snapshot,"pulls")}</strong></div>
<div class="stat">تشغيلات GitHub<strong>{_count(snapshot,"runs")}</strong></div>
<div class="stat">Workflows<strong>{_count(snapshot,"workflows")}</strong></div></div>
<p>المستودع: <a href="{base_url}">{_e(REPOSITORY)}</a> · الفرع: <code>{_e(INTEGRATION_BRANCH)}</code></p>
<label for="q">البحث عن مسار أو PR</label><input id="q" type="search" placeholder="بحث في المسارات والطلبات…" autocomplete="off">
<section id="lanes"><h2>المسارات التقنية ({len(LANES)})</h2><div class="cards">{lanes}</div></section>
<section id="prs"><h2>طلبات الدمج (للإدارة عبر GitHub)</h2>{prs_html}</section>
<section id="ci" class="panel"><h2>آخر تشغيلات GitHub</h2><ul>{runs_html or '<li>لا توجد تشغيلات في اللقطة.</li>'}</ul><a href="{base_url}/actions" target="_blank" rel="noopener noreferrer">فتح GitHub Actions ↗</a></section>
<section><h2>التشخيص</h2><ul>{errors or '<li>لا توجد أخطاء قراءة مسجلة في اللقطة.</li>'}</ul></section>
</main><script>document.getElementById('q').addEventListener('input',function(){{const q=this.value.trim().toLocaleLowerCase();document.querySelectorAll('[data-filter]').forEach(el=>{{el.hidden=!el.dataset.filter.toLocaleLowerCase().includes(q)}})}});</script>
</body></html>'''


def write_atomic(output: Path, contents: str) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=".owner-panel-", suffix=".tmp", dir=output.parent)
    try:
        os.fchmod(fd, 0o600)
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(contents)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(name, output)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--live", action="store_true", help="Read current GitHub via owner-authenticated gh CLI")
    group.add_argument("--snapshot", type=Path, help="Use a verified-shape local snapshot")
    parser.add_argument("--output", type=Path, required=True, help="HTML saved locally, not committed")
    args = parser.parse_args()
    if args.live:
        snapshot = collect_snapshot()
    else:
        snapshot = validate_snapshot(json.loads(args.snapshot.read_text(encoding="utf-8")))
        for observation in snapshot["observations"].values():
            if observation["status"] in DATA_STATES:
                observation["status"] = "CACHED"
    write_atomic(args.output, render(snapshot))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
