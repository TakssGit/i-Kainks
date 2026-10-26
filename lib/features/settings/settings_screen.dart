import 'package:flutter/material.dart';
import '../../core/database/database_service.dart';
import 'global_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _sloganController;
  late TextEditingController _sectorController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phonesController;
  late TextEditingController _statController;
  late TextEditingController _nifController;
  late TextEditingController _rcsController;
  late TextEditingController _currencyController;

  bool _isLoading = true;
  GlobalSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await DatabaseService.isar.globalSettings.get(1);
    if (_settings != null) {
      _nameController = TextEditingController(text: _settings!.companyName);
      _sloganController = TextEditingController(text: _settings!.slogan);
      _sectorController = TextEditingController(text: _settings!.sectorActivity);
      _addressController = TextEditingController(text: _settings!.address);
      _cityController = TextEditingController(text: _settings!.city);
      _phonesController = TextEditingController(text: _settings!.phones);
      _statController = TextEditingController(text: _settings!.stat);
      _nifController = TextEditingController(text: _settings!.nif);
      _rcsController = TextEditingController(text: _settings!.rcs);
      _currencyController = TextEditingController(text: _settings!.currency);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseService.isar.writeTxn(() async {
        _settings!
          ..companyName = _nameController.text
          ..slogan = _sloganController.text
          ..sectorActivity = _sectorController.text
          ..address = _addressController.text
          ..city = _cityController.text
          ..phones = _phonesController.text
          ..stat = _statController.text
          ..nif = _nifController.text
          ..rcs = _rcsController.text
          ..currency = _currencyController.text;

        await DatabaseService.isar.globalSettings.put(_settings!);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres enregistrés avec succès !')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _sectorController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phonesController.dispose();
    _statController.dispose();
    _nifController.dispose();
    _rcsController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres Universels - i-Kaink\'s')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom de l\'entreprise')),
              TextFormField(controller: _sloganController, decoration: const InputDecoration(labelText: 'Slogan')),
              TextFormField(controller: _sectorController, decoration: const InputDecoration(labelText: 'Secteur d\'activité (ex: Quincaillerie, Pharmacie...)')),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adresse')),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Ville')),
              TextFormField(controller: _phonesController, decoration: const InputDecoration(labelText: 'Téléphones (séparés par /)')),
              TextFormField(controller: _statController, decoration: const InputDecoration(labelText: 'STAT')),
              TextFormField(controller: _nifController, decoration: const InputDecoration(labelText: 'NIF')),
              TextFormField(controller: _rcsController, decoration: const InputDecoration(labelText: 'RCS')),
              TextFormField(controller: _currencyController, decoration: const InputDecoration(labelText: 'Devise (ex: Ar)')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}