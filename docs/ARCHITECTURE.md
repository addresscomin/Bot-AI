# ZeekDrop architecture

## Product surfaces
- Customer Android app: browse, search, series details, HLS playback, watchlist, continue watching, report content and profile.
- Creator Studio: create drama and episode metadata, save drafts and submit owned/licensed material for review.
- Owner Studio: inspect catalogue, enter verified rights evidence, publish approved dramas and process content reports.
- Backend: public catalogue reads plus authenticated profile, watchlist and reporting APIs.
- Database: Supabase Postgres with RLS and explicit distribution-rights gates.

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
5. Publishing is allowed only while series rights are verified and in-date. If episode-specific rights exist, they must also be verified and in-date.
6. Expired/revoked rights block public catalogue access.
7. Keep a takedown/report workflow and add immutable audit events before public launch.

Never scrape or re-upload third-party shows without explicit distribution rights. A credit line is not a licence.

## Environments and secrets
- Use a dedicated Supabase project for ZeekDrop; do not reuse unrelated projects.
- Frontend/mobile may contain only the Supabase project URL and publishable key.
- Never put service-role/secret keys in Android, web assets, GitHub commits or public build logs.
- Configure server secrets in the deployment provider.
- Keep development and production credentials separate.

## Release gates
- Database migration applied to the dedicated project and security advisors reviewed.
- RLS tests prove users cannot read other users' watch data or grant themselves roles.
- Rights verification and playback authorization tested.
- Upload validation, file size/type limits and malware scanning integrated.
- Playback tested on real Android devices and slow networks.
- Privacy policy, terms, content reporting and age-rating disclosures ready.
- Signed Android App Bundle built and tested before Play Store submission.

## Current implementation state
Implemented in the repository: customer UI preview, initial native Android shell, TypeScript API, Supabase schema/RLS migration, owner moderation UI, creator metadata portal and GitHub Actions build workflow. Backend TypeScript build and Android debug APK build both passed in GitHub Actions run 42238785935.

Not yet deployed or production-ready: live Supabase project and migration, account bootstrap, deployed API, creator media upload, transcoding/HLS/CDN, signed playback, full Android authentication/player integration, audit pipeline, production monitoring, signed AAB and Play Store submission.
