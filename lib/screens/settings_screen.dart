import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_selection_screen.dart';
import '../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changeLanguage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_language');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LanguageSelectionScreen(),
      ),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🌙 DARK MODE TOGGLE
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Reduce eye strain at night'),
            value: themeController.isDarkMode,
            onChanged: (value) {
              context.read<ThemeController>().toggleTheme(value);
            },
          ),

          const Divider(height: 32),

          /// 🌐 CHANGE LANGUAGE
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _changeLanguage(context),
          ),
        ],
      ),
    );
  }
}
