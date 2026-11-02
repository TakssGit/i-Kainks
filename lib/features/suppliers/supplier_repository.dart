import 'package:isar/isar.dart';
import 'supplier.dart';

class SupplierRepository {
  final Isar db;
  SupplierRepository(this.db);
  Future<List<Supplier>> all() => db.suppliers.where().findAll();
  Future<Supplier?> byLegacyId(String id) => db.suppliers.filter().legacyIdEqualTo(id).findFirst();
  Future<String?> validate(Supplier supplier) async {
    supplier.code = supplier.code.trim().toUpperCase();
    supplier.name = supplier.name.trim();
    supplier.email = supplier.email?.trim();
    if (supplier.code.isEmpty || supplier.name.isEmpty) return 'Code et raison sociale obligatoires';
    if (!RegExp(r'^[A-Z0-9_-]{2,30}$').hasMatch(supplier.code)) return 'Code invalide (2 à 30 caractères)';
    final email = supplier.email ?? '';
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return 'Adresse e-mail invalide';
    final duplicate = await db.suppliers.filter().codeEqualTo(supplier.code).findFirst();
    if (duplicate != null && duplicate.id != supplier.id) return 'Code fournisseur déjà utilisé';
    return null;
  }
  Future<void> save(Supplier supplier) async {
    final error = await validate(supplier);
    if (error != null) throw FormatException(error);
    supplier.updatedAt = DateTime.now();
    await db.writeTxn(() async { await db.suppliers.put(supplier); });
  }
  Future<void> setActive(Supplier supplier, bool value) async {
    supplier.active = value;
    await save(supplier);
  }
}
