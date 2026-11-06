-- ZeekDrop initial production schema
-- Apply only to the dedicated ZeekDrop Supabase project.
create extension if not exists pgcrypto;

create type public.app_role as enum ('viewer', 'creator', 'moderator', 'admin');
create type public.content_status as enum ('draft', 'submitted', 'review', 'scheduled', 'published', 'rejected', 'removed');
create type public.rights_status as enum ('pending', 'verified', 'expired', 'revoked');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null default 'viewer',
  granted_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

create table public.series (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  synopsis text not null default '',
  poster_url text,
  banner_url text,
  genres text[] not null default '{}',
  language_code text not null default 'hi',
  age_rating text not null default '13+',
  status public.content_status not null default 'draft',
  created_by uuid references auth.users(id),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.episodes (
  id uuid primary key default gen_random_uuid(),
  series_id uuid not null references public.series(id) on delete cascade,
  episode_number integer not null check (episode_number > 0),
  title text not null,
  synopsis text not null default '',
  duration_seconds integer check (duration_seconds is null or duration_seconds > 0),
  playback_manifest_path text,
  thumbnail_url text,
  status public.content_status not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  unique (series_id, episode_number)
);

create table public.content_rights (
  id uuid primary key default gen_random_uuid(),
  series_id uuid references public.series(id) on delete cascade,
  episode_id uuid references public.episodes(id) on delete cascade,
  rights_holder text not null,
  agreement_reference text not null,
  territory_codes text[] not null default '{}',
  platforms text[] not null default '{android,web}',
  starts_at timestamptz not null,
  ends_at timestamptz,
  status public.rights_status not null default 'pending',
  verified_by uuid references auth.users(id),
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  check (series_id is not null or episode_id is not null),
  check (ends_at is null or ends_at > starts_at)
);

create table public.watchlist (
  user_id uuid not null references auth.users(id) on delete cascade,
  series_id uuid not null references public.series(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, series_id)
);

create table public.watch_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  episode_id uuid not null references public.episodes(id) on delete cascade,
  position_seconds integer not null default 0 check (position_seconds >= 0),
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, episode_id)
);

create table public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  series_id uuid references public.series(id) on delete cascade,
  episode_id uuid references public.episodes(id) on delete cascade,
  reason text not null,
  details text not null default '',
  status text not null default 'open' check (status in ('open','investigating','resolved','dismissed')),
  created_at timestamptz not null default now(),
  check (series_id is not null or episode_id is not null)
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''));
  return new;
end;
$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create index series_status_published_idx on public.series(status, published_at desc);
create index episodes_series_status_idx on public.episodes(series_id, status, episode_number);
create index rights_status_dates_idx on public.content_rights(status, starts_at, ends_at);

create or replace function public.has_role(required_role public.app_role)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role = required_role
  );
$$;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = ''
as $
  select exists (
    select 1 from public.user_roles
    where user_id = (select auth.uid()) and role in ('moderator','admin')
  );
$;

-- SECURITY DEFINER helpers keep private contract records unreadable to viewers
-- while allowing catalogue policies to verify distribution rights.
create or replace function public.has_active_series_rights(p_series_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $
  select exists (
    select 1 from public.content_rights r
    where r.series_id = p_series_id
      and r.status = 'verified'
      and r.starts_at <= now()
      and (r.ends_at is null or r.ends_at > now())
  );
$;

create or replace function public.has_active_episode_rights(p_episode_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $
  select exists (
    select 1 from public.content_rights r
    where r.episode_id = p_episode_id
      and r.status = 'verified'
      and r.starts_at <= now()
      and (r.ends_at is null or r.ends_at > now())
  );
$;

revoke all on function public.has_active_series_rights(uuid) from public;
revoke all on function public.has_active_episode_rights(uuid) from public;
grant execute on function public.has_active_series_rights(uuid) to anon, authenticated;
grant execute on function public.has_active_episode_rights(uuid) to anon, authenticated;

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.series enable row level security;
alter table public.episodes enable row level security;
alter table public.content_rights enable row level security;
alter table public.watchlist enable row level security;
alter table public.watch_progress enable row level security;
alter table public.content_reports enable row level security;

create policy "profiles_read_self_or_staff" on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.is_staff());
create policy "profiles_update_self" on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "roles_read_self_or_staff" on public.user_roles for select to authenticated
using (user_id = (select auth.uid()) or public.is_staff());

create policy "published_series_public_read" on public.series for select to anon, authenticated
using (status = 'published' and public.has_active_series_rights(id));
create policy "staff_manage_series" on public.series for all to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "published_episodes_public_read" on public.episodes for select to anon, authenticated
using (
  status = 'published'
  and exists (
    select 1 from public.series s
    where s.id = series_id
      and s.status = 'published'
      and public.has_active_series_rights(s.id)
  )
  -- Series-wide licences cover every episode unless an episode has its own
  -- rights record; explicit episode records must themselves be verified.
  and (
    not exists (
      select 1 from public.content_rights er
      where er.episode_id = id
    )
    or public.has_active_episode_rights(id)
  )
);
create policy "staff_manage_episodes" on public.episodes for all to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "staff_manage_rights" on public.content_rights for all to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "watchlist_owner_access" on public.watchlist for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "watch_progress_owner_access" on public.watch_progress for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "reporter_create_report" on public.content_reports for insert to authenticated
with check (reporter_id = (select auth.uid()));
create policy "reporter_read_own_or_staff" on public.content_reports for select to authenticated
using (reporter_id = (select auth.uid()) or public.is_staff());
create policy "staff_update_reports" on public.content_reports for update to authenticated
using (public.is_staff()) with check (public.is_staff());

grant usage on schema public to anon, authenticated;
grant select on public.series, public.episodes to anon, authenticated;
grant select, insert, update, delete on public.watchlist, public.watch_progress to authenticated;
grant select, insert on public.content_reports to authenticated;
grant select, update on public.profiles to authenticated;
grant select on public.user_roles to authenticated;

-- No user can self-assign elevated roles. Bootstrap the first admin through a
-- trusted server-side procedure after verifying the owner identity.
