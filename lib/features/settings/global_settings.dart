import 'package:isar/isar.dart';

part 'global_settings.g.dart';

@Collection()
class GlobalSettings {
  Id id = 1;

  late String companyName;
  late String slogan;
  late String sectorActivity;
  late String address;
  late String city;
  late String phones;
  late String stat;
  late String nif;
  late String rcs;
  late String currency;
}