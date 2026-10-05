const encoder = new TextEncoder();

function jsonResponse(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

function hexToBytes(hex) {
  if (!/^[0-9a-f]{64}$/i.test(hex)) return null;
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = Number.parseInt(hex.slice(i, i + 2), 16);
  }
  return bytes;
}

export async function verifyGitHubSignature(secret, rawBody, signatureHeader) {
  if (!secret || !signatureHeader?.startsWith("sha256=")) return false;

  const signature = hexToBytes(signatureHeader.slice("sha256=".length));
  if (!signature) return false;

  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["verify"],
  );

  return crypto.subtle.verify(
    "HMAC",
    key,
    signature,
    encoder.encode(rawBody),
  );
}

export function evaluateMergedPullRequest(eventName, payload, env) {
  if (eventName !== "pull_request") {
    return { eligible: false, reason: "event_not_pull_request" };
  }
  if (payload?.action !== "closed") {
    return { eligible: false, reason: "pull_request_not_closed" };
  }
  if (payload?.pull_request?.merged !== true) {
    return { eligible: false, reason: "pull_request_not_merged" };
  }
  if (payload?.repository?.full_name !== env.EXPECTED_REPOSITORY) {
    return { eligible: false, reason: "repository_mismatch" };
  }
  if (payload?.pull_request?.base?.ref !== env.EXPECTED_BASE_BRANCH) {
    return { eligible: false, reason: "base_branch_mismatch" };
  }

  const prTitle =
    typeof payload?.pull_request?.title === "string"
      ? payload.pull_request.title
      : "";
  const prBody =
    typeof payload?.pull_request?.body === "string"
      ? payload.pull_request.body
      : "";
  if (`${prTitle}\n${prBody}`.toLowerCase().includes("[skip build]")) {
    return { eligible: false, reason: "skip_build_requested" };
  }

  const mergeSha = payload?.pull_request?.merge_commit_sha;
  if (typeof mergeSha !== "string" || !/^[0-9a-f]{40}$/i.test(mergeSha)) {
    return { eligible: false, reason: "merge_sha_missing" };
  }

  return { eligible: true, mergeSha };
}

function requireBinding(env, name) {
  const value = env?.[name];
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`Missing required Worker binding: ${name}`);
  }
  return value;
}

export async function handleRequest(request, env, fetchImpl = fetch) {
  if (request.method !== "POST") {
    return jsonResponse({ ok: false, error: "method_not_allowed" }, 405);
  }

  let webhookSecret;
  try {
    webhookSecret = requireBinding(env, "GITHUB_WEBHOOK_SECRET");
  } catch {
    return jsonResponse({ ok: false, error: "worker_not_configured" }, 500);
  }

  const rawBody = await request.text();
  const signatureHeader = request.headers.get("x-hub-signature-256");
  if (!(await verifyGitHubSignature(webhookSecret, rawBody, signatureHeader))) {
    return jsonResponse({ ok: false, error: "invalid_signature" }, 401);
  }

  let payload;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return jsonResponse({ ok: false, error: "invalid_json" }, 400);
  }

  const eventName = request.headers.get("x-github-event") ?? "";
  if (eventName === "ping") {
    return jsonResponse({ ok: true, event: "ping" });
  }

  const eligibility = evaluateMergedPullRequest(eventName, payload, env);
  if (!eligibility.eligible) {
    return jsonResponse({ ok: true, ignored: true, reason: eligibility.reason });
  }

  let apiToken;
  let appId;
  let workflowId;
  try {
    apiToken = requireBinding(env, "CODEMAGIC_API_TOKEN");
    appId = requireBinding(env, "CODEMAGIC_APP_ID");
    workflowId = requireBinding(env, "CODEMAGIC_WORKFLOW_ID");
  } catch {
    return jsonResponse({ ok: false, error: "worker_not_configured" }, 500);
  }

  const branch = env.EXPECTED_BASE_BRANCH;
  const deliveryId = request.headers.get("x-github-delivery") ?? "unknown";
  const codemagicPayload = {
    appId,
    workflowId,
    branch,
    labels: ["github-merge", `sha-${eligibility.mergeSha.slice(0, 12)}`],
    environment: {
      variables: {
        EXPECTED_MERGE_SHA: eligibility.mergeSha,
        GITHUB_DELIVERY_ID: deliveryId,
      },
    },
  };

  let codemagicResponse;
  try {
    codemagicResponse = await fetchImpl("https://api.codemagic.io/builds", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-auth-token": apiToken,
      },
      body: JSON.stringify(codemagicPayload),
    });
  } catch {
    return jsonResponse({ ok: false, error: "codemagic_unreachable" }, 502);
  }

  if (!codemagicResponse.ok) {
    return jsonResponse(
      {
        ok: false,
        error: "codemagic_rejected_request",
        upstreamStatus: codemagicResponse.status,
      },
      502,
    );
  }

  let responseBody = {};
  try {
    responseBody = await codemagicResponse.json();
  } catch {
    // A successful upstream response without JSON should not expose or block the webhook.
  }

  return jsonResponse(
    {
      ok: true,
      triggered: true,
      buildId: responseBody.buildId ?? null,
      mergeSha: eligibility.mergeSha,
      deliveryId,
    },
    202,
  );
}

export default {
  fetch(request, env) {
    return handleRequest(request, env, fetch);
  },
};
