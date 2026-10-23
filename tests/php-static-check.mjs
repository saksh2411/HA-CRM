import fs from 'node:fs';
import path from 'node:path';
import Engine from 'php-parser';
const parser=new Engine({parser:{phpVersion:'8.2',extractDoc:true,suppressErrors:false},ast:{withPositions:true},lexer:{short_tags:true,asp_tags:false}});
const roots=['app','cron','public'];const files=[];
for(const root of roots){const walk=d=>{for(const entry of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,entry.name);if(entry.isDirectory())walk(p);else if(p.endsWith('.php'))files.push(p)}};walk(root)}
files.push('cron.php','bootstrap.php');const errors=[];
for(const file of files){try{parser.parseCode(fs.readFileSync(file,'utf8'),file)}catch(e){errors.push(`${file}: ${e.message}`)}}
if(errors.length){console.error(errors.join('\n'));process.exit(1)}console.log(`PHP syntax parser passed: ${files.length} source files.`);
