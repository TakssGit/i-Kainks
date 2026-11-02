import 'package:isar/isar.dart';
part 'client.g.dart';

@collection
class Client {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: false)
  late String code;
  late String nom;
  String? telephone;
  String? email;
  String? adresse;
  String? ville;
  String type = 'Particulier';
  bool actif = true;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
