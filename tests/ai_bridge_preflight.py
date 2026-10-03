from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Final

WORKFLOW_RELATIVE: Final = Path('.github/workflows/ai_collaboration_bridge.yml')
POLICY_RELATIVE: Final = Path('docs/architecture/PROJECT_VISION_AND_RULES.md')


class ContractViolation(ValueError):
    """Raised when the AI collaboration bridge violates the static safety contract."""


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractViolation(message)


def _job_section(workflow: str, job_name: str) -> str:
    match = re.search(rf'(?m)^  {re.escape(job_name)}:\s*$', workflow)
    _require(match is not None, f'missing workflow job: {job_name}')
    start = match.start()
    following = re.search(r'(?m)^  [A-Za-z0-9_-]+:\s*$', workflow[match.end():])
    end = match.end() + following.start() if following else len(workflow)
    return workflow[start:end]


def _step_block(job: str, step_name: str) -> str:
    marker = f'      - name: {step_name}'
    start = job.find(marker)
    _require(start >= 0, f'missing required step: {step_name}')
    next_step = job.find('\n      - name:', start + len(marker))
    return job[start:] if next_step < 0 else job[start:next_step]


def validate_contract_text(workflow: str, policy: str) -> dict[str, object]:
    """Validate the bridge statically without executing provider calls or requiring secrets."""
    ai_job = _job_section(workflow, 'ai-architecture-review')

    _require('AI_COLLABORATION_ENABLED' in workflow, 'activation variable is not wired')
    _require('AI_COLLABORATION_BILLING_APPROVED' in workflow, 'billing approval variable is not wired')

    activation = _step_block(ai_job, 'Enforce activation and billing guard')
    enabled_true = re.search(
        r'AI_COLLABORATION_ENABLED\"?\s*==\s*\"true\"', activation
    )
    billing_true = re.search(
        r'AI_COLLABORATION_BILLING_APPROVED\"?\s*==\s*\"true\"', activation
    )
    _require(enabled_true is not None, 'activation must require AI_COLLABORATION_ENABLED=true')
    _require(billing_true is not None, 'billing approval must explicitly require true')
    _require('active=false' in activation, 'cost guard must fail closed when activation is not approved')

    secret_or_provider_steps = (
        'Validate provider secrets',
        'Build bounded architecture context',
        'OpenAI architecture analysis',
        'Gemini critique and arbitration',
        'Publish collaboration review',
        'Enforce collaboration verdict',
    )
    for name in secret_or_provider_steps:
        block = _step_block(ai_job, name)
        _require(
            "if: steps.activation.outputs.active == 'true'" in block,
            f'{name} must require the activation output',
        )

    for line in ai_job.splitlines():
        stripped = line.strip()
        if stripped.startswith('#'):
            continue
        _require(
            not re.search(r'\buses:\s*actions/checkout@', stripped),
            'secret-backed ai-architecture-review job must not perform PR-head checkout',
        )

    _require('UNTRUSTED_CONTEXT_BEGIN' in ai_job, 'untrusted context boundary is missing')
    _require('DIFF_TRUNCATED' in ai_job, 'truncation evidence is missing')
    _require('store: false' in ai_job, 'OpenAI requests must keep store: false')
    _require('name: ai-architecture-review' in ai_job, 'required review status name drifted')

    policy_lower = policy.lower()
    _require('untrusted data' in policy_lower, 'policy must classify PR/Issue content as untrusted data')
    _require('never execute pr-head code' in policy_lower, 'policy must forbid PR-head execution with secrets')
    _require('zero additional billing' in policy_lower, 'policy must preserve zero-additional-billing')
    _require('AI_COLLABORATION_ENABLED=true' in policy, 'policy must document the activation variable')
    _require('AI_COLLABORATION_BILLING_APPROVED=true' in policy, 'policy must document billing approval')
    _require('ai-architecture-review' in policy, 'policy must document the future server-side check name')
    _require('never auto-approve' in policy_lower, 'policy must forbid automatic PR approval')
    _require('never mutate source code automatically' in policy_lower, 'policy must forbid automatic source mutation')

    return {
        'status': 'PASS',
        'billing_guard': 'FAIL_CLOSED',
        'provider_calls_require_activation': True,
        'pr_head_checkout_with_provider_secrets': False,
        'server_side_check': 'ai-architecture-review',
        'network_calls_executed': False,
        'api_keys_required_for_preflight': False,
    }


def validate_repository(repo_root: Path) -> dict[str, object]:
    workflow_path = repo_root / WORKFLOW_RELATIVE
    policy_path = repo_root / POLICY_RELATIVE
    _require(workflow_path.is_file(), f'missing workflow: {WORKFLOW_RELATIVE}')
    _require(policy_path.is_file(), f'missing policy: {POLICY_RELATIVE}')
    return validate_contract_text(
        workflow_path.read_text(encoding='utf-8'),
        policy_path.read_text(encoding='utf-8'),
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description='Static AI collaboration bridge contract preflight')
    parser.add_argument('--repo-root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args(argv)
    try:
        report = validate_repository(args.repo_root.resolve())
    except (ContractViolation, OSError) as exc:
        print(json.dumps({'status': 'FAIL', 'error': str(exc)}, ensure_ascii=False, indent=2))
        return 1
    print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
