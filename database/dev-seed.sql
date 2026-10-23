-- Development-only defaults. Run only in an empty local database after database.sql.
INSERT INTO tenants(name,slug,status,timezone,currency) VALUES('Development Workspace','development-workspace','active','Asia/Kolkata','INR');
SET @tenant_id=LAST_INSERT_ID();
INSERT INTO roles(tenant_id,name) VALUES(@tenant_id,'Admin'),(@tenant_id,'Sales Manager'),(@tenant_id,'Sales Rep'),(@tenant_id,'Support Agent');
INSERT INTO role_permissions(role_id,permission_id)
 SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.tenant_id=@tenant_id AND r.name='Admin';
INSERT INTO pipelines(tenant_id,name,is_default) VALUES(@tenant_id,'Sales Pipeline',1);
SET @pipeline_id=LAST_INSERT_ID();
INSERT INTO pipeline_stages(tenant_id,pipeline_id,name,position,probability,is_won,is_lost) VALUES
(@tenant_id,@pipeline_id,'Lead In',1,10,0,0),(@tenant_id,@pipeline_id,'Meeting Scheduled',2,25,0,0),
(@tenant_id,@pipeline_id,'Proposal Sent',3,50,0,0),(@tenant_id,@pipeline_id,'Negotiation',4,75,0,0),
(@tenant_id,@pipeline_id,'Closed Won',5,100,1,0),(@tenant_id,@pipeline_id,'Closed Lost',6,0,0,1);
INSERT INTO company_settings(tenant_id,company_name) VALUES(@tenant_id,'Development Workspace');
INSERT INTO accounts(tenant_id,company_name,industry,phone,website) VALUES(@tenant_id,'Sample Workspace Account','Technology','+91 00000 00000','https://example.test');
SET @account_id=LAST_INSERT_ID();
INSERT INTO contacts(tenant_id,account_id,first_name,last_name,email,phone) VALUES(@tenant_id,@account_id,'Sample','Contact','sample-contact@example.test','+91 00000 00001');
SET @contact_id=LAST_INSERT_ID();
INSERT INTO leads(tenant_id,first_name,last_name,email,phone,company,lead_status,lead_source,lead_value,lead_score,priority) VALUES(@tenant_id,'Sample','Lead','sample-lead@example.test','+91 00000 00002','Sample Workspace Account','Qualified','Website Form',25000,72,'Medium');
SET @lead_id=LAST_INSERT_ID();
INSERT INTO deals(tenant_id,deal_title,pipeline_id,stage_id,contact_id,account_id,source_lead_id,amount,currency,expected_close_date,win_probability) VALUES(@tenant_id,'Sample CRM Opportunity',@pipeline_id,(SELECT id FROM pipeline_stages WHERE pipeline_id=@pipeline_id ORDER BY position LIMIT 1),@contact_id,@account_id,@lead_id,25000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 30 DAY),25);
INSERT INTO activities(tenant_id,activity_type,subject,related_type,related_id,due_at,status,priority) VALUES(@tenant_id,'Task','Sample follow-up','Lead',@lead_id,DATE_ADD(NOW(),INTERVAL 1 DAY),'Pending','Medium');
-- No login user or password is seeded. Use the local CLI-only scripts/create-tenant-admin.php to provision this existing demo workspace.
