import 'package:isar/isar.dart';
part 'supplier.g.dart';

@collection
class Supplier {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: false)
  late String code;
  late String name;
  String? contact;
  String? phone;
  String? email;
  String? address;
  String? city;
  String? nif;
  String? stat;
  String? rcs;
  String? notes;
  String category = 'Professionnel';
  bool active = true;
  @Index(unique: true, replace: false)
  String? legacyId;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
