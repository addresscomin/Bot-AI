# ZeekDrop release checklist

## Foundation
- [ ] Dedicated ZeekDrop Supabase project created and credentials stored securely
- [ ] Initial SQL migration applied and schema inspected
- [ ] RLS/security advisor review completed
- [ ] Auth provider and account recovery configured

## Backend
- [ ] Typed API contract and validation
- [ ] Role-protected admin and creator endpoints
- [ ] Rights verification and expiry enforcement
- [ ] Signed upload and playback authorization
- [ ] Audit events, rate limits and abuse reporting

## Media pipeline
- [ ] Private media bucket and upload limits
- [ ] Transcoding to HLS renditions
- [ ] Poster/thumbnail and subtitle processing
- [ ] CDN delivery and playback authorization
- [ ] Retry queue, dead-letter handling and cost alerts

## Apps and portals
- [ ] Native Android customer app
- [ ] Creator submission portal
- [ ] Owner/admin dashboard
- [ ] Accessible loading, empty, error and offline states

## Quality and release
- [ ] Unit, integration and end-to-end tests
- [ ] Android device playback tests
- [ ] Privacy policy, terms and content rating
- [ ] Copyright/takedown process
- [ ] Signed AAB and Play Console review
- [ ] Monitoring, backups and incident runbook

A checkbox is complete only after evidence from a real test or deployment exists.
