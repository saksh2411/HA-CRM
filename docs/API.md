# HA CRM API

All routes are same-origin JSON under `/api`. Successful responses use `{ "data": ... }`; errors use `{ "error": { "message": ..., "details": ... } }`. Authenticated responses use session cookies. Send `X-CSRF-Token` on every POST/PUT/PATCH/DELETE after obtaining the token from `GET /api/auth/csrf` or `GET /api/auth/session`.

## Identity and registration

- `GET /api/auth/csrf`, `GET /api/auth/session`
- `POST /api/auth/register` — public registration body: `{tenant_name,tenant_slug,full_name,email,password,password_confirmation,timezone?}`. Creates a new tenant and first Admin atomically, hashes the password, and signs the user in. Workspace slugs are unique; passwords must be 12–72 bytes.
- `POST /api/auth/login` — `{email,password,tenant}` where `tenant` is the workspace slug. Workspace-not-found and invalid-credentials responses are reported without revealing whether an email is registered.
- `POST /api/auth/logout`
- Legacy `POST /api/setup` delegates to the same new-tenant registration rules; it no longer claims an existing tenant or blocks after the first user.
- The pre-seeded `development-workspace` has no default account. For local use, its first Admin can be provisioned with the CLI-only `scripts/create-tenant-admin.php` tool.

## CRM resources

CRUD resources use `GET /api/{resource}?page=1&per_page=25&q=...`, `POST /api/{resource}`, `GET /api/{resource}/{id}`, `PUT /api/{resource}/{id}`, and `DELETE /api/{resource}/{id}`. Page sizes are 25, 50, or 100. Supported resources: `leads`, `accounts`, `contacts`, `deals`, `pipelines`, `pipeline-stages`, `activities`, `quotes`, `invoices`, `payments` (read-only; record through invoice payment), `tickets`, `ticket-messages`, `ticket-notes`, `users`, `teams`, `team-members`, `roles`, `custom-fields`, and `quotas`.

Lead list filters: `q`, `lead_status`, `lead_source`, `assigned_to`. Other resources support `q` where applicable and status filters. Mutations only accept registered fields; tenant ID is derived from the session.

## Workflows

- `POST /api/leads/{id}/convert` — qualified lead to contact/account/deal; transaction and repeated-call safe.
- `POST /api/deals/{id}/convert-stage` — body `{stage_id}`.
- `POST /api/deals/{id}/quote` — creates a quote from deal amount/tax/discount.
- `POST /api/quotes/{id}/invoice` — converts quote items into an invoice.
- `POST /api/invoices` and `POST /api/quotes` — require line `items`; server computes totals.
- `POST /api/invoices/{id}/send` — draft to sent.
- `POST /api/invoices/{id}/payments` — records amount and recalculates paid/balance/status.
- `GET /api/invoices/{id}/pdf` — authorized FPDF download.
- `POST /api/lead-capture.php` — public capture; requires `tenant`, first/last name, email and phone.
- `GET /api/notifications/poll?since={id}`, `POST /api/notifications/read`.
- `GET /api/dashboard`; `GET /api/reports/forecast|performance|sources`.
- `GET|PUT /api/company-settings`; `GET|PUT /api/smtp` (password is write-only; read returns configured state only).

## Important API behavior

- Lead/deal data is tenant-scoped; Sales Reps are restricted to assigned/team records.
- SMTP settings are never returned with their password.
- Invoice/quote totals are recalculated by the server; client totals are not accepted at document creation.
- Errors are sanitized; detailed exceptions are written to the PHP error log with a reference ID.
