import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Devis indépendants des ventes. Aucun mouvement de stock ni conversion automatique.
class QuotesProScreen extends StatefulWidget {
  const QuotesProScreen({super.key});
  @override
  State<QuotesProScreen> createState() => _QuotesProScreenState();
}
class _QuotesProScreenState extends State<QuotesProScreen> {
  static const String keyName = 'ikainks_v009_quotes_pro';
  static const String articleKey = 'ikainks_v005_articles';
  final TextEditingController search = TextEditingController();
  List<Map<String, dynamic>> quotes = [];
  List<Map<String, dynamic>> articles = [];
  bool busy = true;
  bool saving = false;
  String? error;
  String filter = 'Tous';
  @override
  void initState() { super.initState(); load(); }
  @override
  void dispose() { search.dispose(); super.dispose(); }
  List<Map<String,dynamic>> decode(String? s) {
    if (s == null || s.isEmpty) return [];
    return (jsonDecode(s) as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
  }
  double number(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.')) ?? double.nan;
  void notify(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final q = decode(p.getString(keyName));
      final a = decode(p.getString(articleKey));
      if (mounted) setState(() { quotes=q; articles=a; busy=false; error=null; });
    } catch(e) { if(mounted) setState(() { busy=false; error='$e'; }); }
  }
  Future<void> persist(List<Map<String,dynamic>> next) async {
    if (saving) return;
    setState(() => saving=true);
    try {
      final p = await SharedPreferences.getInstance();
      if (!await p.setString(keyName,jsonEncode(next))) throw StateError('Écriture non confirmée');
      if (mounted) setState(() => quotes=next);
    } catch(e) { notify('Échec enregistrement : $e'); }
    finally { if(mounted) setState(() => saving=false); }
  }
  Future<void> create() async {
    if (saving || error!=null) return;
    final customer=TextEditingController();
    final qty=TextEditingController(text:'1');
    final unitPrice=TextEditingController();
    final notes=TextEditingController();
    String? selected;
    String? issue;
    final active=articles.where((a)=>a['active']!=false).toList();
    if(active.isEmpty) { notify('Aucun article disponible'); return; }
    final data=await showDialog<Map<String,dynamic>>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,update)=>AlertDialog(
      title:const Text('Nouveau devis'),
      content:SizedBox(width:540,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:customer,decoration:const InputDecoration(labelText:'Client *')),
        DropdownButtonFormField<String>(isExpanded:true,initialValue:selected,decoration:const InputDecoration(labelText:'Article *'),
          items:active.map((a)=>DropdownMenuItem<String>(value:'${a['id']}',child:Text('${a['reference']} — ${a['name']}',overflow:TextOverflow.ellipsis))).toList(),
          onChanged:(v){update(()=>selected=v); final a=active.firstWhere((x)=>'${x['id']}'==v);unitPrice.text='${a['price']??0}';}),
        TextField(controller:qty,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Quantité *')),
        TextField(controller:unitPrice,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Prix unitaire (Ar) *')),
        TextField(controller:notes,decoration:const InputDecoration(labelText:'Observations')),
        if(issue!=null) Text(issue!,style:const TextStyle(color:Colors.red)),
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Annuler')),
        FilledButton(onPressed:(){
          final q=number(qty.text); final price=number(unitPrice.text);
          if(customer.text.trim().isEmpty||selected==null||!q.isFinite||q<=0||!price.isFinite||price<0){update(()=>issue='Client, article, quantité positive et prix valide obligatoires');return;}
          final a=active.firstWhere((x)=>'${x['id']}'==selected);
          Navigator.pop(ctx,{'customer':customer.text.trim(),'articleId':selected,'reference':'${a['reference']}','article':'${a['name']}','quantity':q,'unitPrice':price,'notes':notes.text.trim()});
        },child:const Text('Enregistrer'))],
    )));
    customer.dispose();qty.dispose();unitPrice.dispose();notes.dispose();
    if(data==null) return;
    final id=DateTime.now().microsecondsSinceEpoch.toString();
    final entry=<String,dynamic>{...data,'id':id,'number':'DEV-$id','status':'Brouillon','total':(data['quantity'] as double)*(data['unitPrice'] as double),'createdAt':DateTime.now().toIso8601String()};
    if(quotes.any((x)=>x['id']==id)) {notify('Identifiant déjà utilisé, recommencez');return;}
    await persist([...quotes,entry]);
  }
  Future<void> status(Map<String,dynamic> item,String nextStatus) async {
    if(saving) return;
    final current='${item['status']}';
    if(current=='Annulé'||current=='Accepté') {notify('Statut final : modification interdite');return;}
    if(nextStatus=='Accepté') {
      final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Accepter le devis ?'),content:const Text('Cette opération ne crée PAS de vente et ne modifie PAS le stock. La conversion sera développée dans une étape transactionnelle séparée.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Retour')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Confirmer'))]));
      if(ok!=true) return;
    }
    final updated=quotes.map((q)=>q['id']==item['id']? <String,dynamic>{...q,'status':nextStatus,'updatedAt':DateTime.now().toIso8601String()}:q).toList();
    await persist(updated);
  }
  Future<void> exportCsv() async {
    String cell(dynamic v)=>'"${'$v'.replaceAll('"','""')}"';
    final lines=<String>['numero;date;client;article;quantite;prix_unitaire;total;statut;notes',
      ...quotes.map((q)=>[q['number'],q['createdAt'],q['customer'],q['article'],q['quantity'],q['unitPrice'],q['total'],q['status'],q['notes']].map(cell).join(';'))];
    await Clipboard.setData(ClipboardData(text:lines.join('\r\n')));
    notify('CSV copié dans le presse-papiers');
  }
  @override
  Widget build(BuildContext context) {
    final term=search.text.toLowerCase().trim();
    final rows=quotes.where((q)=>(filter=='Tous'||q['status']==filter)&&('$q'.toLowerCase().contains(term))).toList()
      ..sort((a,b)=>'${b['createdAt']}'.compareTo('${a['createdAt']}'));
    return Scaffold(appBar:AppBar(title:const Text('Devis • Version Pro'),actions:[IconButton(tooltip:'Exporter CSV',onPressed:quotes.isEmpty?null:exportCsv,icon:const Icon(Icons.file_download_outlined)),IconButton(tooltip:'Actualiser',onPressed:load,icon:const Icon(Icons.refresh))]),
      floatingActionButton:FloatingActionButton.extended(onPressed:busy||saving||error!=null?null:create,icon:const Icon(Icons.add),label:const Text('Nouveau devis')),
      body:busy?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Text('Lecture impossible : $error')):
        Column(children:[Padding(padding:const EdgeInsets.all(12),child:Wrap(spacing:12,runSpacing:8,children:[
          SizedBox(width:300,child:TextField(controller:search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'Rechercher'))),
          DropdownButton<String>(value:filter,items:['Tous','Brouillon','Envoyé','Accepté','Refusé','Annulé'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>filter=v??'Tous')),
          Text('${rows.length} devis'),
        ])),
        Expanded(child:rows.isEmpty?const Center(child:Text('Aucun devis pour ce filtre')):ListView.builder(itemCount:rows.length,itemBuilder:(ctx,i){final q=rows[i];return Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:ListTile(
          title:Text('${q['number']} — ${q['customer']}'),
          subtitle:Text('${q['article']} • ${q['quantity']} × ${q['unitPrice']} Ar\n${q['status']} • ${q['createdAt']}',maxLines:3),
          trailing:PopupMenuButton<String>(tooltip:'Changer le statut',enabled:!saving&&q['status']!='Annulé'&&q['status']!='Accepté',onSelected:(v)=>status(q,v),itemBuilder:(ctx)=>['Envoyé','Accepté','Refusé','Annulé'].map((s)=>PopupMenuItem(value:s,child:Text(s))).toList()),
          onTap:()=>showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:Text('${q['number']}'),content:SelectableText('Client : ${q['customer']}\nArticle : ${q['article']}\nQuantité : ${q['quantity']}\nPrix : ${q['unitPrice']} Ar\nTotal : ${q['total']} Ar\nStatut : ${q['status']}\nObservations : ${q['notes']}'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Fermer'))])),
        ));})),
      ]));
  }
}
