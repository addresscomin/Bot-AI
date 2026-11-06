# ZeekDrop Project Structure

## Current repository
```
.
├── index.html              # Responsive frontend design preview (current)
├── README.md               # Product scope and implementation status
└── PROJECT_STRUCTURE.md    # This architecture plan
```

## Planned Android application (native Kotlin / Jetpack Compose)
```
android/
  app/
    src/main/
      java/.../zeekdrop/
        app/                 # Application entry point and navigation
        core/design/         # Colors, typography, dark/light themes
        core/network/        # API client and error handling
        core/storage/        # Secure preferences and local cache
        data/                # DTOs, repositories and data sources
        domain/              # Models and use cases
        feature/
          onboarding/
          auth/
          home/
          explore/
          search/
          drama/
          player/
          watchlist/
          history/
          profile/
```

## Planned backend and operations
```
backend/
  api/                       # Authenticated catalogue and user APIs
  admin/                     # Restricted owner/admin web console
  creator-portal/            # Creator and licensed supplier intake
  workers/
    ingest/                  # Approved provider feeds and resumable uploads
    media-processing/        # Transcoding, thumbnails and subtitles
    publishing/              # Rights-gated scheduling and publication
  database/
    migrations/
    policies/
```

## Key product flows
- Viewer: Home → Drama details → Episode → Player → Watchlist / History.
- Supplier: approved account → upload or feed import → rights evidence → review → publish.
- Admin: review rights and reports → approve/reject → schedule → monitor delivery.
- Automation: ingest → validate file/metadata/rights → process media → queue approval → publish on schedule.

## Safety, rights and reliability requirements
- No scraping or reuploading third-party dramas without permission.
- Store rights holder, territory, term, permitted platforms, expiry and evidence for each title.
- Use age ratings, reporting, moderation and takedown workflows.
- Keep video files in object storage/CDN, not in the metadata database.
- Use signed playback access where required; monitor storage, transcoding and bandwidth costs.
- Never expose supplier credentials, private storage keys or admin secrets in the Android client.
