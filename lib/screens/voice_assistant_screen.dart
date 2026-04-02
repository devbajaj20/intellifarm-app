import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startListening();
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') _stopAndReturn();
      },
      onError: (_) => _stopAndReturn(),
    );

    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      listenMode: stt.ListenMode.search,
      partialResults: true,
      onSoundLevelChange: (level) {
        setState(() => _soundLevel = level.clamp(0, 20));
      },
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });

        if (result.finalResult) {
          _stopAndReturn();
        }
      },
    );
  }

  void _stopAndReturn() {
    if (!_isListening) return;
    _speech.stop();
    Navigator.pop(context, _spokenText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 🔥 PERFECT CENTERING
            children: [
              const Text(
                'Listening…',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              /// 🌊 MIC WAVE
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 120 + (_soundLevel * 4),
                    height: 120 + (_soundLevel * 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.25),
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 80 + (_soundLevel * 2),
                    height: 80 + (_soundLevel * 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.4),
                    ),
                  ),

                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.mic, size: 34, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              /// 🎤 SPOKEN TEXT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  _spokenText.isEmpty ? 'Speak now…' : _spokenText,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// ❌ CANCEL
              TextButton(
                onPressed: _stopAndReturn,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
