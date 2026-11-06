# ZeekDrop architecture

## Product surfaces
- Customer Android app: browse, search, series details, HLS playback, watchlist, continue watching, report content, profile.
- Creator portal: submit metadata and media, track review state, view rights expiry and processing status.
- Owner console: roles, rights evidence, moderation queue, catalogue publishing, scheduled releases and audit trail.
- Backend: authenticated APIs, catalogue, entitlement/playback authorization, ingestion and publishing jobs.

## Default technical direction
- Android: Kotlin + Jetpack Compose.
- API: Node.js + TypeScript.
- Data/auth: Supabase Postgres + Auth with Row Level Security.
- Media: private object storage (Cloudflare R2 or equivalent), HLS packaging and CDN.
- Jobs: queue-backed workers for validation, transcoding, thumbnail/subtitle processing and scheduled publication.

## Content safety and rights gates
1. Supplier/creator submits content and a distribution agreement reference.
2. Store territory, platform, start/end dates and rights holder.
3. Keep new content private while rights status is pending.
4. Staff verifies the agreement and moderation checks.
5. Publishing is allowed only while rights are verified and in-date.
6. Expired/revoked rights automatically block playback and new publication.
7. Keep a takedown/report workflow and immutable operational audit events.

Never scrape or re-upload third-party shows without explicit distribution rights. A credit line is not a licence.

## Environments and secrets
- Use a dedicated Supabase project for ZeekDrop; do not reuse unrelated projects.
- Frontend/mobile may contain only the Supabase project URL and publishable key.
- Never put service-role/secret keys in Android, web assets, GitHub commits or public build logs.
- Configure secrets in the deployment provider.
- Keep development and production credentials separate.

## Release gates
- Database migrations applied to the dedicated project and security advisors reviewed.
- RLS tests prove users cannot read other users' watch data or grant themselves roles.
- Rights verification and playback authorization tested.
- Upload validation, file size/type limits and malware scanning integrated.
- Playback tested on real Android devices and slow networks.
- Privacy policy, terms, content reporting and age-rating disclosures ready.
- Signed Android App Bundle built and tested before Play Store submission.

## Current implementation state
The repository currently contains a web UI preview and this architecture/schema scaffold. The migration is not yet applied to a live database; no live streaming provider, API deployment, signed APK/AAB or production credentials are configured.
