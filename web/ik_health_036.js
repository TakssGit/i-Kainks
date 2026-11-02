/* i-Kaink's PATCH 036 - diagnostic non destructif */
(function () {
  'use strict';
  var failures = [], started = Date.now();
  function add(kind, message) { failures.push({time:new Date().toISOString(),type:kind,message:String(message).slice(0,600)}); }
  window.addEventListener('error',function(e){ add('error',e.message || (e.target && e.target.src) || 'Erreur inconnue'); },true);
  window.addEventListener('unhandledrejection',function(e){ add('promise', e.reason && (e.reason.stack || e.reason.message) || String(e.reason)); });
  function check() {
    var scripts=[].slice.call(document.querySelectorAll('script[src]')).map(function(s){return s.getAttribute('src');});
    var styles=[].slice.call(document.querySelectorAll('link[rel="stylesheet"][href]')).map(function(s){return s.getAttribute('href');});
    var main=document.querySelector('main,#root,#app,[role="main"]');
    var text=(document.body && document.body.innerText || '').trim();
    var report={page:location.href,at:new Date().toISOString(),elapsed_ms:Date.now()-started,title:document.title,readyState:document.readyState,mainFound:!!main,bodyTextLength:text.length,scriptSources:scripts,styleSources:styles,errors:failures,notice:'Un code HTTP 200 ne garantit pas que l application est rendue.'};
    var status=document.getElementById('ik-health-036-status');
    if(status){status.textContent='Etat : '+(failures.length?'erreurs detectees ('+failures.length+')':'aucune erreur JS interceptee')+' | texte visible : '+text.length+' caracteres';}
    return report;
  }
  function makePanel(){
    if(document.getElementById('ik-health-036'))return;
    var el=document.createElement('aside');el.id='ik-health-036';el.setAttribute('aria-label','Diagnostic i-Kainks');
    el.style.cssText='position:fixed;left:12px;bottom:12px;z-index:2147483647;background:#11233c;color:white;padding:12px;border:1px solid #d6ae55;border-radius:12px;max-width:340px;font:12px/1.45 Arial,sans-serif;box-shadow:0 6px 25px #0005';
    var h=document.createElement('strong');h.textContent='i-Kaink\u2019s | Diagnostic 036';el.appendChild(h);
    var p=document.createElement('p');p.id='ik-health-036-status';p.textContent='Verification en cours';el.appendChild(p);
    var b=document.createElement('button');b.textContent='Copier le rapport';b.style.cssText='padding:7px 10px;cursor:pointer;background:#e5b858;border:0;border-radius:6px;color:#102139';
    b.addEventListener('click',function(){var s=JSON.stringify(check(),null,2);if(navigator.clipboard && navigator.clipboard.writeText){navigator.clipboard.writeText(s).then(function(){b.textContent='Rapport copie';},function(){window.prompt('Copiez ce diagnostic :',s);});}else{window.prompt('Copiez ce diagnostic :',s);}});el.appendChild(b);
    var close=document.createElement('button');close.textContent='Masquer';close.style.cssText='margin-left:7px;padding:7px;cursor:pointer';close.addEventListener('click',function(){el.remove();});el.appendChild(close);
    document.body.appendChild(el);check();
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',makePanel);else makePanel();
  setTimeout(check,1500);
  window.ikHealth036=check;
})();
