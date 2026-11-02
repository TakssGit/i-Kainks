const {test}=require('node:test');
const assert=require('node:assert/strict');
const tx=require('../web/ik_transactions_052_055.js');
const sale=()=>tx.transact(tx.create({article:3}),{key:'sale',type:'sale',product:'article',quantity:1,unitPrice:200000}).state;
test('paiement partiel 200000 - 75000 = 125000, puis règlement',()=>{
 const initial=sale();
 const first=tx.pay(initial,{key:'pay',saleKey:'sale',amount:75000});
 assert.equal(first.balance,125000);assert.equal(initial.payments.length,0);
 assert.equal(tx.pay(first.state,{key:'pay',saleKey:'sale',amount:75000}).status,'duplicate');
 assert.equal(first.state.payments.length,1);
 assert.equal(tx.pay(first.state,{key:'final',saleKey:'sale',amount:125000}).balance,0);
 assert.throws(()=>tx.pay(first.state,{key:'over',saleKey:'sale',amount:125001}));
});
test('stock déduit une fois, entrée et absence de mutation sur erreur',()=>{
 const state=sale();assert.equal(state.stock.article,2);
 assert.equal(tx.transact(state,{key:'sale'}).status,'duplicate');
 const before=JSON.stringify(state);
 assert.throws(()=>tx.transact(state,{key:'bad',type:'sale',product:'article',quantity:3,unitPrice:10}));
 assert.equal(JSON.stringify(state),before);
 assert.equal(tx.transact(state,{key:'in',type:'receipt',product:'article',quantity:4}).state.stock.article,6);
});
test('débordements et identifiants dangereux refusés sans mutation',()=>{
 const state=tx.create({article:Number.MAX_SAFE_INTEGER});
 assert.throws(()=>tx.transact(state,{key:'in',type:'receipt',product:'article',quantity:1}));
 assert.equal(state.stock.article,Number.MAX_SAFE_INTEGER);
 for(const product of ['__proto__','constructor','prototype']){
  assert.throws(()=>tx.create(JSON.parse(`{"${product}":1}`)));
  assert.throws(()=>tx.transact(tx.create(),{key:'in',type:'receipt',product,quantity:1}));
 }
 assert.throws(()=>tx.create({' article ':1}));
});
test('devis exact, entrées invalides et dépassement monétaire',()=>{
 assert.equal(tx.quote([{product:'a',quantity:3,unitPrice:75000}]).total,225000);
 for(const amount of [-1,NaN,Infinity,0.1]) assert.throws(()=>tx.quote([{product:'a',quantity:1,unitPrice:amount}]));
 assert.throws(()=>tx.quote([{product:'a',quantity:2,unitPrice:Number.MAX_SAFE_INTEGER}]));
});
