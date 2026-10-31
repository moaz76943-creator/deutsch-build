import copy
import json
from pathlib import Path

from tools.automation.merge_sequencer import (
    PR_BRANCHES,
    DependencyCycleError,
    build_merge_plan,
    compute_topological_order,
    derive_pr_dependencies,
    load_backlog,
    render_merge_pipeline,
    _main,
)

ROOT = Path(__file__).resolve().parents[1]
BACKLOG = ROOT / "tools" / "automation" / "backlog.json"


def _all_branches():
    return frozenset(PR_BRANCHES.values())


def test_sequence_for_prs_104_through_111_is_deterministic():
    backlog = load_backlog(BACKLOG)
    dependencies = derive_pr_dependencies(backlog)

    first = compute_topological_order(dependencies)
    second = compute_topological_order(copy.deepcopy(dependencies))

    assert first == second == [104, 105, 106, 107, 108, 109, 110, 111]
    assert dependencies[111] == frozenset({106, 108, 110})


def test_branching_paths_keep_python_tools_independent_from_dart_core():
    backlog = load_backlog(BACKLOG)
    plan = build_merge_plan(backlog, active_branches=_all_branches())
    by_pr = {item.pr_number: item for item in plan}

    assert by_pr[107].lane == "python-tools"
    assert by_pr[109].lane == "python-tools"
    assert by_pr[107].ready is True
    assert by_pr[109].ready is True

    assert by_pr[106].lane == "dart-core"
    assert by_pr[108].lane == "dart-core"
    assert by_pr[110].lane == "dart-core"
    assert by_pr[111].lane == "dart-core"
    assert by_pr[111].ready is False
    assert by_pr[111].blocked_by == (106, 108, 110)


def test_session_pr_becomes_ready_after_foundational_prs_are_merged():
    backlog = load_backlog(BACKLOG)
    plan = build_merge_plan(
        backlog,
        active_branches=_all_branches(),
        merged_prs={106, 108, 110},
    )
    by_pr = {item.pr_number: item for item in plan}
    assert by_pr[111].ready is True
    assert by_pr[111].blocked_by == ()


def test_markdown_report_has_dynamic_ready_and_blocked_badges():
    backlog = load_backlog(BACKLOG)
    plan = build_merge_plan(backlog, active_branches=_all_branches())
    markdown = render_merge_pipeline(plan)

    assert "MERGE_PIPELINE" in markdown
    assert "img.shields.io/badge/merge-ready_to_merge" in markdown
    assert "img.shields.io/badge/merge-blocked" in markdown
    assert "#111" in markdown
    assert "#106, #108, #110" in markdown


def test_cycle_returns_exit_code_one(tmp_path):
    cycle = {
        "tasks": [
            {
                "task_id": "A",
                "branch": "a",
                "prerequisites": ["B"],
                "external_prerequisites": ["PR #104"],
            },
            {
                "task_id": "B",
                "branch": "b",
                "prerequisites": ["A"],
                "external_prerequisites": ["PR #111"],
            },
        ]
    }
    path = tmp_path / "backlog.json"
    path.write_text(json.dumps(cycle), encoding="utf-8")

    assert _main(["--backlog", str(path)]) == 1
