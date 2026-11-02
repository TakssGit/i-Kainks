import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestion compatible avec les ventes historiques ikainks_v005_articles.
/// Aucun schema Isar concurrent: les ventes existantes conservent leurs IDs.
class InventoryProScreen extends StatefulWidget {
  const InventoryProScreen({super.key, this.onChanged});
  final VoidCallback? onChanged;
  @override
  State<InventoryProScreen> createState() => _InventoryProScreenState();
}

class _InventoryProScreenState extends State<InventoryProScreen> {
  static const _articlesKey = 'ikainks_v005_articles';
  static const _movementsKey = 'ikainks_v006_stock_movements';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _moves = [];
  bool _busy = true;
  String _filter = 'Tous';
  String _sort = 'Nom';
  int _page = 0;
  static const _pageSize = 15;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  double _n(dynamic x) => x is num ? x.toDouble() : double.tryParse('$x'.replaceAll(',', '.')) ?? 0;
  String _money(num n) => '${n.toStringAsFixed(0)} Ar';
  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();
  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final items = _decode(p.getString(_articlesKey));
      final moves = _decode(p.getString(_movementsKey));
      if (!mounted) return;
      setState(() { _items = items; _moves = moves; _busy = false; });
    } catch (e) { if (mounted) { setState(() => _busy = false); _notify('Lecture impossible : $e'); } }
  }
  void _notify(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }
  Future<bool> _save(List<Map<String, dynamic>> items, List<Map<String, dynamic>> moves) async {
    try {
      final p = await SharedPreferences.getInstance();
      // Une seule cle pour les articles reste compatible avec les ventes existantes.
      // Journal séparé, sauvegardé d'abord; l'installateur ne migre aucune donnée.
      if (!await p.setString(_movementsKey, jsonEncode(moves))) throw StateError('Journal non enregistré');
      if (!await p.setString(_articlesKey, jsonEncode(items))) throw StateError('Articles non enregistrés');
      if (!mounted) return true;
      setState(() { _items = items; _moves = moves; });
      widget.onChanged?.call();
      return true;
    } catch (e) { _notify('Enregistrement échoué : $e. Vérifier les données avant de recommencer.'); return false; }
  }
  InputDecoration _dec(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true);
  Widget _field(TextEditingController c, String label, {bool numeric = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: _dec(label)));
  Future<void> _edit([Map<String, dynamic>? old]) async {
    final name = TextEditingController(text: '${old?['name'] ?? ''}');
    final ref = TextEditingController(text: '${old?['reference'] ?? ''}');
    final barcode = TextEditingController(text: '${old?['barcode'] ?? ''}');
    final category = TextEditingController(text: '${old?['category'] ?? ''}');
    final unit = TextEditingController(text: '${old?['unit'] ?? 'pièce'}');
    final supplier = TextEditingController(text: '${old?['supplierCode'] ?? ''}');
    final cost = TextEditingController(text: '${old?['cost'] ?? 0}');
    final price = TextEditingController(text: '${old?['price'] ?? 0}');
    final qty = TextEditingController(text: '${old?['qty'] ?? 0}');
    final alert = TextEditingController(text: '${old?['alert'] ?? 5}');
    final controllers = [name,ref,barcode,category,unit,supplier,cost,price,qty,alert];
    String? error;
    final result = await showDialog<Map<String,dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
      title: Text(old == null ? 'Nouvel article' : 'Modifier article'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(name, 'Désignation *'), _field(ref, 'Référence unique *'), _field(barcode, 'Code-barres'),
        _field(category, 'Catégorie'), _field(unit, 'Unité'), _field(supplier, 'Code fournisseur'),
        _field(cost, 'Prix d’achat (Ar)', numeric:true), _field(price, 'Prix de vente (Ar)', numeric:true),
        if (old == null) _field(qty, 'Stock initial', numeric:true),
        _field(alert, 'Seuil d’alerte', numeric:true),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.red))
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        FilledButton(onPressed: () {
          final parsed = [cost,price,alert,if (old == null) qty].map((c) => double.tryParse(c.text.replaceAll(',', '.'))).toList();
          if (name.text.trim().isEmpty || ref.text.trim().isEmpty) { refresh(() => error = 'Nom et référence obligatoires'); return; }
          if (parsed.any((x) => x == null || !x.isFinite || x < 0)) { refresh(() => error = 'Montants et quantités doivent être positifs'); return; }
          if (_items.any((x) => x['id'] != old?['id'] && '${x['reference'] ?? ''}'.toLowerCase() == ref.text.trim().toLowerCase())) { refresh(() => error = 'Référence déjà utilisée'); return; }
          final data = Map<String,dynamic>.from(old ?? {});
          data.addAll({'id':old?['id'] ?? _uid(),'name':name.text.trim(),'reference':ref.text.trim(),
            'barcode':barcode.text.trim(),'category':category.text.trim(),'unit':unit.text.trim(),
            'supplierCode':supplier.text.trim(),'cost':parsed[0], 'price':parsed[1], 'alert':parsed[2],
            'qty':old == null ? parsed[3] : _n(old['qty']), 'active':old?['active'] ?? true,
            'updatedAt':DateTime.now().toIso8601String()});
          Navigator.pop(ctx,data);
        }, child: const Text('Enregistrer'))]
    )));
    for (final c in controllers) { c.dispose(); }
    if (result == null) return;
    final items = _items.map((x) => Map<String,dynamic>.from(x)).toList();
    final moves = _moves.map((x) => Map<String,dynamic>.from(x)).toList();
    if (old == null) {
      items.add(result);
      if (_n(result['qty']) > 0) moves.add(_move(result,'Stock initial',_n(result['qty']),0,'Création article'));
    } else { final i = items.indexWhere((x) => x['id'] == old['id']); if (i < 0) return; items[i] = result; }
    if (await _save(items,moves)) _notify('Article enregistré');
  }
  Map<String,dynamic> _move(Map<String,dynamic> item, String type, double delta, double before, String reason) => {
    'id':_uid(),'articleId':item['id'],'reference':item['reference'] ?? '',
    'article':item['name'],'type':type,'delta':delta,'before':before,'after':before+delta,
    'reason':reason,'at':DateTime.now().toIso8601String()};
  Future<void> _adjust(Map<String,dynamic> item) async {
    final amount = TextEditingController(); final reason = TextEditingController();
    String type = 'Entrée'; String? error;
    final result = await showDialog<Map<String,dynamic>>(context:context,builder:(ctx) => StatefulBuilder(builder:(ctx,refresh) => AlertDialog(
      title: Text('Mouvement : ${item['name']}'),
      content:SizedBox(width:420,child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text('Stock actuel : ${_n(item['qty'])}'),const SizedBox(height:12),
        DropdownButtonFormField<String>(initialValue:type,items:['Entrée','Sortie','Inventaire'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>refresh(()=>type=x ?? type),decoration:_dec('Opération')),
        const SizedBox(height:12),_field(amount,type=='Inventaire'?'Stock compté':'Quantité',numeric:true),_field(reason,'Motif obligatoire'),
        if(error!=null) Text(error!,style:const TextStyle(color:Colors.red))])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Annuler')),
        FilledButton(onPressed:(){final n=double.tryParse(amount.text.replaceAll(',','.'));
          if(n==null || !n.isFinite || n<0 || (type!='Inventaire' && n==0) || reason.text.trim().isEmpty) {refresh(()=>error='Quantité et motif valides obligatoires');return;}
          final before=_n(item['qty']);final delta=type=='Inventaire'?n-before:(type=='Sortie'?-n:n);
          if(before+delta<0) {refresh(()=>error='Stock insuffisant');return;}
          Navigator.pop(ctx,{'type':type,'delta':delta,'reason':reason.text.trim()});
        },child:const Text('Valider'))]
    )));
    amount.dispose();reason.dispose();if(result==null)return;
    final items=_items.map((x)=>Map<String,dynamic>.from(x)).toList();
    final i=items.indexWhere((x)=>x['id']==item['id']);if(i<0)return;
    final before=_n(items[i]['qty']);final delta=_n(result['delta']);
    items[i]['qty']=before+delta;
    final moves=_moves.map((x)=>Map<String,dynamic>.from(x)).toList();
    moves.add(_move(items[i],result['type'] as String,delta,before,result['reason'] as String));
    if(await _save(items,moves)) _notify('Mouvement enregistré');
  }
  Future<void> _archive(Map<String,dynamic> item) async {
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text(item['active']==false?'Réactiver ?':'Archiver ?'),content:Text('${item['name']} : aucune suppression de données.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Confirmer'))]));
    if(yes!=true)return;
    final items=_items.map((x)=>Map<String,dynamic>.from(x)).toList();final i=items.indexWhere((x)=>x['id']==item['id']);if(i<0)return;
    items[i]['active']=item['active']==false;await _save(items,_moves);
  }
  Future<void> _export() async {
    String esc(dynamic x)=>'"${(x??'').toString().replaceAll('"','""')}"';
    final rows=<List<dynamic>>[['Référence','Désignation','Catégorie','Stock','Seuil','Achat','Vente','Actif'],
      ..._visible.map((x)=>[x['reference'],x['name'],x['category'],x['qty'],x['alert'],x['cost'],x['price'],x['active']!=false])];
    await Clipboard.setData(ClipboardData(text:rows.map((r)=>r.map(esc).join(';')).join('\r\n')));
    _notify('CSV copié dans le presse-papiers');
  }
  List<Map<String,dynamic>> get _visible {
    final q=_search.text.trim().toLowerCase();
    final rows=_items.where((x){final active=x['active']!=false;
      if(_filter=='Actifs'&&!active)return false;if(_filter=='Archivés'&&active)return false;
      if(_filter=='Alertes'&&(!active || _n(x['qty'])>_n(x['alert'])))return false;
      return [x['name'],x['reference'],x['barcode'],x['category'],x['supplierCode']].any((v)=>'$v'.toLowerCase().contains(q));
    }).toList();
    rows.sort((a,b)=>_sort=='Stock'?_n(a['qty']).compareTo(_n(b['qty'])):'${a[_sort=='Référence'?'reference':'name']??''}'.toLowerCase().compareTo('${b[_sort=='Référence'?'reference':'name']??''}'.toLowerCase()));
    return rows;
  }
  @override Widget build(BuildContext context) {
    if(_busy)return const Center(child:CircularProgressIndicator());
    final rows=_visible;final start=_page*_pageSize;final pageRows=rows.skip(start).take(_pageSize).toList();
    final stockValue=_items.where((x)=>x['active']!=false).fold<double>(0,(s,x)=>s+_n(x['qty'])*_n(x['cost']));
    return Column(children:[
      Wrap(spacing:12,runSpacing:8,children:[Chip(label:Text('Articles : ${_items.length}')),Chip(label:Text('Valeur achat : ${_money(stockValue)}')),Chip(label:Text('Alertes : ${_items.where((x)=>x['active']!=false&&_n(x['qty'])<=_n(x['alert'])).length}')),
        FilledButton.icon(onPressed:()=>_edit(),icon:const Icon(Icons.add),label:const Text('Nouvel article')),
        OutlinedButton.icon(onPressed:_export,icon:const Icon(Icons.copy),label:const Text('CSV')),
        OutlinedButton.icon(onPressed:_load,icon:const Icon(Icons.refresh),label:const Text('Actualiser'))]),
      const SizedBox(height:12),
      Wrap(spacing:12,runSpacing:8,children:[SizedBox(width:260,child:TextField(controller:_search,onChanged:(_)=>setState(()=>_page=0),decoration:_dec('Recherche article / référence'))),
        DropdownButton<String>(value:_filter,items:['Tous','Actifs','Archivés','Alertes'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState((){_filter=v??'Tous';_page=0;})),
        DropdownButton<String>(value:_sort,items:['Nom','Référence','Stock'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>_sort=v??'Nom'))]),
      const SizedBox(height:8),
      Expanded(child:rows.isEmpty?const Center(child:Text('Aucun article')):ListView.builder(itemCount:pageRows.length,itemBuilder:(ctx,i){final x=pageRows[i];final low=_n(x['qty'])<=_n(x['alert']);return Card(child:ListTile(
        leading:Icon(low?Icons.warning_amber:Icons.inventory_2,color:low?Colors.orange:null),
        title:Text('${x['name']}  •  ${x['reference']??'Sans référence'}'),
        subtitle:Text('Stock ${x['qty']} ${x['unit']??''} | Vente ${_money(_n(x['price']))} | ${x['active']==false?'Archivé':'Actif'}'),
        trailing:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(tooltip:'Modifier',onPressed:()=>_edit(x),icon:const Icon(Icons.edit)),IconButton(tooltip:'Mouvement',onPressed:x['active']==false?null:()=>_adjust(x),icon:const Icon(Icons.swap_horiz)),IconButton(tooltip:'Archiver / réactiver',onPressed:()=>_archive(x),icon:Icon(x['active']==false?Icons.unarchive:Icons.archive))])));})),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(onPressed:_page>0?()=>setState(()=>_page--):null,icon:const Icon(Icons.chevron_left)),Text('${rows.isEmpty?0:_page+1} / ${rows.isEmpty?0:(rows.length/_pageSize).ceil()}'),IconButton(onPressed:(_page+1)*_pageSize<rows.length?()=>setState(()=>_page++):null,icon:const Icon(Icons.chevron_right))]),
      if(_moves.isNotEmpty) ExpansionTile(title:Text('Journal des mouvements (${_moves.length})'),children:_moves.reversed.take(20).map((m)=>ListTile(dense:true,title:Text('${m['type']} • ${m['article']} • ${m['delta']}'),subtitle:Text('${m['at']} — ${m['reason']}'))).toList())
    ]);
  }
}
