(function(){'use strict';
 var key='ikainks_compact_mode_104_107';
 function init(){
  if(document.getElementById('ik-compact-toggle-104'))return;
  var enabled=false;
  try{enabled=localStorage.getItem(key)==='1'}catch(e){}
  document.body.classList.toggle('ik-compact-104',enabled);
  var b=document.createElement('button');b.type='button';b.id='ik-compact-toggle-104';
  b.setAttribute('aria-label','Activer ou desactiver l affichage compact');
  function label(){b.textContent=document.body.classList.contains('ik-compact-104')?'Affichage normal':'Affichage compact'}
  b.addEventListener('click',function(){var state=document.body.classList.toggle('ik-compact-104');try{localStorage.setItem(key,state?'1':'0')}catch(e){}label()});
  label();document.body.appendChild(b);
 }
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init,{once:true});else init();
})();
