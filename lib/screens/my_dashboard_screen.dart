import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/live_weather_service.dart';
import '../utils/app_strings.dart';
import '../models/crop_master.dart';
import '../models/user_crop.dart';
import '../models/live_weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';


class MyDashboardScreen extends StatefulWidget {
  const MyDashboardScreen({super.key});

  @override
  State<MyDashboardScreen> createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen> {
  List<UserCrop> _userCrops = [];
  List<CropMaster> _availableCrops = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();


  bool _loadingLocation = true;
  bool _loadingWeather = true;
  bool _locationDenied = false;

  double? _lat;
  double? _lon;
  LiveWeather? _weather;
  String? _cityName;
  Timer? _weatherTimer;
  static const int _refreshMinutes = 10; // ⏱ refresh interval
  static const String _savedCityKey = 'last_city';
  static const String _savedModeKey = 'location_mode'; // auto | manual
  bool _manualMode = false; // false = GPS, true = Manual
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _restoreLastLocation();
    _loadAdminCrops().then((_) {
      _loadUserCrops();
    });
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    super.dispose();
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF121212),
      ),
    );
  }



  // ─────────────────────────────────────────────
// LOCATION + WEATHER
// ─────────────────────────────────────────────

  Color _stageColor(String stageName) {
    switch (stageName.toLowerCase()) {
      case 'germination':
        return Colors.blueGrey;
      case 'vegetative':
        return Colors.red;
      case 'flowering':
        return Colors.orange;
      case 'harvest':
        return Colors.yellowAccent;
      default:
        return Colors.white;
    }
  }

  void _openManualLocationDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("📍 Search Location"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter city name",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final city = controller.text.trim();
                  if (city.isEmpty) return;

                  Navigator.pop(context);
                  await _loadWeatherForCity(city);
                },
                child: const Text("Search"),
              ),
            ],
          ),
    );
  }

  Future<void> _loadWeatherForCity(String city) async {
    setState(() {
      _loadingWeather = true;
      _locationDenied = false;
    });

    final weather = await LiveWeatherService.fetchByCity(city);

    if (weather == null) {
      setState(() => _loadingWeather = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedCityKey, weather.city);
    await prefs.setString(_savedModeKey, 'manual');

    setState(() {
      _weather = weather;
      _cityName = weather.city;
      _loadingWeather = false;
      _lastUpdated = DateTime.now();
    });

    _startAutoRefresh(manual: true);
  }

  Future<void> _restoreLastLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final String? mode = prefs.getString(_savedModeKey);
    final String? city = prefs.getString(_savedCityKey);

    setState(() {
      _loadingLocation = true;
      _loadingWeather = true;
      _locationDenied = false;
    });

    // 🔁 MANUAL MODE (City-based)
    if (mode == 'manual' && city != null && city.isNotEmpty) {
      setState(() {
        _manualMode = true;
      });

      await _loadWeatherForCity(city);
      _startAutoRefresh(manual: true);

      return;
    }

    // 📍 AUTO GPS MODE (Default / fallback)
    setState(() {
      _manualMode = false;
    });

    await _initLocationAndWeather();
    _startAutoRefresh(manual: false);
  }

  void _startAutoRefresh({required bool manual}) {
    _weatherTimer?.cancel();

    _weatherTimer = Timer.periodic(
      Duration(minutes: _refreshMinutes),
          (_) {
        if (manual && _cityName != null) {
          _loadWeatherForCity(_cityName!);
        } else {
          _fetchLiveWeather();
        }
      },
    );
  }


  Future<void> _initLocationAndWeather() async {
    setState(() {
      _loadingLocation = true;
      _loadingWeather = true;
      _locationDenied = false;
    });

    final locationData = await LocationService.getCurrentLocation();

    if (locationData == null) {
      setState(() {
        _loadingLocation = false;
        _loadingWeather = false;
        _locationDenied = true;
      });
      return;
    }

    _lat = locationData.latitude;
    _lon = locationData.longitude;

    setState(() {
      _loadingLocation = false;
    });

    await _fetchLiveWeather();
  }

  Future<void> _saveUserCrop({
    required CropMaster crop,
    required DateTime sowingDate,
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError('User not logged in');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_crops')
        .add({
      'cropId': crop.id,
      'sowingDate': Timestamp.fromDate(sowingDate),
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _loadUserCrops() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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

      // 🔗 Find matching admin crop
      final CropMaster crop = _availableCrops.firstWhere(
            (c) => c.id == cropId,
        orElse: () {
          // Skip deleted / inactive admin crops safely
          return null as CropMaster;
        },
      );

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

    // 🔒 SAFETY CHECK (VERY IMPORTANT)
    if (!mounted) return;

    // Remove existing items
    for (int i = _userCrops.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
            (context, animation) => const SizedBox(),
      );
    }

    _userCrops.clear();

// Insert with animation
    for (int i = 0; i < loadedCrops.length; i++) {
      _userCrops.insert(i, loadedCrops[i]);
      _listKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 450),
      );
    }

  }

  Future<void> _fetchLiveWeather() async {
    if (_lat == null || _lon == null) return;

    final weather = await LiveWeatherService.fetch(_lat!, _lon!);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedModeKey, 'auto');
    await prefs.setString(_savedCityKey, weather?.city ?? '');

    setState(() {
      _weather = weather;
      _cityName = weather?.city;
      _loadingWeather = false;
      _lastUpdated = DateTime.now();
    });
  }

  Future<String?> _askLocationLabel() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Crop Location'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter field / village name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    controller.text
                        .trim()
                        .isEmpty
                        ? AppStrings.text('current_location')
                        : controller.text.trim(),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUserCrop(UserCrop crop) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🔹 Remove from UI immediately (Dismissible requirement)
    setState(() {
      _userCrops.removeWhere((c) => c.id == crop.id);
    });

    // 🔹 Delete from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_crops')
        .doc(crop.id)
        .delete();
  }


  // ─────────────────────────────────────────────
  // LOAD CROPS (ADMIN)
  // ─────────────────────────────────────────────
  Future<void> _loadAdminCrops() async {
    final snap = await FirebaseFirestore.instance
        .collection('crops')
        .where('isActive', isEqualTo: true)
        .get();

    if (!mounted) return;

    setState(() {
      _availableCrops =
          snap.docs.map((e) => CropMaster.fromDoc(e)).toList();
    });
  }


  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,


      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _spotifyStyleHeader(context),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Builder(
                  builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E) // dark card
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.6)
                                : Colors.black12,
                            blurRadius: isDark ? 8 : 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _modeButton(
                            title: "Auto GPS",
                            active: !_manualMode,
                            onTap: () async {
                              setState(() => _manualMode = false);
                              await _initLocationAndWeather();
                            },
                          ),
                          _modeButton(
                            title: "Search",
                            active: _manualMode,
                            onTap: () {
                              setState(() => _manualMode = true);
                              _openManualLocationDialog();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              _weatherSection(),

              const SizedBox(height: 12),

              _userCrops.isEmpty ? _emptyState() : _cropPager(),
            ],
          ),

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: _openAddCropSheet,
          icon: const Icon(Icons.add),
          label: const Text("Add Crop"),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WEATHER UI
  // ─────────────────────────────────────────────
  Widget _modeButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? Colors.green // ✅ active background
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,

                // 🔥 FIXED TEXT COLOR LOGIC
                color: active
                    ? Colors.white // always white on green
                    : isDark
                    ? Colors.white70 // inactive dark mode
                    : Colors.black54, // inactive light mode
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _weatherSection() {
    if (_loadingLocation || _loadingWeather) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),

      );
    }

    if (_locationDenied) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📍 Location permission required",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initLocationAndWeather,
              child: const Text("Enable Location"),
            ),
          ],
        ),

      );
    }

    if (_weather == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Weather unavailable"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_weather != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "📍 ${_weather!.city}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "⏱ Updated at ${_lastUpdated!.hour.toString().padLeft(2, '0')}:"
                    "${_lastUpdated!.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

          Row(
            children: [
              _weatherTile("🌡", "${_weather!.temperature}°C", "Temp"),
              _weatherTile("💧", "${_weather!.humidity}%", "Humidity"),
              _weatherTile("☀️", _weather!.condition, "Condition"),
            ],
          ),
        ],
      ),
    );
  }
  Widget _spotifyStyleHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 👤 Profile Avatar
          GestureDetector(
            onTap: () {
              // TODO: open profile
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade800,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🏷 Title
          Expanded(
            child: Text(
              AppStrings.text('my_dashboard'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // 🔔 Actions (Spotify style)
          _headerIcon(Icons.search, () {}),
          _headerIcon(Icons.notifications_none, () {}),
          _headerIcon(Icons.settings_outlined, () {}),
        ],
      ),
    );
  }
  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }

  Widget _weatherTile(String icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E1E) // dark card
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black12,
              blurRadius: isDark ? 8 : 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white60
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _emptyState() =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 72,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.text('add_your_crop'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Track growth, weather & stages",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );

  Widget _cropPager() {
    return ListView.builder(
      shrinkWrap: true, // 🔑 VERY IMPORTANT
      physics: const NeverScrollableScrollPhysics(), // 🔑
      itemCount: _userCrops.length,
      itemBuilder: (context, index) {
        final crop = _userCrops[index];

        return AnimatedSlide(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          offset: const Offset(0, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: 1,
            child: _animatedCropCard(crop),
          ),
        );
      },
    );
  }


  Widget _animatedCropCard(UserCrop crop) {
    return Dismissible(
      key: ValueKey(crop.id),
      direction: DismissDirection.endToStart,
      background: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ THIS FIXES YOUR CRASH
      onDismissed: (_) {
        _deleteUserCrop(crop);
      },

      child: _cropCard(crop),
    );
  }





  Widget _cropCard(UserCrop uc) {
    final int daysPassed =
    DateTime
        .now()
        .difference(uc.sowingDate)
        .inDays
        .clamp(
      0,
      uc.crop.totalDuration,
    );

    final int daysLeft =
    (uc.crop.totalDuration - daysPassed).clamp(0, uc.crop.totalDuration);

    final double progress =
    uc.crop.totalDuration == 0 ? 0 : daysPassed / uc.crop.totalDuration;

    final stage = uc.crop.getCurrentStage(daysPassed);
    final String stageName = stage?.name ?? 'vegetative';
    final Color progressColor = _stageColor(stageName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ───── HEADER ─────
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    uc.crop.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stage?.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// 📍 LOCATION
            Text(
              '📍 ${uc.locationLabel}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            /// ───── PROGRESS BAR ─────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),


            const SizedBox(height: 10),

            /// ───── FOOTER STATS ─────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem(
                  icon: Icons.timelapse,
                  label: 'Progress',
                  value: '${(progress * 100).toInt()}%',
                ),
                _statItem(
                  icon: Icons.schedule,
                  label: 'Days Left',
                  value: '$daysLeft',
                ),
                _statItem(
                  icon: Icons.event,
                  label: 'Sown',
                  value:
                  '${uc.sowingDate.day}/${uc.sowingDate.month}/${uc.sowingDate
                      .year}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }


  // ─────────────────────────────────────────────
  // ADD CROP
  // ─────────────────────────────────────────────
  void _openAddCropSheet() {
    CropMaster? selectedCrop;
    DateTime? sowingDate;
    final locationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ───── HEADER ─────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "🌱 Add Crop",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// 🌾 Crop
                      DropdownButtonFormField<CropMaster>(
                        value: selectedCrop,
                        isExpanded: true,
                        items: _availableCrops.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedCrop = v),
                        decoration: const InputDecoration(
                          labelText: "Crop",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// 📅 Sowing Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => sowingDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                sowingDate == null
                                    ? "Sowing Date"
                                    : "${sowingDate!.day}/${sowingDate!
                                    .month}/${sowingDate!.year}",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// 📍 Location Label
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: "Field / Location Name",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 💾 SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: selectedCrop != null &&
                              sowingDate != null &&
                              locationController.text
                                  .trim()
                                  .isNotEmpty &&
                              _lat != null &&
                              _lon != null
                              ? () async {
                            await _saveUserCrop(
                              crop: selectedCrop!,
                              sowingDate: sowingDate!,
                              latitude: _lat!,
                              longitude: _lon!,
                              locationLabel:
                              locationController.text.trim(),
                            );

                            await _loadUserCrops();

                            if (!mounted) return;

                            Navigator.pop(context);

                            _showSuccessAnimation();
                          }
                              : null,
                          child: const Text(
                            "Save Crop",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (_) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Crop Added Successfully',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // ⏳ Auto close
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.pop(context);
    });
  }
}