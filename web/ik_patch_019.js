/* PATCH 019 - Extensions d'ecrans et ameliorations UX. Donnees de DEMONSTRATION. */
'use strict';
(function(){
const extraDefs={"factures": ["Numéro", "Date", "Client", "Commande", "Montant", "TVA", "Total TTC", "Échéance", "Statut", "Notes"], "avoirs": ["Numéro", "Date", "Facture", "Client", "Motif", "Montant", "Statut", "Notes"], "bons_reception": ["Numéro", "Date", "Fournisseur", "Commande", "Dépôt", "Article", "Quantité", "Statut", "Notes"], "bons_sortie": ["Numéro", "Date", "Client", "Dépôt", "Article", "Quantité", "Motif", "Statut", "Notes"], "transferts": ["Référence", "Date", "Article", "Dépôt source", "Dépôt destination", "Quantité", "Statut", "Notes"], "prix": ["Code", "Article", "Catégorie", "Prix achat", "Prix vente", "Marge", "Date", "Statut"], "codes_barres": ["Code", "Article", "Code-barres", "Unité", "Statut", "Notes"], "alertes": ["Référence", "Date", "Type", "Article", "Niveau", "Responsable", "Statut", "Notes"], "budgets": ["Référence", "Date", "Centre de coût", "Catégorie", "Budget", "Réalisé", "Écart", "Statut", "Notes"], "taxes": ["Référence", "Date", "Type taxe", "Base", "Taux", "Montant", "Statut", "Notes"], "roles": ["Code", "Nom", "Description", "Permissions", "Statut"], "journaux": ["Référence", "Date", "Utilisateur", "Action", "Module", "Détail", "Statut"], "sauvegardes": ["Référence", "Date", "Type", "Fichier", "Responsable", "Statut", "Notes"], "contacts": ["Code", "Nom", "Organisation", "Fonction", "Téléphone", "Email", "Statut", "Notes"], "objectifs": ["Référence", "Date", "Période", "Responsable", "Indicateur", "Objectif", "Réalisé", "Statut"], "points_vente": ["Code", "Nom", "Adresse", "Responsable", "Téléphone", "Statut", "Notes"]};
const extraLabels={"factures": "Factures", "avoirs": "Avoirs", "bons_reception": "Bons de réception", "bons_sortie": "Bons de sortie", "transferts": "Transferts entre dépôts", "prix": "Grilles de prix", "codes_barres": "Codes-barres", "alertes": "Alertes et notifications", "budgets": "Budgets", "taxes": "Taxes", "roles": "Rôles et permissions", "journaux": "Journal des opérations", "sauvegardes": "Historique des sauvegardes", "contacts": "Contacts", "objectifs": "Objectifs commerciaux", "points_vente": "Points de vente"};
Object.assign(defs,extraDefs);Object.assign(labels,extraLabels);
for(const key of Object.keys(extraDefs))icons[key]='▣';
const families=[['Pilotage',['dashboard','rapports','objectifs','alertes']],['Commercial',['articles','ventes','devis','commandes','factures','avoirs','clients','tarifs','prix','codes_barres','credits']],['Approvisionnement',['fournisseurs','achats','bons_reception','livraisons','retours']],['Stocks & logistique',['categories','depots','points_vente','mouvements','transferts','bons_sortie','inventaires']],['Finance',['caisse','reglements','depenses','budgets','taxes']],['Administration',['utilisateurs','roles','contacts','taches','maintenance','garanties','audits','journaux','sauvegardes','settings']]];
const navRoot=document.getElementById('nav');
const originalNav=nav;
nav=function(){
 navRoot.innerHTML=families.map(([family,keys])=>`<div class="ik-nav-family"><span>${esc(family)}</span>${keys.filter(k=>labels[k]).map(k=>`<button type="button" data-module="${k}" class="${state.module===k?'active':''}"><span class="ik-nav-icon">${icons[k]||'▣'}</span>${esc(labels[k])}</button>`).join('')}</div>`).join('');
 navRoot.querySelectorAll('button[data-module]').forEach(b=>b.addEventListener('click',()=>switchTo(b.dataset.module)));
};
const top=document.querySelector('.top');
if(top){
 const search=document.createElement('div');search.className='ik-global-actions';
 search.innerHTML='<button id="ikQuick" type="button" title="Acces rapide (Ctrl+K)">⌕ &nbsp;Accès rapide <kbd>Ctrl K</kbd></button><button id="ikTheme" type="button" title="Basculer clair / sombre">◐</button>';
 top.insertBefore(search,document.getElementById('dbStatus'));
}
const popup=document.createElement('dialog');popup.id='ikQuickDialog';popup.innerHTML='<div class="ik-quick"><div class="row"><strong>Accès rapide aux fenêtres</strong><button type="button" id="ikCloseQuick">✕</button></div><input id="ikQuickFilter" autocomplete="off" placeholder="Rechercher une gestion, une fenêtre…"><div id="ikQuickList"></div></div>';document.body.appendChild(popup);
function showQuick(){document.getElementById('ikQuickFilter').value='';renderQuick('');popup.showModal();document.getElementById('ikQuickFilter').focus()}
function renderQuick(q){const needle=q.toLocaleLowerCase();document.getElementById('ikQuickList').innerHTML=Object.entries(labels).filter(([k,v])=>v.toLocaleLowerCase().includes(needle)||k.includes(needle)).map(([k,v])=>`<button type="button" data-go="${k}">${icons[k]||'▣'} &nbsp;${esc(v)}</button>`).join('')||'<p>Aucun résultat</p>';document.querySelectorAll('[data-go]').forEach(b=>b.onclick=()=>{popup.close();switchTo(b.dataset.go)})}
document.getElementById('ikQuick').onclick=showQuick;
document.getElementById('ikCloseQuick').onclick=()=>popup.close();
document.getElementById('ikQuickFilter').oninput=e=>renderQuick(e.target.value);
document.addEventListener('keydown',e=>{if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){e.preventDefault();showQuick()}if(e.key==='Escape'&&document.querySelector('.sidebar.open'))document.querySelector('.sidebar').classList.remove('open')});
function setTheme(){const v=localStorage.getItem('ik019_theme')==='dark'?'dark':'light';document.body.classList.toggle('ik-dark',v==='dark')}
document.getElementById('ikTheme').onclick=()=>{localStorage.setItem('ik019_theme',document.body.classList.contains('ik-dark')?'light':'dark');setTheme()};setTheme();
// Donnees fictives pour les NOUVEAUX modules, sans toucher aux modules existants.
const demoCounts={factures:230,avoirs:27,bons_reception:115,bons_sortie:92,transferts:44,prix:180,codes_barres:180,alertes:38,budgets:24,taxes:40,roles:7,journaux:250,sauvegardes:15,contacts:90,objectifs:32,points_vente:6};
const people=['Rakoto','Rasoa','Andry','Miora','Lova','Fara','Hery','Noro'];
const items=['Ciment 50 kg','Fer 10 mm','Tuyau PVC','Peinture 4 L','Serrure','Carrelage','Ampoule LED','Robinet'];
function demoValue(k,f,i){const code=k.slice(0,3).toUpperCase()+'-'+String(i).padStart(5,'0');const date=new Date(Date.now()-(i*86400000)% (220*86400000)).toISOString().slice(0,10);const amount=12000+(i*3947)%980000;
 if(/^(Code|Référence|Numéro|Code-barres)$/.test(f))return code;
 if(/Date|Échéance/.test(f))return date;
 if(/Article/.test(f))return items[i%items.length];
 if(/Client|Fournisseur|Utilisateur|Responsable|Nom|Organisation/.test(f))return people[i%people.length]+' '+people[(i+3)%people.length];
 if(/Montant|Budget|Réalisé|Objectif|Prix|Base|Marge|Écart|Total TTC/.test(f))return String(amount);
 if(/Quantité|Taux/.test(f))return String(1+i%30);
 if(f==='Statut')return ['Actif','Validé','En attente','Terminé'][i%4];
 if(f==='Dépôt source')return 'Dépôt central';if(f==='Dépôt destination')return 'Dépôt secondaire';
 if(f==='Email')return 'contact'+i+'@exemple.invalid';if(f==='Téléphone')return '034 00 '+String(10000+i).slice(-5);
 if(f==='Adresse')return 'Antananarivo, Madagascar';if(f==='Période')return '2026-T'+(1+i%4);
 return f+' exemple '+i;
}
async function seedNew(){if(!state.db){notify('Base indisponible');return}const all=await listAll();const counts={};for(const r of all)counts[r.module]=(counts[r.module]||0)+1;const pending=[];for(const [k,target] of Object.entries(demoCounts)){for(let i=(counts[k]||0)+1;i<=target;i++){const values={};for(const f of defs[k])values[f]=demoValue(k,f,i);pending.push({module:k,values,demoKey:'PATCH019:'+k+':'+i,updated:new Date().toISOString()})}}
 if(!pending.length){notify('Tous les nouveaux modules ont leurs exemples');return}if(!confirm('Ajouter '+pending.length+' exemples FICTIFS dans les nouveaux modules ?'))return;
 try{for(let n=0;n<pending.length;n+=150){const batch=pending.slice(n,n+150);await new Promise((ok,fail)=>{const t=state.db.transaction('rows','readwrite'),s=t.objectStore('rows');for(const r of batch)s.add(r);t.oncomplete=ok;t.onerror=()=>fail(t.error);t.onabort=()=>fail(t.error)})}signal();notify(pending.length+' exemples créés');render()}catch(e){notify('Erreur de génération : '+e.message)}
}
const action=document.createElement('div');action.className='ik-demo-banner';action.innerHTML='<div><strong>PATCH 019 · Espace de gestion étendu</strong><small>Fenêtres accessibles depuis le menu · Démonstration IndexedDB · PC et mobile</small></div><button id="ikSeedNew" type="button">+ Remplir les nouvelles gestions</button>';
const workspace=document.querySelector('.workspace');workspace.insertBefore(action,document.getElementById('content'));
document.getElementById('ikSeedNew').onclick=seedNew;
const help=document.createElement('button');help.className='ik-floating-help';help.textContent='?';help.title='Aide et raccourcis';help.onclick=()=>alert('i-Kaink’s — Prototype Web\nCtrl+K : accès rapide\n☰ : menu mobile\nAjout / modification : formulaires des tableaux\nSauvegardes : Paramètres\nDonnées fictives : bouton Remplir les nouvelles gestions\nLes données sont locales à Chrome, non synchronisées avec Flutter Windows.');document.body.appendChild(help);
nav();
})();
