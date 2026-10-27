import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/settings/global_settings.dart';

class DatabaseService {
  static late final Isar isar;
  static Future<void> initialize() async {
    final root = await getApplicationSupportDirectory();
    final dbDir = Directory(root.path);
    if (!await dbDir.exists()) await dbDir.create(recursive: true);
    final existing = Isar.getInstance('ikainks');
    isar = existing ?? await Isar.open(
      [GlobalSettingsSchema], directory: dbDir.path, name: 'ikainks');
    final current = await isar.globalSettings.get(1);
    if (current == null) {
      await isar.writeTxn(() async {
        final defaults = GlobalSettings()
          ..id = 1
          ..companyName = "Aaron's Store"
          ..slogan = "Plus qu'un partenaire... en Quincaillerie Générale"
          ..sectorActivity = 'Quincaillerie Générale'
          ..address = 'Lot IIP 79 Anaradoha'
          ..city = 'Antananarivo 101'
          ..phones = '034 31 789 34 / 033 29 879 91'
          ..stat = '47521 11 2014 0 0 5975/'
          ..nif = '500175197'
          ..rcs = '2014 A 01349'
          ..currency = 'Ar';
        await isar.globalSettings.put(defaults);
      });
    }
  }
}
