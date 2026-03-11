import 'package:flutter/material.dart';
import 'theme/Theme.dart';
import 'screens/Landing_screen.dart';

void main() {
  runApp(const FarmLinkApp());
}

class FarmLinkApp extends StatelessWidget {
  const FarmLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}