import fs from 'node:fs';

const schema = fs.readFileSync('database/database.sql', 'utf8');
const seed = fs.readFileSync('database/dev-seed.sql', 'utf8');
const tables = new Map();
for (const match of schema.matchAll(/CREATE TABLE\s+([a-z_]+)\s*\(([\s\S]*?)\)\s*ENGINE=/gi)) {
  tables.set(match[1].toLowerCase(), match[2]);
}
const errors = [];
const inserts = [...seed.matchAll(/INSERT(?:\s+IGNORE)?\s+INTO\s+([a-z_]+)/gi)].map(m => m[1].toLowerCase());
for (const table of inserts) if (!tables.has(table)) errors.push(`Seed inserts into missing schema table ${table}.`);
for (const match of seed.matchAll(/\b(?:FROM|JOIN)\s+([a-z_]+)/gi)) {
  const table = match[1].toLowerCase();
  if (!tables.has(table)) errors.push(`Seed references missing schema table ${table}.`);
}
const firstInsert = new Map();
for (const match of seed.matchAll(/INSERT(?:\s+IGNORE)?\s+INTO\s+([a-z_]+)/gi)) {
  const table = match[1].toLowerCase();
  if (!firstInsert.has(table)) firstInsert.set(table, match.index);
}
for (const [table, body] of tables) {
  if (!firstInsert.has(table)) continue;
  for (const match of body.matchAll(/FOREIGN KEY\s*\(([^)]+)\)\s+REFERENCES\s+([a-z_]+)/gi)) {
    const parent = match[2].toLowerCase();
    if (firstInsert.has(parent) && firstInsert.get(parent) > firstInsert.get(table)) {
      errors.push(`Seed inserts into ${table} before its referenced table ${parent}.`);
    }
  }
}
for (const required of ['tenants','roles','role_permissions','pipelines','pipeline_stages','company_settings','accounts','contacts','leads','deals','activities']) {
  if (!firstInsert.has(required)) errors.push(`Development seed does not create ${required}.`);
}
if (!seed.includes('Sample CRM Opportunity') || !seed.includes('Sample follow-up')) errors.push('Expected demo opportunity and follow-up are absent.');
if (/password_hash|password\s*=|SecurePassword|admin@example/i.test(seed)) errors.push('Seed must not introduce a default credential.');
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
console.log(`Seed static checks passed: ${inserts.length} inserts reference existing tables in dependency order; safe demo rows are present.`);
