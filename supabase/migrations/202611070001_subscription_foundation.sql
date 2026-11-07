-- ZeekDrop subscription foundation (INR)
-- Apply only after the dedicated ZeekDrop Supabase project is created.
-- Prices below are proposed launch prices; payment collection is not enabled by this migration.

create type public.subscription_status as enum ('pending','active','past_due','cancelled','expired','refunded');
create type public.billing_interval as enum ('month','year');

create table public.subscription_plans (
  id text primary key,
  name text not null,
  amount_paise integer not null check (amount_paise >= 0),
  currency char(3) not null default 'INR' check (currency = 'INR'),
  billing_interval public.billing_interval,
  interval_count integer not null default 1 check (interval_count > 0),
  benefits jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

insert into public.subscription_plans
  (id,name,amount_paise,currency,billing_interval,interval_count,benefits,display_order)
values
  ('free','Free',0,'INR',null,1,'["Standard catalogue","Watchlist and viewing history"]'::jsonb,0),
  ('premium_monthly','Premium Monthly',9900,'INR','month',1,'["Premium catalogue access","Selected early premieres","Premium profile badge"]'::jsonb,1),
  ('premium_annual','Premium Annual',79900,'INR','year',1,'["Premium catalogue access","Selected early premieres","Premium profile badge","Annual membership"]'::jsonb,2)
on conflict (id) do update set
  name=excluded.name,
  amount_paise=excluded.amount_paise,
  currency=excluded.currency,
  billing_interval=excluded.billing_interval,
  interval_count=excluded.interval_count,
  benefits=excluded.benefits,
  display_order=excluded.display_order;

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_id text not null references public.subscription_plans(id),
  status public.subscription_status not null default 'pending',
  currency char(3) not null default 'INR' check (currency = 'INR'),
  amount_paise integer not null check (amount_paise >= 0),
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  cancelled_at timestamptz,
  provider text,
  provider_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (current_period_end is null or current_period_start is null or current_period_end > current_period_start)
);

create unique index subscriptions_provider_id_unique
  on public.subscriptions(provider,provider_subscription_id)
  where provider_subscription_id is not null;
create index subscriptions_user_status_idx on public.subscriptions(user_id,status,current_period_end desc);

create table public.subscription_payments (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null,
  provider_payment_id text,
  provider_order_id text,
  amount_paise integer not null check (amount_paise >= 0),
  currency char(3) not null default 'INR' check (currency = 'INR'),
  status text not null check (status in ('created','authorized','captured','failed','refunded','partially_refunded')),
  receipt_reference text,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index subscription_payments_provider_payment_unique
  on public.subscription_payments(provider,provider_payment_id)
  where provider_payment_id is not null;
create index subscription_payments_user_created_idx on public.subscription_payments(user_id,created_at desc);

-- Webhook event IDs are stored once to make payment-provider retries idempotent.
create table public.payment_webhook_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  provider_event_id text not null,
  event_type text not null,
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  unique(provider,provider_event_id)
);

alter table public.subscription_plans enable row level security;
alter table public.subscriptions enable row level security;
alter table public.subscription_payments enable row level security;
alter table public.payment_webhook_events enable row level security;

create policy "active_subscription_plans_public_read"
  on public.subscription_plans for select to anon,authenticated using (is_active=true);
create policy "subscription_owner_read"
  on public.subscriptions for select to authenticated
  using (user_id=(select auth.uid()) or public.is_staff());
create policy "subscription_payment_owner_read"
  on public.subscription_payments for select to authenticated
  using (user_id=(select auth.uid()) or public.is_staff());
create policy "staff_read_payment_webhook_events"
  on public.payment_webhook_events for select to authenticated
  using (public.is_staff());

grant select on public.subscription_plans to anon,authenticated;
grant select on public.subscriptions,public.subscription_payments to authenticated;
grant select on public.payment_webhook_events to authenticated;

-- Intentionally no client-side INSERT/UPDATE/DELETE grants or policies for
-- subscriptions, payments, or webhook events. A trusted server webhook must
-- verify provider signatures before activating or changing a membership.
