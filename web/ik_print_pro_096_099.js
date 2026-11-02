/* i-Kaink's print chrome — no business-data writes. */
(function(){
  'use strict';
  if(window.__ikPrintPro096) return;
  window.__ikPrintPro096=true;
  const settings=Object.freeze({company:"i-Kaink's", footer:"Document commercial", version:"096-099"});
  function clean(s){return String(s||'').replace(/[<>\u0000-\u001f]/g,'').slice(0,100)}
  function make(tag,cls,text){const e=document.createElement(tag);e.className=cls;e.textContent=clean(text);return e}
  function title(){
    const el=document.querySelector('[data-print-title],.print-title,h1');
    return clean(el?.textContent||document.title||'Document');
  }
  function ensure(){
    if(!document.body) return;
    if(!document.querySelector('.ik-print-header')){
      const h=make('div','ik-print-header','');
      h.append(make('strong','ik-print-brand',settings.company),make('span','ik-print-document-title',title()));
      document.body.prepend(h);
    }
    if(!document.querySelector('.ik-print-footer')){
      const f=make('div','ik-print-footer','');
      f.append(make('span','ik-print-footer-label',settings.footer),make('span','ik-page-number','Page '));
      document.body.append(f);
    }
    const label=document.querySelector('.ik-print-document-title');
    if(label)label.textContent=title();
  }
  document.addEventListener('DOMContentLoaded',ensure,{once:true});
  window.addEventListener('beforeprint',ensure);
  if(document.readyState!=='loading')ensure();
  window.IKPrintPro={refresh:ensure,settings:settings};
})();
