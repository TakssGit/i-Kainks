/* i-Kaink's PATCH 033: diagnostics non destructifs */
(function () {
  'use strict';
  if (window.__ikDiagnostic033) return;
  window.__ikDiagnostic033 = true;
  var events = [], max = 100;
  function record(kind, message) {
    events.push({time: new Date().toISOString(), type: kind, message: String(message || '')});
    if (events.length > max) events.shift();
    update();
  }
  function update() {
    var count = document.getElementById('ik033-count');
    if (count) count.textContent = String(events.length);
  }
  window.addEventListener('error', function (e) {
    if (e.target && e.target !== window) {
      record('resource', (e.target.tagName || 'element') + ' ' + (e.target.src || e.target.href || 'unknown'));
    } else record('javascript', (e.message || 'error') + ' ' + (e.filename || '') + ':' + (e.lineno || ''));
  }, true);
  window.addEventListener('unhandledrejection', function (e) {
    record('promise', e.reason && (e.reason.stack || e.reason.message) || String(e.reason));
  });
  function render() {
    if (document.getElementById('ik033-panel')) return;
    var p = document.createElement('div');
    p.id = 'ik033-panel';
    p.style.cssText = 'position:fixed;bottom:12px;right:12px;z-index:2147483647;font:13px Arial,sans-serif;background:#11283f;color:#fff;padding:10px;border-radius:10px;box-shadow:0 3px 15px #0006;max-width:min(360px,90vw)';
    var title = document.createElement('div'); title.textContent = 'i-Kaink\'s - Diagnostic PATCH 033'; title.style.fontWeight = 'bold';
    var status = document.createElement('div'); status.style.margin = '6px 0';
    status.appendChild(document.createTextNode('Erreurs detectees : '));
    var count = document.createElement('strong'); count.id='ik033-count'; count.textContent=String(events.length); status.appendChild(count);
    var copy = document.createElement('button'); copy.type='button'; copy.textContent='Copier le diagnostic'; copy.style.cssText='padding:7px;margin-right:5px;cursor:pointer';
    copy.addEventListener('click', function () {
      var report = JSON.stringify({url:location.href, userAgent:navigator.userAgent, time:new Date().toISOString(), events:events}, null, 2);
      if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(report).then(function(){copy.textContent='Copie OK';}).catch(function(){window.prompt('Copiez le diagnostic',report);});
      else window.prompt('Copiez le diagnostic', report);
    });
    var toggle = document.createElement('button'); toggle.type='button'; toggle.textContent='Masquer'; toggle.style.cssText='padding:7px;cursor:pointer';
    toggle.addEventListener('click', function(){p.style.display='none'; var b=document.createElement('button');b.textContent='Diagnostic';b.style.cssText='position:fixed;bottom:12px;right:12px;z-index:2147483647;padding:8px';b.onclick=function(){p.style.display='block';b.remove();};document.body.appendChild(b);});
    p.appendChild(title);p.appendChild(status);p.appendChild(copy);p.appendChild(toggle);document.body.appendChild(p);
    if (!document.querySelector('main, #app, #root, [data-app]')) record('information','Aucun conteneur applicatif standard detecte (peut etre normal)');
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', render);
  else render();
})();
