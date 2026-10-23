import fs from 'node:fs';

const read = path => fs.readFileSync(path, 'utf8');
const api = read('app/Domain/Api.php');
const registry = read('app/Domain/ResourceRegistry.php');
const frontend = read('resources/frontend/src/main.jsx');
const autoload = read('app/autoload.php');
const automation = read('app/Services/AutomationRunner.php');
const sql = read('database/database.sql');
const errors = [];

for (const resource of ['leads','accounts','contacts','deals','pipeline-stages','activities','quotes','invoices','payments','tickets','ticket-messages','ticket-notes','users','teams','team-members','roles','custom-fields','quotas']) {
  if (!registry.includes(`'${resource}'=>`)) errors.push(`Frontend/API resource ${resource} is missing from ResourceRegistry.`);
}
for (const route of ['setup-status','auth','setup','lead-capture','notifications','dashboard','search','timeline','roles','reports','deals','quotes','invoices','leads','smtp','company-settings']) {
  if (!api.includes(`$endpoint==='${route}'`)) errors.push(`API dispatcher does not register ${route}.`);
}
for (const module of ['leads','deals','contacts','accounts','activities','quotes','invoices','payments','support','users','teams','roles','custom-fields']) {
  if (!frontend.includes(`'${module}'`)) errors.push(`React app does not reference module ${module}.`);
}
for (const dependency of [
  ['vendor/phpmailer/phpmailer/src/PHPMailer.php','PHPMailer'],
  ['vendor/setasign/fpdf/fpdf.php','FPDF'],
  ['public/assets/build/index.html','production build'],
]) if (!fs.existsSync(dependency[0])) errors.push(`Missing ${dependency[1]} dependency/artifact at ${dependency[0]}.`);
if (!autoload.includes('vendor/autoload.php') || !autoload.includes('phpmailer')) errors.push('Runtime autoload does not support bundled third-party libraries.');
if (!api.includes("SELECT host,port,username,encryption,from_email,from_name,is_configured")) errors.push('SMTP read API must only return configured status and non-secret connection fields.');
if (/SELECT[^;]*password_encrypted[^;]*Response::ok/is.test(api)) errors.push('Potential SMTP secret exposure in API response.');
if (!api.includes("$name==='contacts'&&$user['role']==='Support Agent'") || !api.includes("$u['role']==='Support Agent'")) errors.push('Support contact and contextual-record access must be restricted by ticket scope.');
if (!api.includes('assigned_to=?') || !api.includes('team_members')) errors.push('Sales Rep assigned/team visibility checks are missing.');
if (!sql.includes('UNIQUE KEY uq_invoice_automation(tenant_id,automation_key)') || !sql.includes('UNIQUE KEY uq_email_event(tenant_id,event_key)') || !sql.includes('UNIQUE KEY uq_automation_event(tenant_id,event_key)')) errors.push('Automation duplicate-prevention constraints are incomplete.');
if (!automation.includes('INSERT IGNORE INTO notifications') || !automation.includes('INSERT IGNORE INTO activities') || !automation.includes('SELECT id FROM invoices WHERE tenant_id=? AND automation_key=?')) errors.push('Cron idempotency insertion guards are incomplete.');
if (!api.includes("WHERE tenant_id=? AND id=?") || !api.includes("Auth::verifyCsrf()")) errors.push('Tenant scoping or CSRF guard markers are missing.');
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
console.log('Integration/security static checks passed: module map, API dispatch, runtime libraries, build artifact, SMTP response, and cron duplicate guards.');
