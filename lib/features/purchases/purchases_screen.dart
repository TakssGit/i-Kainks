import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Achats locaux. Les réceptions sont idempotentes via la clé de transaction.
/// Ne modifie pas les achats historiques stockés par les anciens modules.
class PurchasesProScreen extends StatefulWidget {
  const PurchasesProScreen({super.key, this.onChanged});
  final VoidCallback? onChanged;
  @override
  State<PurchasesProScreen> createState() => _PurchasesProScreenState();
}

class _PurchasesProScreenState extends State<PurchasesProScreen> {
  static const String _ordersKey = 'ikainks_v007_purchase_orders';
  static const String _articlesKey = 'ikainks_v005_articles';
  static const String _movesKey = 'ikainks_v006_stock_movements';
  static const String _pendingKey = 'ikainks_v007_purchase_pending';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _articles = [];
  bool _busy = true;
  bool _locked = false;
  String? _recoveryError;
  String _filter = 'Tous';
  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();
  double _num(dynamic x) => x is num ? x.toDouble() : double.tryParse('$x'.replaceAll(',', '.')) ?? 0;
  List<Map<String, dynamic>> _parse(String? s) {
    if (s == null || s.isEmpty) return [];
    return (jsonDecode(s) as List).map((x) => Map<String, dynamic>.from(x as Map)).toList();
  }
  void _toast(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }
  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      await _recover(p);
      if (!mounted) return;
      setState(() { _orders = _parse(p.getString(_ordersKey)); _articles = _parse(p.getString(_articlesKey)); _busy = false; _recoveryError = null; });
    } catch (e) { if (mounted) { setState(() { _busy = false; _recoveryError = '$e'; }); _toast('Lecture impossible : $e'); } }
  }
  // En cas d'arrêt entre deux écritures, une opération en attente est rejouée
  // uniquement si son identifiant n'est pas déjà dans le journal des mouvements.
  Future<void> _recover(SharedPreferences p) async {
    final raw = p.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return;
    final tx = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final id = '${tx['id']}';
    final orders = _parse(p.getString(_ordersKey));
    final articles = _parse(p.getString(_articlesKey));
    final moves = _parse(p.getString(_movesKey));
    final existing = moves.any((m) => '${m['purchaseTx'] ?? ''}' == id);
    if (!existing) {
      final index = articles.indexWhere((a) => '${a['id']}' == '${tx['articleId']}');
      if (index < 0) throw StateError('Réception en attente: article introuvable. Restauration manuelle requise.');
      final article = articles[index];
      final before = _num(article['qty']);
      final qty = _num(tx['qty']);
      if (qty <= 0 || !qty.isFinite) throw StateError('Quantité de réception invalide');
      // La valeur de stock attendue est écrite à partir du snapshot initial.
      // Si la valeur diffère, interrompre pour éviter un double mouvement.
      final original = _num(tx['before']);
      final expected = original + qty;
      if ((before - original).abs() > 0.000001 && (before - expected).abs() > 0.000001) {
        throw StateError('Stock modifié pendant une réception interrompue. Vérification manuelle requise.');
      }
      if ((before - original).abs() < 0.000001) {
        article['qty'] = expected;
        if (!await p.setString(_articlesKey, jsonEncode(articles))) throw StateError('Écriture stock refusée');
      }
      moves.add({'id':id, 'purchaseTx':id, 'articleId':article['id'], 'reference':article['reference'] ?? '',
        'article':article['name'] ?? '', 'type':'Réception achat', 'delta':qty,
        'before':original, 'after':expected, 'reason':'Commande ${tx['orderId']}', 'at':tx['at']});
      if (!await p.setString(_movesKey, jsonEncode(moves))) throw StateError('Écriture journal refusée');
    }
    final i = orders.indexWhere((o) => '${o['id']}' == '${tx['orderId']}');
    if (i < 0) throw StateError('Commande absente lors de la reprise');
    orders[i]['status'] = 'Réceptionnée';
    orders[i]['receivedAt'] = tx['at'];
    orders[i]['purchaseTx'] = id;
    if (!await p.setString(_ordersKey, jsonEncode(orders))) throw StateError('Écriture commande refusée');
    if (!await p.remove(_pendingKey)) throw StateError('Nettoyage transaction refusé');
  }
  Future<void> _newOrder() async {
    if (_locked || _recoveryError != null) return;
    final supplier = TextEditingController();
    final ref = TextEditingController();
    final qty = TextEditingController(text:'1');
    final cost = TextEditingController(text:'0');
    String? selected;
    String? error;
    final active = _articles.where((a) => a['active'] != false).toList();
    if (active.isEmpty) { _toast('Créer d’abord un article actif dans Articles et Stocks'); return; }
    final result = await showDialog<Map<String, dynamic>>(context:context, builder:(dialog) => StatefulBuilder(builder:(dialog, update) => AlertDialog(
      title:const Text('Nouvelle commande fournisseur'),
      content:SizedBox(width:520, child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:supplier,decoration:const InputDecoration(labelText:'Code fournisseur *')),
        TextField(controller:ref,decoration:const InputDecoration(labelText:'Référence commande *')),
        DropdownButtonFormField<String>(initialValue:selected, isExpanded:true, decoration:const InputDecoration(labelText:'Article *'),
          items:active.map((a)=>DropdownMenuItem<String>(value:'${a['id']}',child:Text('${a['reference'] ?? ''} — ${a['name'] ?? ''}',overflow:TextOverflow.ellipsis))).toList(),
          onChanged:(v)=>update(()=>selected=v)),
        TextField(controller:qty,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Quantité *')),
        TextField(controller:cost,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Prix achat unitaire (Ar) *')),
        if(error!=null) Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Colors.red)))
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialog),child:const Text('Annuler')),
        FilledButton(onPressed:(){
          final q=double.tryParse(qty.text.replaceAll(',','.'));
          final c=double.tryParse(cost.text.replaceAll(',','.'));
          if(supplier.text.trim().isEmpty || ref.text.trim().isEmpty || selected==null || q==null || !q.isFinite || q<=0 || c==null || !c.isFinite || c<0) {
            update(()=>error='Fournisseur, référence, article, quantité et prix valides obligatoires'); return;
          }
          if(_orders.any((o)=>'${o['reference']}'.toLowerCase()==ref.text.trim().toLowerCase())) {
            update(()=>error='Référence de commande déjà utilisée'); return;
          }
          Navigator.pop(dialog,{'id':_uid(),'reference':ref.text.trim(),'supplierCode':supplier.text.trim(),
            'articleId':selected,'qty':q,'unitCost':c,'status':'Brouillon','createdAt':DateTime.now().toIso8601String()});
        },child:const Text('Enregistrer'))]
    )));
    supplier.dispose(); ref.dispose(); qty.dispose(); cost.dispose();
    if(result==null)return;
    try {
      final p=await SharedPreferences.getInstance();
      final orders=_parse(p.getString(_ordersKey));
      if(orders.any((o)=>'${o['reference']}'.toLowerCase()=='${result['reference']}'.toLowerCase()))throw StateError('Référence déjà existante');
      orders.add(result);
      if(!await p.setString(_ordersKey,jsonEncode(orders)))throw StateError('Enregistrement refusé');
      await _load(); _toast('Commande créée');
    } catch(e) { _toast('Échec : $e'); }
  }
  Future<void> _receive(Map<String,dynamic> order) async {
    if(_locked || _recoveryError != null || order['status']=='Réceptionnée' || order['status']=='Annulée')return;
    final confirm=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('Confirmer la réception'),
      content:Text('Commande ${order['reference']} : ajouter ${order['qty']} unités au stock ? Cette action sera journalisée.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Annuler')),
        FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Réceptionner'))]));
    if(confirm!=true)return;
    setState(()=>_locked=true);
    try {
      final p=await SharedPreferences.getInstance();
      await _recover(p);
      final orders=_parse(p.getString(_ordersKey));
      final current=orders.firstWhere((o)=>'${o['id']}'=='${order['id']}');
      if(current['status']=='Réceptionnée' || current['status']=='Annulée')throw StateError('Commande déjà traitée');
      final articles=_parse(p.getString(_articlesKey));
      final a=articles.firstWhere((x)=>'${x['id']}'=='${current['articleId']}');
      if(a['active']==false)throw StateError('Article archivé');
      final qty=_num(current['qty']);
      if(qty<=0 || !qty.isFinite)throw StateError('Quantité invalide');
      final tx={'id':'purchase-${current['id']}','orderId':current['id'],'articleId':a['id'],
        'qty':qty,'before':_num(a['qty']),'at':DateTime.now().toIso8601String()};
      if(!await p.setString(_pendingKey,jsonEncode(tx)))throw StateError('Préparation transaction impossible');
      await _recover(p);
      await _load(); _toast('Réception enregistrée'); widget.onChanged?.call();
    } catch(e) { _toast('Réception suspendue : $e. Ne pas recommencer avant vérification.'); }
    finally { if(mounted)setState(()=>_locked=false); }
  }
  Future<void> _cancel(Map<String,dynamic> order) async {
    if(_locked || _recoveryError != null || order['status']!='Brouillon')return;
    final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('Annuler la commande ?'),
      content:const Text('La commande reste dans l’historique.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Retour')),
        FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Confirmer'))]));
    if(ok!=true)return;
    try {final p=await SharedPreferences.getInstance();final rows=_parse(p.getString(_ordersKey));
      final i=rows.indexWhere((o)=>'${o['id']}'=='${order['id']}');if(i<0)return;
      if(rows[i]['status']!='Brouillon')throw StateError('Statut modifié');
      rows[i]['status']='Annulée';
      if(!await p.setString(_ordersKey,jsonEncode(rows)))throw StateError('Écriture refusée');
      await _load();
    } catch(e) {_toast('Échec annulation : $e');}
  }
  Future<void> _export() async {
    String esc(dynamic x)=>'"${(x??'').toString().replaceAll('"','""')}"';
    final rows=<List<dynamic>>[['Référence','Fournisseur','Article ID','Quantité','Prix unitaire','Statut','Créée le'],
      ..._visible.map((o)=>[o['reference'],o['supplierCode'],o['articleId'],o['qty'],o['unitCost'],o['status'],o['createdAt']])];
    await Clipboard.setData(ClipboardData(text:rows.map((r)=>r.map(esc).join(';')).join('\r\n')));
    _toast('CSV copié dans le presse-papiers');
  }
  List<Map<String,dynamic>> get _visible {
    final q=_search.text.trim().toLowerCase();
    final rows=_orders.where((o)=> (_filter=='Tous'||o['status']==_filter) &&
      [o['reference'],o['supplierCode'],o['articleId']].any((v)=>'$v'.toLowerCase().contains(q))).toList();
    rows.sort((a,b)=>'${b['createdAt']}'.compareTo('${a['createdAt']}'));
    return rows;
  }
  @override Widget build(BuildContext context) {
    if(_busy)return const Center(child:CircularProgressIndicator());
    if(_recoveryError!=null)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Icon(Icons.warning_amber,size:40,color:Colors.orange),
      Text('Transaction suspendue : $_recoveryError'),
      const Text('Ne pas modifier le stock avant vérification. Restaurer une sauvegarde si nécessaire.'),
      OutlinedButton(onPressed:_load,child:const Text('Réessayer'))]));
    final rows=_visible;
    final amount=_orders.fold<double>(0,(s,o)=>s+_num(o['qty'])*_num(o['unitCost']));
    return Column(children:[
      Wrap(spacing:12,runSpacing:8,children:[Chip(label:Text('Commandes : ${_orders.length}')),
        Chip(label:Text('Montant total : ${amount.toStringAsFixed(0)} Ar')),
        FilledButton.icon(onPressed:_locked?null:_newOrder,icon:const Icon(Icons.add),label:const Text('Nouvel achat')),
        OutlinedButton.icon(onPressed:_export,icon:const Icon(Icons.copy),label:const Text('CSV')),
        OutlinedButton.icon(onPressed:_locked?null:_load,icon:const Icon(Icons.refresh),label:const Text('Actualiser'))]),
      const SizedBox(height:12),
      Wrap(spacing:12,runSpacing:8,children:[SizedBox(width:250,child:TextField(controller:_search,
        onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'Recherche achats',border:OutlineInputBorder()))),
        DropdownButton<String>(value:_filter,items:['Tous','Brouillon','Réceptionnée','Annulée'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
          onChanged:(v)=>setState(()=>_filter=v??'Tous'))]),
      const SizedBox(height:8),
      Expanded(child:rows.isEmpty?const Center(child:Text('Aucune commande')):ListView.builder(itemCount:rows.length,itemBuilder:(ctx,i){
        final o=rows[i];return Card(child:ListTile(leading:const Icon(Icons.shopping_cart),
          title:Text('${o['reference']} • ${o['supplierCode']}'),
          subtitle:Text('Article ${o['articleId']} • ${o['qty']} × ${o['unitCost']} Ar • ${o['status']}'),
          trailing:Row(mainAxisSize:MainAxisSize.min,children:[
            if(o['status']=='Brouillon') IconButton(tooltip:'Réceptionner',onPressed:_locked?null:()=>_receive(o),icon:const Icon(Icons.inventory)),
            if(o['status']=='Brouillon') IconButton(tooltip:'Annuler',onPressed:_locked?null:()=>_cancel(o),icon:const Icon(Icons.cancel_outlined))
          ])));
      })),
      const Padding(padding:EdgeInsets.all(8),child:Text('Réception et stock : écriture reprise automatiquement après interruption. Vérifier les achats historiques avant import.'))
    ]);
  }
}
