# ZeekDrop Supabase setup

Apply this only to a **new, dedicated ZeekDrop Supabase project**. Do not run it in any unrelated project.

## 1. Create the project and apply the schema

1. Create a dedicated Supabase project.
2. Open SQL Editor and run the complete migration in `migrations/202611060001_initial_schema.sql`.
3. Review the migration result and run Supabase Database Linter / Security Advisor.
4. Configure an authentication provider and account recovery.

The migration has not been applied automatically. It creates the schema, RLS policies and rights checks; it does not create a production media pipeline.

## 2. Bootstrap the first owner (one-time trusted operation)

1. Sign up the owner account through Supabase Auth.
2. In Supabase Dashboard → Authentication → Users, verify the account belongs to the actual project owner and copy that user's UUID.
3. In SQL Editor, replace the placeholder below with that exact UUID and run it once:

```sql
insert into public.user_roles (user_id, role, granted_by)
values ('REPLACE-WITH-VERIFIED-OWNER-UUID', 'admin', null)
on conflict (user_id, role) do nothing;
```

Never expose an endpoint that lets a user choose their own role. Assign creator/moderator roles only after reviewing the person and their content rights. The web portals check roles from the database; they do not grant roles.

## 3. Connect the portals

Use the project URL and publishable key only. The owner portal is `web/admin/index.html`; creator portal is `web/creator/index.html`. These browser pages never need a service-role key.

## 4. Before real content

- Verify signed agreements, territory, platforms and dates before marking rights as verified.
- The current portal supports metadata drafts and rights records; it does not upload or transcode video.
- Do not publish third-party shows without explicit streaming/distribution permission.
- Do not launch until RLS, moderation, privacy, takedown and age-rating checks pass.
