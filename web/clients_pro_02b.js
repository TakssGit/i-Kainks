/* i-Kaink's - PACK 02B : sauvegarde et controle de la base Clients TEST uniquement. */
(()=>{'use strict';
const DB='ikainks_clients_test_plan02',STORE='clients';
const panel=document.querySelector('section.panel.no-print .controls');
if(!panel||document.getElementById('ik02bExport'))return;
const btn=(id,label)=>{const b=document.createElement('button');b.id=id;b.textContent=label;b.type='button';b.className='secondary';panel.appendChild(b);return b;};
const exportBtn=btn('ik02bExport','Sauvegarder clients (JSON)');
const importBtn=btn('ik02bImport','Restaurer dans base test');
const file=document.createElement('input');file.type='file';file.accept='.json,application/json';file.hidden=true;panel.appendChild(file);
const status=document.createElement('p');status.id='ik02bStatus';status.setAttribute('role','status');status.style.width='100%';status.style.fontWeight='600';panel.appendChild(status);
const msg=(s,err=false)=>{status.textContent=s;status.style.color=err?'#a72c32':'#176447';};
function open(){return new Promise((resolve,reject)=>{const r=indexedDB.open(DB);r.onupgradeneeded=()=>{r.transaction.abort();reject(Error('Base Clients de test absente. Ouvrez la page Clients et réessayez.'));};r.onsuccess=()=>{if(!r.result.objectStoreNames.contains(STORE)){r.result.close();reject(Error('Table Clients absente'));return;}resolve(r.result);};r.onerror=()=>reject(r.error||Error('Ouverture impossible'));});}
async function read(){const db=await open();try{return await new Promise((resolve,reject)=>{const t=db.transaction(STORE,'readonly'),r=t.objectStore(STORE).getAll();r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);});}finally{db.close();}}
function download(data,name){const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),2000);}
exportBtn.onclick=async()=>{try{const rows=await read();download({format:'ikainks-clients-test-02b',version:1,exportedAt:new Date().toISOString(),clients:rows},'ikainks_clients_test_'+new Date().toISOString().slice(0,10)+'.json');msg(rows.length+' client(s) exporté(s).');}catch(e){msg('Export impossible : '+e.message,true);}};
importBtn.onclick=()=>file.click();
file.onchange=async()=>{const f=file.files?.[0];file.value='';if(!f)return;try{if(f.size>5*1024*1024)throw Error('Fichier trop volumineux (limite 5 Mo)');const payload=JSON.parse(await f.text());if(payload.format!=='ikainks-clients-test-02b'||!Array.isArray(payload.clients))throw Error('Format de sauvegarde incompatible');if(payload.clients.length>10000)throw Error('Trop de clients');const codes=new Set();const allowed=['id','code','nom','type','telephone','email','ville','statut','nif','stat','adresse','notes'];const rows=payload.clients.map(c=>{if(!c||typeof c!=='object'||Array.isArray(c))throw Error('Client invalide');const o={};for(const k of allowed){if(k==='id'){if(c.id!==undefined){if(!Number.isSafeInteger(c.id)||c.id<1)throw Error('Identifiant invalide');o.id=c.id;}continue;}o[k]=String(c[k]??'').trim();if(o[k].length>({code:30,nom:120,email:120,adresse:300,notes:400}[k]||100))throw Error('Champ trop long : '+k);}if(!/^[A-Za-z0-9_-]+$/.test(o.code)||!o.nom)throw Error('Code ou nom invalide');const key=o.code.toLocaleLowerCase();if(codes.has(key))throw Error('Code client en doublon');codes.add(key);if(!['actif','inactif'].includes(o.statut)||!['entreprise','particulier'].includes(o.type))throw Error('Statut ou type invalide');return o;});
const existing=await read();if(existing.length)throw Error('Restauration refusée : base test non vide. Exportez vos données puis utilisez une base test vide. Aucun écrasement autorisé.');
if(!confirm('Importer '+rows.length+' clients dans la base de TEST vide ? Aucune base de production ne sera modifiée.'))return;
const db=await open();try{await new Promise((resolve,reject)=>{const t=db.transaction(STORE,'readwrite');for(const row of rows)t.objectStore(STORE).add(row);t.oncomplete=resolve;t.onerror=()=>reject(t.error||Error('Transaction échouée'));t.onabort=()=>reject(t.error||Error('Import annulé'));});}finally{db.close();}
msg(rows.length+' clients importés dans la base de test. Actualisation...');setTimeout(()=>location.reload(),350);
}catch(e){msg('Import annulé : '+e.message,true);}};
})();
