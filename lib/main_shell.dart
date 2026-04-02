import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/screens/my_dashboard_screen.dart';
import '/screens/home.dart';
import '/screens/ai_chatbot_screen.dart';
import '/screens/more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showNavBar = true;

  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _screens = const [
    HomeScreen(),
    AiChatbotScreen(),
    MyDashboardScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_showNavBar) setState(() => _showNavBar = false);
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_showNavBar) setState(() => _showNavBar = true);
            }
          }
          return false;
        },
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),

      // 🎧 Floating Spotify-style Glass Nav
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        offset: _showNavBar ? Offset.zero : const Offset(0, 1),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home_outlined, 'Home', 0),
                      _navItem(Icons.people_alt_outlined, 'Connect', 1),
                      _navItem(Icons.insights, 'Insights', 2),
                      _navItem(Icons.menu_rounded, 'More', 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0, // 🔥 icon scale
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF1DB954)
                    : Colors.white70,
                shadows: isSelected
                    ? [
                  Shadow(
                    color: const Color(0xFF1DB954)
                        .withOpacity(0.8), // 🔥 glow
                    blurRadius: 12,
                  ),
                ]
                    : [],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF1DB954)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
