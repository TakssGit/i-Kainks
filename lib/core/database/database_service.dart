import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:i_kainks/features/settings/global_settings.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> initialize() async {
    // Utiliser le dossier de support de l'application (recommandé pour les bases de données locales)
    final dir = await getApplicationSupportDirectory();
    
    final dbDir = Directory(dir.path);
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    
    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [GlobalSettingsSchema],
        directory: dbDir.path,
      );
    } else {
      isar = Isar.getInstance()!;
    }

    final settingsCount = await isar.globalSettings.count();
    if (settingsCount == 0) {
      await isar.writeTxn(() async {
        final defaultSettings = GlobalSettings()
          ..companyName = "Aaron's Store"
          ..slogan = "Plus qu'un partenaire... en Quincaillerie Générale"
          ..sectorActivity = "Quincaillerie Générale"
          ..address = "Lot IIP 79 Anaradoha"
          ..city = "Antananarivo 101"
          ..phones = "034 31 789 34 / 033 29 879 91"
          ..stat = "47521 11 2014 0 0 5975/"
          ..nif = "500175197"
          ..rcs = "2014 A 01349"
          ..currency = "Ar";
        await isar.globalSettings.put(defaultSettings);
      });
    }
  }
}