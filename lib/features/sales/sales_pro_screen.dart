import 'dart:convert';
import 'package:flutter/material.dart';
import '../documents/documents_pro_screen.dart';
import '../returns/returns_pro_screen.dart';
import '../payments/payments_pro_screen.dart';
import '../deliveries/deliveries_pro_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ventes nouvelles uniquement. Ne modifie jamais les ventes historiques.
/// Chaque vente porte un identifiant de mouvement unique et une reprise prudente.
class SalesProScreen extends StatefulWidget {
  const SalesProScreen({super.key, this.onChanged});
  final VoidCallback? onChanged;
  @override
  State<SalesProScreen> createState() => _SalesProScreenState();
}

class _SalesProScreenState extends State<SalesProScreen> {
  static const _salesKey = 'ikainks_v008_sales_pro';
  static const _articlesKey = 'ikainks_v005_articles';
  static const _movesKey = 'ikainks_v006_stock_movements';
  static const _pendingKey = 'ikainks_v008_sales_pending';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _articles = [];
  bool _busy = true;
  bool _locked = false;
  String? _error;
  String _filter = 'Toutes';
  double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.')) ?? double.nan;
  String _money(num n) => '${n.toStringAsFixed(0)} Ar';
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  List<Map<String, dynamic>> _decode(String? value) {
    if (value == null || value.isEmpty) return [];
    return (jsonDecode(value) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  void _notice(String value) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); }
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _recover(prefs);
      if (!mounted) return;
      setState(() { _sales = _decode(prefs.getString(_salesKey)); _articles = _decode(prefs.getString(_articlesKey)); _busy = false; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = '$e'; });
    }
  }
  // Reprise sur snapshot; en cas de divergence, arrêt sans écrasement.
  Future<void> _recover(SharedPreferences prefs) async {
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return;
    final tx = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final id = '${tx['id']}';
    final articles = _decode(prefs.getString(_articlesKey));
    final moves = _decode(prefs.getString(_movesKey));
    final sales = _decode(prefs.getString(_salesKey));
    final articleIndex = articles.indexWhere((x) => '${x['id']}' == '${tx['articleId']}');
    if (articleIndex < 0) throw StateError('Article introuvable pour transaction en attente $id');
    final article = articles[articleIndex];
    final before = _n(tx['before']);
    final quantity = _n(tx['quantity']);
    final current = _n(article['qty']);
    final after = before - quantity;
    if (![before, quantity, current].every((v) => v.isFinite) || quantity <= 0 || after < 0) {
      throw StateError('Transaction en attente invalide; contrôle manuel requis');
    }
    final alreadyMoved = moves.any((m) => '${m['salesTx'] ?? ''}' == id);
    if (!alreadyMoved) {
      if ((current - before).abs() < 0.000001) {
        article['qty'] = after;
        if (!await prefs.setString(_articlesKey, jsonEncode(articles))) throw StateError('Échec écriture stock');
      } else if ((current - after).abs() > 0.000001) {
        throw StateError('Stock modifié depuis la vente en attente; réconciliation manuelle obligatoire');
      }
      moves.add({'id': id, 'salesTx': id, 'articleId': tx['articleId'], 'reference': tx['reference'],
        'article': tx['article'], 'type': 'Vente', 'delta': -quantity, 'before': before,
        'after': after, 'reason': 'Vente ${tx['invoice']}', 'at': tx['at']});
      if (!await prefs.setString(_movesKey, jsonEncode(moves))) throw StateError('Échec journal stock');
    }
    if (!sales.any((s) => '${s['id']}' == id)) {
      sales.add(Map<String, dynamic>.from(tx['sale'] as Map));
      if (!await prefs.setString(_salesKey, jsonEncode(sales))) throw StateError('Échec écriture vente');
    }
    if (!await prefs.remove(_pendingKey)) throw StateError('Échec nettoyage transaction');
  }
  Future<void> _create() async {
    if (_locked || _error != null) return;
    final client = TextEditingController();
    final quantity = TextEditingController(text: '1');
    final price = TextEditingController();
    String? articleId;
    String? validation;
    final active = _articles.where((a) => a['active'] != false && _n(a['qty']).isFinite && _n(a['qty']) > 0).toList();
    if (active.isEmpty) { _notice('Aucun article actif avec stock disponible'); return; }
    final values = await showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: const Text('Nouvelle vente'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: client, decoration: const InputDecoration(labelText: 'Client (nom ou code)')),
        DropdownButtonFormField<String>(initialValue: articleId, isExpanded: true,
          decoration: const InputDecoration(labelText: 'Article *'),
          items: active.map((a) => DropdownMenuItem<String>(value: '${a['id']}', child: Text('${a['reference']} — ${a['name']} (stock ${a['qty']})', overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) { update(() { articleId = v; validation = null; }); final a = active.firstWhere((x) => '${x['id']}' == v); price.text = '${a['price'] ?? 0}'; }),
        TextField(controller: quantity, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantité *')),
        TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Prix unitaire (Ar) *')),
        if (validation != null) Text(validation!, style: const TextStyle(color: Colors.red)),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        FilledButton(onPressed: () {
          final q = _n(quantity.text);
          final p = _n(price.text);
          final match = active.where((a) => '${a['id']}' == articleId).toList();
          if (match.isEmpty || !q.isFinite || !p.isFinite || q <= 0 || p < 0 || q > _n(match.first['qty'])) {
            update(() => validation = 'Article, quantité ou prix invalide / stock insuffisant'); return;
          }
          Navigator.pop(ctx, {'articleId': articleId, 'client': client.text.trim(), 'qty': q, 'price': p});
        }, child: const Text('Valider la vente'))],
    )));
    client.dispose(); quantity.dispose(); price.dispose();
    if (values == null) return;
    setState(() => _locked = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getString(_pendingKey) ?? '').isNotEmpty) throw StateError('Transaction en attente : redémarrer le module');
      final articles = _decode(prefs.getString(_articlesKey));
      final index = articles.indexWhere((a) => '${a['id']}' == '${values['articleId']}');
      if (index < 0) throw StateError('Article supprimé');
      final article = articles[index];
      final q = _n(values['qty']);
      final before = _n(article['qty']);
      if (!before.isFinite || before < q || article['active'] == false) throw StateError('Stock insuffisant ou article archivé');
      final id = _id();
      final at = DateTime.now().toIso8601String();
      final invoice = 'V-$id';
      final sale = <String, dynamic>{'id': id, 'invoice': invoice, 'client': values['client'],
        'articleId': article['id'], 'article': article['name'], 'reference': article['reference'],
        'qty': q, 'price': values['price'], 'total': q * _n(values['price']), 'at': at, 'status': 'Validée'};
      final tx = {'id': id, 'articleId': article['id'], 'reference': article['reference'], 'article': article['name'],
        'quantity': q, 'before': before, 'invoice': invoice, 'at': at, 'sale': sale};
      if (!await prefs.setString(_pendingKey, jsonEncode(tx))) throw StateError('Échec écriture transaction');
      await _recover(prefs);
      await _load();
      widget.onChanged?.call();
      _notice('Vente $invoice enregistrée');
    } catch (e) {
      if (mounted) setState(() => _error = 'Vérifier avant de recommencer : $e');
      _notice('Vente interrompue : $e');
    } finally { if (mounted) setState(() => _locked = false); }
  }
  Future<void> _export() async {
    final b = StringBuffer('Facture;Date;Client;Article;Quantité;Prix unitaire;Total;Statut\n');
    for (final s in _filtered) {
      String cell(dynamic v) => '"${'$v'.replaceAll('"', '""')} "'.trimRight();
      b.writeln([s['invoice'], s['at'], s['client'], s['article'], s['qty'], s['price'], s['total'], s['status']].map(cell).join(';'));
    }
    await Clipboard.setData(ClipboardData(text: b.toString()));
    _notice('CSV copié dans le presse-papiers');
  }
  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _sales.where((s) {
      if (_filter == 'Avec client' && '${s['client'] ?? ''}'.isEmpty) return false;
      return q.isEmpty || [s['invoice'], s['client'], s['article'], s['reference']].any((v) => '$v'.toLowerCase().contains(q));
    }).toList().reversed.toList();
  }
  @override
  Widget build(BuildContext context) {
    if (_busy) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warning_amber_rounded, size: 48),
      Padding(padding: const EdgeInsets.all(16), child: SelectableText('Vérification nécessaire : $_error')),
      FilledButton(onPressed: () { setState(() { _busy = true; _error = null; }); _load(); }, child: const Text('Retenter la reprise')),
    ]));
    final shown = _filtered;
    final total = shown.fold<double>(0, (sum, s) => sum + (_n(s['total']).isFinite ? _n(s['total']) : 0));
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('Ventes Pro', style: Theme.of(context).textTheme.titleLarge),
        FilledButton.icon(onPressed: _locked ? null : _create, icon: const Icon(Icons.add), label: const Text('Nouvelle vente')),
        OutlinedButton.icon(onPressed: _export, icon: const Icon(Icons.copy), label: const Text('CSV')),
        OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Actualiser')),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DocumentsProScreen())), icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('Documents PDF')),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReturnsProScreen())), icon: const Icon(Icons.assignment_return_outlined), label: const Text('Retours')) ,
        OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PaymentsProScreen())), icon: const Icon(Icons.payments_outlined), label: const Text('Règlements')),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DeliveriesProScreen())), icon: const Icon(Icons.local_shipping_outlined), label: const Text('Livraisons')) ,
      ]),
      const SizedBox(height: 10),
      Text('Ventes affichées : ${shown.length}  •  Total : ${_money(total)}'),
      const SizedBox(height: 10),
      TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Rechercher facture, client ou article', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      DropdownButton<String>(value: _filter, items: const [DropdownMenuItem(value: 'Toutes', child: Text('Toutes')), DropdownMenuItem(value: 'Avec client', child: Text('Avec client'))], onChanged: (v) => setState(() => _filter = v ?? 'Toutes')),
      Expanded(child: shown.isEmpty ? const Center(child: Text('Aucune vente dans ce registre. Les ventes historiques sont conservées séparément.')) :
        ListView.builder(itemCount: shown.length, itemBuilder: (ctx, i) {
          final s = shown[i];
          return Card(child: ListTile(title: Text('${s['invoice']} — ${s['article']}'),
            subtitle: Text('${s['client']} • ${s['qty']} × ${_money(_n(s['price']))} • ${s['at']}'),
            trailing: Text(_money(_n(s['total'])))));
        })),
    ]));
  }
}
