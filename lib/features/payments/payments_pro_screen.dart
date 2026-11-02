import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paiements liés uniquement aux ventes Pro. Aucun effet sur le stock.
class PaymentsProScreen extends StatefulWidget {
  const PaymentsProScreen({super.key});
  @override
  State<PaymentsProScreen> createState() => _PaymentsProScreenState();
}

class _PaymentsProScreenState extends State<PaymentsProScreen> {
  static const _paymentsKey = 'ikainks_v011_payments_pro';
  static const _salesKey = 'ikainks_v008_sales_pro';
  final _search = TextEditingController();
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _sales = [];
  bool _busy = true;
  bool _saving = false;
  String? _error;
  String _filter = 'Tous';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  double _amount(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value'.replaceAll(',', '.')) ?? double.nan;
  String _money(num value) => '${value.toStringAsFixed(0)} Ar';
  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw);
    if (data is! List) throw const FormatException('Liste invalide');
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
  void _notify(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sales = _decode(prefs.getString(_salesKey));
      final payments = _decode(prefs.getString(_paymentsKey));
      if (mounted) setState(() { _sales = sales; _payments = payments; _busy = false; _error = null; });
    } catch (error) {
      if (mounted) setState(() { _busy = false; _error = '$error'; });
    }
  }
  double _paid(String saleId, List<Map<String, dynamic>> payments) => payments
      .where((payment) => '${payment['saleId']}' == saleId)
      .fold<double>(0, (sum, payment) => sum + _amount(payment['amount']));
  Future<void> _create() async {
    if (_saving || _error != null) return;
    final eligible = _sales.where((sale) {
      final total = _amount(sale['total']);
      final paid = _paid('${sale['id']}', _payments);
      return total.isFinite && total > 0 && paid.isFinite && total - paid > 0.005;
    }).toList();
    if (eligible.isEmpty) { _notify('Aucune vente Pro avec solde positif'); return; }
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    String? selected;
    String method = 'Espèces';
    String? validation;
    final data = await showDialog<Map<String, String>>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: const Text('Enregistrer un encaissement'),
        content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: selected, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Vente Pro *'),
            items: eligible.map((sale) => DropdownMenuItem<String>(
              value: '${sale['id']}',
              child: Text('${sale['invoice']} — ${sale['client']} — ${_money(_amount(sale['total']) - _paid('${sale['id']}', _payments))}', overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) => update(() { selected = value; validation = null; })),
          TextField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Montant reçu (Ar) *')),
          DropdownButtonFormField<String>(initialValue: method,
            decoration: const InputDecoration(labelText: 'Mode de paiement'),
            items: ['Espèces', 'Virement', 'Mobile Money', 'Chèque', 'Carte', 'Autre']
              .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => update(() => method = value ?? 'Espèces')),
          TextField(controller: referenceController, decoration: const InputDecoration(labelText: 'Référence externe (facultative)')),
          TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Observation')),
          if (validation != null) Text(validation!, style: const TextStyle(color: Colors.red)),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () {
            final amount = _amount(amountController.text);
            if (selected == null || !amount.isFinite || amount <= 0) {
              update(() => validation = 'Vente et montant positif obligatoires'); return;
            }
            Navigator.pop(ctx, {'saleId': selected!, 'amount': '$amount',
              'method': method, 'reference': referenceController.text.trim(), 'notes': notesController.text.trim()});
          }, child: const Text('Enregistrer')),
        ],
      )));
    amountController.dispose(); referenceController.dispose(); notesController.dispose();
    if (data == null || _saving) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final freshSales = _decode(prefs.getString(_salesKey));
      final freshPayments = _decode(prefs.getString(_paymentsKey));
      final matches = freshSales.where((sale) => '${sale['id']}' == data['saleId']).toList();
      if (matches.length != 1) throw StateError('Vente introuvable ou ambiguë');
      final sale = matches.single;
      final total = _amount(sale['total']);
      final amount = _amount(data['amount']);
      final paid = _paid('${sale['id']}', freshPayments);
      if (!total.isFinite || !paid.isFinite || !amount.isFinite || amount <= 0 || total - paid < amount - 0.005) {
        throw StateError('Montant supérieur au solde disponible ou montant invalide');
      }
      final reference = data['reference']!.toLowerCase();
      if (reference.isNotEmpty && freshPayments.any((item) => '${item['reference']}'.toLowerCase() == reference)) {
        throw StateError('Référence de paiement déjà utilisée');
      }
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      if (freshPayments.any((item) => '${item['id']}' == id)) throw StateError('Identifiant de paiement déjà présent');
      final entry = <String, dynamic>{'id': id, 'receipt': 'REG-$id', 'saleId': '${sale['id']}',
        'invoice': '${sale['invoice']}', 'client': '${sale['client']}', 'amount': amount,
        'method': data['method'], 'reference': data['reference'], 'notes': data['notes'],
        'createdAt': DateTime.now().toIso8601String()};
      if (!await prefs.setString(_paymentsKey, jsonEncode([...freshPayments, entry]))) {
        throw StateError('Écriture non confirmée');
      }
      if (mounted) setState(() { _payments = [...freshPayments, entry]; _sales = freshSales; });
      _notify('Encaissement ${entry['receipt']} enregistré');
    } catch (error) { _notify('Paiement non enregistré : $error'); await _load(); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _export() async {
    String cell(dynamic value) => '"${'$value'.replaceAll('"', '""')}"';
    final buffer = StringBuffer('Reçu;Date;Facture;Client;Montant Ar;Mode;Référence;Observation\n');
    for (final item in _payments) {
      buffer.writeln([item['receipt'], item['createdAt'], item['invoice'], item['client'],
        item['amount'], item['method'], item['reference'], item['notes']].map(cell).join(';'));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    _notify('CSV des encaissements copié dans le presse-papiers');
  }
  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final shown = _payments.where((item) {
      final matches = query.isEmpty || [item['receipt'], item['invoice'], item['client'], item['reference']]
        .any((value) => '$value'.toLowerCase().contains(query));
      return matches && (_filter == 'Tous' || item['method'] == _filter);
    }).toList()..sort((a, b) => '${b['createdAt']}'.compareTo('${a['createdAt']}'));
    final received = _payments.fold<double>(0, (sum, item) => sum + _amount(item['amount']));
    final due = _sales.fold<double>(0, (sum, sale) {
      final total = _amount(sale['total']);
      final balance = total - _paid('${sale['id']}', _payments);
      return sum + (balance.isFinite && balance > 0 ? balance : 0);
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Règlements & encaissements Pro')),
      body: _busy ? const Center(child: CircularProgressIndicator()) :
        _error != null ? Center(child: Text('Données illisibles : $_error. Aucune écriture autorisée.')) :
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(onPressed: _saving ? null : _create, icon: const Icon(Icons.add), label: const Text('Encaisser')),
            OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Actualiser')),
            OutlinedButton.icon(onPressed: _export, icon: const Icon(Icons.copy), label: const Text('CSV')),
          ]),
          const SizedBox(height: 12),
          Text('Encaissements : ${_money(received)}   •   Soldes des ventes Pro : ${_money(due)}'),
          TextField(controller: _search, onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Rechercher un règlement')),
          DropdownButton<String>(value: _filter,
            items: ['Tous', 'Espèces', 'Virement', 'Mobile Money', 'Chèque', 'Carte', 'Autre']
              .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() => _filter = value ?? 'Tous')),
          Expanded(child: shown.isEmpty ? const Center(child: Text('Aucun règlement')) :
            ListView.builder(itemCount: shown.length, itemBuilder: (ctx, index) {
              final item = shown[index];
              return Card(child: ListTile(
                title: Text('${item['receipt']} — ${_money(_amount(item['amount']))}'),
                subtitle: Text('${item['invoice']} • ${item['client']} • ${item['method']} • ${item['createdAt']}'),
                onTap: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                  title: Text('${item['receipt']}'),
                  content: SelectableText('Facture : ${item['invoice']}\nClient : ${item['client']}\nMontant : ${_money(_amount(item['amount']))}\nMode : ${item['method']}\nRéférence : ${item['reference']}\nNote : ${item['notes']}'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))]))));
            })),
        ])),
    );
  }
}
