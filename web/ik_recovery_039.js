/* i-Kaink's PATCH 039 - diagnostic within application iframe; no data modification. */
(function(){'use strict';
 const errors=[];const stamp=()=>new Date().toISOString();
 window.addEventListener('error',e=>{errors.push({at:stamp(),type:'error',message:String(e.message||''),source:String(e.filename||''),line:e.lineno||0});update();},true);
 window.addEventListener('unhandledrejection',e=>{errors.push({at:stamp(),type:'promise',message:String(e.reason&&e.reason.message||e.reason||'Promise rejected')});update();});
 const visible=el=>!!el&&!el.hidden&&getComputedStyle(el).display!=='none'&&el.getBoundingClientRect().width>0;
 function state(){const login=document.getElementById('login'),app=document.getElementById('app'),content=document.getElementById('content');return {at:stamp(),url:location.href,loginVisible:visible(login),appVisible:visible(app),contentCharacters:content?content.innerText.length:0,appExists:!!app,loginExists:!!login,scriptCount:document.scripts.length,errors:errors.slice(-30)};}
 let panel;
 function update(){if(!panel)return;const s=state(),bad=errors.length||(!s.loginVisible&&!s.appVisible);panel.querySelector('#ik039status').textContent=bad?'Attention : verifier le chargement':'Interface detectee';panel.querySelector('#ik039status').style.color=bad?'#fbbf24':'#86efac';}
 function save(){const blob=new Blob([JSON.stringify(state(),null,2)],{type:'application/json'}),a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='IKAINKS_DIAGNOSTIC_039_'+(window.innerWidth<600?'MOBILE':'PC')+'.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),2000);}
 function mount(){if(document.getElementById('ik039panel'))return;panel=document.createElement('aside');panel.id='ik039panel';panel.style.cssText='position:fixed;right:10px;bottom:10px;z-index:2147483647;background:#10283e;color:#fff;padding:10px 12px;border-radius:10px;box-shadow:0 5px 22px #0006;font:12px Arial,sans-serif;max-width:290px';panel.innerHTML='<div style="font-weight:bold">i-Kaink\'s · Verification 039</div><div id="ik039status" style="margin:5px 0">Analyse...</div><button id="ik039save" style="padding:6px 9px;cursor:pointer">Exporter diagnostic</button><button id="ik039hide" style="padding:6px 9px;cursor:pointer">Masquer</button>';document.body.appendChild(panel);panel.querySelector('#ik039save').addEventListener('click',save);panel.querySelector('#ik039hide').addEventListener('click',()=>panel.remove());update();}
 window.addEventListener('DOMContentLoaded',()=>setTimeout(mount,2500));
 window.addEventListener('message',e=>{if(e.origin===location.origin&&e.data==='IK039_STATE'&&e.source){e.source.postMessage({kind:'IK039_STATE_REPLY',payload:state()},e.origin);}});
})();
