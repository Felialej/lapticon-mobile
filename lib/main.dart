import 'package:flutter/material.dart';
import 'screens/registro_screen.dart';  
import 'theme/app_theme.dart';

void main() {
  runApp(const LapticonApp());
}

class LapticonApp extends StatelessWidget {
  const LapticonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lapticon',
      theme: AppTheme.lightTheme,
      home: const RegistroScreen(),
    );
  }
}