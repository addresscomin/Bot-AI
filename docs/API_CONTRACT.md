# Initial API contract

All write endpoints require a valid user session. Staff endpoints additionally require a server-verified moderator/admin role. Never trust a role supplied by the client.

## Public catalogue
- GET /v1/series?genre=&q=&cursor= — published series only.
- GET /v1/series/:seriesId — published series metadata.
- GET /v1/series/:seriesId/episodes — published episodes only.

## Signed-in viewer
- GET /v1/me
- GET /v1/me/watchlist
- PUT /v1/me/watchlist/:seriesId
- DELETE /v1/me/watchlist/:seriesId
- PUT /v1/me/progress/:episodeId
- POST /v1/reports

## Creator
- POST /v1/creator/submissions
- POST /v1/creator/uploads — returns a short-lived signed upload target after server-side checks.
- GET /v1/creator/submissions/:submissionId

## Staff
- GET /v1/admin/review-queue
- POST /v1/admin/rights/:rightsId/verify
- POST /v1/admin/series/:seriesId/publish
- POST /v1/admin/reports/:reportId/resolve

## Playback
- POST /v1/playback/:episodeId/session — returns a short-lived playback URL only if the episode is published and current distribution rights are verified for the viewer's territory/platform.

All endpoints must validate inputs, apply rate limits, avoid returning private storage paths, and log security-relevant actions without logging tokens or secrets.
