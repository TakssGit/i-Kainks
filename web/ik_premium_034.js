/* i-Kaink's PATCH 034 - optional UI enhancements, no database changes */
(function(){'use strict';
  if(window.__ik034Loaded)return;window.__ik034Loaded=true;
  function ready(){
    document.documentElement.dataset.ikPatch='034';
    document.querySelectorAll('button:not([type])').forEach(function(b){if(b.closest('form')&& !b.hasAttribute('data-submit'))b.setAttribute('type','button');});
    document.addEventListener('keydown',function(e){
      if(e.key==='Escape'){var d=document.querySelector('dialog[open]');if(d&&typeof d.close==='function')d.close();}
      if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){
        var s=document.getElementById('quickSearch');if(s&&!s.disabled){e.preventDefault();s.focus();s.select();}
      }
    });
    var main=document.querySelector('main');if(main&&!main.hasAttribute('tabindex'))main.setAttribute('tabindex','-1');
    var toast=document.getElementById('toast');if(toast){toast.setAttribute('role','status');toast.setAttribute('aria-live','polite');}
    console.info('[i-Kainks] PATCH 034 interface chargee. Aucune base de donnees modifiee.');
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',ready,{once:true});else ready();
})();
