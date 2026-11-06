# ZeekDrop API

Minimal TypeScript/Express API foundation. It currently exposes health and public catalogue reads. User-authenticated writes, creator/admin routes, playback authorization and upload signing are intentionally not exposed until server-side role checks and the dedicated database are configured.

## Local run
1. Copy `.env.example` to `.env` and set the project URL + publishable key.
2. Run `npm install`.
3. Run `npm run dev`.

The API returns 503 for database-backed routes until credentials are configured. Never place a Supabase secret/service-role key in this service's public environment or mobile app. For privileged server operations, add a separate secret-backed server client only after deployment secrets and authorization tests are in place.
