/* i-Kaink's PACK 116-119 - Outils de tableaux en lecture seule. */
(() => {
 'use strict';
 if (window.__ikTableTools116119) return;
 window.__ikTableTools116119 = true;
 const css = document.createElement('style');
 css.textContent = `.ik-table-tools{display:flex;flex-wrap:wrap;align-items:center;gap:8px;padding:8px 0;font:13px system-ui,sans-serif}.ik-table-tools input{padding:8px;border:1px solid #aeb8c9;border-radius:7px;max-width:230px;background:#fff;color:#14243c}.ik-table-tools button{border:1px solid #1a4677;background:#1a4677;color:white;border-radius:7px;padding:8px 11px;cursor:pointer}.ik-table-tools .ik-count{color:inherit;font-size:12px}.ik-table-tools,.ik-table-tools *{box-sizing:border-box}@media print{.ik-table-tools{display:none!important}}`;
 document.head.appendChild(css);
 const safe = v => String(v == null ? '' : v).replace(/[\r\n]+/g,' ').trim();
 const csv = rows => '\uFEFF' + rows.map(r => r.map(v => '"' + safe(v).replace(/"/g,'""') + '"').join(';')).join('\r\n');
 function install(table){
  if(table.dataset.ikTools116119 || !table.querySelector('thead tr, tr'))return;
  const bodyRows = [...table.querySelectorAll('tbody tr')];
  if(!bodyRows.length) return;
  table.dataset.ikTools116119='1';
  const tools=document.createElement('div'); tools.className='ik-table-tools'; tools.setAttribute('role','group');tools.setAttribute('aria-label','Outils du tableau');
  const input=document.createElement('input'); input.type='search';input.placeholder='Rechercher dans le tableau';input.setAttribute('aria-label','Filtrer les lignes');
  const count=document.createElement('span');count.className='ik-count';
  const reset=document.createElement('button');reset.type='button';reset.textContent='Réinitialiser';
  const exp=document.createElement('button');exp.type='button';exp.textContent='Exporter CSV';
  function rows(){return [...table.querySelectorAll('tbody tr')];}
  function refresh(){const q=input.value.toLocaleLowerCase().trim();let n=0;for(const tr of rows()){const match=!q||tr.textContent.toLocaleLowerCase().includes(q);tr.hidden=!match;tr.style.display=match?'':'none';if(match)n++;}count.textContent=`${n} / ${rows().length} lignes`;}
  input.addEventListener('input',refresh);
  reset.addEventListener('click',()=>{input.value='';refresh();});
  exp.addEventListener('click',()=>{
   const head=[...table.querySelectorAll('thead tr')].map(tr=>[...tr.cells].map(c=>c.innerText));
   const data=rows().filter(tr=>!tr.hidden).map(tr=>[...tr.cells].map(c=>c.innerText));
   const content=csv([...head,...data]);const blob=new Blob([content],{type:'text/csv;charset=utf-8'});const url=URL.createObjectURL(blob);
   const a=document.createElement('a');a.href=url;a.download='ikainks_tableau_'+new Date().toISOString().slice(0,10)+'.csv';document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),2000);
  });
  tools.append(input,reset,exp,count);table.parentElement.insertBefore(tools,table);refresh();
 }
 let pending=false;
 function scan(){pending=false;document.querySelectorAll('table').forEach(install);}
 function schedule(){if(!pending){pending=true;requestAnimationFrame(scan);}}
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>{scan();new MutationObserver(schedule).observe(document.body,{subtree:true,childList:true});});
 else {scan();new MutationObserver(schedule).observe(document.body,{subtree:true,childList:true});}
})();
