import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supplier.dart';
import 'supplier_repository.dart';

class SuppliersScreen extends StatefulWidget {
  final Isar database;
  const SuppliersScreen({super.key, required this.database});
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SupplierRepository repository = SupplierRepository(widget.database);
  List<Supplier> records = [];
  String search = '';
  String status = 'Actifs';
  String sort = 'Nom';
  int page = 0;
  static const int pageSize = 15;
  bool busy = false;

  @override
  void initState() { super.initState(); _reload(); }

  Future<void> _reload() async {
    try {
      final data = await repository.all();
      if (mounted) setState(() { records = data; busy = false; });
    } catch (e) { if (mounted) { setState(() => busy = false); _notice('Lecture impossible : $e'); } }
  }

  void _notice(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Supplier> get filtered {
    final q = search.trim().toLowerCase();
    final list = records.where((s) {
      if (status == 'Actifs' && !s.active) return false;
      if (status == 'Archivés' && s.active) return false;
      return q.isEmpty || [s.code, s.name, s.contact, s.phone, s.email, s.city, s.nif]
          .any((x) => (x ?? '').toLowerCase().contains(q));
    }).toList();
    list.sort((a,b) {
      switch (sort) {
        case 'Code': return a.code.compareTo(b.code);
        case 'Récent': return b.updatedAt.compareTo(a.updatedAt);
        default: return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });
    return list;
  }

  Future<void> _edit([Supplier? original]) async {
    final fields = <String, TextEditingController>{
      'Code *': TextEditingController(text: original?.code ?? ''),
      'Raison sociale / Nom *': TextEditingController(text: original?.name ?? ''),
      'Contact': TextEditingController(text: original?.contact ?? ''),
      'Téléphone': TextEditingController(text: original?.phone ?? ''),
      'E-mail': TextEditingController(text: original?.email ?? ''),
      'Adresse': TextEditingController(text: original?.address ?? ''),
      'Ville': TextEditingController(text: original?.city ?? ''),
      'NIF': TextEditingController(text: original?.nif ?? ''),
      'STAT': TextEditingController(text: original?.stat ?? ''),
      'RCS': TextEditingController(text: original?.rcs ?? ''),
      'Notes': TextEditingController(text: original?.notes ?? ''),
    };
    String category = original?.category ?? 'Professionnel';
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, refresh) => AlertDialog(
        title: Text(original == null ? 'Nouveau fournisseur' : 'Modifier fournisseur'),
        content: SizedBox(width: 540, child: Form(key: formKey, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final entry in fields.entries)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(
                controller: entry.value,
                maxLines: entry.key == 'Notes' ? 3 : 1,
                decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder(), isDense: true),
                validator: (value) => entry.key.endsWith('*') && (value ?? '').trim().isEmpty ? 'Champ obligatoire' : null,
              )),
            DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
              items: const ['Professionnel','Particulier','Grossiste','Autre'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (value) { if (value != null) refresh(() => category = value); }),
          ])))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(onPressed: () { if (formKey.currentState?.validate() == true) Navigator.pop(dialogContext, true); }, child: const Text('Enregistrer')),
        ],
      ),
    ));
    if (result == true) {
      // Use a fresh object so a failed validation never mutates an existing row.
      final s = Supplier()
        ..id = original?.id ?? Isar.autoIncrement
        ..legacyId = original?.legacyId
        ..createdAt = original?.createdAt ?? DateTime.now()
        ..active = original?.active ?? true
        ..code = fields['Code *']!.text
        ..name = fields['Raison sociale / Nom *']!.text
        ..contact = fields['Contact']!.text
        ..phone = fields['Téléphone']!.text
        ..email = fields['E-mail']!.text
        ..address = fields['Adresse']!.text
        ..city = fields['Ville']!.text
        ..nif = fields['NIF']!.text
        ..stat = fields['STAT']!.text
        ..rcs = fields['RCS']!.text
        ..notes = fields['Notes']!.text
        ..category = category;
      try { await repository.save(s); _notice('Fournisseur enregistré'); await _reload(); }
      catch (e) { _notice('Enregistrement refusé : $e'); }
    }
    for (final controller in fields.values) { controller.dispose(); }
  }

  Future<void> _toggle(Supplier s) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.active ? 'Archiver le fournisseur ?' : 'Réactiver le fournisseur ?'),
      content: Text('${s.code} — ${s.name}\nAucune suppression physique ne sera effectuée.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer'))]));
    if (ok != true) return;
    try { await repository.setActive(s, !s.active); await _reload(); }
    catch (e) { _notice('Opération impossible : $e'); }
  }

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';
  String _csv(List<Supplier> list) {
    final rows = <List<String>>[
      ['Code','Nom','Catégorie','Contact','Téléphone','E-mail','Adresse','Ville','NIF','STAT','RCS','Actif'],
      for (final s in list) [s.code,s.name,s.category,s.contact ?? '',s.phone ?? '',s.email ?? '',s.address ?? '',s.city ?? '',s.nif ?? '',s.stat ?? '',s.rcs ?? '',s.active ? 'Oui':'Non'],
    ];
    return '\uFEFF${rows.map((r) => r.map(_csvCell).join(';')).join('\r\n')}';
  }

  Future<void> _copyCsv() async {
    await Clipboard.setData(ClipboardData(text: _csv(filtered)));
    _notice('${filtered.length} fournisseurs copiés au format CSV (presse-papiers)');
  }

  Future<void> _pdf([Supplier? supplier]) async {
    try {
      final doc = pw.Document();
      if (supplier == null) {
        final list = filtered;
        doc.addPage(pw.MultiPage(build: (_) => [
          pw.Text('i-Kaink\'s - Répertoire fournisseurs', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(headers: ['Code','Fournisseur','Téléphone','Ville','Statut'],
            data: list.map((s) => [s.code,s.name,s.phone ?? '',s.city ?? '',s.active ? 'Actif':'Archivé']).toList()),
        ]));
      } else {
        doc.addPage(pw.MultiPage(build: (_) => [
          pw.Text('i-Kaink\'s - Fiche fournisseur', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 14),
          for (final row in <List<String>>[
            ['Code',supplier.code],['Nom',supplier.name],['Catégorie',supplier.category],
            ['Contact',supplier.contact ?? ''],['Téléphone',supplier.phone ?? ''],
            ['E-mail',supplier.email ?? ''],['Adresse',supplier.address ?? ''],
            ['Ville',supplier.city ?? ''],['NIF',supplier.nif ?? ''],['STAT',supplier.stat ?? ''],
            ['RCS',supplier.rcs ?? ''],['Notes',supplier.notes ?? ''],
          ]) pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('${row[0]} : ${row[1]}')),
        ]));
      }
      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e) { _notice('Impression impossible : $e'); }
  }

  Future<void> _importLegacy() async {
    if (busy) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ikainks_v005_suppliers');
    if (raw == null || raw.isEmpty) { _notice('Aucun ancien fournisseur à importer'); return; }
    List<dynamic> old;
    try { old = jsonDecode(raw) as List<dynamic>; }
    catch (e) { _notice('Format historique invalide : $e'); return; }
    final approved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Importer les anciens fournisseurs ?'),
      content: Text('${old.length} enregistrements trouvés. Effectuez une sauvegarde de vos données AVANT de continuer. Les anciennes données ne seront pas effacées. Les achats historiques ne seront pas modifiés.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sauvegarde effectuée, importer'))]));
    if (approved != true) return;
    setState(() => busy = true);
    int imported = 0, skipped = 0;
    for (var i = 0; i < old.length; i++) {
      try {
        final row = Map<String,dynamic>.from(old[i] as Map);
        final legacy = (row['id'] ?? 'row_$i').toString();
        if (await repository.byLegacyId(legacy) != null) { skipped++; continue; }
        final name = (row['name'] ?? '').toString().trim();
        if (name.isEmpty) { skipped++; continue; }
        final s = Supplier()
          ..legacyId = legacy
          ..code = 'OLD${(i+1).toString().padLeft(6,'0')}'
          ..name = name
          ..phone = (row['phone'] ?? '').toString()
          ..address = (row['address'] ?? '').toString();
        await repository.save(s);
        imported++;
      } catch (_) { skipped++; }
    }
    if (mounted) { setState(() => busy = false); _notice('Import : $imported ajoutés, $skipped ignorés. Historique préservé.'); }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final all = filtered;
    final totalPages = all.isEmpty ? 1 : ((all.length - 1) ~/ pageSize) + 1;
    final safePage = page.clamp(0, totalPages - 1).toInt();
    final visible = all.skip(safePage * pageSize).take(pageSize).toList();
    return Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const Text('FOURNISSEURS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
        FilledButton.icon(onPressed: busy ? null : () => _edit(), icon: const Icon(Icons.add), label: const Text('Ajouter')),
        OutlinedButton.icon(onPressed: busy ? null : _copyCsv, icon: const Icon(Icons.copy), label: const Text('Copier CSV')),
        OutlinedButton.icon(onPressed: busy ? null : () => _pdf(), icon: const Icon(Icons.print), label: const Text('Imprimer PDF')),
        OutlinedButton.icon(onPressed: busy ? null : _importLegacy, icon: const Icon(Icons.input), label: const Text('Importer anciens')),
      ]))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [
        SizedBox(width: 240, child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher', border: OutlineInputBorder(), isDense: true),
          onChanged: (v) => setState(() { search = v; page = 0; }))),
        DropdownButton<String>(value: status, items: const ['Actifs','Archivés','Tous'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) { if (v != null) setState(() { status = v; page = 0; }); }),
        DropdownButton<String>(value: sort, items: const ['Nom','Code','Récent'].map((v) => DropdownMenuItem(value: v, child: Text('Tri : $v'))).toList(),
          onChanged: (v) { if (v != null) setState(() { sort = v; page = 0; }); }),
        Text('${all.length} résultat(s)'),
      ])),
      Expanded(child: visible.isEmpty ? const Center(child: Text('Aucun fournisseur correspondant')) : ListView.builder(
        itemCount: visible.length, itemBuilder: (context, index) {
          final s = visible[index];
          return Card(child: ListTile(
            leading: Icon(s.active ? Icons.local_shipping : Icons.archive_outlined),
            title: Text('${s.code} — ${s.name}', maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${s.phone ?? ''}  ${s.city ?? ''}  ${s.active ? 'Actif':'Archivé'}'),
            trailing: Wrap(spacing: 2, children: [
              IconButton(tooltip: 'Fiche PDF', onPressed: () => _pdf(s), icon: const Icon(Icons.picture_as_pdf_outlined)),
              IconButton(tooltip: 'Modifier', onPressed: () => _edit(s), icon: const Icon(Icons.edit_outlined)),
              IconButton(tooltip: s.active ? 'Archiver':'Réactiver', onPressed: () => _toggle(s), icon: Icon(s.active ? Icons.archive_outlined : Icons.restore)),
            ]),
          ));
        })),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: safePage > 0 ? () => setState(() => page = safePage - 1) : null, icon: const Icon(Icons.chevron_left)),
        Text('Page ${safePage + 1} / $totalPages'),
        IconButton(onPressed: safePage + 1 < totalPages ? () => setState(() => page = safePage + 1) : null, icon: const Icon(Icons.chevron_right)),
      ]),
    ]);
  }
}
