/* PATCH 040 - non destructive boot recovery for the existing web prototype */
(function(){'use strict';
  const problems=[];const started=Date.now();let panel=null;
  function note(type,message){problems.push({at:new Date().toISOString(),type,message:String(message).slice(0,2000)});if(panel)update();}
  window.addEventListener('error',e=>note('javascript',e.message||'Erreur inconnue'),true);
  window.addEventListener('unhandledrejection',e=>note('promesse',e.reason&&e.reason.message||e.reason||'Rejet inconnu'));
  function state(){const login=document.getElementById('login'),app=document.getElementById('app');return {url:location.href,elapsedMs:Date.now()-started,loginExists:!!login,loginHidden:login?login.hidden:null,appExists:!!app,appHidden:app?app.hidden:null,contentChars:document.getElementById('content')?.innerText?.length||0,indexedDBAvailable:!!window.indexedDB,errors:problems};}
  function exportReport(){const blob=new Blob([JSON.stringify(state(),null,2)],{type:'application/json'});const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download='IKAINKS_ETAT_040.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),5000);}
  function update(){if(!panel)return;const s=state();panel.querySelector('[data-state]').textContent=(!s.loginHidden||!s.appHidden)?'Interface detectee':'Application non visible : diagnostic disponible';panel.querySelector('[data-detail]').textContent=problems.length+' erreur(s) JavaScript / promesses';}
  function show(){if(panel)return;const s=state();if(!s.loginHidden||!s.appHidden)return;
    panel=document.createElement('section');panel.id='ik-boot-040';panel.setAttribute('role','alert');panel.style.cssText='position:fixed;inset:0;z-index:2147483646;background:#edf3fa;color:#142b45;display:flex;align-items:center;justify-content:center;padding:24px;font:16px Segoe UI,Arial,sans-serif';
    const card=document.createElement('div');card.style.cssText='background:#fff;border-radius:18px;box-shadow:0 15px 55px #102b4a35;padding:30px;max-width:620px;width:100%;line-height:1.5';
    card.innerHTML='<h1 style="margin:0;color:#123c64">i-Kaink\'s — Recuperation du demarrage</h1><p data-state>Verification de l\'application...</p><p data-detail></p><p>Le chargement de la gestion commerciale ne s\'est pas termine. Vos donnees locales ne sont pas effacees.</p><div data-actions style="display:flex;flex-wrap:wrap;gap:10px"></div><small style="display:block;margin-top:18px">Prototype Web local : ne pas confondre avec l\'application Flutter Windows/Android.</small>';
    const actions=card.querySelector('[data-actions]');
    function btn(label,cb){const b=document.createElement('button');b.textContent=label;b.type='button';b.style.cssText='background:#1767a5;color:white;border:0;border-radius:9px;padding:11px 14px;cursor:pointer';b.addEventListener('click',cb);actions.appendChild(b)}
    btn('Exporter le diagnostic',exportReport);btn('Recharger',()=>location.reload());
    btn('Afficher la connexion',()=>{const login=document.getElementById('login'),app=document.getElementById('app');if(login){login.hidden=false;if(app)app.hidden=true;panel.remove();panel=null;note('action','Connexion affichee manuellement; initialisation BD non confirmee')}else note('action','Formulaire de connexion absent')});
    btn('Ouvrir sans apercu',()=>window.open(location.href,'_blank','noopener'));
    panel.appendChild(card);document.body.appendChild(panel);update();
  }
  window.addEventListener('DOMContentLoaded',()=>setTimeout(show,6500));
  window.addEventListener('load',()=>setTimeout(show,7500));
})();
