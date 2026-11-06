# ZeekDrop API contract

Base path: `/v1`. All authenticated routes require an Authorization: Bearer Supabase access token. The API validates the token with Supabase Auth and forwards the same user JWT to Postgres so RLS remains the final access-control layer.

## Implemented in the current backend

- `GET /health` — service health and whether database configuration is present.
- `GET /v1/series?q=&genre=` — published catalogue only.
- `GET /v1/series/:seriesId/episodes` — published episodes for a published, rights-cleared series.
- `GET /v1/me` — signed-in account, roles and profile.
- `GET /v1/watchlist` — current user's saved series.
- `POST /v1/watchlist` — add `{ "seriesId": "uuid" }`.
- `DELETE /v1/watchlist/:seriesId` — remove a saved series.
- `POST /v1/reports` — create a report with exactly one of `seriesId` or `episodeId`, plus `reason` and optional `details`.

## Planned, not implemented

- Watch-progress sync.
- Creator media upload signing and submission APIs.
- Admin review queue and role-management APIs.
- Rights-expiry scheduler and audit-event pipeline.
- Short-lived playback sessions and HLS authorization.
- Subscription/payment and entitlement APIs.

Do not treat planned routes as available. All inputs must be validated, writes must be rate-limited before public launch, and security logs must never contain tokens or secrets.
