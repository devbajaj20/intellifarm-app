import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/crop_master.dart';
import '../services/api_service.dart';

class CropRecommendationDetailScreen extends StatefulWidget {
  final Map recommendation;
  final CropMaster crop;
  final String n, p, k, ph, soil, temperature, humidity, rainfall;

  const CropRecommendationDetailScreen({
    super.key,
    required this.recommendation,
    required this.crop,
    required this.n,
    required this.p,
    required this.k,
    required this.ph,
    required this.soil,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
  });

  @override
  State<CropRecommendationDetailScreen> createState() =>
      _CropRecommendationDetailScreenState();
}

class _CropRecommendationDetailScreenState
    extends State<CropRecommendationDetailScreen> {
  bool loading = true;
  bool saving = false;
  String? explanation;

  DateTime sowingDate = DateTime.now();
  final TextEditingController _locationController = TextEditingController();

  double sliderValue = 0;

  double get confidence =>
      widget.recommendation["confidence"].toDouble();

  @override
  void initState() {
    super.initState();
    _loadExplanation();
  }

  Future<void> _loadExplanation() async {
    final text = await ApiService.explainCrop(
      crop: widget.crop.name,
      soil: widget.soil,
      n: widget.n,
      p: widget.p,
      k: widget.k,
      ph: widget.ph,
      temperature: widget.temperature,
      humidity: widget.humidity,
      rainfall: widget.rainfall,
      confidence: confidence,
    );

    if (!mounted) return;
    setState(() {
      explanation = text;
      loading = false;
    });
  }

  // ─────────────────────────────
  // ADD TO DASHBOARD FLOW
  // ─────────────────────────────
  Future<void> _confirmAndSave() async {
    final location = await _askLocation();
    if (location == null) {
      setState(() => sliderValue = 0);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => saving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_crops')
        .add({
      'cropId': widget.crop.id, // 🔥 MUST MATCH ADMIN CROP ID
      'sowingDate': Timestamp.fromDate(sowingDate),
      'latitude': 0.0,
      'longitude': 0.0,
      'locationLabel': location,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pop(context, true); // 🔥 refresh dashboard
  }

  Future<String?> _askLocation() async {
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📍 Field Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Field / Location Name",
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: sowingDate,
                  firstDate:
                  DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => sowingDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Sowing Date",
                ),
                child: Text(
                  "${sowingDate.day}/${sowingDate.month}/${sowingDate.year}",
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_locationController.text.trim().isEmpty) return;
              Navigator.pop(context, _locationController.text.trim());
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Color confidenceColor(double c) {
    if (c >= 80) return Colors.green;
    if (c >= 60) return Colors.lightGreen;
    if (c >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _chip(String label, String value) {
    String formatted =
    value.isNotEmpty ? value[0].toUpperCase() + value.substring(1) : value;

    return Chip(
      label: Text("$label: $formatted"),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🍎 CROP NAME (APPLE STYLE)
              Text(
                widget.crop.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              /// CONFIDENCE
              Text(
                "${confidence.toStringAsFixed(1)}% confidence",
                style: TextStyle(
                  color: confidenceColor(confidence),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 28),

              /// PARAMETERS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _chip("N", widget.n),
                  _chip("P", widget.p),
                  _chip("K", widget.k),
                  _chip("pH", widget.ph),
                  _chip("Soil", widget.soil),
                  _chip("Temp", "${widget.temperature}°C"),
                  _chip("Humidity", "${widget.humidity}%"),
                  _chip("Rain", "${widget.rainfall}mm"),
                ],
              ),

              const SizedBox(height: 36),

              /// 🤖 AI EXPLANATION
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Why this crop?",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              if (loading)
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

              if (!loading && explanation != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.grey.shade100,
                  ),
                  child: Text(
                    explanation!,
                    style: const TextStyle(
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      /// 🔥 SLIDE TO ADD (PREMIUM)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF2E7D32),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  sliderValue >= 0.95
                      ? "Adding to Dashboard..."
                      : "Slide to add to My Dashboard",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Positioned(
                left: 6 + sliderValue * (MediaQuery.of(context).size.width - 120),
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      sliderValue += d.delta.dx / 260;
                      sliderValue = sliderValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (sliderValue > 0.95) {
                      _confirmAndSave();
                    } else {
                      setState(() => sliderValue = 0);
                    }
                  },
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 34,
                      color: Colors.green,
                    ),
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
