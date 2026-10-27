import 'package:flutter/material.dart';
import 'core/database/database_service.dart';
import 'features/management/management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseService.initialize();
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: SelectableText('Impossible d’ouvrir la base locale : $e'))))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'i-Kaink’s', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2354a2)), scaffoldBackgroundColor: const Color(0xfff5f7fb)),
    home: const ManagementScreen(),
  );
}
