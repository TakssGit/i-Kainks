/* i-Kaink's PATCH 017 : DEMONSTRATION, donnees FICTIVES uniquement.
 * Compatible IndexedDB PATCH 015/016, sans suppression des lignes existantes.
 * Dessin de graphiques CANVAS avec mesures calculees a partir des lignes reelles du prototype.
 */
'use strict';
(function(){
 const COUNT=50;
 const catalog=['Ciment 50 kg','Fer rond 10 mm','Peinture acrylique 4 L','Clou 80 mm','Tuyau PVC 32 mm','Cable electrique 2,5 mm²','Vis a bois','Serrure porte','Carrelage 40x40','Pince universelle','Marteau','Ampoule LED 12 W','Robinet laiton','Disjoncteur 20 A','Tôle galvanisée','Sable 1 m³','Gravier 1 m³','Bois de charpente','Brouette','Brosse peinture'];
 const groups=['Cimenterie','Métallurgie','Peinture','Plomberie','Électricité','Outillage','Construction'];
 const statuses=['Actif','Validé','En attente','Terminé','Payé','Partiel'];
 const first=['Rakoto','Rasoa','Rabe','Randria','Andry','Fara','Miora','Hery','Tiana','Lova','Mamy','Noro'];
 const names=['Distribution','Quincaillerie','Construction','Services','Matériaux','Bâtiment'];
 const pad=n=>String(n).padStart(3,'0');
 const date=i=>{const d=new Date();d.setDate(d.getDate()-((i*7+3)%180));return d.toISOString().slice(0,10)};
 const ref=(m,i)=>m.toUpperCase().slice(0,3)+'-D'+pad(i);
 const person=i=>first[i%first.length]+' '+first[(i*3+5)%first.length];
 const client=i=>'CL-D'+pad((i%COUNT)+1)+' · '+person(i);
 const article=i=>'ART-D'+pad((i%COUNT)+1)+' · '+catalog[i%catalog.length];
 function valuesFor(m,i){
   const v={},qty=1+(i*7)%45,price=7500+(i*1739)%110000,amount=qty*price;
   for(const f of defs[m]){
     let x='';
     if(f==='Référence'||f==='Numéro'||f==='Code'||f==='Identifiant')x=ref(m,i);
     else if(f==='Date')x=date(i);
     else if(f==='Échéance'||f==='Validité'||f==='Livraison prévue')x=date(i+4);
     else if(f==='Désignation'||f==='Article')x=article(i);
     else if(f==='Client'||f==='Tiers')x=client(i);
     else if(f==='Fournisseur')x='FOU-D'+pad((i%COUNT)+1)+' · '+names[i%names.length];
     else if(f==='Nom')x=(m==='categories'?groups[i%groups.length]:m==='depots'?'Dépôt '+(i+1):person(i));
     else if(f==='Catégorie')x=groups[i%groups.length];
     else if(f==='Libellé'||f==='Objet'||f==='Tâche'||f==='Opération'||f==='Intervention')x='Opération de démonstration '+pad(i);
     else if(f==='Équipement')x='Équipement '+pad(i);
     else if(f==='Responsable')x=person(i+2);
     else if(f==='Transporteur')x='Transport '+pad(i);
     else if(f==='Adresse')x=(i%2?'Antananarivo':'Antsirabe')+', Madagascar';
     else if(f==='Téléphone')x='034 '+String(1000000+i).slice(0,2)+' '+String(1000000+i).slice(2,5)+' '+String(1000000+i).slice(5);
     else if(f==='Email')x='demo'+i+'@exemple.invalid';
     else if(f==='Unité')x=['pièce','sac','mètre','kg'][i%4];
     else if(f==='Statut')x=statuses[i%statuses.length];
     else if(f==='Quantité'||f==='Stock'||f==='Stock théorique')x=String(qty);
     else if(f==='Stock compté')x=String(qty-(i%5));
     else if(f==='Écart')x=String(-(i%5));
     else if(f==='Seuil alerte')x=String(4+i%8);
     else if(f==='Prix achat')x=String(Math.round(price*.72));
     else if(f==='Prix vente'||f==='Prix'||f==='Prix unitaire')x=String(price);
     else if(f==='Montant')x=String(amount);
     else if(f==='Coût')x=String(price);
     else if(f==='Plafond crédit')x=String(200000+i*5000);
     else if(f==='Mode paiement')x=['Espèces','Mobile Money','Virement','Chèque'][i%4];
     else if(f==='Type')x=['Entrée','Sortie','Vente','Achat'][i%4];
     else if(f==='Dépôt')x='Dépôt '+(i%5+1);
     else if(f==='Durée')x=String(6+i%24)+' mois';
     else if(f==='Priorité')x=['Basse','Normale','Haute'][i%3];
     else if(f==='Rôle')x=['Administrateur','Vendeur','Magasinier'][i%3];
     else if(f==='Résultat')x=['Conforme','À vérifier'][i%2];
     else if(f==='Notes'||f==='Description'||f==='Motif')x='DONNÉE FICTIVE POUR ESSAI · '+m+' '+pad(i);
     else if(f==='Délai livraison')x=String(2+i%10)+' jours';
     else x='Exemple '+pad(i);
     v[f]=x;
   }
   return v;
 }
 // Bulk transaction: no 1,150 independent IDB writes, avoids heavy UI stalls.
 async function populate(automatic=false){
   if(!state.db){notify('Base indisponible');return}
   const all=await listAll();const seen=new Set(all.map(r=>r.demoKey).filter(Boolean));
   const rows=[];
   for(const m of Object.keys(defs))for(let i=1;i<=COUNT;i++){
     const demoKey='PATCH017:'+m+':'+i;
     if(!seen.has(demoKey))rows.push({module:m,values:valuesFor(m,i),demoKey,updated:new Date().toISOString()});
   }
   if(!rows.length){notify('Les 50 exemples de chaque gestion sont déjà présents.');return}
   if(automatic!==true && !confirm('Ajouter '+rows.length+' lignes FICTIVES (50 par gestion) sans effacer les données existantes ?'))return;
   try{
     await new Promise((resolve,reject)=>{
       const t=state.db.transaction('rows','readwrite'),s=t.objectStore('rows');
       for(const r of rows)s.add(r);
       t.oncomplete=resolve;t.onerror=()=>reject(t.error);t.onabort=()=>reject(t.error);
     });
     signal();notify(rows.length+' lignes de démonstration ajoutées.');await render();
   }catch(e){notify('Import démonstration échoué : '+e.message)}
 }
 async function eraseDemo(){
   if(prompt('Supprimer uniquement les exemples PATCH 017 ? Tapez DEMO')!=='DEMO')return;
   const all=await listAll(),ids=all.filter(r=>r.demoKey?.startsWith('PATCH017:')).map(r=>r.id);
   await new Promise((resolve,reject)=>{const t=state.db.transaction('rows','readwrite'),s=t.objectStore('rows');ids.forEach(id=>s.delete(id));t.oncomplete=resolve;t.onerror=()=>reject(t.error);t.onabort=()=>reject(t.error)});
   signal();notify(ids.length+' exemples supprimés');await render();
 }
 const origSettings=settings;
 settings=function(){origSettings();const pane=document.createElement('div');pane.className='panel';pane.innerHTML='<h2>Jeu de démonstration complet</h2><p class="muted">50 lignes fictives dans chacune des '+Object.keys(defs).length+' gestions : '+Object.keys(defs).length*COUNT+' lignes au total. Les ajouts sont idempotents et ne remplacent pas vos données. Les graphiques se calculent sur les lignes enregistrées.</p><div class="actions"><button class="primary" id="demo017">Installer 50 exemples par gestion</button><button id="clearDemo017" class="danger">Supprimer uniquement les exemples PATCH 017</button></div><p class="muted">Les exemples sont fictifs et destinés aux essais. Exportez une sauvegarde JSON avant toute opération sensible.</p>';
 $('content').prepend(pane);$('demo017').onclick=populate;$('clearDemo017').onclick=eraseDemo;
 };
 const originalSeed=seed;
 seed=populate;
 // True CANVAS charts: values read from IndexedDB, no placeholder images.
 const colors=['#1767aa','#08a88a','#ef9b3b','#8e63c7','#df6a74','#33a6c2','#667d98','#63a06b'];
 const isAmount=k=>['ventes','achats','depenses','caisse','reglements','devis','commandes','credits','tarifs','maintenance'].includes(k);
 const moneyNum=r=>numeric(r.values.Montant??r.values.Prix??r.values['Prix vente']??0);
 function bar(canvas,items){const ctx=canvas.getContext('2d');if(!ctx)return;const W=canvas.width,H=canvas.height;ctx.clearRect(0,0,W,H);const left=52,top=24,right=16,bottom=60,max=Math.max(1,...items.map(x=>x.value));ctx.strokeStyle='#b9c9d6';ctx.beginPath();ctx.moveTo(left,top);ctx.lineTo(left,H-bottom);ctx.lineTo(W-right,H-bottom);ctx.stroke();items.forEach((item,i)=>{const width=(W-left-right)/items.length,x=left+i*width+width*.12,bh=(H-top-bottom-12)*item.value/max;ctx.fillStyle=colors[i%colors.length];ctx.fillRect(x,H-bottom-bh,width*.72,bh);ctx.fillStyle='#24445e';ctx.font='12px Segoe UI';ctx.textAlign='center';ctx.fillText(String(Math.round(item.value)),x+width*.36,H-bottom-bh-5);ctx.save();ctx.translate(x+width*.36,H-bottom+12);ctx.rotate(-.55);ctx.fillText(item.name.slice(0,15),0,0);ctx.restore()})}
 function donut(canvas,items){const ctx=canvas.getContext('2d');if(!ctx)return;ctx.clearRect(0,0,canvas.width,canvas.height);const total=items.reduce((s,x)=>s+x.value,0)||1;let angle=-Math.PI/2;items.forEach((it,i)=>{const end=angle+it.value/total*Math.PI*2;ctx.beginPath();ctx.moveTo(160,140);ctx.arc(160,140,104,angle,end);ctx.closePath();ctx.fillStyle=colors[i%colors.length];ctx.fill();angle=end});ctx.beginPath();ctx.arc(160,140,57,0,Math.PI*2);ctx.fillStyle='#fff';ctx.fill();ctx.textAlign='center';ctx.fillStyle='#193b58';ctx.font='bold 22px Segoe UI';ctx.fillText(String(items.reduce((s,x)=>s+x.value,0)),160,147);ctx.font='12px Segoe UI';items.slice(0,8).forEach((it,i)=>{ctx.fillStyle=colors[i%colors.length];ctx.fillRect(305,35+i*28,12,12);ctx.fillStyle='#24445e';ctx.textAlign='left';ctx.fillText(it.name.slice(0,19)+' : '+it.value,323,46+i*28)})}
 function charts(all){
   const module=state.module;if(module==='settings')return;
   const pane=document.createElement('section');pane.className='panel ikcharts';pane.innerHTML='<div class="row"><div><h2>Graphiques calculés sur la base locale</h2><p class="muted">Données '+(all.some(r=>r.demoKey)?'de démonstration et saisies':'saisies')+' · actualisation automatique après modification</p></div><button id="refreshCharts">↻ Actualiser</button></div><div class="chartgrid"><div><h3 id="chartTitle1">Volumes</h3><canvas id="ikBar" width="620" height="320" role="img" aria-label="Histogramme des données"></canvas></div><div><h3 id="chartTitle2">Répartition</h3><canvas id="ikDonut" width="600" height="290" role="img" aria-label="Graphique circulaire des données"></canvas></div></div>';
   if(module==='dashboard'||module==='rapports')$('content').append(pane);else $('content').prepend(pane);
   let items,distribution;
   if(module==='dashboard'||module==='rapports'){
     items=Object.keys(defs).map(k=>({name:labels[k],value:all.filter(r=>r.module===k).length})).sort((a,b)=>b.value-a.value).slice(0,8);
     distribution=['ventes','achats','depenses','reglements','credits','caisse'].map(k=>({name:labels[k],value:all.filter(r=>r.module===k).length}));
   }else{
     const rows=currentRows(all);
     const key=defs[module].includes('Statut')?'Statut':defs[module].includes('Catégorie')?'Catégorie':defs[module].includes('Type')?'Type':null;
     const group=new Map();rows.forEach(r=>{const name=key?String(r.values[key]||'Non défini'):(r.values.Date||'Sans date').slice(0,7);group.set(name,(group.get(name)||0)+1)});
     items=[...group].map(([name,value])=>({name,value})).sort((a,b)=>b.value-a.value).slice(0,8);
     distribution=items;
   }
   $('chartTitle1').textContent=module==='dashboard'||module==='rapports'?'Nombre d’enregistrements par gestion':'Répartition des lignes filtrées';
   $('chartTitle2').textContent='Répartition par '+(module==='dashboard'||module==='rapports'?'activité':'catégorie / statut / période');
   bar($('ikBar'),items);donut($('ikDonut'),distribution);
   $('refreshCharts').onclick=()=>render();
 }
 const originalRender=render;
 render=async function(){await originalRender();if(!state.db||state.module==='settings')return;try{charts(await listAll())}catch(e){console.error('Graphiques',e)}};
 // Prominent setup shortcut on all pages and automatic first-use opt-in.
 const badge=document.createElement('button');badge.id='demoShortcut';badge.textContent='＋ 50 exemples / gestion';badge.title='Ajouter les exemples fictifs sans écraser les données';badge.onclick=populate;
 document.querySelector('.top').append(badge);
 // Remplissage automatique uniquement si la base est entièrement vide.
 (async()=>{for(let n=0;n<30&&!state.db;n++)await new Promise(r=>setTimeout(r,150));if(state.db && (await listAll()).length===0)await populate(true)})().catch(e=>console.error('Demo auto',e));
 const style=document.createElement('style');style.textContent='.ikcharts{margin:0 0 16px}.chartgrid{display:grid;grid-template-columns:1fr 1fr;gap:18px;overflow:hidden}.chartgrid>div{min-width:0}.chartgrid canvas{display:block;max-width:100%;height:auto}.chartgrid h3{font-size:14px;color:#294b64;margin:8px 0}#demoShortcut{background:#e3f5ec;color:#086a49;border:1px solid #9acbb7;border-radius:8px;padding:9px 12px;cursor:pointer;font-weight:700}@media(max-width:900px){.chartgrid{grid-template-columns:1fr}#demoShortcut{font-size:11px;padding:6px}}';document.head.append(style);
})();
