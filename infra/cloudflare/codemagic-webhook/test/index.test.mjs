import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import test from "node:test";

import {
  evaluateMergedPullRequest,
  handleRequest,
  verifyGitHubSignature,
} from "../src/index.js";

const secret = "test-webhook-secret";
const env = {
  GITHUB_WEBHOOK_SECRET: secret,
  CODEMAGIC_API_TOKEN: "cm-test-token",
  CODEMAGIC_APP_ID: "cm-app-id",
  CODEMAGIC_WORKFLOW_ID: "signed-android-aab",
  EXPECTED_REPOSITORY: "sali97m-cpu/deutsch-bilarabi",
  EXPECTED_BASE_BRANCH: "main",
};

function mergedPayload(overrides = {}) {
  return {
    action: "closed",
    repository: { full_name: env.EXPECTED_REPOSITORY },
    pull_request: {
      merged: true,
      base: { ref: "main" },
      merge_commit_sha: "a".repeat(40),
    },
    ...overrides,
  };
}

function signatureFor(body, signingSecret = secret) {
  return `sha256=${createHmac("sha256", signingSecret).update(body).digest("hex")}`;
}

function githubRequest(payload, extraHeaders = {}) {
  const body = JSON.stringify(payload);
  return new Request("https://worker.example.test/", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-github-event": "pull_request",
      "x-github-delivery": "delivery-123",
      "x-hub-signature-256": signatureFor(body),
      ...extraHeaders,
    },
    body,
  });
}

test("accepts a valid GitHub HMAC signature", async () => {
  const body = JSON.stringify({ hello: "world" });
  assert.equal(await verifyGitHubSignature(secret, body, signatureFor(body)), true);
  assert.equal(await verifyGitHubSignature(secret, body, signatureFor(body, "wrong")), false);
});

test("only accepts merged pull requests into main for the canonical repository", () => {
  assert.deepEqual(evaluateMergedPullRequest("pull_request", mergedPayload(), env), {
    eligible: true,
    mergeSha: "a".repeat(40),
  });

  const wrongBranch = mergedPayload({
    pull_request: {
      merged: true,
      base: { ref: "develop" },
      merge_commit_sha: "a".repeat(40),
    },
  });
  assert.equal(evaluateMergedPullRequest("pull_request", wrongBranch, env).eligible, false);
});

test("skips an eligible merged PR when skip build is requested", () => {
  const skipTitle = mergedPayload({
    pull_request: {
      merged: true,
      base: { ref: "main" },
      merge_commit_sha: "a".repeat(40),
      title: "docs: metadata only [skip build]",
      body: "",
    },
  });
  assert.deepEqual(
    evaluateMergedPullRequest("pull_request", skipTitle, env),
    { eligible: false, reason: "skip_build_requested" },
  );

  const skipBody = mergedPayload({
    pull_request: {
      merged: true,
      base: { ref: "main" },
      merge_commit_sha: "a".repeat(40),
      title: "docs: metadata only",
      body: "No release artifact needed. [SKIP BUILD]",
    },
  });
  assert.deepEqual(
    evaluateMergedPullRequest("pull_request", skipBody, env),
    { eligible: false, reason: "skip_build_requested" },
  );
});

test("triggers the pinned Codemagic workflow for an eligible merge", async () => {
  const calls = [];
  const fakeFetch = async (url, options) => {
    calls.push({ url, options });
    return new Response(JSON.stringify({ buildId: "build-123" }), {
      status: 200,
      headers: { "content-type": "application/json" },
    });
  };

  const response = await handleRequest(githubRequest(mergedPayload()), env, fakeFetch);
  assert.equal(response.status, 202);
  assert.equal(calls.length, 1);
  assert.equal(calls[0].url, "https://api.codemagic.io/builds");
  assert.equal(calls[0].options.headers["x-auth-token"], env.CODEMAGIC_API_TOKEN);

  const body = JSON.parse(calls[0].options.body);
  assert.deepEqual(body, {
    appId: env.CODEMAGIC_APP_ID,
    workflowId: "signed-android-aab",
    branch: "main",
    labels: ["github-merge", "sha-aaaaaaaaaaaa"],
    environment: {
      variables: {
        EXPECTED_MERGE_SHA: "a".repeat(40),
        GITHUB_DELIVERY_ID: "delivery-123",
      },
    },
  });
});

test("rejects an invalid signature before contacting Codemagic", async () => {
  let called = false;
  const request = githubRequest(mergedPayload(), {
    "x-hub-signature-256": `sha256=${"0".repeat(64)}`,
  });

  const response = await handleRequest(request, env, async () => {
    called = true;
    return new Response("{}", { status: 200 });
  });

  assert.equal(response.status, 401);
  assert.equal(called, false);
});

test("fails closed when Codemagic rejects the trigger", async () => {
  const response = await handleRequest(
    githubRequest(mergedPayload()),
    env,
    async () => new Response("denied", { status: 403 }),
  );

  assert.equal(response.status, 502);
  const body = await response.json();
  assert.equal(body.error, "codemagic_rejected_request");
  assert.equal(body.upstreamStatus, 403);
});
