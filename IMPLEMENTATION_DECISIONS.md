# HA-CRM implementation decisions

These decisions resolve the choices authorized in the implementation request and remain consistent with the SRS:

1. React is the browser UI. Vite builds static production assets; Node is build-time only.
2. PHP 8.2+ is a native MVC-style modular monolith with PDO and a native router returning REST-style JSON.
3. MariaDB/MySQL uses InnoDB, utf8mb4, DECIMAL amounts, and dependency-ordered foreign keys.
4. Tenants share one database. Each tenant-owned row has tenant_id; API requests derive tenant scope from the authenticated session and never trust a submitted tenant ID.
5. User email is unique per tenant. Roles are Admin, Sales Manager, Sales Rep, Support Agent; access checks are server-side.
6. Sales Rep visibility includes assigned records and records assigned to their teams. Sales Managers/Admins see the tenant pipeline. Support Agents can work tickets and associated contacts.
7. “Online” lead recipients mean active, eligible Sales Reps in the tenant, since shared hosting has no persistent presence service.
8. Financial calculations use DECIMAL and line subtotal → item discounts → subtotal → global discount → taxable amount → tax → grand total, with currency rounding to two decimal places.
9. Payments update paid amount and remaining balance server-side. Invoice status is Draft, Sent, Partially Paid, Paid, or Overdue.
10. Contact deletion preserves deal history: deal contact references use SET NULL. Records carrying financial/audit history are restricted or soft-deleted rather than cascaded.
11. Custom fields use definition/value metadata tables; CRM tables are not dynamically altered.
12. Cron handlers are idempotent using unique event keys and processed markers.
13. Notifications use AJAX polling; no WebSockets.
14. PDF output uses FPDF; PHPMailer provides SMTP delivery.
15. SMTP password is never returned through an API; responses report configured/unconfigured only.
16. Security includes password hashing, secure sessions, CSRF, output escaping, prepared statements, RBAC, tenant isolation, IDOR checks, validation, lead-capture abuse controls, and safe errors.
17. Tax rules are generic percentage tax because the SRS provides no jurisdiction-specific rates or legal invoice template. Currency conversion is not performed.
18. Ticket SLA target is stored per ticket (hours) and captured at creation; no escalation ladder is inferred because the SRS provides none.
19. Reporting uses tenant-scoped CRM data. Revenue forecast is amount × win probability; lead-source ROI cannot be fully computed until acquisition costs are entered, so report returns source totals and marks missing cost inputs.
20. The schema contains modules and supporting tables directly required by the SRS plus normalized support tables. Development seeds contain safe demo records only and are not production credentials.
21. Store timestamps in UTC. Convert date/time form values from the tenant's configured timezone; new workspaces use the timezone selected in setup (defaulting to the browser's local zone).
