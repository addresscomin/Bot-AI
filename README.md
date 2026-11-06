# ZEEKDROP — Short Drama Streaming Platform

ZeekDrop is being converted from the previous Bot-AI learning frontend into a mobile-first short-drama streaming product.

## Frontend preview (Phase 1)

The current `index.html` is a responsive product-design prototype for the Android experience. It includes:
- Premium dark and light themes (preference saved locally)
- Home feed with featured series and trending/fresh rows
- Explore page and genre filters
- Search across the sample catalogue
- Drama details and episode selector
- Player interface preview
- Watchlist and recently opened history (local browser storage)
- Profile and settings screen
- Responsive desktop sidebar and Android-style bottom navigation

The sample drama catalogue and artwork are placeholders for interface testing. They are not licensed content and must not be treated as a publishable catalogue.

## Important implementation status

This is a **frontend preview**, not yet a native Android APK or a production streaming service. The player is a visual interaction placeholder; it does not stream video. Login, cloud sync, subscriptions, creator uploads, rights verification, video transcoding, CDN delivery, admin operations and analytics are not connected yet.

## Planned build phases

1. **Frontend:** finalize Android screen designs and navigation; then implement native Kotlin + Jetpack Compose screens.
2. **Backend:** authentication, user profiles, catalogue APIs, episode metadata, watchlist/history sync, reporting and admin roles.
3. **Content operations:** licensed supplier/creator intake, rights records, moderation, upload processing, transcoding and scheduled publishing.
4. **Streaming:** object storage, HLS packaging, CDN delivery, playback authorization and cost monitoring.
5. **Release:** accessibility, privacy and safety review, QA, signed Android App Bundle and Play Store preparation.

## Preview

Open `index.html` in a browser or enable GitHub Pages for the repository. On mobile, it uses a compact bottom navigation layout.

## Content and copyright

Only content owned by ZeekDrop or content covered by documented distribution/streaming rights may be published. Sample cards in this prototype are for UI demonstration only.
