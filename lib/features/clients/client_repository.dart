import 'package:isar/isar.dart';
import 'client.dart';

class ClientRepository {
  final Isar db;
  ClientRepository(this.db);

  Future<List<Client>> all() => db.clients.where().findAll();

  Future<String?> validate(Client client) async {
    client.code = client.code.trim().toUpperCase();
    client.nom = client.nom.trim();
    if (client.code.isEmpty || client.nom.isEmpty) return 'Code et nom obligatoires';
    if (!RegExp(r'^[A-Z0-9_-]{2,30}$').hasMatch(client.code)) return 'Code invalide (2 à 30 caractères)';
    final email = client.email?.trim() ?? '';
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return 'Email invalide';
    final existing = await db.clients.filter().codeEqualTo(client.code).findFirst();
    if (existing != null && existing.id != client.id) return 'Code client déjà utilisé';
    return null;
  }

  Future<void> save(Client client) async {
    final error = await validate(client);
    if (error != null) throw FormatException(error);
    client.updatedAt = DateTime.now();
    await db.writeTxn(() async { await db.clients.put(client); });
  }

  Future<void> reactivate(Client client) async {
    client.actif = true;
    await save(client);
  }

  Future<void> archive(Client client) async {
    client.actif = false;
    await save(client);
  }
}
