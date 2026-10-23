-- =====================================================================
-- HA CRM DEMO DATA  (local development only - never import in production)
-- Import AFTER database/database.sql, into an otherwise empty database.
-- Creates workspace slug:  demo-company
-- All demo users share the password:  Demo@12345678
--   admin@demo.test    (Admin)
--   manager@demo.test  (Sales Manager)
--   rep1@demo.test     (Sales Rep)
--   rep2@demo.test     (Sales Rep)
--   support@demo.test  (Support Agent)
-- Dates are relative to the moment you import, so the data always looks fresh.
-- =====================================================================
SET NAMES utf8mb4;

INSERT INTO tenants(name,slug,status,timezone,currency) VALUES
('Demo Company','demo-company','active','Asia/Kolkata','INR');
SET @t=(SELECT id FROM tenants WHERE slug='demo-company');
INSERT INTO roles(tenant_id,name) VALUES
(@t,'Admin'),
(@t,'Sales Manager'),
(@t,'Sales Rep'),
(@t,'Support Agent');
INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.tenant_id=@t AND r.name='Admin';
INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r JOIN permissions p ON p.permission_key IN ('dashboard.view','leads.view','leads.manage','deals.view','deals.manage','contacts.view','contacts.manage','activities.view','activities.manage','billing.view','billing.manage','tickets.view','reports.view','users.view') WHERE r.tenant_id=@t AND r.name='Sales Manager';
INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r JOIN permissions p ON p.permission_key IN ('dashboard.view','leads.view','leads.manage','deals.view','deals.manage','contacts.view','contacts.manage','activities.view','activities.manage','billing.view') WHERE r.tenant_id=@t AND r.name='Sales Rep';
INSERT IGNORE INTO role_permissions(role_id,permission_id) SELECT r.id,p.id FROM roles r JOIN permissions p ON p.permission_key IN ('dashboard.view','contacts.view','activities.view','tickets.view','tickets.manage') WHERE r.tenant_id=@t AND r.name='Support Agent';
INSERT INTO users(tenant_id,full_name,email,password_hash,role,status,eligible_for_leads) VALUES
(@t,'Aarav Mehta','admin@demo.test','$argon2id$v=19$m=65536,t=4,p=1$MUI5RmJWU3F4eE9xcVlrbQ$sbl1FuR2RuzpcK8pWnUcRaALC2jXw38+JL4CIEHKkCQ','Admin','Active',1),
(@t,'Priya Nair','manager@demo.test','$argon2id$v=19$m=65536,t=4,p=1$MUI5RmJWU3F4eE9xcVlrbQ$sbl1FuR2RuzpcK8pWnUcRaALC2jXw38+JL4CIEHKkCQ','Sales Manager','Active',1),
(@t,'Rohan Verma','rep1@demo.test','$argon2id$v=19$m=65536,t=4,p=1$MUI5RmJWU3F4eE9xcVlrbQ$sbl1FuR2RuzpcK8pWnUcRaALC2jXw38+JL4CIEHKkCQ','Sales Rep','Active',1),
(@t,'Sneha Kulkarni','rep2@demo.test','$argon2id$v=19$m=65536,t=4,p=1$MUI5RmJWU3F4eE9xcVlrbQ$sbl1FuR2RuzpcK8pWnUcRaALC2jXw38+JL4CIEHKkCQ','Sales Rep','Active',1),
(@t,'Karan Joshi','support@demo.test','$argon2id$v=19$m=65536,t=4,p=1$MUI5RmJWU3F4eE9xcVlrbQ$sbl1FuR2RuzpcK8pWnUcRaALC2jXw38+JL4CIEHKkCQ','Support Agent','Active',0);
SET @admin=(SELECT id FROM users WHERE tenant_id=@t AND email='admin@demo.test');
SET @mgr=(SELECT id FROM users WHERE tenant_id=@t AND email='manager@demo.test');
SET @rep1=(SELECT id FROM users WHERE tenant_id=@t AND email='rep1@demo.test');
SET @rep2=(SELECT id FROM users WHERE tenant_id=@t AND email='rep2@demo.test');
SET @sup=(SELECT id FROM users WHERE tenant_id=@t AND email='support@demo.test');
INSERT INTO teams(tenant_id,name) VALUES
(@t,'Enterprise Sales'),
(@t,'SMB Sales');
SET @team1=(SELECT id FROM teams WHERE tenant_id=@t AND name='Enterprise Sales');
SET @team2=(SELECT id FROM teams WHERE tenant_id=@t AND name='SMB Sales');
INSERT INTO team_members(tenant_id,team_id,user_id) VALUES
(@t,@team1,@mgr),
(@t,@team1,@rep1),
(@t,@team2,@rep2),
(@t,@team2,@mgr);
INSERT INTO pipelines(tenant_id,name,is_default) VALUES
(@t,'Sales Pipeline',1);
SET @pl=(SELECT id FROM pipelines WHERE tenant_id=@t AND name='Sales Pipeline');
INSERT INTO pipeline_stages(tenant_id,pipeline_id,name,position,probability,is_won,is_lost) VALUES
(@t,@pl,'Lead In',1,10,0,0),
(@t,@pl,'Meeting Scheduled',2,25,0,0),
(@t,@pl,'Proposal Sent',3,50,0,0),
(@t,@pl,'Negotiation',4,75,0,0),
(@t,@pl,'Closed Won',5,100,1,0),
(@t,@pl,'Closed Lost',6,0,0,1);
SET @s1=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=1);
SET @s2=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=2);
SET @s3=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=3);
SET @s4=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=4);
SET @s5=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=5);
SET @s6=(SELECT id FROM pipeline_stages WHERE pipeline_id=@pl AND position=6);
INSERT INTO company_settings(tenant_id,company_name,address,phone,website,tax_id) VALUES
(@t,'Demo Company','12 MG Road, Pune, Maharashtra 411001','+91 20 5550 0100','https://demo-company.example','27ABCDE1234F1Z5');
INSERT INTO accounts(tenant_id,company_name,industry,annual_revenue,employee_count,phone,website,created_by) VALUES
(@t,'Nimbus Cloud Pvt Ltd','Technology',52000000,180,'+91 20 5550 1001','https://nimbuscloud.example',@admin),
(@t,'Greenfield Agro Industries','Agriculture',98000000,420,'+91 22 5550 1002','https://greenfieldagro.example',@admin),
(@t,'Sapphire Retail Group','Retail',240000000,950,'+91 11 5550 1003','https://sapphireretail.example',@admin),
(@t,'Helix Healthcare','Healthcare',130000000,310,'+91 80 5550 1004','https://helixhealth.example',@admin),
(@t,'Orbit Logistics','Logistics',76000000,260,'+91 40 5550 1005','https://orbitlogistics.example',@admin),
(@t,'BrightPath Education','Education',31000000,120,'+91 20 5550 1006','https://brightpath.example',@admin),
(@t,'Zenith Finserv','Finance',310000000,640,'+91 22 5550 1007','https://zenithfinserv.example',@admin),
(@t,'Lotus Hospitality','Hospitality',64000000,230,'+91 44 5550 1008','https://lotushospitality.example',@admin);
INSERT INTO contacts(tenant_id,account_id,first_name,last_name,email,phone,preferred_contact,assigned_to,created_by) VALUES
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Nimbus Cloud Pvt Ltd'),'Vikram','Sethi','vikram.sethi@nimbuscloud.example','+91 9853464097','Email',@rep1,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Nimbus Cloud Pvt Ltd'),'Anjali','Rao','anjali.rao@nimbuscloud.example','+91 9830246633','Phone',@rep1,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Greenfield Agro Industries'),'Mohan','Patil','mohan.patil@greenfieldagro.example','+91 9862992312','Phone',@rep2,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Sapphire Retail Group'),'Neha','Kapoor','neha.kapoor@sapphireretail.example','+91 9897366946','Email',@rep1,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Sapphire Retail Group'),'Arjun','Malhotra','arjun.m@sapphireretail.example','+91 9816480894','WhatsApp',@rep1,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Helix Healthcare'),'Dr. Isha','Banerjee','isha.banerjee@helixhealth.example','+91 9819722233','Email',@rep2,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Orbit Logistics'),'Sameer','Khan','sameer.khan@orbitlogistics.example','+91 9881924865','Phone',@rep2,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='BrightPath Education'),'Pooja','Deshmukh','pooja.d@brightpath.example','+91 9822633920','Email',@rep1,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Zenith Finserv'),'Rahul','Bhatia','rahul.bhatia@zenithfinserv.example','+91 9859081935','Email',@mgr,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Zenith Finserv'),'Kavya','Menon','kavya.menon@zenithfinserv.example','+91 9888220482','Phone',@mgr,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Lotus Hospitality'),'Tanvi','Shah','tanvi.shah@lotushospitality.example','+91 9817784483','WhatsApp',@rep2,@admin),
(@t,(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Orbit Logistics'),'Aditya','Rane','aditya.rane@orbitlogistics.example','+91 9878106871','Email',@rep2,@admin);
INSERT INTO leads(tenant_id,first_name,last_name,job_title,company,email,phone,lead_status,lead_source,industry,lead_value,lead_score,priority,assigned_to,team_id,next_follow_up,created_by,created_at) VALUES
(@t,'Aditi','Sharma','CTO','Nova Systems','aditi.sharma@nova.example','+91 9983517017','New','Website Form','Retail',85000,51,'Low',NULL,NULL,DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 5 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 5 HOUR)),
(@t,'Rajesh','Iyer','Founder','BlueOak Traders','rajesh.iyer@blueoak.example','+91 9972492024','New','Referral','Hospitality',40000,54,'High',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 9 DAY),INTERVAL 6 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 1 HOUR)),
(@t,'Meera','Gupta','Marketing Director','Quantum Fabrics','meera.gupta@quantum.example','+91 9980490681','Contacted','Cold Call','Hospitality',40000,59,'Medium',@mgr,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 3 HOUR)),
(@t,'Siddharth','Reddy','IT Manager','Pinnacle Foods','siddharth.reddy@pinnacle.example','+91 9932140838','Qualified','Paid Ad','Education',25000,85,'Medium',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 6 HOUR)),
(@t,'Ananya','Chopra','Founder','Aurora Motors','ananya.chopra@aurora.example','+91 9957000147','Contacted','Event','Hospitality',85000,33,'Low',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 9 DAY),INTERVAL 5 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 32 DAY),INTERVAL 13 HOUR)),
(@t,'Karthik','Nambiar','CEO','Vertex Analytics','karthik.nambiar@vertex.example','+91 9951554798','Contacted','Website Form','Hospitality',40000,39,'Medium',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 8 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 30 DAY),INTERVAL 2 HOUR)),
(@t,'Ishaan','Joshi','CTO','Coral Exports','ishaan.joshi@coral.example','+91 9976262352','Contacted','Referral','Technology',25000,30,'High',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 6 DAY),INTERVAL 2 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 25 DAY),INTERVAL 11 HOUR)),
(@t,'Divya','Pillai','CTO','Ironclad Security','divya.pillai@ironclad.example','+91 9932329304','Qualified','Cold Call','Hospitality',60000,59,'High',@mgr,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 7 DAY),INTERVAL 7 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 19 DAY),INTERVAL 4 HOUR)),
(@t,'Nikhil','Agarwal','IT Manager','Maple Interiors','nikhil.agarwal@maple.example','+91 9958153450','New','Paid Ad','Logistics',25000,45,'High',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 9 DAY),INTERVAL 4 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 36 DAY),INTERVAL 8 HOUR)),
(@t,'Riya','Bose','CEO','Stellar Pharma','riya.bose@stellar.example','+91 9975090595','Contacted','Event','Manufacturing',40000,50,'Medium',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 3 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 2 HOUR)),
(@t,'Varun','Saxena','Founder','Riverbend Hotels','varun.saxena@riverbend.example','+91 9926843185','Qualified','Website Form','Technology',60000,46,'High',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 9 DAY),INTERVAL 5 HOUR),@admin,DATE_SUB(NOW(),INTERVAL 19 DAY)),
(@t,'Shreya','Mishra','Finance Controller','Crescent Textiles','shreya.mishra@crescent.example','+91 9995132904','New','Referral','Logistics',15000,78,'High',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 7 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 36 DAY),INTERVAL 12 HOUR)),
(@t,'Manish','Thakur','Operations Head','Skyline Realty','manish.thakur@skyline.example','+91 9924754327','Lost','Cold Call','Education',85000,54,'High',@mgr,@team1,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 13 DAY),INTERVAL 2 HOUR)),
(@t,'Pallavi','Kulkarni','CTO','Pixel Studios','pallavi.kulkarni@pixel.example','+91 9958802897','Contacted','Paid Ad','Technology',15000,28,'Urgent',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 3 DAY),INTERVAL 8 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 4 DAY),INTERVAL 3 HOUR)),
(@t,'Harsh','Jain','Founder','Evergreen Organics','harsh.jain@evergreen.example','+91 9973639532','Contacted','Event','Retail',15000,76,'Medium',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 5 DAY),INTERVAL 5 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 14 DAY),INTERVAL 19 HOUR)),
(@t,'Simran','Sinha','Operations Head','Titan Tools','simran.sinha@titan.example','+91 9923715389','Qualified','Website Form','Education',120000,89,'High',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 5 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 32 DAY),INTERVAL 14 HOUR)),
(@t,'Gaurav','Naidu','Founder','Harbor Shipping','gaurav.naidu@harbor.example','+91 9929676659','Qualified','Referral','Technology',250000,48,'Urgent',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 3 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 17 DAY),INTERVAL 15 HOUR)),
(@t,'Tara','Desai','Operations Head','Lumen Solar','tara.desai@lumen.example','+91 9957740731','New','Cold Call','Healthcare',85000,39,'Medium',@mgr,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 9 DAY),INTERVAL 5 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 34 DAY),INTERVAL 9 HOUR)),
(@t,'Yash','Chawla','IT Manager','Cobalt Capital','yash.chawla@cobalt.example','+91 9940432459','Qualified','Paid Ad','Healthcare',85000,70,'Medium',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 3 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 35 DAY),INTERVAL 16 HOUR)),
(@t,'Nisha','Rastogi','Marketing Director','Banyan Wellness','nisha.rastogi@banyan.example','+91 9973382988','Lost','Event','Finance',25000,31,'Low',@rep2,@team2,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 32 DAY),INTERVAL 11 HOUR)),
(@t,'Amit','Verma','Founder','Falcon Aviation','amit.verma@falcon.example','+91 9920809644','Unqualified','Website Form','Healthcare',15000,85,'Medium',@rep1,@team1,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 39 DAY),INTERVAL 11 HOUR)),
(@t,'Sakshi','Pawar','CEO','Opal Jewellers','sakshi.pawar@opal.example','+91 9974353833','Qualified','Referral','Education',250000,53,'Medium',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 7 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 15 DAY),INTERVAL 15 HOUR)),
(@t,'Dev','Kohli','Finance Controller','Zephyr Telecom','dev.kohli@zephyr.example','+91 9933960779','Unqualified','Cold Call','Logistics',250000,77,'Medium',@mgr,@team1,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 6 DAY),INTERVAL 3 HOUR)),
(@t,'Radhika','Menon','Operations Head','Granite Builders','radhika.menon@granite.example','+91 9932817504','New','Paid Ad','Manufacturing',15000,78,'High',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 7 DAY),INTERVAL 1 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 22 DAY),INTERVAL 2 HOUR)),
(@t,'Kunal','Bhalla','Finance Controller','Mosaic Media','kunal.bhalla@mosaic.example','+91 9998217056','Lost','Event','Education',25000,87,'Medium',@rep2,@team2,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 10 DAY),INTERVAL 18 HOUR)),
(@t,'Mansi','Trivedi','CEO','Sunrise Dairy','mansi.trivedi@sunrise.example','+91 9997197858','Unqualified','Website Form','Retail',85000,44,'Low',@rep1,@team1,NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 36 DAY),INTERVAL 17 HOUR)),
(@t,'Rohit','Kapoor','Procurement Manager','Echo Audio','rohit.kapoor@echo.example','+91 9949321318','Contacted','Referral','Healthcare',250000,52,'Medium',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 4 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 9 DAY),INTERVAL 13 HOUR)),
(@t,'Ira','Dutta','CEO','Atlas Packaging','ira.dutta@atlas.example','+91 9957484087','New','Cold Call','Hospitality',120000,61,'Urgent',NULL,NULL,DATE_ADD(DATE_ADD(NOW(),INTERVAL 7 DAY),INTERVAL 2 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 38 DAY),INTERVAL 10 HOUR)),
(@t,'Sanjay','Rao','Operations Head','Willow Learning','sanjay.rao@willow.example','+91 9980263864','New','Paid Ad','Technology',250000,81,'Urgent',@rep1,@team1,DATE_ADD(DATE_ADD(NOW(),INTERVAL 3 DAY),INTERVAL 8 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 38 DAY),INTERVAL 16 HOUR)),
(@t,'Bhavna','Singh','Finance Controller','Prism Optics','bhavna.singh@prism.example','+91 9993094361','New','Event','Retail',85000,28,'Medium',@rep2,@team2,DATE_ADD(DATE_ADD(NOW(),INTERVAL 3 DAY),INTERVAL 2 HOUR),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 29 DAY),INTERVAL 5 HOUR));
INSERT INTO deals(tenant_id,deal_title,pipeline_id,stage_id,contact_id,account_id,amount,net_value,currency,expected_close_date,win_probability,loss_reason,assigned_to,team_id,created_by,closed_at) VALUES
(@t,'Nimbus Cloud - Annual Platform License',@pl,@s4,(SELECT id FROM contacts WHERE tenant_id=@t AND email='vikram.sethi@nimbuscloud.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Nimbus Cloud Pvt Ltd'),950000,950000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 20 DAY),75,NULL,@rep1,@team1,@admin,NULL),
(@t,'Greenfield Agro - Field Sales CRM',@pl,@s2,(SELECT id FROM contacts WHERE tenant_id=@t AND email='mohan.patil@greenfieldagro.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Greenfield Agro Industries'),420000,420000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 35 DAY),25,NULL,@rep2,@team2,@admin,NULL),
(@t,'Sapphire Retail - Omnichannel Rollout',@pl,@s3,(SELECT id FROM contacts WHERE tenant_id=@t AND email='neha.kapoor@sapphireretail.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Sapphire Retail Group'),1850000,1850000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 25 DAY),50,NULL,@rep1,@team1,@admin,NULL),
(@t,'Helix Healthcare - Patient Engagement',@pl,@s4,(SELECT id FROM contacts WHERE tenant_id=@t AND email='isha.banerjee@helixhealth.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Helix Healthcare'),1250000,1250000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),75,NULL,@rep2,@team2,@admin,NULL),
(@t,'Orbit Logistics - Fleet Dashboard',@pl,@s1,(SELECT id FROM contacts WHERE tenant_id=@t AND email='sameer.khan@orbitlogistics.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Orbit Logistics'),310000,310000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 50 DAY),10,NULL,@rep2,@team2,@admin,NULL),
(@t,'BrightPath - Admissions Automation',@pl,@s2,(SELECT id FROM contacts WHERE tenant_id=@t AND email='pooja.d@brightpath.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='BrightPath Education'),275000,275000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 30 DAY),25,NULL,@rep1,@team1,@admin,NULL),
(@t,'Zenith Finserv - Compliance Suite',@pl,@s3,(SELECT id FROM contacts WHERE tenant_id=@t AND email='rahul.bhatia@zenithfinserv.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Zenith Finserv'),2400000,2400000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 40 DAY),50,NULL,@mgr,@team1,@admin,NULL),
(@t,'Lotus Hospitality - Guest CRM',@pl,@s1,(SELECT id FROM contacts WHERE tenant_id=@t AND email='tanvi.shah@lotushospitality.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Lotus Hospitality'),180000,180000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL 55 DAY),10,NULL,@rep2,@team2,@admin,NULL),
(@t,'Nimbus Cloud - Support Add-on',@pl,@s5,(SELECT id FROM contacts WHERE tenant_id=@t AND email='anjali.rao@nimbuscloud.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Nimbus Cloud Pvt Ltd'),240000,240000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL -12 DAY),100,NULL,@rep1,@team1,@admin,DATE_SUB(NOW(),INTERVAL 12 DAY)),
(@t,'Sapphire Retail - Pilot Program',@pl,@s5,(SELECT id FROM contacts WHERE tenant_id=@t AND email='arjun.m@sapphireretail.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Sapphire Retail Group'),520000,520000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL -25 DAY),100,NULL,@rep1,@team1,@admin,DATE_SUB(NOW(),INTERVAL 25 DAY)),
(@t,'Zenith Finserv - Analytics Module',@pl,@s5,(SELECT id FROM contacts WHERE tenant_id=@t AND email='kavya.menon@zenithfinserv.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Zenith Finserv'),760000,760000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL -6 DAY),100,NULL,@mgr,@team1,@admin,DATE_SUB(NOW(),INTERVAL 6 DAY)),
(@t,'Orbit Logistics - Route Optimizer',@pl,@s6,(SELECT id FROM contacts WHERE tenant_id=@t AND email='aditya.rane@orbitlogistics.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Orbit Logistics'),390000,390000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL -18 DAY),0,'Price',@rep2,@team2,@admin,DATE_SUB(NOW(),INTERVAL 18 DAY)),
(@t,'Greenfield Agro - Training Package',@pl,@s6,(SELECT id FROM contacts WHERE tenant_id=@t AND email='mohan.patil@greenfieldagro.example'),(SELECT id FROM accounts WHERE tenant_id=@t AND company_name='Greenfield Agro Industries'),95000,95000,'INR',DATE_ADD(CURRENT_DATE,INTERVAL -9 DAY),0,'Competitor',@rep2,@team2,@admin,DATE_SUB(NOW(),INTERVAL 9 DAY));
INSERT INTO activities(tenant_id,activity_type,subject,related_type,related_id,due_at,duration_minutes,status,priority,assigned_to,created_by) VALUES
(@t,'Call','Intro call with Aditi Sharma','Lead',(SELECT id FROM leads WHERE tenant_id=@t AND email='aditi.sharma@nova.example'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 0 DAY),INTERVAL 3 HOUR),30,'Pending','High',@admin,@admin),
(@t,'Meeting','Product walkthrough - Nimbus Cloud','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Nimbus Cloud - Annual Platform License'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 2 HOUR),60,'Pending','High',@admin,@admin),
(@t,'Email','Send pricing proposal to Sapphire Retail','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Sapphire Retail - Omnichannel Rollout'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 6 HOUR),15,'Pending','Medium',@admin,@admin),
(@t,'Demo','Live demo for Helix Healthcare','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Helix Healthcare - Patient Engagement'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 2 DAY),INTERVAL 4 HOUR),45,'Pending','Urgent',@admin,@admin),
(@t,'Task','Prepare compliance checklist for Zenith','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Compliance Suite'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 3 DAY),INTERVAL 0 HOUR),NULL,'Pending','Medium',@admin,@admin),
(@t,'Call','Follow up with Rajesh Iyer','Lead',(SELECT id FROM leads WHERE tenant_id=@t AND email='rajesh.iyer@blueoak.example'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 4 DAY),INTERVAL 1 HOUR),20,'Pending','Low',@admin,@admin),
(@t,'Meeting','Contract review - Zenith Finserv','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Compliance Suite'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 6 DAY),INTERVAL 3 HOUR),60,'In Progress','High',@admin,@admin),
(@t,'Task','Review Q4 pipeline with team',NULL,NULL,DATE_ADD(DATE_ADD(NOW(),INTERVAL 8 DAY),INTERVAL 0 HOUR),NULL,'Pending','Medium',@admin,@admin),
(@t,'Call','Discovery call - Greenfield Agro','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Greenfield Agro - Field Sales CRM'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 0 DAY),INTERVAL 6 HOUR),30,'Pending','Medium',@rep2,@admin),
(@t,'Email','Share case studies with BrightPath','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='BrightPath - Admissions Automation'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 0 HOUR),10,'Pending','Low',@rep1,@admin),
(@t,'Demo','Fleet dashboard demo - Orbit Logistics','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Orbit Logistics - Fleet Dashboard'),DATE_ADD(DATE_ADD(NOW(),INTERVAL 3 DAY),INTERVAL 5 HOUR),45,'Pending','Medium',@rep2,@admin),
(@t,'Task','Update CRM notes after Nimbus meeting','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Nimbus Cloud - Annual Platform License'),DATE_SUB(NOW(),INTERVAL 1 DAY),NULL,'Pending','High',@rep1,@admin),
(@t,'Call','Chase overdue invoice INV-DEMO-0003 with Zenith','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Analytics Module'),DATE_SUB(NOW(),INTERVAL 2 DAY),15,'Pending','Urgent',@mgr,@admin),
(@t,'Meeting','Kickoff - Sapphire pilot','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Sapphire Retail - Pilot Program'),DATE_SUB(NOW(),INTERVAL 10 DAY),60,'Completed','Medium',@rep1,@admin),
(@t,'Call','Qualification call - Meera Gupta','Lead',(SELECT id FROM leads WHERE tenant_id=@t AND email='meera.gupta@quantum.example'),DATE_SUB(NOW(),INTERVAL 4 DAY),25,'Completed','Medium',@rep2,@admin),
(@t,'Email','Welcome email to Zenith analytics team','Deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Analytics Module'),DATE_SUB(NOW(),INTERVAL 5 DAY),10,'Completed','Low',@mgr,@admin);
INSERT INTO quotes(tenant_id,quote_number,deal_id,account_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,terms,bank_details,created_by) VALUES
(@t,'Q-DEMO-0001',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Sapphire Retail - Omnichannel Rollout'),NULL,(SELECT id FROM contacts WHERE tenant_id=@t AND email='neha.kapoor@sapphireretail.example'),'Sent',DATE(DATE_SUB(NOW(),INTERVAL 3 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),'INR',1550000,1550000,279000.0,1829000.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @q=(SELECT id FROM quotes WHERE tenant_id=@t AND quote_number='Q-DEMO-0001');
INSERT INTO quote_items(tenant_id,quote_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@q,'Retail CRM Platform - 50 seats','Annual subscription',50,28000,18,1400000,1400000,252000.0,1652000.0),
(@t,@q,'Implementation & training','One-time onboarding',1,150000,18,150000,150000,27000.0,177000.0);
INSERT INTO quotes(tenant_id,quote_number,deal_id,account_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,terms,bank_details,created_by) VALUES
(@t,'Q-DEMO-0002',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Nimbus Cloud - Support Add-on'),NULL,(SELECT id FROM contacts WHERE tenant_id=@t AND email='anjali.rao@nimbuscloud.example'),'Accepted',DATE(DATE_SUB(NOW(),INTERVAL 20 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),'INR',240000,240000,43200.0,283200.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @q=(SELECT id FROM quotes WHERE tenant_id=@t AND quote_number='Q-DEMO-0002');
INSERT INTO quote_items(tenant_id,quote_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@q,'Support Add-on','Premium 24x7 support',1,240000,18,240000,240000,43200.0,283200.0);
INSERT INTO quotes(tenant_id,quote_number,deal_id,account_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,terms,bank_details,created_by) VALUES
(@t,'Q-DEMO-0003',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Compliance Suite'),NULL,(SELECT id FROM contacts WHERE tenant_id=@t AND email='rahul.bhatia@zenithfinserv.example'),'Draft',DATE(DATE_SUB(NOW(),INTERVAL 1 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL 15 DAY),'INR',2150000,2150000,387000.0,2537000.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @q=(SELECT id FROM quotes WHERE tenant_id=@t AND quote_number='Q-DEMO-0003');
INSERT INTO quote_items(tenant_id,quote_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@q,'Compliance Suite','Annual license',1,2000000,18,2000000,2000000,360000.0,2360000.0),
(@t,@q,'Data migration','One-time',1,150000,18,150000,150000,27000.0,177000.0);
INSERT INTO invoices(tenant_id,invoice_number,deal_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,paid_amount,balance_due,terms,bank_details,created_by) VALUES
(@t,'INV-DEMO-0001',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Nimbus Cloud - Support Add-on'),(SELECT id FROM contacts WHERE tenant_id=@t AND email='anjali.rao@nimbuscloud.example'),'Paid',DATE(DATE_SUB(NOW(),INTERVAL 18 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL -3 DAY),'INR',240000,240000,43200.0,283200.0,283200.0,0.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @i=(SELECT id FROM invoices WHERE tenant_id=@t AND invoice_number='INV-DEMO-0001');
INSERT INTO invoice_items(tenant_id,invoice_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@i,'Support Add-on','Premium 24x7 support',1,240000,18,240000,240000,43200.0,283200.0);
INSERT INTO payments(tenant_id,invoice_id,amount,currency,payment_date,method,reference,recorded_by) VALUES
(@t,@i,283200.0,'INR',DATE_SUB(NOW(),INTERVAL 5 DAY),'Bank Transfer','UTR000188120',@admin);
INSERT INTO invoices(tenant_id,invoice_number,deal_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,paid_amount,balance_due,terms,bank_details,created_by) VALUES
(@t,'INV-DEMO-0002',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Sapphire Retail - Pilot Program'),(SELECT id FROM contacts WHERE tenant_id=@t AND email='neha.kapoor@sapphireretail.example'),'Partially Paid',DATE(DATE_SUB(NOW(),INTERVAL 15 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY),'INR',520000,520000,93600.0,613600.0,306800.0,306800.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @i=(SELECT id FROM invoices WHERE tenant_id=@t AND invoice_number='INV-DEMO-0002');
INSERT INTO invoice_items(tenant_id,invoice_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@i,'Retail Pilot Program','Pilot phase',1,520000,18,520000,520000,93600.0,613600.0);
INSERT INTO payments(tenant_id,invoice_id,amount,currency,payment_date,method,reference,recorded_by) VALUES
(@t,@i,306800.0,'INR',DATE_SUB(NOW(),INTERVAL 5 DAY),'Bank Transfer','UTR000288120',@admin);
INSERT INTO invoices(tenant_id,invoice_number,deal_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,paid_amount,balance_due,terms,bank_details,created_by) VALUES
(@t,'INV-DEMO-0003',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Analytics Module'),(SELECT id FROM contacts WHERE tenant_id=@t AND email='rahul.bhatia@zenithfinserv.example'),'Overdue',DATE(DATE_SUB(NOW(),INTERVAL 40 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL -25 DAY),'INR',760000,760000,136800.0,896800.0,0.0,896800.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @i=(SELECT id FROM invoices WHERE tenant_id=@t AND invoice_number='INV-DEMO-0003');
INSERT INTO invoice_items(tenant_id,invoice_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@i,'Analytics Module','Annual license',1,760000,18,760000,760000,136800.0,896800.0);
INSERT INTO invoices(tenant_id,invoice_number,deal_id,contact_id,status,issue_date,due_date,currency,subtotal,taxable_amount,tax_total,grand_total,paid_amount,balance_due,terms,bank_details,created_by) VALUES
(@t,'INV-DEMO-0004',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Nimbus Cloud - Annual Platform License'),(SELECT id FROM contacts WHERE tenant_id=@t AND email='vikram.sethi@nimbuscloud.example'),'Sent',DATE(DATE_SUB(NOW(),INTERVAL 2 DAY)),DATE_ADD(CURRENT_DATE,INTERVAL 13 DAY),'INR',285000,285000,51300.0,336300.0,0.0,336300.0,'Payment due within 15 days of invoice date. Prices in INR, exclusive of GST unless stated.','Demo Bank | A/C 0012345678 | IFSC DEMO0001234',@admin);
SET @i=(SELECT id FROM invoices WHERE tenant_id=@t AND invoice_number='INV-DEMO-0004');
INSERT INTO invoice_items(tenant_id,invoice_id,item_name,description,quantity,unit_price,tax_rate,line_subtotal,taxable_amount,tax_amount,item_total) VALUES
(@t,@i,'Platform License - 30% advance','Advance payment',1,285000,18,285000,285000,51300.0,336300.0);
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0001',(SELECT id FROM contacts WHERE tenant_id=@t AND email='vikram.sethi@nimbuscloud.example'),'Cannot export leads to CSV','Open','High',@sup,4,DATE_ADD(DATE_ADD(NOW(),INTERVAL 0 DAY),INTERVAL 5 HOUR),NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0001');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','Hi team, the CSV export button spins forever. Please help.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Thanks for reporting - we are looking into the export job now.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0002',(SELECT id FROM contacts WHERE tenant_id=@t AND email='neha.kapoor@sapphireretail.example'),'Need to add 10 more user seats','In Progress','Medium',@sup,24,DATE_ADD(DATE_ADD(NOW(),INTERVAL 1 DAY),INTERVAL 4 HOUR),NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0002');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','We would like to add 10 more seats to our plan.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Happy to help - I have shared an updated quote for the additional seats.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0003',(SELECT id FROM contacts WHERE tenant_id=@t AND email='isha.banerjee@helixhealth.example'),'Invoice PDF shows wrong GST number','Waiting on Customer','High',@sup,8,DATE_ADD(DATE_ADD(NOW(),INTERVAL 0 DAY),INTERVAL 2 HOUR),NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0003');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','The GST number on invoice INV-0098 looks incorrect.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Could you confirm the GST number we should print? We will regenerate the PDF.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0004',(SELECT id FROM contacts WHERE tenant_id=@t AND email='rahul.bhatia@zenithfinserv.example'),'Request: custom dashboard widget','Open','Low',@sup,72,DATE_ADD(DATE_ADD(NOW(),INTERVAL 2 DAY),INTERVAL 10 HOUR),NULL,@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0004');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','Is it possible to add a revenue-by-region widget to the dashboard?',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Logged as a feature request - we will update you after the next planning review.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0005',(SELECT id FROM contacts WHERE tenant_id=@t AND email='sameer.khan@orbitlogistics.example'),'Password reset email not received','Resolved','Medium',@sup,24,DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0005');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','I never received the password reset email.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Resolved - the email was caught by a spam filter; whitelisted the sender.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO tickets(tenant_id,ticket_number,contact_id,subject,status,priority,assigned_to,sla_target_hours,sla_due_at,resolved_at,created_by,created_at) VALUES
(@t,'T-DEMO-0006',(SELECT id FROM contacts WHERE tenant_id=@t AND email='tanvi.shah@lotushospitality.example'),'Calendar shows wrong timezone','Closed','Low',@sup,48,DATE_SUB(NOW(),INTERVAL 3 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),@admin,DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR));
SET @tk=(SELECT id FROM tickets WHERE tenant_id=@t AND ticket_number='T-DEMO-0006');
INSERT INTO ticket_messages(tenant_id,ticket_id,author_id,author_type,message,created_at) VALUES
(@t,@tk,NULL,'Customer','Meetings appear 5 hours off in the calendar.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 3 HOUR)),
(@t,@tk,@sup,'Agent','Fixed - workspace timezone is now set to Asia/Kolkata.',DATE_SUB(DATE_SUB(NOW(),INTERVAL 2 DAY),INTERVAL 1 HOUR));
INSERT INTO notifications(tenant_id,user_id,notification_type,title,body,entity_type,entity_id,created_at) VALUES
(@t,@admin,'lead_assigned','New lead assigned','Aditi Sharma from Nova Systems needs a first call.','lead',(SELECT id FROM leads WHERE tenant_id=@t AND email='aditi.sharma@nova.example'),DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 1 HOUR)),
(@t,@admin,'task_due','Task due today','Intro call with Aditi Sharma is due in a few hours.','activity',NULL,DATE_SUB(DATE_SUB(NOW(),INTERVAL 0 DAY),INTERVAL 2 HOUR)),
(@t,@admin,'deal_won','Deal won!','Zenith Finserv - Analytics Module was marked Closed Won.','deal',(SELECT id FROM deals WHERE tenant_id=@t AND deal_title='Zenith Finserv - Analytics Module'),DATE_SUB(NOW(),INTERVAL 6 DAY)),
(@t,@admin,'invoice_overdue','Invoice overdue','INV-DEMO-0003 is past its due date.','invoice',NULL,DATE_SUB(NOW(),INTERVAL 2 DAY));
SET @ms=DATE_SUB(CURRENT_DATE,INTERVAL DAY(CURRENT_DATE)-1 DAY);
INSERT INTO user_monthly_quotas(tenant_id,user_id,month_start,target_amount,won_amount) VALUES
(@t,@admin,@ms,1500000,0),
(@t,@mgr,@ms,1200000,760000),
(@t,@rep1,@ms,900000,760000),
(@t,@rep2,@ms,800000,0);
-- Done. Sign in with workspace 'demo-company', e.g. admin@demo.test / Demo@12345678
