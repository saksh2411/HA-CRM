# Local XAMPP runtime validation

Date: 2026-10-01 (local environment)

## Scope and environment

- PHP executable: `C:\xampp82\php\php.exe`, PHP 8.2.12.
- PHP extensions verified: PDO, `pdo_mysql`, MySQLi, mbstring, OpenSSL, session, and JSON.
- Apache executable: XAMPP Apache 2.4.58; `httpd.exe -t` returned `Syntax OK`. Apache was not started for this validation.
- Database executable: XAMPP MariaDB 10.4.32. It is below the SRS target of MariaDB 10.5+; this run does not certify the target DB version.
- Runtime APIs were served by PHP's built-in server using the XAMPP PHP executable. Requests used only `ha_crm_runtime_test`.
- The test schema was created for this task; no pre-existing application database was modified. No real email was sent: the test tenant had no SMTP configuration.

## Results

| Validation | Result |
|---|---|
| PHP version/extensions | PASS: PHP 8.2.12 and required extensions available |
| PHP syntax | PASS: 18 application/public/cron PHP files linted with `php -l`; frontend static check additionally parsed 21 source files |
| Apache availability | PASS: binary available and configuration syntax valid; service not started |
| Database schema import | PASS: `database/database.sql` imported into the isolated test schema without FK errors (earlier in this validation session) |
| Schema integrity | PASS: 33 base tables, 83 foreign keys, all tables InnoDB; no referenced FK column type mismatches |
| Seed import/references | PASS: development seed imported without FK errors; seed-backed workspace/admin setup used in runtime checks |
| Auth/session/CSRF | PASS: first-admin setup, login, session context, CSRF requests; logout left session unauthenticated |
| RBAC | PASS: Sales Rep authenticated and received 403 for company-settings management |
| Tenant isolation | PASS: Tenant A read/update/delete attempts for Tenant B lead ID each returned 404; Tenant B record remained readable and unchanged |
| Representative CRM workflow | PASS: account/contact/lead API creation and lead filtering; lead conversion created contact/account/deal; deal moved to Negotiation and then Closed Won |
| Billing | PASS: quote/invoice with two lines: subtotal 235.00, global discount 23.50, tax 25.65, grand total 237.15; $50 payment led to 187.15 balance and Partially Paid; paying remainder led to zero balance and Paid |
| PDF | PASS: quote and invoice download endpoints each returned HTTP 200; generated files were 1,682 and 1,676 bytes and began with `%PDF` |
| SMTP exposure | PASS: GET SMTP response was `{"is_configured":false}` with no password fields; no SMTP settings or external email delivery configured |
| Cron | PASS: XAMPP PHP CLI ran `cron.php` twice (exit code 0 both runs); overdue invoice became Overdue; overdue event/task/notice, task reminder, Closed Won event/draft invoice/welcome outbox event each existed once; SMTP outbox mail failed safely as unconfigured |
| Notification polling | PASS: AJAX poll returned three cron-created notices |
| Frontend checks | PASS: `npm run check` and `npm run build`; Vite emitted minified CSS/JS production assets |

The previous API checks also exercised account/contact/lead writes, status filtering, and tenant-scoped resource APIs. After collecting the results, the newly created `ha_crm_runtime_test` schema and temporary API/PDF/session runtime artifacts were removed; no pre-existing database was changed.

## Remaining gaps and interpretation

- **Numeric relationship IDs:** This is an implementation/UI ergonomics limitation rather than an explicit SRS requirement for a particular selector widget. The underlying relationships are validated server-side and linked records are tenant-scoped. Prefer lookup controls as a usability improvement.
- **Separate Contacts/Accounts routes:** Both modules have separate routes and CRUD; that satisfies the independent module requirement. The SRS's combined split-profile/timeline interaction is only partially represented by the contextual drawer, so the richer split-pane treatment remains a UI gap if that specific described layout is mandatory.
- **Document line-item editing:** The SRS requires document item grids and editable financial details; creation supports multiple line items and server-side calculation. Editing line items after a document is created is not clearly specified as a separate workflow, so it is not treated as a confirmed missing requirement.
- **Limited profile control:** The app profile control currently provides logout rather than profile preferences. The SRS does call for user settings; profile editing is therefore a remaining SRS gap.
- **Database target:** Runtime import and workflows passed on MariaDB 10.4.32, while the SRS target is MariaDB 10.5+ or MySQL 8.0. Retest on the target version before production.
- **Deployment/runtime limits:** Apache was syntax-checked but not launched; cPanel, TLS termination, real SMTP delivery, load/performance goals, and cron concurrency were not validated here.

## Reproduction commands

```powershell
C:\xampp82\php\php.exe -v
C:\xampp82\php\php.exe -m
C:\xampp82\apache\bin\httpd.exe -t
C:\xampp82\mysql\bin\mysql.exe -uroot -e "SELECT VERSION(); SHOW DATABASES;"
npm run check
npm run build
```

Database/API workflows were executed against the temporary `ha_crm_runtime_test` schema and its local PHP API server; do not point these steps at a production database.
