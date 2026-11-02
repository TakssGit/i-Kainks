import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bons de livraison lies aux ventes Pro. Aucun mouvement de stock additionnel.
class DeliveriesProScreen extends StatefulWidget {
  const DeliveriesProScreen({super.key});
  @override
  State<DeliveriesProScreen> createState() => _DeliveriesProScreenState();
}

class _DeliveriesProScreenState extends State<DeliveriesProScreen> {
  static const _key = 'ikainks_v010_deliveries_pro';
  static const _salesKey = 'ikainks_v008_sales_pro';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _deliveries = [];
  List<Map<String, dynamic>> _sales = [];
  bool _busy = true;
  bool _saving = false;
  String? _error;
  String _filter = 'Tous';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw);
    if (data is! List) throw const FormatException('Liste de données invalide');
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  void _message(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sales = _decode(prefs.getString(_salesKey));
      final deliveries = _decode(prefs.getString(_key));
      if (mounted) setState(() { _sales = sales; _deliveries = deliveries; _error = null; _busy = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _busy = false; });
    }
  }
  Future<bool> _save(List<Map<String, dynamic>> next) async {
    if (_saving) return false;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_key, jsonEncode(next))) throw StateError('Écriture non confirmée');
      if (mounted) setState(() => _deliveries = next);
      return true;
    } catch (e) { _message('Échec de sauvegarde : $e'); return false; }
    finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _create() async {
    if (_saving || _error != null) return;
    final existing = _deliveries.map((e) => '${e['saleId']}').toSet();
    final available = _sales.where((s) => !existing.contains('${s['id']}')).toList();
    if (available.isEmpty) { _message('Aucune vente Pro sans bon de livraison'); return; }
    final recipient = TextEditingController();
    final address = TextEditingController();
    final notes = TextEditingController();
    String? selected;
    String? validation;
    final result = await showDialog<Map<String, String>>(context: context, builder: (dialogContext) =>
      StatefulBuilder(builder: (dialogContext, update) => AlertDialog(
        title: const Text('Nouveau bon de livraison'),
        content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(isExpanded: true, initialValue: selected,
            decoration: const InputDecoration(labelText: 'Vente Pro *'),
            items: available.map((s) => DropdownMenuItem<String>(value: '${s['id']}',
              child: Text('${s['invoice']} • ${s['client']} • ${s['article']}', overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => update(() { selected = v; validation = null; })),
          TextField(controller: recipient, decoration: const InputDecoration(labelText: 'Destinataire *')),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse de livraison *')),
          TextField(controller: notes, decoration: const InputDecoration(labelText: 'Instructions')),
          if (validation != null) Text(validation!, style: const TextStyle(color: Colors.red)),
        ]))),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(onPressed: () {
            if (selected == null || recipient.text.trim().isEmpty || address.text.trim().isEmpty) {
              update(() => validation = 'Vente, destinataire et adresse obligatoires'); return;
            }
            Navigator.pop(dialogContext, {'saleId': selected!, 'recipient': recipient.text.trim(),
              'address': address.text.trim(), 'notes': notes.text.trim()});
          }, child: const Text('Créer'))],
      )));
    recipient.dispose(); address.dispose(); notes.dispose();
    if (result == null) return;
    final prefs = await SharedPreferences.getInstance();
    final fresh = _decode(prefs.getString(_key));
    if (fresh.any((d) => '${d['saleId']}' == result['saleId'])) {
      _message('Un bon existe déjà pour cette vente'); await _load(); return;
    }
    final saleMatches = _decode(prefs.getString(_salesKey)).where((s) => '${s['id']}' == result['saleId']);
    if (saleMatches.isEmpty) { _message('Vente introuvable, création refusée'); return; }
    final sale = saleMatches.first;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = <String, dynamic>{...result, 'id': id, 'number': 'BL-$id',
      'invoice': '${sale['invoice']}', 'client': '${sale['client']}',
      'article': '${sale['article']}', 'quantity': sale['qty'],
      'status': 'À préparer', 'createdAt': DateTime.now().toIso8601String()};
    if (await _save([...fresh, entry])) _message('Bon ${entry['number']} créé sans déduction de stock');
  }
  Future<void> _setStatus(Map<String, dynamic> item, String next) async {
    if (_saving) return;
    final current = '${item['status']}';
    const transitions = <String, List<String>>{
      'À préparer': ['Expédiée', 'Annulée'],
      'Expédiée': ['Livrée', 'Incident'],
      'Incident': ['Expédiée', 'Livrée'],
      'Livrée': [], 'Annulée': [],
    };
    if (!(transitions[current] ?? []).contains(next)) { _message('Transition de statut interdite'); return; }
    if (next == 'Livrée') {
      final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la livraison ?'),
        content: const Text('Cette confirmation clôture le bon. Elle ne modifie pas le stock.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Retour')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer'))]));
      if (ok != true) return;
    }
    final nextList = _deliveries.map((d) => d['id'] == item['id']
      ? <String, dynamic>{...d, 'status': next, 'updatedAt': DateTime.now().toIso8601String()}
      : d).toList();
    await _save(nextList);
  }
  Future<void> _csv() async {
    String cell(dynamic x) => '"${'$x'.replaceAll('"', '""')} "'.trimRight();
    final lines = <String>['bon;facture;date;client;destinataire;adresse;article;quantite;statut;notes',
      ..._deliveries.map((d) => [d['number'], d['invoice'], d['createdAt'], d['client'],
        d['recipient'], d['address'], d['article'], d['quantity'], d['status'], d['notes']].map(cell).join(';'))];
    await Clipboard.setData(ClipboardData(text: lines.join('\r\n')));
    _message('CSV copié dans le presse-papiers');
  }
  @override
  Widget build(BuildContext context) {
    final term = _search.text.toLowerCase().trim();
    final filtered = _deliveries.where((d) => (_filter == 'Tous' || d['status'] == _filter) &&
      '$d'.toLowerCase().contains(term)).toList()
      ..sort((a, b) => '${b['createdAt']}'.compareTo('${a['createdAt']}'));
    return Scaffold(appBar: AppBar(title: const Text('Livraisons • Pro'), actions: [
      IconButton(tooltip: 'Exporter CSV', onPressed: _deliveries.isEmpty ? null : _csv, icon: const Icon(Icons.copy)),
      IconButton(tooltip: 'Actualiser', onPressed: _load, icon: const Icon(Icons.refresh)),
    ]), floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy || _saving || _error != null ? null : _create,
      icon: const Icon(Icons.add), label: const Text('Nouveau BL')),
      body: _busy ? const Center(child: CircularProgressIndicator()) : _error != null
        ? Center(child: SelectableText('Lecture impossible : $_error'))
        : Column(children: [Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 12, runSpacing: 8,
          children: [SizedBox(width: 280, child: TextField(controller: _search,
            onChanged: (_) => setState(() {}), decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), labelText: 'Rechercher un bon'))),
            DropdownButton<String>(value: _filter,
              items: ['Tous', 'À préparer', 'Expédiée', 'Livrée', 'Incident', 'Annulée']
                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (s) => setState(() => _filter = s ?? 'Tous'))])),
          Expanded(child: filtered.isEmpty ? const Center(child: Text('Aucun bon de livraison')) :
            ListView.builder(itemCount: filtered.length, itemBuilder: (ctx, i) {
              final d = filtered[i];
              final current = '${d['status']}';
              final actions = <String, List<String>>{
                'À préparer': ['Expédiée', 'Annulée'], 'Expédiée': ['Livrée', 'Incident'],
                'Incident': ['Expédiée', 'Livrée'], 'Livrée': [], 'Annulée': []};
              return Card(child: ExpansionTile(title: Text('${d['number']} • ${d['invoice']}'),
                subtitle: Text('${d['client']} • $current'), children: [
                  ListTile(title: Text('${d['article']} × ${d['quantity']}'),
                    subtitle: Text('${d['recipient']} • ${d['address']}')),
                  if ('${d['notes']}'.isNotEmpty) ListTile(title: Text('${d['notes']}')),
                  Wrap(spacing: 8, children: (actions[current] ?? []).map((s) =>
                    OutlinedButton(onPressed: _saving ? null : () => _setStatus(d, s), child: Text(s))).toList()),
                ]));
            })),
        ]));
  }
}
