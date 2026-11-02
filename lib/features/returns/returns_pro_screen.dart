import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registre des demandes de retour. Aucun stock, paiement ou avoir comptable n'est modifié.
class ReturnsProScreen extends StatefulWidget {
  const ReturnsProScreen({super.key});
  @override
  State<ReturnsProScreen> createState() => _ReturnsProScreenState();
}
class _ReturnsProScreenState extends State<ReturnsProScreen> {
  static const _key = 'ikainks_v012_returns_pro';
  static const _salesKey = 'ikainks_v008_sales_pro';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _returns = [];
  List<Map<String, dynamic>> _sales = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _filter = 'Tous';
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final value = jsonDecode(raw);
    if (value is! List) throw const FormatException('Format de liste invalide');
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  void _notice(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final returns = _decode(prefs.getString(_key));
      final sales = _decode(prefs.getString(_salesKey));
      if (mounted) setState(() { _returns = returns; _sales = sales; _loading = false; _error = null; });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = '$e'; }); }
  }
  Future<void> _create() async {
    if (_saving || _error != null) return;
    if (_sales.isEmpty) { _notice('Aucune vente Pro disponible'); return; }
    final reason = TextEditingController();
    final quantity = TextEditingController(text: '1');
    String? saleId;
    String? validation;
    final result = await showDialog<Map<String, String>>(context: context, builder: (dialogContext) =>
      StatefulBuilder(builder: (dialogContext, update) => AlertDialog(
        title: const Text('Demande de retour'),
        content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: saleId, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Vente Pro *'),
            items: _sales.map((sale) => DropdownMenuItem<String>(value: '${sale['id']}',
              child: Text('${sale['invoice']} — ${sale['client']}', overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) => update(() { saleId = value; validation = null; })),
          TextField(controller: quantity, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité demandée *')),
          TextField(controller: reason, maxLines: 3,
            decoration: const InputDecoration(labelText: 'Motif détaillé *')),
          if (validation != null) Text(validation!, style: const TextStyle(color: Colors.red)),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(onPressed: () {
            final q = int.tryParse(quantity.text.trim());
            if (saleId == null || q == null || q <= 0 || reason.text.trim().isEmpty) {
              update(() => validation = 'Vente, quantité positive et motif obligatoires'); return;
            }
            Navigator.pop(dialogContext, {'saleId': saleId!, 'quantity': '$q', 'reason': reason.text.trim()});
          }, child: const Text('Enregistrer')),
        ],
      )));
    // Ne pas libérer les contrôleurs pendant la fermeture animée de la boîte de dialogue.
    if (result == null || _saving) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final freshSales = _decode(prefs.getString(_salesKey));
      final freshReturns = _decode(prefs.getString(_key));
      final matching = freshSales.where((sale) => '${sale['id']}' == result['saleId']).toList();
      if (matching.length != 1) throw StateError('Vente introuvable ou ambiguë');
      final sale = matching.single;
      final q = int.parse(result['quantity']!);
      final sold = int.tryParse('${sale['quantity']}');
      if (sold == null || sold <= 0) throw StateError('Quantité de vente non vérifiable');
      final already = freshReturns.where((entry) => '${entry['saleId']}' == result['saleId'] && entry['status'] != 'Rejeté')
        .fold<int>(0, (sum, entry) => sum + (int.tryParse('${entry['quantity']}') ?? 0));
      if (q > sold - already) throw StateError('Quantité supérieure au solde retournable');
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      if (freshReturns.any((entry) => '${entry['id']}' == id)) throw StateError('Identifiant déjà utilisé');
      final entry = <String, dynamic>{'id': id, 'number': 'RET-$id', 'saleId': result['saleId'],
        'invoice': '${sale['invoice']}', 'client': '${sale['client']}', 'article': '${sale['article']}',
        'quantity': q, 'reason': result['reason'], 'status': 'Demandé',
        'createdAt': DateTime.now().toIso8601String()};
      if (!await prefs.setString(_key, jsonEncode([...freshReturns, entry]))) throw StateError('Écriture non confirmée');
      if (mounted) setState(() { _returns = [...freshReturns, entry]; _sales = freshSales; });
      _notice('Demande enregistrée sans effet sur le stock');
    } catch (e) { _notice('Enregistrement refusé : $e'); await _load(); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _setStatus(Map<String, dynamic> item, String status) async {
    if (_saving || _error != null) return;
    if (item['status'] != 'Demandé') { _notice('Seules les demandes peuvent être examinées'); return; }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final fresh = _decode(prefs.getString(_key));
      final matching = fresh.where((entry) => '${entry['id']}' == '${item['id']}').toList();
      if (matching.length != 1 || matching.single['status'] != 'Demandé') throw StateError('Statut modifié entre-temps');
      matching.single['status'] = status;
      matching.single['updatedAt'] = DateTime.now().toIso8601String();
      if (!await prefs.setString(_key, jsonEncode(fresh))) throw StateError('Écriture non confirmée');
      if (mounted) setState(() => _returns = fresh);
      _notice('Statut mis à jour — aucun remboursement ni mouvement de stock');
    } catch (e) { _notice('Mise à jour refusée : $e'); await _load(); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _export() async {
    String cell(dynamic value) => '"${'$value'.replaceAll('"', '""')}"';
    final buffer = StringBuffer('Numéro;Date;Facture;Client;Article;Quantité;Statut;Motif\n');
    for (final item in _returns) {
      buffer.writeln([item['number'], item['createdAt'], item['invoice'], item['client'], item['article'],
        item['quantity'], item['status'], item['reason']].map(cell).join(';'));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    _notice('CSV copié dans le presse-papiers');
  }
  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase().trim();
    final shown = _returns.where((entry) =>
      (_filter == 'Tous' || entry['status'] == _filter) &&
      (query.isEmpty || [entry['number'], entry['invoice'], entry['client'], entry['article'], entry['reason']]
        .any((value) => '$value'.toLowerCase().contains(query)))).toList()
      ..sort((a, b) => '${b['createdAt']}'.compareTo('${a['createdAt']}'));
    return Scaffold(appBar: AppBar(title: const Text('Retours et demandes d’avoir Pro')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
      _error != null ? Center(child: Text('Données illisibles : $_error. Écriture bloquée.')) :
      Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        const Text('Registre de demandes uniquement : aucun retour en stock, remboursement ou avoir comptable automatique.'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(onPressed: _saving ? null : _create, icon: const Icon(Icons.assignment_return_outlined), label: const Text('Demander un retour')),
          OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Actualiser')),
          OutlinedButton.icon(onPressed: _export, icon: const Icon(Icons.copy), label: const Text('CSV')),
        ]),
        TextField(controller: _search, onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Rechercher')),
        DropdownButton<String>(value: _filter,
          items: ['Tous', 'Demandé', 'Accepté', 'Rejeté'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (value) => setState(() => _filter = value ?? 'Tous')),
        Expanded(child: shown.isEmpty ? const Center(child: Text('Aucune demande de retour')) :
          ListView.builder(itemCount: shown.length, itemBuilder: (ctx, index) {
            final item = shown[index];
            return Card(child: ListTile(
              title: Text('${item['number']} • ${item['status']}'),
              subtitle: Text('${item['invoice']} • ${item['client']} • Qté ${item['quantity']} • ${item['reason']}'),
              trailing: item['status'] == 'Demandé' ? PopupMenuButton<String>(
                onSelected: (status) => _setStatus(item, status),
                itemBuilder: (_) => [const PopupMenuItem(value: 'Accepté', child: Text('Accepter la demande')),
                  const PopupMenuItem(value: 'Rejeté', child: Text('Rejeter la demande'))]) : null,
            ));
          })),
      ])));
  }
}
