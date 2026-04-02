import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'utils/app_strings.dart';
import 'screens/splash_screen.dart';

import 'theme/theme_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await AppStrings.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IntelliFarm',

      // 🌞 Light theme
      theme: lightTheme,

      // 🌙 Dark theme
      darkTheme: darkTheme,

      // 🎚 Theme mode (from settings)
      themeMode:
      themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ✅ ALWAYS splash
      home: const SplashScreen(),
    );
  }
}
