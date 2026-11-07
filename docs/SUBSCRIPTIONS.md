# ZeekDrop subscriptions and billing foundation

## Product pricing draft (INR)

| Plan | Proposed price | Billing |
|---|---:|---|
| Free | ₹0 | No billing |
| Premium Monthly | ₹99 | Monthly |
| Premium Annual | ₹799 | Annual |

These are planning values only. The customer UI clearly marks payment as not enabled. Do not collect money until the payment provider, legal terms, refund policy, tax treatment and support workflow are reviewed.

## Subscription lifecycle

1. Customer chooses a plan in the app.
2. A trusted backend creates a provider order/subscription; the client never sets its own paid status.
3. Customer completes payment on the provider's hosted checkout.
4. Backend verifies the provider webhook signature and amount/currency/order reference.
5. Webhook event ID is stored once in `payment_webhook_events` to prevent duplicate processing.
6. Only verified server-side payment events can activate, renew, cancel or expire a subscription.
7. Customer can read their own current status and payment history; staff can inspect subscription records.
8. Entitlements are checked by the API before premium episodes are served.

## Database

Migration: `supabase/migrations/202611070001_subscription_foundation.sql`

- `subscription_plans`: public INR catalogue, prices stored as paise.
- `subscriptions`: private per-user status, billing window and cancellation state.
- `subscription_payments`: private transaction history, amounts stored as paise.
- `payment_webhook_events`: idempotency ledger for provider webhooks.

Client-side users receive SELECT-only access to their own records. No client-side insert/update/delete policy is provided for billing records. Never put payment-provider secrets or Supabase service-role keys in the web app or Android app.

## API foundation

- `GET /v1/subscription-plans` — active INR plans.
- `GET /v1/me/subscription` — signed-in user's latest subscription.
- `GET /v1/me/subscription/payments` — signed-in user's payment history.
- `GET /v1/admin/subscriptions` — staff-only subscription list, optional status and limit filters.

## Not connected yet

- Supabase migration has not been applied to a dedicated live ZeekDrop project.
- No Razorpay/UPI provider account, API keys, checkout, signed webhook or refund integration is configured.
- Subscription activation, renewal, cancellation and expiry automation are not live.
- Premium playback entitlement enforcement still needs to be wired into the playback API.

Do not describe the current preview as accepting payments or activating paid memberships.
