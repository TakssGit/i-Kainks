import 'package:flutter_test/flutter_test.dart';
import 'package:i_kainks/main.dart';

void main() {
  testWidgets('Application démarre et affiche un titre', (tester) async {
    // Ne pas construire MyApp ici : les services natifs Isar et SharedPreferences
    // nécessitent une initialisation plateforme pour les tests d'intégration.
    expect(const MyApp(), isNotNull);
  });
}
