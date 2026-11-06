# ZeekDrop — project structure

This repository is being repurposed from the Bot-AI starter into **ZeekDrop**, a mobile-development learning platform. The existing backend files are intentionally left untouched during Phase 1.

## Development phases

### Phase 1 — Frontend first
- Responsive learning dashboard
- Frontend and backend developer roadmap based on the supplied mobile-development skills map
- Course catalogue and lesson outline view
- Practice / quiz interaction
- Progress view with local prototype persistence
- Mobile bottom navigation, desktop sidebar, reduced-motion support

Current implementation: `index.html` is a self-contained responsive frontend prototype. It does not claim to provide real accounts, cloud sync, a code execution sandbox, full lesson content, certificates, or production backend services yet.

### Phase 2 — Backend
Planned modules:
- Authentication and user profiles
- Course, module, lesson and quiz APIs
- Persistent learning progress and bookmarks
- Secure server-side validation and rate limiting
- Admin/content management
- Database migrations, backups and audit logging

### Phase 3 — App readiness
- Connect frontend to backend APIs
- Add automated tests and accessibility checks
- Package the mobile experience (Flutter is the planned Android/iOS client)
- Configure signing, privacy disclosures, Play Store assets and release testing

## Proposed long-term layout

```
Bot-AI/
├── index.html                 # Phase 1 web frontend prototype
├── assets/                    # Images, icons and fonts
├── frontend/                  # UI modules when frontend is split
│   ├── dashboard/
│   ├── roadmap/
│   ├── courses/
│   ├── lessons/
│   ├── playground/
│   ├── quizzes/
│   ├── progress/
│   └── profile/
├── backend/                   # Phase 2 API and business logic
│   ├── auth/
│   ├── users/
│   ├── courses/
│   ├── lessons/
│   ├── progress/
│   └── quizzes/
├── database/                  # Schema and migrations
├── api/                       # API contracts
├── tests/
└── README.md
```

## Current status
Frontend prototype only. Backend and Play Store release are not complete. The repository name can be changed to ZeekDrop after the user approves the rename.
