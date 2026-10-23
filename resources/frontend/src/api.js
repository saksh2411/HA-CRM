window.HA_CRM_BASE = window.HA_CRM_BASE || document.querySelector('meta[name="ha-crm-base"]')?.content || '';
let csrf = '';
export async function getCsrf(){const r=await fetch(`${window.HA_CRM_BASE||''}/api/auth/csrf`,{credentials:'include'});const j=await r.json();csrf=j.data?.token||'';return csrf;}
export async function api(path, options={}) {
  const method=(options.method||'GET').toUpperCase();
  if(method!=='GET'&&!csrf)await getCsrf();
  const response=await fetch(`${window.HA_CRM_BASE||''}/api/${path.replace(/^\//,'')}`,{credentials:'include',headers:{'Accept':'application/json','Content-Type':'application/json',...(method!=='GET'?{'X-CSRF-Token':csrf}:{}),...options.headers},...options,body:options.body&&typeof options.body!=='string'?JSON.stringify(options.body):options.body});
  const json=await response.json().catch(()=>({error:{message:'Invalid server response.'}}));
  if(!response.ok)throw Object.assign(new Error(json.error?.message||'Request failed.'),{status:response.status,details:json.error?.details||{}});
  if(json.data?.csrf)csrf=json.data.csrf;
  return json.data;
}
export const query=(params={})=>new URLSearchParams(Object.entries(params).filter(([,v])=>v!==''&&v!=null)).toString();
