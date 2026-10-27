'use strict';
/* PATCH 022-024 groupé. Frontend de démonstration, non APK. Conserve IndexedDB et l'app 021. */
(()=>{
 const $=s=>document.querySelector(s);
 const escape=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const isMobile=()=>matchMedia('(max-width:750px)').matches;
 const money=n=>(Number(n)||0).toLocaleString('fr-FR')+' Ar';
 const catalogUrl='ik_catalog_022.json';
 let catalog=[], seeded=false, busy=false, active='dashboard';
 const moduleTargets={articles:180,clients:137,fournisseurs:54,ventes:320,achats:140,devis:95,commandes:110,livraisons:85,factures:210,reglements:155,categories:12,depenses:75,caisse:115,inventaires:32,mouvements:200,retours:24,depots:5,utilisateurs:12,tarifs:90,garanties:35};
 const firstNames=['Rasoa','Andry','Fara','Tiana','Noro','Hery','Mamy','Soa','Tahina','Rivo','Voahangy','Lova','Fanja','Tojo','Hanta'];
 const lastNames=['Rakoto','Rasoanaivo','Rajaonarison','Randriamihaja','Ravelomanana','Raharison','Razafindrakoto','Andrianina','Ramanantsoa','Ratsimbazafy'];
 const cities=['Antananarivo','Antsirabe','Toamasina','Fianarantsoa','Mahajanga','Toliara','Antsiranana','Ambatondrazaka'];
 const suppliers=['Matériaux Tana','BatiPro Madagascar','Quincaillerie Anosy','Mada Industrie','Equipement Plus','Batirama','Distribution Vakinankaratra','Outillage Océan Indien'];
 const status=['Validé','Payé','En attente','Partiel','Terminé'];
 const day=i=>{const d=new Date();d.setDate(d.getDate()-(i*7%360));return d.toISOString().slice(0,10)};
 const source='DEMO022';
 const imgFor=r=>{
  const img=String(r?.values?.Image||'');
  if(/^assets\/products\/IK-\d{4}\.svg$/.test(img))return img;
  const ref=String(r?.values?.Référence||'');
  const item=catalog.find(p=>p.ref===ref||p.name===r?.values?.Désignation);
  if(item)return item.image;
  const cat=String(r?.values?.Catégorie||'').toLowerCase();
  const index=Math.max(0,['ciment','peinture','visserie','plomberie','électricité','outillage','carrelage','bois','jardin','serrurerie','toiture','quincaillerie'].findIndex(x=>cat.includes(x)));
  return `assets/products/IK-${String(index+1).padStart(4,'0')}.svg`;
 };
 const img=(r,cls='thumb')=>`<img class="${cls}" loading="lazy" alt="Illustration ${escape(r?.values?.Désignation||'article')}" src="${imgFor(r)}">`;
 const rand=i=>((i*37+11)%97);
 function makeRow(module,i){
  const p=catalog[(i*7+rand(i))%catalog.length], client=firstNames[i%firstNames.length]+' '+lastNames[(i*3)%lastNames.length], fournisseur=suppliers[i%suppliers.length],qty=1+(i*3%9),date=day(i),amount=qty*p.price,ref=module.toUpperCase().slice(0,3)+'-D22-'+String(i+1).padStart(5,'0');
  const v={Référence:ref,Numéro:ref,Date:date,Statut:status[i%status.length],Notes:'Démonstration fictive • PATCH 022'};
  switch(module){
   case 'articles':return {Référence:p.ref,Désignation:p.name,Catégorie:p.category,Unité:'Unité',Stock:String(p.stock),'Seuil alerte':'10','Prix achat':String(p.cost),'Prix vente':String(p.price),Fournisseur:suppliers[i%8],Statut:'Actif',Date:date,Image:p.image};
   case 'clients':return {Code:ref,Nom:client,Téléphone:'03'+String(2+i%3)+' '+String(1000000+i*153).padStart(7,'0'),Adresse:cities[i%cities.length],Email:`client${i+1}@exemple.mg`,'Plafond crédit':String(100000+i*10000),Statut:'Actif',Date:date};
   case 'fournisseurs':return {Code:ref,Nom:fournisseur+' '+String(1+Math.floor(i/8)),Téléphone:'034 '+String(1000000+i*217).padStart(7,'0'),Adresse:cities[i%cities.length],Email:`fournisseur${i+1}@exemple.mg`,'Délai livraison':'7',Statut:'Actif',Date:date};
   case 'categories':return {Code:ref,Nom:catalog[i%catalog.length].category,Description:'Famille de produits de quincaillerie',Statut:'Actif'};
   case 'ventes':case 'achats':return {...v,Client:client,Fournisseur:fournisseur,Article:p.name,Quantité:String(qty),'Prix unitaire':String(module==='ventes'?p.price:p.cost),Montant:String(module==='ventes'?amount:qty*p.cost),'Mode paiement':['Espèces','Mobile Money','Virement'][i%3]};
   case 'factures':return {...v,Client:client,Commande:'CMD-'+i,Montant:String(amount),TVA:'0','Total TTC':String(amount),'Échéance':day(i+4)};
   case 'devis':case 'commandes':return {...v,Client:client,Objet:p.name,Montant:String(amount),Validité:day(i+5),'Livraison prévue':day(i+2)};
   case 'livraisons':return {...v,Commande:'CMD-'+i,Client:client,Transporteur:'Livraison locale'};
   case 'reglements':return {...v,Tiers:client,Type:'Client',Montant:String(amount),'Échéance':day(i+3),'Mode paiement':'Espèces'};
   case 'mouvements':return {...v,Article:p.name,Type:i%2?'Entrée':'Sortie',Quantité:String(qty),Dépôt:'Principal',Motif:'Historique de démonstration'};
   case 'inventaires':return {...v,Dépôt:'Principal',Article:p.name,'Stock théorique':String(p.stock),'Stock compté':String(p.stock-1),Écart:'-1'};
   case 'depenses':case 'caisse':return {...v,Libellé:'Opération '+(i+1),Catégorie:'Exploitation',Type:i%2?'Entrée':'Sortie',Montant:String(amount),'Mode paiement':'Espèces'};
   case 'depots':return {Code:ref,Nom:'Dépôt '+cities[i%cities.length],Adresse:cities[i%cities.length],Responsable:client,Statut:'Actif'};
   case 'utilisateurs':return {Identifiant:'demo'+(i+1),Nom:client,Rôle:i?'Vendeur':'Administrateur',Email:`demo${i+1}@exemple.mg`,Statut:'Actif'};
   case 'tarifs':return {Code:ref,Article:p.name,'Type tarif':'Détail',Prix:String(p.price),Date:date,Statut:'Actif'};
   case 'retours':return {...v,Type:'Retour client',Tiers:client,Article:p.name,Quantité:String(qty),Motif:'Échange',Statut:'En attente'};
   case 'garanties':return {...v,Client:client,Article:p.name,Durée:'12 mois'};
   default:return v;
  }
 }
 async function seed(){if(busy||seeded||!catalog.length)return;busy=true;
  try{
   const existing=await IK.Store.all();const counts={};for(const r of existing)counts[r.module]=(counts[r.module]||0)+1;
   const inserts=[];
   for(const [module,target] of Object.entries(moduleTargets)){
    const need=Math.max(0,target-(counts[module]||0));
    for(let i=0;i<need;i++)inserts.push({module,values:makeRow(module,i+(counts[module]||0)),source,updated:new Date().toISOString()});
   }
   // Seed only missing records; never delete or overwrite user records.
   if(inserts.length)await IK.Store.transaction(['rows'],'readwrite',tx=>{const s=tx.objectStore('rows');inserts.forEach(r=>s.add(r))});
   seeded=true;await IK.Controller.refresh();
   console.info('[i-Kainks PATCH022] Base enrichie',inserts.length,'lignes, images SVG locales',catalog.length);
  }catch(e){console.error('[PATCH022] Initialisation démo',e)}finally{busy=false}
 }
 function mobileHome(){
  const content=$('#content');if(!content||!isMobile()||active!=='dashboard')return;
  const rows=IK.Model.by('articles').slice(0,12),cats=[...new Set(catalog.map(p=>p.category))].slice(0,8);
  const user=$('#sessionName')?.textContent||'Équipe';
  content.innerHTML=`<section class="mobile-welcome"><div class="mobile-greet"><span>Bonjour, ${escape(user)} 👋</span><h1>Votre quincaillerie<br>au quotidien</h1><p>Gérez vos produits, ventes et stocks en un geste.</p></div><div class="welcome-circle">▤</div></section>
  <div class="mobile-search"><span>⌕</span><input id="mobileProductSearch" placeholder="Rechercher un article…" aria-label="Rechercher un article"><button id="mobileSearchGo">⌕</button></div>
  <div class="mobile-section-title"><h2>Catégories</h2><button id="allCategories">Voir tout</button></div><div class="category-grid">${cats.map((c,i)=>`<button data-category="${escape(c)}"><img src="assets/products/IK-${String(i+1).padStart(4,'0')}.svg" alt="${escape(c)}"><span>${escape(c)}</span></button>`).join('')}</div>
  <section class="mobile-offer"><div><small>VOTRE ACTIVITÉ</small><h2>Suivi en temps réel</h2><p>${IK.Model.by('ventes').length} ventes · ${IK.Model.by('articles').length} articles</p><button id="offerSales">Voir les ventes →</button></div><div class="offer-icon">◈</div></section>
  <div class="mobile-section-title"><h2>Produits populaires</h2><button id="allProducts">Voir tout</button></div><div class="product-grid">${rows.map((r,i)=>`<article class="product-tile">${img(r,'product-photo')}<div class="product-info"><strong>${escape(r.values.Désignation)}</strong><span>${money(r.values['Prix vente'])}</span><small>Stock : ${escape(r.values.Stock)}</small></div><button class="product-plus" data-prod="${escape(r.values.Désignation)}" title="Voir les produits">+</button></article>`).join('')}</div>
  <div class="mobile-section-title"><h2>Actions rapides</h2></div><div class="mobile-shortcuts"><button data-shortcut="ventes">◈<span>Nouvelle vente</span></button><button data-shortcut="achats">↙<span>Achats</span></button><button data-shortcut="inventaires">▤<span>Inventaire</span></button></div>`;
  $('#mobileProductSearch').onkeydown=e=>{if(e.key==='Enter')IK.Controller.navigate('articles')};$('#mobileSearchGo').onclick=()=>IK.Controller.navigate('articles');
  $('#allCategories').onclick=()=>IK.Controller.navigate('categories');$('#allProducts').onclick=()=>IK.Controller.navigate('articles');$('#offerSales').onclick=()=>IK.Controller.navigate('ventes');
  content.querySelectorAll('[data-category]').forEach(b=>b.onclick=()=>IK.Controller.navigate('articles'));
  content.querySelectorAll('[data-prod]').forEach(b=>b.onclick=()=>IK.Controller.navigate('articles'));
  content.querySelectorAll('[data-shortcut]').forEach(b=>b.onclick=()=>IK.Controller.navigate(b.dataset.shortcut));
 }
 function decorate(){
  const title=$('#screenTitle')?.textContent||'';active=Object.entries(labels).find(([,v])=>v===title)?.[0]||'dashboard';
  document.body.classList.toggle('ik-mobile',isMobile());
  document.querySelectorAll('#mobileBottom [data-mobile-go]').forEach(b=>b.classList.toggle('selected',b.dataset.mobileGo===active));
  if(isMobile()&&active==='dashboard'){mobileHome();return}
  if(active==='articles'){
   const table=$('#content .tablewrap table');if(table){
    const header=table.querySelector('thead tr');if(header&&!header.querySelector('.photo-col')){const th=document.createElement('th');th.className='photo-col';th.textContent='Photo';header.prepend(th)}
    const rows=IK.Model.filtered();const pageText=$('#content .pager span')?.textContent||'Page 1';const pg=Number(pageText.match(/Page\s+(\d+)/)?.[1]||1);const pageSize=table.querySelectorAll('tbody tr').length;
    table.querySelectorAll('tbody tr').forEach((tr,i)=>{const r=rows[(pg-1)*pageSize+i];if(r&&!tr.querySelector('.photo-cell')){const td=document.createElement('td');td.className='photo-cell';td.innerHTML=img(r);tr.prepend(td)}});
   }
   $('#content .mobilecards')?.querySelectorAll('.mobilecard').forEach((card,i)=>{if(card.querySelector('img'))return;const r=IK.Model.filtered()[i];if(r)card.insertAdjacentHTML('afterbegin',img(r,'mobile-product-thumb'))});
  }
 }
 const originalRender=IK.View.render.bind(IK.View);
 IK.View.render=function(){originalRender();if(!$('#app')?.hidden)decorate()};
 const originalList=IK.View.list.bind(IK.View);
 IK.View.list=function(){originalList();if(!$('#app')?.hidden)decorate()};
 const originalDash=IK.View.dashboard.bind(IK.View);
 IK.View.dashboard=function(report){originalDash(report);if(!$('#app')?.hidden)decorate()};
 document.querySelectorAll('#mobileBottom [data-mobile-go]').forEach(b=>b.onclick=()=>IK.Controller.navigate(b.dataset.mobileGo));
 window.addEventListener('resize',()=>{if(!$('#app')?.hidden)IK.View.render()});
 async function init(){try{const r=await fetch(catalogUrl,{cache:'no-cache'});if(!r.ok)throw Error('Catalogue manquant');catalog=await r.json();for(let i=0;i<80;i++){try{await IK.Store.all();break}catch{await new Promise(resolve=>setTimeout(resolve,100))}}await seed();IK.View.render()}catch(e){console.error('PATCH022',e)}}
 init();
})();
