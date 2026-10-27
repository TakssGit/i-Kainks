/* PATCH 018 : demo variable, identite, impressions, langues et themes.
 * Donnees FICTIVES uniquement. IndexedDB partage avec PATCH 015-017.
 */
'use strict';
(function(){
 const targets={articles:180,clients:100,fournisseurs:48,ventes:320,achats:145,devis:96,commandes:120,livraisons:88,retours:35,depenses:90,caisse:210,mouvements:175,depots:12,categories:28,reglements:165,inventaires:62,utilisateurs:16,taches:44,tarifs:72,credits:36,garanties:25,maintenance:30,audits:40};
 const sampleNames=['Ciment 50 kg','Fer rond 10 mm','Peinture blanche 4 L','Tuyau PVC 32 mm','Ampoule LED','Marteau','Carrelage 40x40','Robinet','Disjoncteur 20A','Serrure'];
 const people=['Rakoto','Rasoa','Rabe','Andry','Fara','Hery','Miora','Lova','Tiana','Noro','Mamy','Tahina'];
 const categories=['Cimenterie','Electricite','Plomberie','Peinture','Outillage','Construction','Quincaillerie'];
 const status=['Valide','En attente','Paye','Partiel','Livre','Actif'];
 const $id=id=>document.getElementById(id);
 const e=s=>esc(s);
 const moneyValue=(n)=>Number(n||0).toLocaleString('fr-FR')+' '+(state.settings.currency||'Ar');
 function getVal(m,i,f){
   const code=m.slice(0,3).toUpperCase()+'-'+String(i).padStart(5,'0');
   const day=new Date(Date.now()-(i*86400000)% (240*86400000)).toISOString().slice(0,10);
   const qty=1+(i*11)%90,price=2500+(i*1733)%190000;
   if(['Code','Reference','Référence','Numéro','Identifiant'].includes(f))return code;
   if(['Date','Validité','Échéance','Livraison prévue'].includes(f))return day;
   if(['Nom','Client','Tiers','Fournisseur','Responsable'].includes(f))return f==='Nom'&&m==='categories'?categories[i%categories.length]:f==='Nom'&&m==='depots'?'Dépôt '+i:people[i%people.length]+' '+people[(i*3+2)%people.length]+(f==='Fournisseur'?' Distribution':'');
   if(['Désignation','Article','Objet','Équipement'].includes(f))return sampleNames[i%sampleNames.length]+' '+i;
   if(f==='Catégorie')return categories[i%categories.length];
   if(f==='Statut')return status[i%status.length];
   if(f==='Quantité'||f==='Stock'||f==='Stock théorique'||f==='Stock compté')return String(qty);
   if(f==='Écart')return '0';
   if(f==='Seuil alerte')return String(5+i%10);
   if(f==='Prix achat')return String(Math.round(price*.7));
   if(['Prix vente','Prix','Prix unitaire'].includes(f))return String(price);
   if(['Montant','Coût','Plafond crédit'].includes(f))return String(qty*price);
   if(f==='Mode paiement')return ['Espèces','Mobile Money','Virement'][i%3];
   if(f==='Unité')return ['pièce','sac','mètre','kg'][i%4];
   if(f==='Téléphone')return '034 '+String(1000000+i).slice(0,2)+' '+String(1000000+i).slice(2,5)+' '+String(1000000+i).slice(5);
   if(f==='Email')return 'demo'+i+'@exemple.invalid';
   if(f==='Adresse')return ['Antananarivo','Antsirabe','Toamasina'][i%3]+', Madagascar';
   if(f==='Rôle')return ['Administrateur','Caissier','Magasinier'][i%3];
   if(f==='Type')return ['Entrée','Sortie'][i%2];
   if(f==='Dépôt')return 'Dépôt '+(i%12+1);
   if(f==='Notes')return 'EXEMPLE FICTIF PATCH018';
   return f+' de démonstration '+i;
 }
 async function installData(){
   if(!state.db){notify('Base non initialisée');return}
   const all=await listAll();const existing={};for(const r of all)existing[r.module]=(existing[r.module]||0)+1;
   const todo=[];for(const [m,target] of Object.entries(targets)){
     const deficit=Math.max(0,target-(existing[m]||0));
     for(let i=1;i<=deficit;i++){
       const n=(existing[m]||0)+i,values={};
       for(const f of defs[m])values[f]=getVal(m,n,f);
       todo.push({module:m,values,demoKey:'PATCH018:'+m+':'+n,updated:new Date().toISOString()});
     }
   }
   if(!todo.length){notify('Tous les objectifs de volumes sont déjà atteints.');return}
   if(!confirm('Ajouter '+todo.length+' lignes FICTIVES pour atteindre les volumes variables, sans effacer les données actuelles ?'))return;
   try{await new Promise((ok,fail)=>{const t=state.db.transaction('rows','readwrite');const s=t.objectStore('rows');todo.forEach(r=>s.add(r));t.oncomplete=ok;t.onerror=()=>fail(t.error);t.onabort=()=>fail(t.error)});signal();notify(todo.length+' exemples fictifs ajoutés');await render()}
   catch(ex){notify('Erreur : '+ex.message)}
 }
 async function erase018(){if(prompt('Supprimer seulement les exemples PATCH018 : tapez DEMO018')!=='DEMO018')return;const all=await listAll(),ids=all.filter(x=>String(x.demoKey||'').startsWith('PATCH018:')).map(x=>x.id);await new Promise((ok,fail)=>{const t=state.db.transaction('rows','readwrite'),s=t.objectStore('rows');ids.forEach(id=>s.delete(id));t.oncomplete=ok;t.onerror=()=>fail(t.error)});signal();notify(ids.length+' lignes fictives supprimées');render()}
 const defaults={company:'i-Kaink’s',legal:'Quincaillerie générale',address:'Antananarivo, Madagascar',phone:'',nif:'',stat:'',rcs:'',footer:'Merci pour votre confiance',language:'FR',theme018:'Clair',printFormat:'A4',printOrientation:'portrait',printHeader:'Oui',printFooter:'Oui',operator:'Administrateur'};
 let cfg={...defaults};
 const words={FR:{title:'Données de démonstration variables',print:'Imprimer la page',receipt:'Imprimer document',save:'Enregistrer les paramètres',identity:'Identité et personnalisation'},EN:{title:'Variable sample data',print:'Print page',receipt:'Print document',save:'Save settings',identity:'Business identity and preferences'},ML:{title:'Angona santionany miovaova',print:'Atao pirinty ny pejy',receipt:'Atao pirinty ny taratasy',save:'Tehirizo ny fikirana',identity:'Mombamomba ny orinasa sy ny fikirana'}};
 function tr(key){return (words[cfg.language]||words.FR)[key]||words.FR[key]}
 function apply(){document.documentElement.lang=cfg.language==='ML'?'mg':cfg.language.toLowerCase();document.body.classList.toggle('ikdark018',cfg.theme018==='Sombre');document.body.classList.toggle('ikblue018',cfg.theme018==='Bleu');document.documentElement.style.setProperty('--ik-print-orientation',cfg.printOrientation);document.title=cfg.company+' · i-Kaink’s';const brand=document.querySelector('.logo');if(brand)brand.innerHTML='▣ '+e(cfg.company)+'<small>'+e(cfg.legal)+'</small>'}
 function printDoc(){const all=document.querySelector('#content');if(!all)return;const w=window.open('','_blank');if(!w){notify('Autorisez les fenêtres pour imprimer');return}const table=all.querySelector('table');const header='<h1>'+e(cfg.company)+'</h1><p>'+e(cfg.legal)+' · '+e(cfg.address)+' · '+e(cfg.phone)+'</p><p>NIF : '+e(cfg.nif)+' · STAT : '+e(cfg.stat)+' · RCS : '+e(cfg.rcs)+'</p>';
   const body=table?table.outerHTML:all.innerHTML;
   const styles='<style>@page{size:'+e(cfg.printFormat)+' '+e(cfg.printOrientation)+';margin:12mm}body{font:12px Arial;color:#172d42}h1{margin-bottom:2px}table{width:100%;border-collapse:collapse}td,th{border:1px solid #aaa;padding:5px}button,input,select,.filters,.actions,.pagination,.cellactions{display:none!important}th:last-child,td:last-child{display:none!important}</style>';
   w.document.write('<!doctype html><html><head><meta charset="utf-8"><title>Impression i-Kainks</title>'+styles+'</head><body>'+(cfg.printHeader==='Oui'?header:'')+'<h2>'+e(labels[state.module]||'Document')+'</h2>'+body+(cfg.printFooter==='Oui'?'<footer><hr>'+e(cfg.footer)+'</footer>':'')+'</body></html>');w.document.close();w.focus();setTimeout(()=>w.print(),350)
 }
 function extraPanel(){const panel=document.createElement('section');panel.className='panel ik018';const count=Object.values(targets).reduce((a,b)=>a+b,0);panel.innerHTML='<h2>'+e(tr('title'))+'</h2><p class="muted">Objectifs de volume par gestion : '+count+' lignes au total, en tenant compte des lignes existantes. Les données ne sont jamais remplacées automatiquement.</p><div class="ik018-counts">'+Object.entries(targets).map(([m,n])=>'<span>'+e(labels[m]||m)+' <b>'+n+'</b></span>').join('')+'</div><div class="actions"><button id="ik018seed" class="primary">Remplir les volumes manquants</button><button id="ik018clear" class="danger">Supprimer les exemples PATCH018</button><button id="ik018print">'+e(tr('print'))+'</button><button id="ik018doc">'+e(tr('receipt'))+'</button></div>';
   $id('content').prepend(panel);$id('ik018seed').onclick=installData;$id('ik018clear').onclick=erase018;$id('ik018print').onclick=()=>window.print();$id('ik018doc').onclick=printDoc;
 }
 function configPanel(){const panel=document.createElement('section');panel.className='panel ik018';const fields=[['company','Nom entreprise'],['legal','Activité'],['address','Adresse'],['phone','Téléphone'],['nif','NIF'],['stat','STAT'],['rcs','RCS'],['operator','Utilisateur / opérateur'],['footer','Pied de page impression']];panel.innerHTML='<h2>'+e(tr('identity'))+'</h2><div class="settingsgrid">'+fields.map(([k,label])=>'<label>'+label+'<input data-ik018="'+k+'" value="'+e(cfg[k])+'"></label>').join('')+'<label>Langue / Language / Fiteny<select data-ik018="language">'+['FR','EN','ML'].map(x=>'<option '+(cfg.language===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label><label>Thème<select data-ik018="theme018">'+['Clair','Sombre','Bleu'].map(x=>'<option '+(cfg.theme018===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label><label>Format impression<select data-ik018="printFormat">'+['A4','A5','Letter'].map(x=>'<option '+(cfg.printFormat===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label><label>Orientation<select data-ik018="printOrientation">'+['portrait','landscape'].map(x=>'<option '+(cfg.printOrientation===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label><label>En-tête impression<select data-ik018="printHeader">'+['Oui','Non'].map(x=>'<option '+(cfg.printHeader===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label><label>Pied de page<select data-ik018="printFooter">'+['Oui','Non'].map(x=>'<option '+(cfg.printFooter===x?'selected':'')+'>'+x+'</option>').join('')+'</select></label></div><p><button class="primary" id="ik018save">'+e(tr('save'))+'</button></p><p class="muted">Langues FR/EN/ML : commandes principales de ce panneau traduites ; les formulaires historiques restent en français. Les comptes sont des fiches de démonstration, sans authentification.</p>';
 $id('content').prepend(panel);$id('ik018save').onclick=async()=>{panel.querySelectorAll('[data-ik018]').forEach(el=>cfg[el.dataset.ik018]=el.value);await tx('config','readwrite',s=>s.put({key:'settings018',value:cfg}));apply();signal();notify('Paramètres enregistrés');render()};
 }
 const originalRender=render;
 render=async function(){await originalRender();if(!state.db)return;if(state.module==='settings')configPanel();else if(state.module==='dashboard'||state.module==='rapports')extraPanel();const btn=document.querySelector('#ik018quickprint');if(!btn){const el=document.createElement('button');el.id='ik018quickprint';el.textContent='🖨 '+tr('print');el.onclick=printDoc;document.querySelector('.top')?.appendChild(el)}};
 const originalStart=start;
 // start() was called in the base script before this module loads. Load config independently.
 (async()=>{for(let n=0;n<50&&!state.db;n++)await new Promise(r=>setTimeout(r,100));if(!state.db)return;try{const saved=await tx('config','readonly',s=>s.get('settings018'));if(saved?.value)cfg={...cfg,...saved.value};apply();await render()}catch(err){console.warn('Configuration 018',err)}})();
 const style=document.createElement('style');style.textContent='.ik018-counts{display:flex;flex-wrap:wrap;gap:7px;margin:15px 0}.ik018-counts span{border-radius:9px;background:#e8f0f9;padding:7px 10px;font-size:12px}.ik018-counts b{margin-left:7px;color:#0a5b9a}.ikdark018{background:#111a29!important;color:#e9f1fb!important}.ikdark018 .workspace,.ikdark018 .panel,.ikdark018 .metric,.ikdark018 .mobilecards article{background:#1c2b3d!important;color:#f1f6ff!important}.ikdark018 .muted{color:#c7d3e1!important}.ikblue018 .top{background:#cfe6ff}.ikdark018 .ik018-counts span{background:#29405b;color:#fff}@media print{.sidebar,.top,.actions,.filters,.cellactions,.pagination,#toast,#ik018quickprint{display:none!important}.workspace{margin:0!important;width:100%!important}.panel{box-shadow:none!important;border:0!important}body{background:white!important;color:black!important}}';document.head.appendChild(style);
})();
