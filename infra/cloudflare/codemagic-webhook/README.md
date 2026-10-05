# Cloudflare Worker: merged PR -> Codemagic signed AAB

This Worker accepts GitHub webhooks, verifies `X-Hub-Signature-256`, ignores every event except a successfully merged pull request into `main` in `sali97m-cpu/deutsch-bilarabi`, and then calls Codemagic `POST /builds` for the `signed-android-aab` workflow.

## Secrets

Never commit the values below. Configure them as Cloudflare Worker secrets:

- `GITHUB_WEBHOOK_SECRET`: a new random webhook secret shared only by GitHub and this Worker.
- `CODEMAGIC_API_TOKEN`: Codemagic Account settings -> API token.
- `CODEMAGIC_APP_ID`: the Codemagic application ID for this repository.

Non-secret values are pinned in `wrangler.jsonc`:

- `CODEMAGIC_WORKFLOW_ID=signed-android-aab`
- `EXPECTED_REPOSITORY=sali97m-cpu/deutsch-bilarabi`
- `EXPECTED_BASE_BRANCH=main`

## Deploy from Wrangler

From this directory:

```sh
npx wrangler secret put GITHUB_WEBHOOK_SECRET
npx wrangler secret put CODEMAGIC_API_TOKEN
npx wrangler secret put CODEMAGIC_APP_ID
npx wrangler deploy
```

The same values can be entered from the Cloudflare dashboard if deployment is being managed from a phone.

## GitHub webhook

In the repository webhook settings:

- Payload URL: the deployed `https://<worker>.<subdomain>.workers.dev/` URL.
- Content type: `application/json`.
- Secret: exactly the same value as `GITHUB_WEBHOOK_SECRET`.
- SSL verification: enabled.
- Event selection: **Pull requests** only.

The Worker returns success without calling Codemagic for unmerged/closed PRs, wrong branches, wrong repositories, and non-PR events. Invalid signatures are rejected before any external API call.

## Local contract test

The Worker has no npm runtime dependency. With Node 18+:

```sh
node --check src/index.js
node --test test/index.test.mjs
```
