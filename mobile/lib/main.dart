import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
void main() => runApp(const DustCollectorApp());
class DustCollectorApp extends StatelessWidget {
  const DustCollectorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dust Collector Pro',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark), useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}
