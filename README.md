# ZEEKDROP — Short Drama Streaming Platform

ZeekDrop is being built as a short-drama streaming product, replacing the previous Bot-AI learning frontend.

## Project surfaces

- **Customer preview:** `index.html` — responsive OTT-style UI prototype with home, explore, search, details, player preview, library and profile.
- **Android:** `android/` — Kotlin + Jetpack Compose native app foundation.
- **Backend:** `backend/` — TypeScript API with health, published catalogue, episode listing, authenticated profile, watchlist and content-report routes.
- **Owner Studio:** `web/admin/index.html` — browser-based moderation console for catalogue review, rights entry and report handling.
- **Creator Studio:** `web/creator/index.html` — browser-based metadata submission portal for creator-owned drafts and episodes.
- **Database:** `supabase/migrations/` — Postgres schema, RLS, rights gates and creator-owned submission policies.
- **CI:** `.github/workflows/zeekdrop-ci.yml` — backend build and Android debug APK build.

## Important current status

The web customer experience and the two portal interfaces are source-code deliverables, not a live production service. The Android app is still a foundation and needs real catalogue/auth/playback integration. The latest GitHub Actions run passed both the backend TypeScript build and Android debug APK build. The debug APK is available as the `zeekdrop-debug-apk` artifact for 7 days from the run: https://github.com/addresscomin/Bot-AI/actions/runs/42238785935. This is a test build, not a signed release.

The SQL migration is committed but has **not** been applied to a dedicated ZeekDrop Supabase project. No live database, API hosting, storage bucket, licensed video catalogue, HLS transcoder, CDN, signed release APK/AAB or Play Store release is configured.

## Start here

1. Read `docs/ARCHITECTURE.md` and `docs/RELEASE_CHECKLIST.md`.
2. Create a dedicated Supabase project; do not reuse unrelated projects.
3. Follow `supabase/README.md` to apply the migration and bootstrap the first owner account.
4. Configure only the Supabase project URL and publishable key in the web portals and Android app. Never put a service-role/secret key in client code.
5. Add creators only after checking their identity and distribution rights.

## Content rights

Only content owned by ZeekDrop or covered by documented distribution/streaming permission may be published. Sample artwork and titles in the customer prototype are placeholders, not a licensed catalogue. Crediting a show does not replace a distribution licence.

## Build commands

Backend:
```sh
cd backend
npm install
npm run build
npm start
```

Android:
```sh
cd android
gradle assembleDebug
```

The generated debug APK is for testing only. A signed release AAB, privacy/terms review, age-rating review, content moderation and real-device testing are still required.
