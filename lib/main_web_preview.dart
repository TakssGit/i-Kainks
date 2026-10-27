import 'package:flutter/material.dart';
import 'features/management/management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'i-Kainks - Apercu mobile Chrome',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff2354a2))),
        home: const ManagementScreen(),
      );
}
