# Token service

This service exchanges a narrowly validated app request for a short-lived OpenAI Realtime Translation client secret. It never receives or relays conversation audio.

## Local setup

```sh
cp .env.example .env
npm ci
npm run typecheck
npm test
npm run build
```

Start the compiled service with `npm start`. The health endpoint is `GET /health`; the credential endpoint is `POST /api/translation-token`.

The initial shared `APP_ACCESS_TOKEN` is suitable only for the private side-loaded pilot described in `../docs/SECURITY.md`. Do not deploy the service publicly without TLS, operational quotas, and the planned per-install credential design or a private network boundary.
