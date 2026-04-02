import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  /// SAVE LANGUAGE + GO TO DASHBOARD
  Future<void> _selectLanguage(
      BuildContext context,
      String languageCode,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'You can change this later in Settings',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 36),

              _langButton(context, 'English', 'en-IN'),
              _langButton(context, 'हिंदी', 'hi-IN'),
              _langButton(context, 'मराठी', 'mr-IN'),
              _langButton(context, 'தமிழ்', 'ta-IN'),
              _langButton(context, 'తెలుగు', 'te-IN'),
              _langButton(context, 'ଓଡ଼ିଆ', 'or-IN'),
            ],
          ),
        ),
      ),
    );
  }

  /// LANGUAGE BUTTON
  Widget _langButton(
      BuildContext context,
      String label,
      String code,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 54),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => _selectLanguage(context, code),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
