import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Lecture seule: documents issus des ventes et devis Pro existants.
/// Aucun changement de stock, de règlement ou de statut.
class DocumentsProScreen extends StatefulWidget {
  const DocumentsProScreen({super.key});
  @override
  State<DocumentsProScreen> createState() => _DocumentsProScreenState();
}

class _DocumentsProScreenState extends State<DocumentsProScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _quotes = [];
  List<Map<String, dynamic>> _payments = [];
  bool _busy = true;
  bool _printing = false;
  String? _error;
  String _type = 'Factures';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Liste de documents invalide');
    return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
  double _number(dynamic value) => value is num
      ? value.toDouble() : double.tryParse('$value'.replaceAll(',', '.')) ?? double.nan;
  String _money(double value) => value.isFinite ? '${value.toStringAsFixed(0)} Ar' : 'Montant invalide';
  String _field(Map<String, dynamic> data, String key) => '${data[key] ?? ''}';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sales = _decode(prefs.getString('ikainks_v008_sales_pro'));
      final quotes = _decode(prefs.getString('ikainks_v009_quotes_pro'));
      final payments = _decode(prefs.getString('ikainks_v011_payments_pro'));
      if (!mounted) return;
      setState(() { _sales = sales; _quotes = quotes; _payments = payments; _busy = false; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = '$e'; });
    }
  }

  double _paid(String saleId) => _payments
      .where((payment) => '${payment['saleId']}' == saleId)
      .fold<double>(0, (sum, payment) {
        final n = _number(payment['amount']);
        return sum + (n.isFinite ? n : 0);
      });

  List<Map<String, dynamic>> get _visible {
    final data = _type == 'Factures' ? _sales : _quotes;
    final query = _search.text.trim().toLowerCase();
    return data.where((item) => query.isEmpty ||
      item.values.any((v) => '$v'.toLowerCase().contains(query))).toList().reversed.toList();
  }

  Future<void> _print(Map<String, dynamic> item) async {
    if (_printing) return;
    setState(() => _printing = true);
    try {
      final invoice = _type == 'Factures';
      final reference = _field(item, invoice ? 'invoice' : 'number');
      final number = reference.isNotEmpty ? reference : _field(item, 'id');
      final qty = _number(item[invoice ? 'qty' : 'quantity']);
      final unit = _number(item[invoice ? 'price' : 'unitPrice']);
      final total = _number(item['total']);
      if (!qty.isFinite || !unit.isFinite || !total.isFinite || qty <= 0 || unit < 0 || total < 0) {
        throw const FormatException('Montants incohérents : impression refusée');
      }
      final paid = invoice ? _paid(_field(item, 'id')) : 0.0;
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(38),
        build: (ctx) => [
          pw.Text('i-KAINKS', style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(invoice ? 'FACTURE - $number' : 'DEVIS - $number', style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text('Date : ${_field(item, invoice ? 'at' : 'createdAt')}'),
          pw.Text('Client : ${_field(item, invoice ? 'client' : 'customer').isEmpty ? 'Non renseigne' : _field(item, invoice ? 'client' : 'customer')}'),
          pw.SizedBox(height: 18),
          pw.Table.fromTextArray(headers: ['Article', 'Quantite', 'P.U. (Ar)', 'Total (Ar)'], data: [[
            _field(item, 'article'), '$qty', unit.toStringAsFixed(2), total.toStringAsFixed(2)
          ]]),
          pw.SizedBox(height: 12),
          pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Total : ${_money(total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          if (invoice) pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Versements enregistres : ${_money(paid)}')),
          if (invoice) pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Reste : ${_money(total - paid)}')),
          pw.SizedBox(height: 18),
          pw.Text('Document genere depuis les donnees Pro existantes. Verifier les informations legales, taxes et identite du vendeur avant remise au client.', style: const pw.TextStyle(fontSize: 9)),
        ]));
      await Printing.layoutPdf(onLayout: (_) async => pdf.save(), name: '${invoice ? 'Facture' : 'Devis'}_$number');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impression impossible : $e')));
    } finally { if (mounted) setState(() => _printing = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Lecture impossible : $_error'),
      FilledButton(onPressed: () { setState(() => _busy = true); _load(); }, child: const Text('Reessayer')),
    ]));
    final visible = _visible;
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('Documents Pro', style: Theme.of(context).textTheme.titleLarge),
        DropdownButton<String>(value: _type, items: const [
          DropdownMenuItem(value: 'Factures', child: Text('Factures')),
          DropdownMenuItem(value: 'Devis', child: Text('Devis')),
        ], onChanged: (v) => setState(() => _type = v ?? 'Factures')),
        OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Actualiser')),
      ]),
      const SizedBox(height: 12),
      TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.search), labelText: 'Rechercher')),
      const SizedBox(height: 12),
      Expanded(child: visible.isEmpty ? const Center(child: Text('Aucun document Pro correspondant')) : ListView.builder(
        itemCount: visible.length, itemBuilder: (ctx, i) {
          final item = visible[i];
          final number = _field(item, _type == 'Factures' ? 'invoice' : 'number');
          return Card(child: ListTile(
            title: Text('${number.isEmpty ? _field(item, 'id') : number} - ${_field(item, _type == 'Factures' ? 'client' : 'customer')}'),
            subtitle: Text('${_field(item, 'article')} | ${_money(_number(item['total']))}'),
            trailing: IconButton(tooltip: 'Imprimer PDF', icon: const Icon(Icons.picture_as_pdf_outlined), onPressed: _printing ? null : () => _print(item)),
          ));
        })),
    ]));
  }
}
