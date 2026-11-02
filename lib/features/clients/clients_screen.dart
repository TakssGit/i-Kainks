import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'client.dart';
import 'client_repository.dart';

class ClientsScreen extends StatefulWidget {
  final Isar database;
  const ClientsScreen({super.key, required this.database});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late final ClientRepository repo = ClientRepository(widget.database);
  List<Client> clients = [];
  String query = '';
  bool onlyActive = true;
  bool busy = false;
  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async {
    final rows = await repo.all();
    if (mounted) setState(() => clients = rows);
  }
  Future<void> edit([Client? current]) async {
    final code = TextEditingController(text: current?.code ?? '');
    final nom = TextEditingController(text: current?.nom ?? '');
    final phone = TextEditingController(text: current?.telephone ?? '');
    final email = TextEditingController(text: current?.email ?? '');
    final city = TextEditingController(text: current?.ville ?? '');
    final address = TextEditingController(text: current?.adresse ?? '');
    final type = TextEditingController(text: current?.type ?? 'Particulier');
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(current == null ? 'Nouveau client' : 'Modifier le client'),
      content: SizedBox(width: 480, child: Form(key: form, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: code, decoration: const InputDecoration(labelText: 'Code *'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Obligatoire' : null),
        TextFormField(controller: nom, decoration: const InputDecoration(labelText: 'Nom *'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Obligatoire' : null),
        TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Téléphone')),
        TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
        TextFormField(controller: city, decoration: const InputDecoration(labelText: 'Ville')),
        TextFormField(controller: address, decoration: const InputDecoration(labelText: 'Adresse')),
        TextFormField(controller: type, decoration: const InputDecoration(labelText: 'Type de client')),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Enregistrer'))],
    ));
    if (ok == true) {
      final item = Client();
      if (current != null) {
        item.id = current.id;
        item.createdAt = current.createdAt;
        item.actif = current.actif;
        item.type = current.type;
      }
      item.code = code.text; item.nom = nom.text; item.telephone = phone.text;
      item.email = email.text; item.ville = city.text; item.adresse = address.text;
      item.type = type.text.trim().isEmpty ? 'Particulier' : type.text.trim();
      try { await repo.save(item); await refresh(); }
      catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enregistrement refusé : $e'))); }
    }
    for (final c in [code, nom, phone, email, city, address, type]) { c.dispose(); }
  }
  String _csvCell(Object? value) => '"${(value ?? '').toString().replaceAll('"', '""')}"';
  Future<void> exportCsv() async {
    final rows = visibleClients();
    final csv = <String>['Code;Nom;Telephone;Email;Ville;Adresse;Type;Actif',
      ...rows.map((c) => [c.code,c.nom,c.telephone,c.email,c.ville,c.adresse,c.type,c.actif ? 'Oui' : 'Non']
        .map(_csvCell).join(';'))].join('\r\n');
    await Clipboard.setData(ClipboardData(text: '\uFEFF$csv'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV copie dans le presse-papiers')));
  }
  Future<void> printClients() async {
    final rows = visibleClients();
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(build: (_) => [
      pw.Text('i-Kaink\'s - Liste des clients', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 14),
      pw.TableHelper.fromTextArray(headers: ['Code','Nom','Telephone','Ville','Statut'],
        data: rows.map((c) => [c.code,c.nom,c.telephone ?? '',c.ville ?? '',c.actif ? 'Actif' : 'Archive']).toList()),
    ]));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
  Future<void> printClient(Client c) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('i-Kaink\'s - Fiche client', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 16),
      ...<String>['Code : ${c.code}','Nom : ${c.nom}','Telephone : ${c.telephone ?? ''}',
        'Email : ${c.email ?? ''}','Ville : ${c.ville ?? ''}',
        'Adresse : ${c.adresse ?? ''}','Type : ${c.type}',
        'Statut : ${c.actif ? 'Actif' : 'Archive'}'].map((t) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text(t))),
    ])));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
  List<Client> visibleClients() {
    final q = query.trim().toLowerCase();
    return clients.where((c) => (!onlyActive || c.actif) &&
      ('${c.code} ${c.nom} ${c.telephone ?? ''} ${c.ville ?? ''}'.toLowerCase().contains(q))).toList()
      ..sort((a,b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
  }
  Future<void> reactivate(Client item) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Réactiver ce client ?'), content: Text(item.nom),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Réactiver'))]));
    if (ok == true) { await repo.reactivate(item); await refresh(); }
  }

  // Reprise volontaire, non destructive. L'ancien stockage est conservé intact.
  Future<void> importLegacy() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('ikainks_v005_clients');
      if (raw == null || raw.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune donnée Clients ancienne à importer')));
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Anciennes données non reconnues');
      final existing = await repo.all();
      final usedCodes = existing.map((c) => c.code.toUpperCase()).toSet();
      final existingNames = existing.map((c) => c.nom.trim().toLowerCase()).toSet();
      final pending = <Client>[];
      var ignored = 0;
      for (var i = 0; i < decoded.length; i++) {
        final value = decoded[i];
        if (value is! Map) { ignored++; continue; }
        final name = (value['name'] ?? '').toString().trim();
        if (name.isEmpty || existingNames.contains(name.toLowerCase())) { ignored++; continue; }
        // Code indépendant des ID de ventes historiques ; aucun ancien ID n'est modifié.
        var code = 'LEGACY-${(i + 1).toString().padLeft(5, '0')}';
        var n = 1;
        while (usedCodes.contains(code)) { code = 'LEGACY-${(i + 1).toString().padLeft(5, '0')}-$n'; n++; }
        final c = Client()..code = code..nom = name
          ..telephone = (value['phone'] ?? '').toString()
          ..adresse = (value['address'] ?? '').toString();
        pending.add(c);
        usedCodes.add(code);
        existingNames.add(name.toLowerCase());
      }
      if (!mounted) return;
      final accepted = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Importer les anciens clients ?'),
        content: Text('${pending.length} client(s) à ajouter ; $ignored ignoré(s). '
          'Les anciens enregistrements SharedPreferences et les ventes ne seront pas modifiés. '
          'Sauvegardez vos données avant de continuer.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer l’import'))]));
      if (accepted != true) return;
      // Une transaction atomique : aucune insertion partielle en cas d'échec.
      await widget.database.writeTxn(() async {
        for (final c in pending) { await widget.database.clients.put(c); }
      });
      await refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${pending.length} client(s) importé(s). Anciennes données conservées.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import annulé : $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> archive(Client item) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Archiver ce client ?'), content: Text(item.nom),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Archiver'))]));
    if (ok == true) { await repo.archive(item); await refresh(); }
  }
  @override
  Widget build(BuildContext context) {
    final rows = visibleClients();
    return Scaffold(appBar: AppBar(title: const Text('Clients'), actions: [IconButton(tooltip: 'Copier CSV', onPressed: exportCsv, icon: const Icon(Icons.table_view)), IconButton(tooltip: 'Imprimer la liste', onPressed: printClients, icon: const Icon(Icons.print)), IconButton(tooltip: 'Importer anciens clients', onPressed: busy ? null : importLegacy, icon: const Icon(Icons.move_to_inbox_outlined)), IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('Client')),
      body: Column(children: [Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 12, children: [
        SizedBox(width: 300, child: TextField(decoration: const InputDecoration(labelText: 'Rechercher', prefixIcon: Icon(Icons.search)), onChanged: (v) => setState(() => query = v))),
        FilterChip(label: const Text('Actifs uniquement'), selected: onlyActive, onSelected: (v) => setState(() => onlyActive = v)),
        Text('${rows.length} client(s)')
      ])), Expanded(child: ListView.builder(itemCount: rows.length, itemBuilder: (ctx, i) {
        final c = rows[i]; return Card(child: ListTile(title: Text(c.nom), subtitle: Text('${c.code} • ${c.telephone ?? ''} • ${c.ville ?? ''}'),
          trailing: Wrap(children: [IconButton(tooltip: 'Imprimer la fiche', icon: const Icon(Icons.print_outlined), onPressed: () => printClient(c)), IconButton(tooltip: 'Modifier', icon: const Icon(Icons.edit), onPressed: () => edit(c)),
            IconButton(tooltip: c.actif ? 'Archiver' : 'Réactiver', icon: Icon(c.actif ? Icons.archive_outlined : Icons.unarchive_outlined), onPressed: c.actif ? () => archive(c) : () => reactivate(c))])));
      }))]));
  }
}
