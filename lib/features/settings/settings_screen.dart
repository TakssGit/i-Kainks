import 'package:flutter/material.dart';
import '../../core/database/database_service.dart';
import 'global_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _key = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fields = {};
  GlobalSettings? _settings;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  static const labels = <String, String>{
    'companyName': 'Nom de l’entreprise', 'slogan': 'Slogan',
    'sectorActivity': 'Secteur d’activité', 'address': 'Adresse',
    'city': 'Ville', 'phones': 'Téléphones', 'stat': 'STAT',
    'nif': 'NIF', 'rcs': 'RCS', 'currency': 'Devise',
  };
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final s = await DatabaseService.isar.globalSettings.get(1);
      if (s == null) throw StateError('Profil entreprise introuvable');
      _settings = s;
      final values = <String, String>{
        'companyName': s.companyName, 'slogan': s.slogan,
        'sectorActivity': s.sectorActivity, 'address': s.address,
        'city': s.city, 'phones': s.phones, 'stat': s.stat,
        'nif': s.nif, 'rcs': s.rcs, 'currency': s.currency,
      };
      for (final entry in values.entries) {
        _fields[entry.key] = TextEditingController(text: entry.value);
      }
    } catch (e) { _error = e.toString(); }
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final s = _settings!;
      String val(String key) => _fields[key]!.text.trim();
      s.companyName = val('companyName'); s.slogan = val('slogan');
      s.sectorActivity = val('sectorActivity'); s.address = val('address');
      s.city = val('city'); s.phones = val('phones');
      s.stat = val('stat'); s.nif = val('nif'); s.rcs = val('rcs');
      s.currency = val('currency');
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.globalSettings.put(s);
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enregistrement impossible : $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  void dispose() {
    for (final c in _fields.values) { c.dispose(); }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil de l’entreprise')),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : _error != null ? Center(child: Padding(
            padding: const EdgeInsets.all(24), child: Text(_error!)))
        : Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 740),
            child: Form(key: _key, child: ListView(padding: const EdgeInsets.all(20),
              children: [
                const Text('Identité de votre quincaillerie',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                for (final entry in labels.entries) ...[
                  TextFormField(controller: _fields[entry.key],
                    decoration: InputDecoration(labelText: entry.value,
                      border: const OutlineInputBorder()),
                    validator: (v) => (entry.key == 'companyName' || entry.key == 'currency') &&
                      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null),
                  const SizedBox(height: 14),
                ],
                FilledButton.icon(onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Enregistrement…' : 'Enregistrer')),
              ])))));
  }
}
