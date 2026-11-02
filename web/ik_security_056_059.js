/* i-Kaink's pack 056-059: reference security rules, NOT connected to production auth. */
(function(root){
'use strict';
const roles = Object.freeze({
 admin:['articles.read','articles.write','sales.read','sales.create','stock.adjust','users.manage','reports.read','backup.export'],
 manager:['articles.read','articles.write','sales.read','sales.create','stock.adjust','reports.read'],
 cashier:['articles.read','sales.read','sales.create'],
 viewer:['articles.read','sales.read','reports.read']
});
const valid = /^[a-z]+\.[a-z]+$/;
function authorize(role,permission){return typeof permission==='string' && valid.test(permission) && Object.prototype.hasOwnProperty.call(roles,role) && roles[role].includes(permission);}
function validateAuditEvent(event){return !!event && typeof event==='object' && typeof event.action==='string' && valid.test(event.action) && typeof event.actor==='string' && event.actor.length>0 && typeof event.at==='string' && !Number.isNaN(Date.parse(event.at));}
function validateBackupEnvelope(obj){return !!obj && obj.format==='ikainks-reference-backup-v1' && Number.isInteger(obj.schemaVersion) && obj.schemaVersion>0 && typeof obj.exportedAt==='string' && !Number.isNaN(Date.parse(obj.exportedAt)) && Array.isArray(obj.records);}
root.IKSecurityReference056059=Object.freeze({roles,authorize,validateAuditEvent,validateBackupEnvelope});
if(typeof module!=='undefined' && module.exports)module.exports=root.IKSecurityReference056059;
})(typeof globalThis!=='undefined'?globalThis:this);
