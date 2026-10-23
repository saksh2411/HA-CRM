-- HA CRM MariaDB 10.5+ / MySQL 8.0 schema. Import with utf8mb4 and InnoDB.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE tenants (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(150) NOT NULL, slug VARCHAR(100) NOT NULL UNIQUE,
 status ENUM('active','suspended') NOT NULL DEFAULT 'active', timezone VARCHAR(64) NOT NULL DEFAULT 'UTC',
 currency CHAR(3) NOT NULL DEFAULT 'INR', created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE roles (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NULL, name VARCHAR(50) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY uq_roles_tenant_name(tenant_id,name),
 CONSTRAINT fk_roles_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE permissions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, permission_key VARCHAR(100) NOT NULL UNIQUE, label VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, full_name VARCHAR(100) NOT NULL,
 email VARCHAR(190) NOT NULL, password_hash VARCHAR(255) NOT NULL,
 role ENUM('Admin','Sales Manager','Sales Rep','Support Agent') NOT NULL DEFAULT 'Sales Rep',
 status ENUM('Active','Inactive') NOT NULL DEFAULT 'Active', eligible_for_leads TINYINT(1) NOT NULL DEFAULT 1,
 last_login_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_users_tenant_email(tenant_id,email), KEY idx_users_tenant_role_status(tenant_id,role,status),
 CONSTRAINT fk_users_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE role_permissions (
 role_id BIGINT UNSIGNED NOT NULL, permission_id BIGINT UNSIGNED NOT NULL, PRIMARY KEY(role_id,permission_id),
 KEY idx_rp_permission(permission_id),
 CONSTRAINT fk_rp_role FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE,
 CONSTRAINT fk_rp_permission FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE teams (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, name VARCHAR(100) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY uq_teams_tenant_name(tenant_id,name),
 CONSTRAINT fk_teams_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE team_members (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, team_id BIGINT UNSIGNED NOT NULL, user_id BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY uq_team_member(team_id,user_id), KEY idx_tm_tenant_user(tenant_id,user_id), KEY idx_tm_user(user_id),
 CONSTRAINT fk_tm_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_tm_team FOREIGN KEY(team_id) REFERENCES teams(id) ON DELETE CASCADE,
 CONSTRAINT fk_tm_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE accounts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, company_name VARCHAR(150) NOT NULL,
 registration_number VARCHAR(100) NULL, industry VARCHAR(100) NULL, annual_revenue DECIMAL(14,2) NULL,
 employee_count INT UNSIGNED NULL, parent_account_id BIGINT UNSIGNED NULL, phone VARCHAR(30) NULL,
 website VARCHAR(255) NULL, office_address TEXT NULL, tax_id VARCHAR(100) NULL,
 created_by BIGINT UNSIGNED NULL, deleted_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_accounts_tenant_name(tenant_id,company_name), KEY idx_accounts_parent(parent_account_id), KEY idx_accounts_creator(created_by),
 CONSTRAINT fk_accounts_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_accounts_parent FOREIGN KEY(parent_account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_accounts_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE contacts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, account_id BIGINT UNSIGNED NULL,
 first_name VARCHAR(80) NOT NULL, last_name VARCHAR(80) NOT NULL, email VARCHAR(190) NOT NULL, phone VARCHAR(30) NULL,
 linkedin_url VARCHAR(255) NULL, billing_address TEXT NULL, shipping_address TEXT NULL,
 preferred_contact ENUM('Email','Phone','WhatsApp') NULL, assigned_to BIGINT UNSIGNED NULL,
 created_by BIGINT UNSIGNED NULL, deleted_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_contacts_tenant_email(tenant_id,email), KEY idx_contacts_account(account_id), KEY idx_contacts_assigned(tenant_id,assigned_to), KEY idx_contacts_assigned_user(assigned_to), KEY idx_contacts_creator(created_by),
 CONSTRAINT fk_contacts_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_contacts_account FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_contacts_assignee FOREIGN KEY(assigned_to) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT fk_contacts_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE pipelines (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, name VARCHAR(100) NOT NULL,
 is_default TINYINT(1) NOT NULL DEFAULT 0, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_pipeline_tenant_name(tenant_id,name), CONSTRAINT fk_pipelines_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE pipeline_stages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, pipeline_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(80) NOT NULL, position SMALLINT UNSIGNED NOT NULL, probability DECIMAL(5,2) NOT NULL DEFAULT 0,
 is_won TINYINT(1) NOT NULL DEFAULT 0, is_lost TINYINT(1) NOT NULL DEFAULT 0,
 UNIQUE KEY uq_stage_position(pipeline_id,position), KEY idx_stages_tenant_pipeline(tenant_id,pipeline_id),
 CONSTRAINT fk_stages_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_stages_pipeline FOREIGN KEY(pipeline_id) REFERENCES pipelines(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE leads (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, salutation VARCHAR(20) NULL,
 first_name VARCHAR(80) NOT NULL, last_name VARCHAR(80) NOT NULL, job_title VARCHAR(100) NULL, company VARCHAR(150) NULL,
 email VARCHAR(190) NOT NULL, secondary_email VARCHAR(190) NULL, phone VARCHAR(30) NOT NULL, mobile VARCHAR(30) NULL,
 website VARCHAR(255) NULL, lead_status ENUM('New','Contacted','Qualified','Unqualified','Lost') NOT NULL DEFAULT 'New',
 lead_source VARCHAR(80) NULL, industry VARCHAR(100) NULL, lead_value DECIMAL(14,2) NOT NULL DEFAULT 0,
 lead_score TINYINT UNSIGNED NULL, priority ENUM('Low','Medium','High','Urgent') NOT NULL DEFAULT 'Medium',
 assigned_to BIGINT UNSIGNED NULL, team_id BIGINT UNSIGNED NULL, next_follow_up DATETIME NULL, internal_notes TEXT NULL,
 created_by BIGINT UNSIGNED NULL, converted_contact_id BIGINT UNSIGNED NULL, converted_account_id BIGINT UNSIGNED NULL,
 converted_deal_id BIGINT UNSIGNED NULL, converted_at DATETIME NULL, source_cost DECIMAL(14,2) NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_leads_tenant_status(tenant_id,lead_status), KEY idx_leads_tenant_assigned(tenant_id,assigned_to),
 KEY idx_leads_tenant_source(tenant_id,lead_source), KEY idx_leads_tenant_created(tenant_id,created_at),
 KEY idx_leads_tenant_email(tenant_id,email), KEY idx_leads_team(team_id), KEY idx_leads_assignee(assigned_to), KEY idx_leads_creator(created_by),
 CONSTRAINT fk_leads_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_leads_assignee FOREIGN KEY(assigned_to) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT fk_leads_team FOREIGN KEY(team_id) REFERENCES teams(id) ON DELETE SET NULL,
 CONSTRAINT fk_leads_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE deals (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, deal_title VARCHAR(150) NOT NULL,
 pipeline_id BIGINT UNSIGNED NOT NULL, stage_id BIGINT UNSIGNED NOT NULL, contact_id BIGINT UNSIGNED NULL,
 account_id BIGINT UNSIGNED NULL, source_lead_id BIGINT UNSIGNED NULL, amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0, tax_rate DECIMAL(7,4) NOT NULL DEFAULT 0,
 net_value DECIMAL(14,2) NOT NULL DEFAULT 0, currency CHAR(3) NOT NULL DEFAULT 'INR', expected_close_date DATE NULL,
 win_probability DECIMAL(5,2) NOT NULL DEFAULT 0, loss_reason ENUM('Price','Competitor','Feature Gap','No Response') NULL,
 assigned_to BIGINT UNSIGNED NULL, team_id BIGINT UNSIGNED NULL, created_by BIGINT UNSIGNED NULL,
 closed_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_deals_tenant_stage(tenant_id,pipeline_id,stage_id), KEY idx_deals_tenant_owner(tenant_id,assigned_to),
 KEY idx_deals_close_date(tenant_id,expected_close_date), KEY idx_deals_contact(contact_id), KEY idx_deals_account(account_id), KEY idx_deals_stage(stage_id), KEY idx_deals_pipeline(pipeline_id), KEY idx_deals_source_lead(source_lead_id), KEY idx_deals_assignee(assigned_to), KEY idx_deals_team(team_id), KEY idx_deals_creator(created_by),
 CONSTRAINT fk_deals_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_deals_pipeline FOREIGN KEY(pipeline_id) REFERENCES pipelines(id) ON DELETE RESTRICT,
 CONSTRAINT fk_deals_stage FOREIGN KEY(stage_id) REFERENCES pipeline_stages(id) ON DELETE RESTRICT,
 CONSTRAINT fk_deals_contact FOREIGN KEY(contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
 CONSTRAINT fk_deals_account FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_deals_lead FOREIGN KEY(source_lead_id) REFERENCES leads(id) ON DELETE SET NULL,
 CONSTRAINT fk_deals_assignee FOREIGN KEY(assigned_to) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT fk_deals_team FOREIGN KEY(team_id) REFERENCES teams(id) ON DELETE SET NULL,
 CONSTRAINT fk_deals_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
ALTER TABLE leads ADD KEY idx_leads_converted_contact(converted_contact_id), ADD KEY idx_leads_converted_account(converted_account_id), ADD KEY idx_leads_converted_deal(converted_deal_id),
 ADD CONSTRAINT fk_leads_converted_contact FOREIGN KEY(converted_contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
 ADD CONSTRAINT fk_leads_converted_account FOREIGN KEY(converted_account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 ADD CONSTRAINT fk_leads_converted_deal FOREIGN KEY(converted_deal_id) REFERENCES deals(id) ON DELETE SET NULL;

CREATE TABLE activities (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL,
 activity_type ENUM('Call','Meeting','Email','Task','Demo') NOT NULL, subject VARCHAR(180) NOT NULL,
 related_type ENUM('Lead','Deal','Contact','Account','Ticket') NULL, related_id BIGINT UNSIGNED NULL,
 due_at DATETIME NOT NULL, duration_minutes SMALLINT UNSIGNED NULL,
 status ENUM('Pending','In Progress','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
 priority ENUM('Low','Medium','High','Urgent') NOT NULL DEFAULT 'Medium', description TEXT NULL,
 assigned_to BIGINT UNSIGNED NULL, team_id BIGINT UNSIGNED NULL, created_by BIGINT UNSIGNED NULL, reminder_sent_at DATETIME NULL,
 idempotency_key VARCHAR(150) NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY idx_activities_due(tenant_id,assigned_to,status,due_at), KEY idx_activities_assignee(assigned_to), KEY idx_activities_team(team_id), KEY idx_activities_related(tenant_id,related_type,related_id), KEY idx_activities_creator(created_by),
 UNIQUE KEY uq_activities_idem(tenant_id,idempotency_key),
 CONSTRAINT fk_activities_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_activities_assignee FOREIGN KEY(assigned_to) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT fk_activities_team FOREIGN KEY(team_id) REFERENCES teams(id) ON DELETE SET NULL,
 CONSTRAINT fk_activities_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE notifications (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, user_id BIGINT UNSIGNED NOT NULL,
 notification_type VARCHAR(60) NOT NULL, title VARCHAR(180) NOT NULL, body TEXT NULL,
 entity_type VARCHAR(40) NULL, entity_id BIGINT UNSIGNED NULL, idempotency_key VARCHAR(190) NULL,
 read_at DATETIME NULL, delivered_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_notifications_idempotency(tenant_id,idempotency_key), KEY idx_notifications_user_read(user_id,read_at,created_at),
 CONSTRAINT fk_notifications_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_notifications_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quotes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, quote_number VARCHAR(60) NOT NULL,
 deal_id BIGINT UNSIGNED NULL, account_id BIGINT UNSIGNED NULL, contact_id BIGINT UNSIGNED NULL,
 status ENUM('Draft','Sent','Accepted','Rejected','Expired') NOT NULL DEFAULT 'Draft', issue_date DATE NOT NULL,
 due_date DATE NULL, currency CHAR(3) NOT NULL DEFAULT 'INR', subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
 global_discount DECIMAL(14,2) NOT NULL DEFAULT 0, global_discount_type ENUM('amount','percent') NOT NULL DEFAULT 'amount',
 taxable_amount DECIMAL(14,2) NOT NULL DEFAULT 0, tax_total DECIMAL(14,2) NOT NULL DEFAULT 0,
 grand_total DECIMAL(14,2) NOT NULL DEFAULT 0, terms TEXT NULL, bank_details TEXT NULL, customer_notes TEXT NULL,
 created_by BIGINT UNSIGNED NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_quotes_number(tenant_id,quote_number), KEY idx_quotes_deal(deal_id), KEY idx_quotes_account(account_id), KEY idx_quotes_contact(contact_id), KEY idx_quotes_creator(created_by),
 CONSTRAINT fk_quotes_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_quotes_deal FOREIGN KEY(deal_id) REFERENCES deals(id) ON DELETE SET NULL,
 CONSTRAINT fk_quotes_account FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_quotes_contact FOREIGN KEY(contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
 CONSTRAINT fk_quotes_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE quote_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, quote_id BIGINT UNSIGNED NOT NULL,
 item_name VARCHAR(180) NOT NULL, description TEXT NULL, quantity DECIMAL(12,3) NOT NULL,
 unit_price DECIMAL(14,2) NOT NULL, discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 discount_percent DECIMAL(7,4) NOT NULL DEFAULT 0, tax_rate DECIMAL(7,4) NOT NULL DEFAULT 0,
 line_subtotal DECIMAL(14,2) NOT NULL DEFAULT 0, taxable_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 tax_amount DECIMAL(14,2) NOT NULL DEFAULT 0, item_total DECIMAL(14,2) NOT NULL DEFAULT 0,
 KEY idx_quote_items_tenant(tenant_id), KEY idx_quote_items_quote(quote_id), CONSTRAINT fk_quote_items_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_quote_items_quote FOREIGN KEY(quote_id) REFERENCES quotes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE invoices (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, invoice_number VARCHAR(60) NOT NULL, automation_key VARCHAR(150) NULL,
 quote_id BIGINT UNSIGNED NULL, deal_id BIGINT UNSIGNED NULL, account_id BIGINT UNSIGNED NULL, contact_id BIGINT UNSIGNED NULL,
 status ENUM('Draft','Sent','Partially Paid','Paid','Overdue') NOT NULL DEFAULT 'Draft', issue_date DATE NOT NULL,
 due_date DATE NOT NULL, currency CHAR(3) NOT NULL DEFAULT 'INR', subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
 global_discount DECIMAL(14,2) NOT NULL DEFAULT 0, global_discount_type ENUM('amount','percent') NOT NULL DEFAULT 'amount',
 taxable_amount DECIMAL(14,2) NOT NULL DEFAULT 0, tax_total DECIMAL(14,2) NOT NULL DEFAULT 0,
 grand_total DECIMAL(14,2) NOT NULL DEFAULT 0, paid_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 balance_due DECIMAL(14,2) NOT NULL DEFAULT 0, terms TEXT NULL, bank_details TEXT NULL, customer_notes TEXT NULL,
 overdue_task_created_at DATETIME NULL, created_by BIGINT UNSIGNED NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_invoices_number(tenant_id,invoice_number), UNIQUE KEY uq_invoice_automation(tenant_id,automation_key), KEY idx_invoices_due(tenant_id,status,due_date), KEY idx_invoices_quote(quote_id), KEY idx_invoices_deal(deal_id), KEY idx_invoices_account(account_id), KEY idx_invoices_contact(contact_id), KEY idx_invoices_creator(created_by),
 CONSTRAINT fk_invoices_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_invoices_quote FOREIGN KEY(quote_id) REFERENCES quotes(id) ON DELETE SET NULL,
 CONSTRAINT fk_invoices_deal FOREIGN KEY(deal_id) REFERENCES deals(id) ON DELETE SET NULL,
 CONSTRAINT fk_invoices_account FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_invoices_contact FOREIGN KEY(contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
 CONSTRAINT fk_invoices_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE invoice_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, invoice_id BIGINT UNSIGNED NOT NULL,
 item_name VARCHAR(180) NOT NULL, description TEXT NULL, quantity DECIMAL(12,3) NOT NULL,
 unit_price DECIMAL(14,2) NOT NULL, discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 discount_percent DECIMAL(7,4) NOT NULL DEFAULT 0, tax_rate DECIMAL(7,4) NOT NULL DEFAULT 0,
 line_subtotal DECIMAL(14,2) NOT NULL DEFAULT 0, taxable_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 tax_amount DECIMAL(14,2) NOT NULL DEFAULT 0, item_total DECIMAL(14,2) NOT NULL DEFAULT 0,
 KEY idx_invoice_items_tenant(tenant_id), KEY idx_invoice_items_invoice(invoice_id), CONSTRAINT fk_invoice_items_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_invoice_items_invoice FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE payments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, invoice_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(14,2) NOT NULL, currency CHAR(3) NOT NULL, payment_date DATETIME NOT NULL,
 method VARCHAR(60) NULL, reference VARCHAR(120) NULL, notes TEXT NULL, recorded_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY idx_payments_tenant(tenant_id), KEY idx_payments_invoice(invoice_id), KEY idx_payments_recorder(recorded_by),
 CONSTRAINT fk_payments_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_payments_invoice FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE RESTRICT,
 CONSTRAINT fk_payments_recorder FOREIGN KEY(recorded_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tickets (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, ticket_number VARCHAR(50) NOT NULL,
 contact_id BIGINT UNSIGNED NULL, account_id BIGINT UNSIGNED NULL, subject VARCHAR(180) NOT NULL,
 status ENUM('Open','In Progress','Waiting on Customer','Resolved','Closed') NOT NULL DEFAULT 'Open',
 priority ENUM('Low','Medium','High','Urgent') NOT NULL DEFAULT 'Medium', assigned_to BIGINT UNSIGNED NULL,
 sla_target_hours SMALLINT UNSIGNED NOT NULL DEFAULT 24, sla_due_at DATETIME NULL, resolved_at DATETIME NULL,
 created_by BIGINT UNSIGNED NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, UNIQUE KEY uq_ticket_number(tenant_id,ticket_number),
 KEY idx_tickets_queue(tenant_id,status,assigned_to,sla_due_at), KEY idx_tickets_assignee(assigned_to), KEY idx_tickets_contact(contact_id), KEY idx_tickets_account(account_id), KEY idx_tickets_creator(created_by),
 CONSTRAINT fk_tickets_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_tickets_contact FOREIGN KEY(contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
 CONSTRAINT fk_tickets_account FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE SET NULL,
 CONSTRAINT fk_tickets_assignee FOREIGN KEY(assigned_to) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT fk_tickets_creator FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE ticket_messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, ticket_id BIGINT UNSIGNED NOT NULL,
 author_id BIGINT UNSIGNED NULL, author_type ENUM('Customer','Agent','System') NOT NULL, message MEDIUMTEXT NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY idx_ticket_messages_tenant(tenant_id), KEY idx_ticket_messages(ticket_id,created_at), KEY idx_ticket_messages_author(author_id),
 CONSTRAINT fk_ticket_messages_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_ticket_messages_ticket FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
 CONSTRAINT fk_ticket_messages_author FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE ticket_notes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, ticket_id BIGINT UNSIGNED NOT NULL,
 author_id BIGINT UNSIGNED NULL, note MEDIUMTEXT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY idx_ticket_notes_tenant(tenant_id), KEY idx_ticket_notes(ticket_id,created_at), KEY idx_ticket_notes_author(author_id), CONSTRAINT fk_ticket_notes_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_ticket_notes_ticket FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
 CONSTRAINT fk_ticket_notes_author FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE custom_field_definitions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, entity_type VARCHAR(40) NOT NULL,
 field_key VARCHAR(80) NOT NULL, label VARCHAR(120) NOT NULL,
 field_type ENUM('text','textarea','number','date','datetime','select','checkbox','url','email') NOT NULL,
 options_json JSON NULL, is_required TINYINT(1) NOT NULL DEFAULT 0, is_active TINYINT(1) NOT NULL DEFAULT 1,
 position SMALLINT UNSIGNED NOT NULL DEFAULT 0, UNIQUE KEY uq_custom_field_key(tenant_id,entity_type,field_key),
 CONSTRAINT fk_custom_def_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE custom_field_values (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, definition_id BIGINT UNSIGNED NOT NULL,
 entity_type VARCHAR(40) NOT NULL, entity_id BIGINT UNSIGNED NOT NULL, value_text MEDIUMTEXT NULL,
 UNIQUE KEY uq_custom_value(definition_id,entity_type,entity_id), KEY idx_custom_entity(tenant_id,entity_type,entity_id),
 CONSTRAINT fk_custom_values_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_custom_values_definition FOREIGN KEY(definition_id) REFERENCES custom_field_definitions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE smtp_settings (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, host VARCHAR(190) NOT NULL,
 port SMALLINT UNSIGNED NOT NULL DEFAULT 587, username VARCHAR(190) NULL, password_encrypted TEXT NULL,
 encryption ENUM('tls','ssl','none') NOT NULL DEFAULT 'tls', from_email VARCHAR(190) NOT NULL,
 from_name VARCHAR(150) NOT NULL, is_configured TINYINT(1) NOT NULL DEFAULT 0,
 UNIQUE KEY uq_smtp_tenant(tenant_id), CONSTRAINT fk_smtp_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE user_monthly_quotas (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, user_id BIGINT UNSIGNED NOT NULL,
 month_start DATE NOT NULL, target_amount DECIMAL(14,2) NOT NULL DEFAULT 0, won_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_quota_user_month(tenant_id,user_id,month_start), KEY idx_quota_user(user_id),
 CONSTRAINT fk_quota_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_quota_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, actor_id BIGINT UNSIGNED NULL,
 action VARCHAR(100) NOT NULL, entity_type VARCHAR(60) NOT NULL, entity_id BIGINT UNSIGNED NULL,
 request_id CHAR(36) NULL, changes_json JSON NULL, ip_address VARCHAR(45) NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY idx_audit_entity(tenant_id,entity_type,entity_id,created_at),
 KEY idx_audit_actor(tenant_id,actor_id,created_at), KEY idx_audit_actor_id(actor_id), CONSTRAINT fk_audit_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_audit_actor FOREIGN KEY(actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE automation_events (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, event_key VARCHAR(190) NOT NULL,
 event_type VARCHAR(80) NOT NULL, entity_type VARCHAR(50) NOT NULL, entity_id BIGINT UNSIGNED NOT NULL,
 processed_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_automation_event(tenant_id,event_key), KEY idx_automation_pending(tenant_id,processed_at),
 CONSTRAINT fk_automation_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE email_outbox (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, tenant_id BIGINT UNSIGNED NOT NULL, event_key VARCHAR(190) NOT NULL,
 recipient VARCHAR(190) NOT NULL, subject VARCHAR(190) NOT NULL, body MEDIUMTEXT NOT NULL,
 status ENUM('pending','processing','sent','failed') NOT NULL DEFAULT 'pending', attempts SMALLINT UNSIGNED NOT NULL DEFAULT 0,
 last_error VARCHAR(500) NULL, claimed_at DATETIME NULL, sent_at DATETIME NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_email_event(tenant_id,event_key), KEY idx_email_pending(tenant_id,status,created_at),
 CONSTRAINT fk_email_outbox_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE lead_capture_limits (
 tenant_id BIGINT UNSIGNED NOT NULL, ip_hash CHAR(64) NOT NULL, window_started_at DATETIME NOT NULL,
 submissions SMALLINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY(tenant_id,ip_hash), KEY idx_capture_window(window_started_at),
 CONSTRAINT fk_capture_limit_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE lead_assignment_cursors (
 tenant_id BIGINT UNSIGNED PRIMARY KEY, cursor_user_id BIGINT UNSIGNED NULL, updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_assignment_cursor_user(cursor_user_id),
 CONSTRAINT fk_assignment_cursor_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT,
 CONSTRAINT fk_assignment_cursor_user FOREIGN KEY(cursor_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE company_settings (
 tenant_id BIGINT UNSIGNED PRIMARY KEY, company_name VARCHAR(150) NULL, registration_number VARCHAR(100) NULL,
 tax_id VARCHAR(100) NULL, address TEXT NULL, phone VARCHAR(30) NULL, website VARCHAR(255) NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_company_settings_tenant FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;

-- Minimal safe defaults. Tenant-specific roles/stages are provisioned by the setup process.
INSERT INTO permissions(permission_key,label) VALUES
('dashboard.view','View dashboard'),('leads.view','View leads'),('leads.manage','Manage leads'),
('deals.view','View deals'),('deals.manage','Manage deals'),('contacts.view','View contacts'),('contacts.manage','Manage contacts'),
('activities.view','View activities'),('activities.manage','Manage activities'),('billing.view','View quotes and invoices'),('billing.manage','Manage quotes and invoices'),
('tickets.view','View support tickets'),('tickets.manage','Manage support tickets'),('reports.view','View reports'),
('settings.view','View settings'),('settings.manage','Manage settings'),('users.view','View users'),('users.manage','Manage users');
