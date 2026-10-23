import fs from 'node:fs';
import path from 'node:path';
const root=process.cwd();
const required=['resources/frontend/src/main.jsx','resources/frontend/src/api.js','resources/frontend/src/styles.css','public/index.php','app/Domain/Api.php','database/database.sql','IMPLEMENTATION_DECISIONS.md'];
const errors=[];for(const f of required)if(!fs.existsSync(path.join(root,f)))errors.push(`Missing required file: ${f}`);
const src=fs.readFileSync(path.join(root,'resources/frontend/src/main.jsx'),'utf8');
for(const route of ['/leads','/deals','/contacts','/accounts','/activities','/calendar','/quotes','/invoices','/payments','/support','/reports','/settings','/users','/teams','/roles','/custom-fields'])if(!src.includes(route))errors.push(`Missing React route ${route}`);
if(src.includes('mock data')||src.includes('MOCK_DATA'))errors.push('Mock data marker found in frontend.');
const sql=fs.readFileSync(path.join(root,'database/database.sql'),'utf8');
const created=[...sql.matchAll(/CREATE TABLE\s+([a-z_]+)/gi)].map(m=>m[1].toLowerCase());const positions=new Map(created.map((n,i)=>[n,i]));
for(const m of sql.matchAll(/CONSTRAINT\s+\w+\s+FOREIGN KEY\s*\([^)]*\)\s+REFERENCES\s+([a-z_]+)/gi)){const ref=m[1].toLowerCase();if(!positions.has(ref))errors.push(`FK references missing table ${ref}`)}
const requiredTables=['tenants','users','teams','team_members','roles','permissions','role_permissions','accounts','contacts','leads','pipelines','pipeline_stages','deals','activities','notifications','quotes','quote_items','invoices','invoice_items','payments','tickets','ticket_messages','ticket_notes','custom_field_definitions','custom_field_values','smtp_settings','user_monthly_quotas','audit_logs'];
for(const t of requiredTables)if(!positions.has(t))errors.push(`Missing schema table ${t}`);
if(errors.length){console.error(errors.join('\n'));process.exit(1)}
console.log(`Static checks passed: ${required.length} files, ${requiredTables.length} required tables, ${created.length} tables, ${src.match(/<Route\b/g)?.length||0} route declarations.`);
