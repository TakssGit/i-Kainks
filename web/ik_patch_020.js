/* PATCH 020 - démonstration professionnelle, IndexedDB local uniquement. */
'use strict';
(function(){
const targets={articles:286,clients:137,fournisseurs:54,ventes:482,achats:174,devis:128,commandes:163,livraisons:147,retours:32,depenses:108,caisse:214,mouvements:310,depots:5,categories:18,reglements:275,inventaires:47,utilisateurs:12,taches:64,tarifs:95,credits:44,garanties:36,maintenance:28,audits:81,factures:396,avoirs:24,bons_reception:152,bons_sortie:105,transferts:62,prix:155,codes_barres:286,alertes:49,budgets:24,taxes:42,roles:7,journaux:320,sauvegardes:14,contacts:111,objectifs:38,points_vente:4};
const goods=[['Ciment Portland 50 kg','Matériaux',39500],['Fer à béton Ø 10 mm (12 m)','Métallurgie',34200],['Fer à béton Ø 8 mm (12 m)','Métallurgie',23800],['Peinture acrylique blanc 4 L','Peinture',87500],['Tuyau PVC pression Ø 32 mm','Plomberie',26500],['Coude PVC 90° Ø 32 mm','Plomberie',3800],['Disjoncteur 20 A','Électricité',43500],['Câble électrique 2,5 mm² (m)','Électricité',5600],['Carrelage grès cérame 60 × 60','Revêtement',42500],['Colle carrelage 25 kg','Revêtement',31500],['Marteau de charpentier 500 g','Outillage',28900],['Perceuse électrique 650 W','Outillage',245000],['Robinet mitigeur lavabo','Plomberie',137000],['Serrure encastrable à clé','Quincaillerie',38500],['Vis bois 5 × 50 mm (boîte)','Quincaillerie',22500],['Tôle galvanisée 2 m','Couverture',63500],['Pince coupante 180 mm','Outillage',41000],['Ampoule LED 12 W E27','Électricité',14500],['Brouette renforcée 80 L','Matériaux',318000],['Silicone sanitaire 280 ml','Quincaillerie',22900],['Gravier 5/15 (sac)','Matériaux',12000],['Sable lavé (sac)','Matériaux',9500],['Clous 80 mm (kg)','Quincaillerie',16800],['Peinture antirouille 1 L','Peinture',42500]];
const given=['Andry','Miora','Lova','Hery','Fara','Tiana','Noro','Toky','Tahina','Soa','Mamy','Rado','Fanja','Voahangy','Solo','Haja'];
const family=['Rakoto','Rasolofoniaina','Ranaivo','Randriamampianina','Raveloson','Rakotondrabe','Rasoanaivo','Razanakolona','Raharimanana','Randrianarisoa','Rabenja'];
const towns=['Antananarivo','Antsirabe','Toamasina','Mahajanga','Fianarantsoa','Toliara','Ambatondrazaka','Moramanga','Antsiranana'];
const suppliers=['Mada Matériaux','BatiPro Distribution','Tana Fer & Acier','Elec Mada','Plomberie Centrale','Quincaillerie Océan','Peintures du Sud','Société Batimax','Outillage Pro','Construction Services'];
const pad=(n,w=4)=>String(n).padStart(w,'0');
const person=i=>given[(i*7+3)%given.length]+' '+family[(i*3+2)%family.length];
const client=i=>person((i%targets.clients)+1);
const vendor=i=>suppliers[i%suppliers.length]+' '+(i%suppliers.length===0?'SARL':'');
const item=i=>goods[i%goods.length];
const day=i=>{const d=new Date(2026,9,25);d.setDate(d.getDate()-((i*11+7)%330));return d.toISOString().slice(0,10)};
const num=(i,k)=>Math.round((8500+(i*7919+k*2399)%880000)/100)*100;
const status=(m,i)=>m==='articles'?'Actif':(['Validé','Terminé','En attente','Payé','Actif','Partiel'][i%6]);
function makeRow(m,i){const g=item(i*3),qty=1+(i*13)%54,unit=g[2]+(i%4)*700,amount=qty*unit;const v={};for(const f of defs[m]){
 let x='';
 if(['Référence','Numéro','Code','Identifiant','Code-barres'].includes(f))x=m.slice(0,3).toUpperCase()+'-26-'+pad(i,5);
 else if(f==='Date'||f==='Échéance'||f==='Validité'||f==='Livraison prévue')x=day(i+(f==='Date'?0:4));
 else if(f==='Désignation'||f==='Article')x=g[0];
 else if(f==='Catégorie')x=g[1];
 else if(f==='Client'||f==='Tiers')x=client(i);
 else if(f==='Fournisseur')x=vendor(i);
 else if(f==='Nom')x=m==='categories'?['Matériaux','Métallurgie','Peinture','Plomberie','Électricité','Outillage','Revêtement','Quincaillerie','Couverture'][i%9]:m==='depots'?'Dépôt '+['central','nord','sud','est','ouest'][i%5]:m==='points_vente'?'Agence '+towns[i%towns.length]:m==='roles'?['Administrateur','Gérant','Vendeur','Caissier','Magasinier','Acheteur','Lecteur'][i%7]:m==='fournisseurs'?vendor(i):person(i);
 else if(f==='Organisation')x=vendor(i);
 else if(f==='Libellé'||f==='Objet'||f==='Tâche'||f==='Opération'||f==='Intervention')x=['Approvisionnement matériaux','Vente comptoir','Commande chantier','Livraison agence','Suivi client','Contrôle qualité'][i%6]+' · '+g[0];
 else if(f==='Responsable'||f==='Utilisateur')x=person(i+4);
 else if(f==='Adresse')x='Lot '+pad(i,3)+' · '+towns[i%towns.length]+', Madagascar';
 else if(f==='Téléphone')x='034 '+pad(10+(i%89),2)+' '+pad((100+i*37)%1000,3)+' '+pad((100+i*17)%1000,3);
 else if(f==='Email')x='contact'+i+'@demo.invalid';
 else if(f==='Statut')x=status(m,i);
 else if(f==='Quantité'||f==='Stock'||f==='Stock théorique')x=String(qty+(m==='articles'?i%130:0));
 else if(f==='Stock compté')x=String(qty-(i%4));
 else if(f==='Seuil alerte')x=String(5+i%11);
 else if(f==='Écart')x=String(-(i%4));
 else if(f==='Prix achat'||f==='Coût')x=String(Math.round(unit*.76));
 else if(f==='Prix vente'||f==='Prix unitaire'||f==='Prix')x=String(unit);
 else if(/Montant|Budget|Réalisé|Objectif|Total TTC|Base|Marge/.test(f))x=String(amount);
 else if(f==='Mode paiement')x=['Espèces','Mobile Money','Virement','Chèque'][i%4];
 else if(f==='Unité')x=['pièce','sac','mètre','boîte'][i%4];
 else if(f==='Type')x=['Entrée','Sortie','Vente','Achat'][i%4];
 else if(f==='Dépôt'||f==='Dépôt source')x='Dépôt central';
 else if(f==='Dépôt destination')x='Dépôt nord';
 else if(f==='Transporteur')x='Transport Mada '+(i%8+1);
 else if(f==='Rôle')x=['Administrateur','Vendeur','Caissier','Magasinier'][i%4];
 else if(f==='Priorité')x=['Normale','Haute','Basse'][i%3];
 else if(f==='Taux')x=String([0,5,10,20][i%4]);
 else if(f==='Durée')x=(6+i%18)+' mois';
 else if(f==='Période')x='2026-T'+(1+i%4);
 else if(f==='Plafond crédit')x=String(150000+(i%18)*100000);
 else if(f==='Délai livraison')x=(2+i%12)+' jours';
 else if(f==='Notes'||f==='Description'||f==='Motif'||f==='Détail')x='Simulation commerciale · '+g[1]+' · '+towns[i%towns.length];
 else x=g[0]+' · '+towns[i%towns.length];
 v[f]=x;
 }return {module:m,values:v,demoKey:'PATCH020:'+m+':'+i,updated:new Date().toISOString()};}
async function populate20(){if(!state.db){notify('Base non disponible');return}const all=await listAll();const existing=new Set(all.filter(r=>r.demoKey?.startsWith('PATCH020:')).map(r=>r.demoKey));const todo=[];for(const [m,n] of Object.entries(targets))if(defs[m])for(let i=1;i<=n;i++){const key='PATCH020:'+m+':'+i;if(!existing.has(key))todo.push(makeRow(m,i))}
 if(!todo.length){notify('Jeu de démonstration PATCH 020 déjà présent');return}
 const btn=document.getElementById('ikPopulate20');if(btn){btn.disabled=true;btn.textContent='Chargement…'}
 try{for(let i=0;i<todo.length;i+=250){const batch=todo.slice(i,i+250);await new Promise((ok,fail)=>{const t=state.db.transaction('rows','readwrite');const store=t.objectStore('rows');for(const row of batch)store.add(row);t.oncomplete=ok;t.onerror=()=>fail(t.error);t.onabort=()=>fail(t.error)});}signal();notify(todo.length+' données fictives ajoutées');await render();}
 catch(e){notify('Erreur : '+e.message)}finally{if(btn){btn.disabled=false;btn.textContent='Compléter les données de démo'}}
}
const groups=[['Pilotage',['dashboard','rapports','objectifs','alertes']],['Ventes & relations clients',['ventes','devis','commandes','factures','avoirs','clients','credits','reglements','tarifs','prix']],['Achats & fournisseurs',['achats','fournisseurs','bons_reception','retours']],['Articles & stocks',['articles','categories','codes_barres','mouvements','inventaires','depots','transferts','bons_sortie']],['Logistique & livraisons',['livraisons','points_vente','garanties','maintenance']],['Finance & trésorerie',['caisse','depenses','budgets','taxes']],['Administration',['utilisateurs','roles','contacts','taches','audits','journaux','sauvegardes','settings']]];
const groupIcon=['◫','◈','↙','▤','▸','▥','⚙'];
nav=function(){const root=document.getElementById('nav');const current=state.module;root.innerHTML=groups.map(([name,keys],i)=>`<details class="ik20-group" ${keys.includes(current)?'open':''}><summary><span>${groupIcon[i]}</span>${esc(name)}<em>${keys.length}</em></summary><div class="ik20-sub">${keys.filter(k=>labels[k]).map(k=>`<button type="button" data-module="${k}" class="${current===k?'active':''}">${esc(labels[k])}</button>`).join('')}</div></details>`).join('');root.querySelectorAll('button').forEach(b=>b.onclick=()=>{const openNames=[...root.querySelectorAll('details[open] summary')].map(x=>x.textContent);switchTo(b.dataset.module);root.querySelectorAll('details').forEach(d=>{if(openNames.some(n=>n.includes(d.querySelector('summary').textContent.trim().replace(/\d+$/,''))))d.open=true})});};
function graphBars(data,maximum){return `<div class="ik20-chart">${data.map(([label,val])=>`<div class="ik20-bar"><span>${esc(label)}</span><div><i style="width:${Math.max(1,100*val/Math.max(1,maximum))}%"></i></div><strong>${Number(val).toLocaleString('fr-FR')}</strong></div>`).join('')}</div>`}
function trendSvg(series){const W=720,H=210,P=28,max=Math.max(1,...series),points=series.map((v,i)=>`${P+i*(W-P*2)/Math.max(1,series.length-1)},${H-P-v/max*(H-2*P)}`).join(' ');return `<svg class="ik20-line" viewBox="0 0 ${W} ${H}" role="img" aria-label="Évolution des ventes des six derniers mois"><defs><linearGradient id="ik20fill" x1="0" x2="0" y1="0" y2="1"><stop stop-color="#20a897" stop-opacity=".26"/><stop offset="1" stop-color="#20a897" stop-opacity="0"/></linearGradient></defs>${[0,.25,.5,.75,1].map(f=>`<line x1="${P}" y1="${P+(H-2*P)*f}" x2="${W-P}" y2="${P+(H-2*P)*f}" stroke="#dce7f0"/>`).join('')}<polygon points="${P},${H-P} ${points} ${W-P},${H-P}" fill="url(#ik20fill)"/><polyline points="${points}" fill="none" stroke="#139d8b" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>${series.map((v,i)=>`<circle cx="${P+i*(W-P*2)/Math.max(1,series.length-1)}" cy="${H-P-v/max*(H-2*P)}" r="4" fill="#139d8b"/>`).join('')}</svg>`}
function overview(all,report=false){const by={};for(const r of all)(by[r.module]??=[]).push(r);const n=k=>(by[k]||[]).length;const total=k=>(by[k]||[]).reduce((s,r)=>s+numeric(r.values.Montant||r.values['Total TTC']||0),0);const dates=Array.from({length:6},(_,i)=>{const d=new Date(2026,9-i,1);return d.toISOString().slice(0,7)}).reverse();const months=dates.map(m=>(by.ventes||[]).filter(r=>(r.values.Date||'').startsWith(m)).reduce((s,r)=>s+numeric(r.values.Montant),0));const low=(by.articles||[]).filter(r=>numeric(r.values.Stock)<=numeric(r.values['Seuil alerte'])).length;
 $('content').innerHTML=`<section class="ik20-hero"><div><span class="ik20-eyebrow">i-KAINK’S / ESPACE DE GESTION</span><h1>${report?'Rapports & performance':'Votre activité en un coup d’œil'}</h1><p>Vue consolidée des enregistrements de démonstration · ${new Date().toLocaleDateString('fr-FR',{day:'numeric',month:'long',year:'numeric'})}</p></div><button id="ik20Refresh">↻ Actualiser</button></section><div class="ik20-warning">MODE DÉMONSTRATION · Données fictives enregistrées dans Chrome (IndexedDB). Les indicateurs ne sont pas des chiffres commerciaux réels et ne sont pas synchronisés avec Flutter.</div><section class="ik20-kpis">${[['Chiffre d’affaires saisi',money(total('ventes')),'↗'],['Ventes',n('ventes'),'◈'],['Clients',n('clients'),'♙'],['Articles',n('articles'),'▤'],['Achats',money(total('achats')),'↙'],['Stock sous seuil',low,'!']].map(([name,value,icon])=>`<article class="ik20-kpi"><span>${esc(name)}</span><strong>${esc(value)}</strong><i>${icon}</i></article>`).join('')}</section><div class="ik20-grid"><section class="ik20-card ik20-wide"><div class="ik20-heading"><h2>Évolution des ventes</h2><span>6 mois · montants saisis</span></div>${trendSvg(months)}<div class="ik20-months">${dates.map(x=>`<span>${x.slice(5)}/${x.slice(2,4)}</span>`).join('')}</div></section><section class="ik20-card"><div class="ik20-heading"><h2>Activité par gestion</h2><span>Nombre de dossiers</span></div>${graphBars(['ventes','achats','devis','factures','livraisons','reglements'].map(k=>[labels[k],n(k)]),Math.max(1,...['ventes','achats','devis','factures','livraisons','reglements'].map(n)))}</section><section class="ik20-card"><div class="ik20-heading"><h2>Accès rapide</h2><span>Actions courantes</span></div><div class="ik20-shortcuts">${['ventes','articles','clients','devis','achats','livraisons','settings','rapports'].map(k=>`<button data-ik20-go="${k}">${esc(labels[k])} <b>→</b></button>`).join('')}</div></section><section class="ik20-card ik20-wide"><div class="ik20-heading"><h2>Dernières ventes</h2><span>Transactions enregistrées</span></div><div class="ik20-table-scroll"><table><thead><tr><th>Référence</th><th>Date</th><th>Client</th><th>Article</th><th>Montant</th><th>Statut</th></tr></thead><tbody>${(by.ventes||[]).slice().sort((a,b)=>(b.values.Date||'').localeCompare(a.values.Date||'')).slice(0,8).map(r=>`<tr>${['Référence','Date','Client','Article'].map(f=>`<td>${esc(r.values[f])}</td>`).join('')}<td><strong>${esc(money(numeric(r.values.Montant)))}</strong></td><td><span class="ik20-status">${esc(r.values.Statut)}</span></td></tr>`).join('')||'<tr><td colspan="6">Aucune vente enregistrée</td></tr>'}</tbody></table></div></section></div><div class="ik20-footer">${all.length.toLocaleString('fr-FR')} enregistrements dans ce navigateur · Prototype interactif local</div>`;
 document.getElementById('ik20Refresh').onclick=()=>render();document.querySelectorAll('[data-ik20-go]').forEach(b=>b.onclick=()=>switchTo(b.dataset.ik20Go));}
dashboard=function(all){overview(all)};reports=function(all){overview(all,true)};
const banner=document.createElement('section');banner.className='ik20-seed';banner.innerHTML='<div><strong>Jeu de données professionnel — PATCH 020</strong><small>Volumes variables, produits de quincaillerie, clients et fournisseurs fictifs. Les données existantes ne sont pas supprimées.</small></div><button id="ikPopulate20" type="button">Compléter les données de démo</button>';
const main=document.getElementById('content');main.parentNode.insertBefore(banner,main);document.getElementById('ikPopulate20').onclick=populate20;
// Démarrage automatique une fois : vérification après initialisation de la base, sans effacer les anciens exemples.
const ready=setInterval(async()=>{if(!state.db)return;clearInterval(ready);try{const all=await listAll();if(!all.some(r=>r.demoKey?.startsWith('PATCH020:')))await populate20();else await render();}catch(e){console.error('PATCH020 initialisation',e)}},300);
nav();
})();
