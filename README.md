# HA CRM

Multi-tenant CRM for PHP 8.2+, MariaDB/MySQL, XAMPP, and PHP shared hosting. React is compiled to static files; Node is used only to build the frontend.

## Requirements

- PHP 8.2+ with PDO MySQL, MySQLi, JSON, mbstring, and OpenSSL extensions.
- MariaDB 10.5+ or MySQL 8.0, InnoDB enabled.
- Bundled PHPMailer and FPDF libraries are included under `vendor/`; Composer is optional for dependency updates.
- Node.js/npm only on the build machine for React assets.
- Apache with `mod_rewrite` for pretty paths, or use the documented PHP entrypoint fallback.

## Local XAMPP installation

1. Copy the project folder to `C:\xampp\htdocs\HA-CRM` (or another Apache-served directory).
2. Start Apache and MySQL in the XAMPP Control Panel.
3. Create an empty database named `ha_crm_db` with `utf8mb4_unicode_ci` in phpMyAdmin.
4. Import `database/database.sql`. Optionally import `database/dev-seed.sql` for sample CRM records in the `development-workspace` tenant; it creates no login user or password.
5. Copy `.env.example` to `.env`; set the DB name/user/password and a random `APP_KEY` of at least 24 characters.
6. On a build machine, run `npm install` and `npm run build`. The built assets are written to `public/assets/build`.
7. Open `http://localhost/HA-CRM/public/`. Select **First time? Set up workspace** to register a new tenant and its first Admin. Choose a unique workspace slug and use a 12–72 byte password; registration signs the Admin in. Normal sign-in requires the registered email, workspace slug, and password.
8. To create the first Admin for the optional, pre-seeded `development-workspace` tenant, run `C:\xampp82\php\php.exe scripts\create-tenant-admin.php` from the project directory in a trusted local terminal. It prompts for the workspace slug, name, email, and a password confirmation; password input is visible in the terminal. It is CLI-only and refuses workspaces that already have a user. This local bootstrap is not exposed as a public registration path.
9. For development, `npm run dev` serves the Vite frontend. Configure the Vite proxy to your XAMPP path in `vite.config.js` if it differs.

If Apache does not use `public/` as the document root, use `public/` as the application URL (`/HA-CRM/public/`). Never expose the project root as a public document root. Ensure `.env`, SQL files, Composer files, logs, and generated artifacts are not downloadable.

## cPanel/shared hosting deployment

1. Select PHP 8.2+ and enable PDO MySQL, MySQLi, JSON, mbstring, and OpenSSL.
2. Create the database and database user in cPanel; grant the user privileges to that database.
3. Build React before upload (`npm install && npm run build`). Upload the project with bundled `vendor/` and `public/assets/build/` included. Composer and Node are not required on the server.
4. Set the domain document root to the `public/` directory when allowed. Keep app, config, vendor, database, and storage directories outside the public root. If hosting forces `public_html`, copy only public entry/assets there and keep private directories elsewhere; update bootstrap paths accordingly.
5. Create `.env` on the host with production DB values, a unique random APP_KEY, `APP_ENV=production`, `APP_DEBUG=false`, and `SESSION_SECURE=true` under HTTPS. Do not put `.env` in a downloadable folder.
6. Import `database/database.sql`, visit the site once, and create the workspace administrator.
7. Configure SMTP under Settings. The API never returns the SMTP password.
8. Add cPanel cron jobs using the host PHP binary. Run `php /home/ACCOUNT/path/to/ha-crm/cron.php` every 5 or 15 minutes. If desired, schedule the focused scripts instead. Cron scripts reject web requests.
9. Configure the host's PHP error log for PHP warnings/errors and keep it outside the public document root. Protect generated invoice PDFs; the API streams PDFs after authorization rather than saving public copies.

## Demo data (local only)

`database/demo-data.sql` creates a ready-to-use demo workspace with sample leads, contacts, accounts, deals, tasks, tickets, quotes, invoices and notifications. Import it in phpMyAdmin after `database/database.sql`. Sign in with workspace `demo-company` and `admin@demo.test` / `Demo@12345678` (also `manager@`, `rep1@`, `rep2@`, `support@demo.test`, same password). Never import it in production.

## Database seed data

`database/dev-seed.sql` is optional local-only setup data and assumes an empty database after `database.sql`. It adds a development tenant, roles, permissions for Admin, default pipeline/stages, company settings, and clearly labeled demo CRM records. It intentionally creates no default user or password. Create its first administrator with the CLI-only `scripts/create-tenant-admin.php` utility; public signup always creates a new tenant and cannot claim an existing workspace. Never import this file in production.

## Development commands

```sh
composer install
npm install
npm run dev
npm run build
npm run check
```

The PHP code uses Composer PSR-4 autoloading. The React build output is static and the production PHP app runs without Node.

## API overview

See [docs/API.md](docs/API.md) for endpoints and session/CSRF behavior. Public lead capture requires a workspace slug and is protected by a honeypot and per-IP/per-tenant rate limit. Authenticated APIs derive tenant ID from the session; client-supplied tenant IDs are ignored.

## Security and limitations

- Use TLS in production. HTTPS-only secure sessions are configured with `SESSION_SECURE=true`.
- Keep APP_KEY stable and secret; it encrypts saved SMTP credentials.
- Configure database backups and retention for tenant/business records.
- SMTP and PDFs use the included PHPMailer and FPDF libraries. Email delivery still requires tenant SMTP configuration.
- Tenant isolation and RBAC are enforced server-side. The implementation includes tenant-scoped CRUD, assigned/team visibility on leads/deals, and support-agent ticket access.
- Report source ROI shows lead/source values and recorded costs; the SRS does not supply cost data or a formula.

## Requirement coverage

See [docs/REQUIREMENT-COVERAGE.md](docs/REQUIREMENT-COVERAGE.md) for SRS-to-module traceability and current implementation status.

See [docs/RUNTIME-VALIDATION.md](docs/RUNTIME-VALIDATION.md) for the final local XAMPP PHP/MariaDB, API, tenant-isolation, billing, PDF, cron, and React build results, including the MariaDB version limitation.
