import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsEntry extends StatefulWidget {
  const SettingsEntry({super.key});
  @override State<SettingsEntry> createState() => _SettingsEntryState();
}
class _SettingsEntryState extends State<SettingsEntry> {
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  bool busy = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    name.text = p.getString('ikainks_preview_company') ?? '';
    address.text = p.getString('ikainks_preview_address') ?? '';
    phone.text = p.getString('ikainks_preview_phone') ?? '';
    setState(() => busy = false);
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('ikainks_preview_company', name.text);
    await p.setString('ikainks_preview_address', address.text);
    await p.setString('ikainks_preview_phone', phone.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parametres de demonstration enregistres dans Chrome')));
  }
  @override void dispose() { name.dispose(); address.dispose(); phone.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => busy ? const Center(child: CircularProgressIndicator()) : ListView(children: [
    const ListTile(title: Text('Entreprise - Apercu Chrome'), subtitle: Text('Donnees Chrome independantes de Windows')),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Entreprise')),
    TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse')),
    TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telephone')),
    const SizedBox(height: 12), FilledButton(onPressed: _save, child: const Text('Enregistrer')),
  ]);
}
