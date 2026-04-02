import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/crop_master.dart';
import 'package:flutter/rendering.dart';
import '../models/advisory_model.dart';
import 'advisory_floating_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_assistant_screen.dart';
import '../utils/app_strings.dart';
import 'crop_recommendation_screen.dart';
import 'disease_detection_screen.dart';
import 'yield_prediction_screen.dart';
import '../models/user_crop.dart';
import 'fertilizer_screen.dart';
import 'marketplace_screen.dart';
import 'weather_screen.dart';
import '../models/crop_master.dart';
import 'loans_screen.dart';
import 'ai_chatbot_screen.dart';
import 'dart:ui';
import '../widgets/user_crop_card.dart';


/// 🌿 GREEN GRADIENT
const LinearGradient kGreenGradient = LinearGradient(
  colors: [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF66BB6A),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedChip = 0;


  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0.0;

  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  void _openModule(String moduleKey) {
    Widget screen;

    switch (moduleKey) {
      case 'crop_recommendation':
        screen = CropRecommendationScreen(
          availableCrops: _availableCrops,
        );
        break;
      case 'disease_detection':
        screen = const DiseaseDetectionScreen();
        break;
      case 'yield_prediction':
        screen = const YieldPredictionScreen();
        break;
      case 'fertilizer':
        screen = const FertilizerScreen();
        break;
      case 'marketplace':
        screen = const MarketplaceScreen();
        break;
      case 'weather':
        screen = const WeatherScreen();
        break;
      case 'loans':
        screen = const LoansScreen();
        break;
      case 'ai_chatbot':
        screen = const AiChatbotScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  late Future<List<UserCrop>> _cropsFuture;

  final List<CropMaster> _availableCrops = [];


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSelectedChip();
    _cropsFuture = _loadUserCropsForDashboard();
  }
  Future<void> _loadSelectedChip() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedChip = prefs.getInt('dashboard_chip') ?? 0;
    });
  }

  Future<void> _loadAdminCrops() async {
    final snap = await FirebaseFirestore.instance
        .collection('crops')
        .where('isActive', isEqualTo: true)
        .get();

    _availableCrops
      ..clear()
      ..addAll(
        snap.docs.map((e) => CropMaster.fromDoc(e)),
      );
  }

  Future<List<UserCrop>> _loadUserCropsForDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Ensure admin crops are loaded
    if (_availableCrops.isEmpty) {
      await _loadAdminCrops();
    }

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_crops')
        .orderBy('createdAt', descending: true)
        .get();

    final List<UserCrop> loadedCrops = [];

    for (final doc in snap.docs) {
      final data = doc.data();
      final cropId = data['cropId'];

      CropMaster? crop;
      try {
        crop = _availableCrops.firstWhere((c) => c.id == cropId);
      } catch (_) {
        crop = null;
      }

      if (crop == null) continue;

      if (crop == null) continue;

      loadedCrops.add(
        UserCrop(
          id: doc.id,
          crop: crop,
          sowingDate: (data['sowingDate'] as Timestamp).toDate(),
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          locationLabel: data['locationLabel'] ?? '',
        ),
      );
    }

    return loadedCrops;
  }

  Future<void> _saveSelectedChip(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dashboard_chip', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      /// 🔝 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        titleSpacing: 12,

        title: Row(
          children: [
            // 👤 Avatar
            GestureDetector(
              onTap: () {
                // drawer later
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade800,
                child: const Icon(Icons.person, color: Colors.white, size: 17),
              ),
            ),

            const SizedBox(width: 12),

            // 🎧 HORIZONTAL SCROLLABLE CHIPS
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(), // Spotify feel
                child: Row(
                  children: [
                    _chip(const Text("Overview"), 0),
                    const SizedBox(width: 8),
                    _chip(const Text("Market"), 1),
                    const SizedBox(width: 7),
                    _chip(const Text("AI"), 2),
                    // future chips → just add more
                  ],
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),




      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _globalSearchBar(),
            const SizedBox(height: 16),
            _highlightAdvisorySlider(),
            const SizedBox(height: 16),
            FutureBuilder<List<UserCrop>>(
              future: _cropsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // 🔕 NO SPACE WHILE LOADING
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink(); // 🔕 NO SPACE WHEN EMPTY
                }

                return _myDashboardSection(snapshot.data!);
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only( bottom : 3.5, left: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Our Services",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _moduleGrid(),


          ],
        ),
      ),

    );
  }


  Widget _globalSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedGradientBorder(
        radius: 26,
        strokeWidth: 1.9,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 21,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 10),

              /// 🔍 SEARCH FIELD
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.text('search_hint'),
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white54
                          : Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              /// 🎙️ MIC BUTTON (MODERN)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const VoiceAssistantScreen(),
                    ),
                  );

                  if (!mounted) return;

                  if (result != null && result.trim().isNotEmpty) {
                    final fixed = _smartCorrect(result);

                    setState(() {
                      _searchCtrl.text = fixed;
                      _searchQuery = fixed.toLowerCase();
                    });
                  }
                },
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGreenGradient,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _chip(Widget child, int index) {
    final bool isActive = _selectedChip == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedChip = index;
        });
        await _saveSelectedChip(index);
      },
      child: AnimatedScale(
        scale: isActive ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 7.5,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1DB954)
                : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(22),
            border: isActive
                ? null
                : Border.all(color: Colors.white24, width: 1),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
            child: child, // ✅ YOUR WIDGET HERE
          ),
        ),
      ),
    );
  }


  /// ⭐ PAGEVIEW + DOTS (MAIN FEATURE)
  Widget _highlightAdvisorySlider() {
    return SizedBox(
      height: 210,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('advisories')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox();
          }

          final advisories = snapshot.data!.docs
              .map(
                (doc) => Advisory.fromJson(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
              .toList();

          return PageView.builder(
            controller: _pageController,
            itemCount: advisories.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _advisoryPage(
                advisories[index],
                advisories.length,
              );
            },
          );
        },
      ),
    );
  }


  /// 📰 SINGLE ADVISORY PAGE
  Widget _advisoryPage(Advisory advisory, int totalPages) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Advisory',
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, __, ___) {
            return Stack(
              children: [
                // 🌫 Background blur
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
                AdvisoryFloatingCard(advisory: advisory),
              ],
            );
          },
          transitionBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: curved,
                child: child,
              ),
            );
          },
        );
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          children: [
            /// 🖼 IMAGE (HERO)
            Hero(
              tag: advisory.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  advisory.image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🌑 GRADIENT OVERLAY
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            /// 🔴 CRITICAL BADGE
            if (advisory.isCritical)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.text('critical'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            /// 👉 READ BUTTON
            Positioned(
              right: 16,
              bottom: totalPages > 1 ? 48 : 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  gradient: kGreenGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  AppStrings.text('read'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            /// 🔘 DOT INDICATOR (ON IMAGE)
            if (totalPages > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                        (index) {
                      final isActive = _currentPage == index;

                      return TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: Colors.white.withOpacity(0.4),
                          end: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                        duration: const Duration(milliseconds: 250),
                        builder: (context, color, _) {
                          return Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 18 : 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _myDashboardSection(List<UserCrop> userCrops) {
    final visibleCrops = userCrops.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "My Crops",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 230,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pageWidth = constraints.maxWidth * 1.1; // 👈 Spotify-style width

              return PageView.builder(
                controller: PageController(viewportFraction: 1.1),
                itemCount: visibleCrops.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: pageWidth,
                    child: UserCropCard(crop: visibleCrops[index]),
                  );
                },
              );
            },
          ),
        ),

      ],
    );
  }


  /// 🧩 MODULE GRID
  Widget _moduleGrid() {
    final modules = [
      _Module('crop_recommendation', Icons.eco),
      _Module('disease_detection', Icons.bug_report),
      _Module('yield_prediction', Icons.trending_up),
      _Module('fertilizer', Icons.science),
      _Module('marketplace', Icons.storefront),
      _Module('weather', Icons.cloud),
      _Module('loans', Icons.account_balance),
      _Module('ai_chatbot', Icons.smart_toy),
    ];


    final filtered = modules.where((m) {
      return m.title.toLowerCase().contains(_searchQuery);
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, index) => _moduleCard(filtered[index]),
    );
  }


  /// 🧱 MODULE CARD
  Widget _moduleCard(_Module module) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedGradientBorder(
      radius: 18,
      strokeWidth: 1.6, // thinner = premium
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openModule(module.title),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: isDark ? 8 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGreenGradient,
                  ),
                  child: Icon(
                    module.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.text(module.title),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                    Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  Future<void> _listen() async {
    // 🎤 REQUEST MIC PERMISSION FIRST
    final micGranted = await Permission.microphone.request();
    if (!micGranted.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    // ▶️ START LISTENING
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');

          // 🛑 AUTO STOP WHEN ENGINE FINISHES
          if (status == 'done' && mounted) {
            setState(() {
              _isListening = false;
              _soundLevel = 0.0;
            });
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          if (mounted) {
            setState(() {
              _isListening = false;
              _soundLevel = 0.0;
            });
          }
        },
      );

      if (!available || !mounted) return;

      setState(() => _isListening = true);

      _speech.listen(
        listenMode: stt.ListenMode.search,
        partialResults: true,

        // 🎧 REAL-TIME VOICE WAVE
        onSoundLevelChange: (level) {
          if (!mounted) return;
          setState(() {
            _soundLevel = level.clamp(0.0, 20.0);
          });
        },

        // 📝 SPEECH RESULT
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _searchQuery = result.recognizedWords.toLowerCase();
            _searchCtrl.text = result.recognizedWords;
          });

          // 🛑 STOP ON FINAL RESULT
          if (result.finalResult) {
            _speech.stop();
            setState(() {
              _isListening = false;
              _soundLevel = 0.0;
            });
          }
        },
      );
    }

    // ⏹ STOP LISTENING MANUALLY
    else {
      _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    }
  }

  String _smartCorrect(String text) {
    final Map<String, String> corrections = {
      'rop': 'crop',
      'corp': 'crop',
      'krop': 'crop',
      'weater': 'weather',
      'wether': 'weather',
      'fertiliser': 'fertilizer',
      'desease': 'disease',
      'loan scheme': 'loans & schemes',
    };

    String fixed = text.toLowerCase();

    corrections.forEach((wrong, right) {
      fixed = fixed.replaceAll(wrong, right);
    });

    return fixed;
  }

  Widget _waveCircle(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.4),
      duration: Duration(milliseconds: 1200 + index * 400),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(
                0.25 - (index * 0.05),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (_isListening) {
          // keeps wave looping
        }
      },
    );
  }


  /// 🔽 BOTTOM NAV
}

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.radius = 18,
    this.strokeWidth = 1.6,
  });

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    print('🔥 AnimatedGradientBorder INIT');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: _GradientBorderPainter(
            progress: _controller.value,
            radius: widget.radius,
            strokeWidth: widget.strokeWidth,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: widget.child, // 👈 child defines the size
          ),
        );
      },
    );
  }


}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final eased = Curves.easeInOut.transform(progress);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        5.2,
      )
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF2E7D32).withOpacity(0.5),
          const Color(0xFF66BB6A).withOpacity(0.7),
          const Color(0xFF2E7D32).withOpacity(0.9),
        ],
        transform: GradientRotation(eased * 6.28318),
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



/// 📦 MODULE MODEL
class _Module {
  final String title;
  final IconData icon;
  _Module(this.title, this.icon);
}

