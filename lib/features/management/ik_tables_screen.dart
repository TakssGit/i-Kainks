import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modules additionnels, stockage local indépendant, aucune migration destructive.
class ModuleDefinition {
  final String title;
  final List<String> fields;
  const ModuleDefinition(this.title, this.fields);
}

const Map<String, ModuleDefinition> ikModules = {
  'purchases': ModuleDefinition('Achats et approvisionnements', [
    'Référence',
    'Fournisseur',
    'Article',
    'Quantité',
    'Prix unitaire',
    'Date',
    'Statut',
    'Notes'
  ]),
  'quotes': ModuleDefinition('Devis et proformas',
      ['Numéro', 'Client', 'Objet', 'Montant', 'Date', 'Statut', 'Notes']),
  'expenses': ModuleDefinition('Dépenses et charges', [
    'Libellé',
    'Catégorie',
    'Montant',
    'Date',
    'Mode de paiement',
    'Statut',
    'Notes'
  ]),
  'cash': ModuleDefinition('Caisse et trésorerie', [
    'Référence',
    'Type',
    'Libellé',
    'Montant',
    'Date',
    'Mode de paiement',
    'Notes'
  ]),
  'movements': ModuleDefinition('Mouvements de stock',
      ['Référence', 'Article', 'Type', 'Quantité', 'Date', 'Motif', 'Notes']),
  'categories': ModuleDefinition(
      'Catégories et familles', ['Nom', 'Code', 'Description', 'Statut']),
  'payments': ModuleDefinition('Suivi des règlements', [
    'Référence',
    'Tiers',
    'Type',
    'Montant',
    'Date',
    'Échéance',
    'Statut',
    'Notes'
  ]),
  'inventory': ModuleDefinition('Inventaires physiques', [
    'Référence',
    'Article',
    'Stock théorique',
    'Stock compté',
    'Date',
    'Statut',
    'Notes'
  ]),
};

class IkTableScreen extends StatefulWidget {
  final String moduleKey;
  final List<Map<String, dynamic>>? externalRows;
  const IkTableScreen({super.key, required this.moduleKey, this.externalRows});
  @override
  State<IkTableScreen> createState() => _IkTableScreenState();
}

class _IkTableScreenState extends State<IkTableScreen> {
  List<Map<String, dynamic>> rows = [];
  bool busy = true;
  String search = '';
  String status = 'Tous';
  String sortField = '';
  bool ascending = true;
  DateTime? from;
  DateTime? until;
  String? error;
  final searchController = TextEditingController();
  ModuleDefinition get def =>
      ikModules[widget.moduleKey] ?? const ModuleDefinition('Tableau', ['Nom']);
  String get keyName => 'ikainks_v011_module_${widget.moduleKey}';
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant IkTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moduleKey != widget.moduleKey ||
        oldWidget.externalRows != widget.externalRows) _load();
  }

  Future<void> _load() async {
    if (widget.externalRows != null) {
      if (mounted)
        setState(() {
          rows = widget.externalRows!
              .map((x) => Map<String, dynamic>.from(x))
              .toList();
          busy = false;
          error = null;
        });
      return;
    }
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(keyName);
      final parsed = raw == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(raw) as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
      if (mounted)
        setState(() {
          rows = parsed;
          busy = false;
          error = null;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          busy = false;
          error = '$e';
        });
    }
  }

  Future<bool> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ok = await p.setString(keyName, jsonEncode(rows));
      if (!ok) throw Exception('Sauvegarde non confirmée');
      return true;
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur de sauvegarde : $e')));
      return false;
    }
  }

  String _value(Map<String, dynamic> row, String field) =>
      '${row[field] ?? ''}';
  DateTime? _date(Map<String, dynamic> row) =>
      DateTime.tryParse(_value(row, 'Date'));
  List<Map<String, dynamic>> get filtered {
    final q = search.trim().toLowerCase();
    final result = rows.where((r) {
      if (q.isNotEmpty && !r.values.any((v) => '$v'.toLowerCase().contains(q)))
        return false;
      if (status != 'Tous' && _value(r, 'Statut') != status) return false;
      if (from != null || until != null) {
        final d = _date(r);
        if (d == null) return false;
        if (from != null && d.isBefore(from!)) return false;
        if (until != null && d.isAfter(until!.add(const Duration(days: 1))))
          return false;
      }
      return true;
    }).toList();
    if (sortField.isNotEmpty) {
      result.sort((a, b) {
        final av = _value(a, sortField), bv = _value(b, sortField);
        final an = double.tryParse(av.replaceAll(',', '.'));
        final bn = double.tryParse(bv.replaceAll(',', '.'));
        final c = an != null && bn != null
            ? an.compareTo(bn)
            : av.toLowerCase().compareTo(bv.toLowerCase());
        return ascending ? c : -c;
      });
    }
    return result;
  }

  Future<void> _edit([Map<String, dynamic>? old]) async {
    final controls = {
      for (final field in def.fields)
        field: TextEditingController(
            text: old == null
                ? (field == 'Date'
                    ? DateTime.now().toIso8601String().substring(0, 10)
                    : '')
                : _value(old, field))
    };
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(old == null
                  ? 'Ajouter — ${def.title}'
                  : 'Modifier — ${def.title}'),
              content: SizedBox(
                  width: MediaQuery.sizeOf(ctx).width < 600
                      ? MediaQuery.sizeOf(ctx).width * 0.76
                      : 500,
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final field in def.fields)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: controls[field],
                            decoration: InputDecoration(
                                labelText: field,
                                border: const OutlineInputBorder(),
                                isDense: true),
                            keyboardType: [
                              'Montant',
                              'Quantité',
                              'Prix unitaire',
                              'Stock théorique',
                              'Stock compté'
                            ].contains(field)
                                ? const TextInputType.numberWithOptions(
                                    decimal: true)
                                : TextInputType.text,
                          )),
                  ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Annuler')),
                FilledButton(
                    onPressed: () {
                      if (controls[def.fields.first]!.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Premier champ obligatoire')));
                        return;
                      }
                      Navigator.pop(ctx, {
                        '_id': old?['_id'] ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        for (final f in def.fields) f: controls[f]!.text.trim()
                      });
                    },
                    child: const Text('Enregistrer'))
              ],
            ));
    // Ne pas disposer avant la fin de la fermeture de la boîte de dialogue.
    if (!mounted || result == null) return;
    final before = rows.map((e) => Map<String, dynamic>.from(e)).toList();
    setState(() {
      if (old == null) {
        rows.add(result);
      } else {
        final i = rows.indexWhere((e) => e['_id'] == old['_id']);
        if (i >= 0) rows[i] = result;
      }
    });
    if (!await _save() && mounted) setState(() => rows = before);
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Supprimer cette ligne ?'),
                content:
                    const Text('Cette opération ne pourra pas être annulée.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Annuler')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Supprimer'))
                ]));
    if (yes != true || !mounted) return;
    final before = rows.map((e) => Map<String, dynamic>.from(e)).toList();
    setState(() => rows.remove(item));
    if (!await _save() && mounted) setState(() => rows = before);
  }

  Future<void> _export() async {
    final data = filtered;
    String quote(String s) => '"${s.replaceAll('"', '""')}"';
    final cols = def.fields;
    final csv =
        '\uFEFF${cols.map(quote).join(';')}\r\n${data.map((r) => cols.map((c) => quote(_value(r, c))).join(';')).join('\r\n')}';
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${data.length} lignes CSV copiées. Coller dans Excel ou un fichier .csv.')));
  }

  Future<void> _chooseDates() async {
    final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: from != null && until != null
            ? DateTimeRange(start: from!, end: until!)
            : null);
    if (range != null && mounted)
      setState(() {
        from = range.start;
        until = range.end;
      });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (busy) return const Center(child: CircularProgressIndicator());
    if (error != null)
      return Center(child: Text('Lecture impossible : $error'));
    final statuses = <String>{
      'Tous',
      ...rows.map((e) => _value(e, 'Statut')).where((s) => s.isNotEmpty)
    }.toList();
    final items = filtered;
    final compact = MediaQuery.sizeOf(context).width < 620;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(def.title, style: Theme.of(context).textTheme.titleLarge),
                if (widget.externalRows == null)
                  FilledButton.icon(
                      onPressed: () => _edit(),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter')),
                OutlinedButton.icon(
                    onPressed: _export,
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copier CSV')),
                OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser')),
              ])),
      Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
                width: compact ? 210 : 240,
                child: TextField(
                    controller: searchController,
                    onChanged: (v) => setState(() => search = v),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher toutes colonnes',
                        border: OutlineInputBorder(),
                        isDense: true))),
            if (def.fields.contains('Statut'))
              SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                      value: statuses.contains(status) ? status : 'Tous',
                      decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: statuses
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => status = v ?? 'Tous'))),
            SizedBox(
                width: 165,
                child: DropdownButtonFormField<String>(
                    value: sortField,
                    decoration: const InputDecoration(
                        labelText: 'Trier par',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: ['', ...def.fields]
                        .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.isEmpty ? 'Aucun' : f,
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => sortField = v ?? ''))),
            IconButton(
                tooltip: ascending ? 'Croissant' : 'Décroissant',
                onPressed: () => setState(() => ascending = !ascending),
                icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward)),
            if (def.fields.contains('Date'))
              OutlinedButton.icon(
                  onPressed: _chooseDates,
                  icon: const Icon(Icons.date_range),
                  label: Text(from == null
                      ? 'Période'
                      : '${from!.toIso8601String().substring(0, 10)} → ${until!.toIso8601String().substring(0, 10)}')),
            TextButton(
                onPressed: () => setState(() {
                      search = '';
                      searchController.clear();
                      status = 'Tous';
                      sortField = '';
                      from = null;
                      until = null;
                    }),
                child: const Text('Effacer filtres')),
          ]),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
              '${items.length} résultat(s) sur ${rows.length} enregistrement(s)')),
      Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                      'Aucune ligne. Ajoutez une entrée ou modifiez les filtres.'))
              : compact
                  ? ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_value(item, def.fields.first),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 8),
                                  for (final field in def.fields.skip(1))
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: 105,
                                                  child: Text(field,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight
                                                              .w600))),
                                              Expanded(
                                                  child: Text(
                                                      _value(item, field))),
                                            ])),
                                  if (widget.externalRows == null)
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                              onPressed: () => _edit(item),
                                              icon: const Icon(
                                                  Icons.edit_outlined),
                                              label: const Text('Modifier')),
                                          IconButton(
                                              tooltip: 'Supprimer',
                                              onPressed: () => _delete(item),
                                              icon: const Icon(
                                                  Icons.delete_outline)),
                                        ]),
                                ]),
                          ),
                        );
                      },
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                showCheckboxColumn: false,
                                columns: [
                                  for (final f in def.fields)
                                    DataColumn(label: Text(f)),
                                  if (widget.externalRows == null)
                                    const DataColumn(label: Text('Actions'))
                                ],
                                rows: [
                                  for (final item in items)
                                    DataRow(cells: [
                                      for (final f in def.fields)
                                        DataCell(ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 220),
                                            child: Text(_value(item, f),
                                                overflow:
                                                    TextOverflow.ellipsis))),
                                      if (widget.externalRows == null)
                                        DataCell(Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  tooltip: 'Modifier',
                                                  onPressed: () => _edit(item),
                                                  icon: const Icon(Icons.edit)),
                                              IconButton(
                                                  tooltip: 'Supprimer',
                                                  onPressed: () =>
                                                      _delete(item),
                                                  icon: const Icon(
                                                      Icons.delete_outline))
                                            ]))
                                    ]),
                                ],
                              ))))),
    ]);
  }
}
