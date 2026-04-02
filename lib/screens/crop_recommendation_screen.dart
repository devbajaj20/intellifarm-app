import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'crop_recommendation_detail_screen.dart';
import '../models/crop_master.dart';



class CropRecommendationScreen extends StatefulWidget {
  final List<CropMaster> availableCrops;
  CropRecommendationScreen({super.key,
  required this.availableCrops,});


  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();

}

class _CropRecommendationScreenState
    extends State<CropRecommendationScreen>
    with TickerProviderStateMixin
{

  Color confidenceGlow(double confidence) {
    if (confidence >= 80) {
      return Colors.greenAccent;
    } else if (confidence >= 60) {
      return Colors.lightGreen;
    } else if (confidence >= 40) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  // 🌡 Environmental input controllers
  final TextEditingController _tempController =
  TextEditingController(text: "28");

  final TextEditingController _humidityController =
  TextEditingController(text: "75");

  final TextEditingController _rainfallController =
  TextEditingController(text: "180");

  Color confidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.greenAccent;
    } else if (confidence >= 60) {
      return Colors.lightGreen;
    } else if (confidence >= 40) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }


  bool loading = true;
  bool predicting = false;

  late List<String> categories;
  late List<String> nutrientLevels;
  late List<String> phLevels;
  late List<String> soilTypes;


  String category = "";
  String n = "medium";
  String p = "medium";
  String k = "medium";
  String ph = "neutral";
  String soil = "";

  List recommendations = [];

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // --------------------------------------------------
  // 🌾 CROP → ICON MAPPING (VERY IMPORTANT)
  // --------------------------------------------------
  IconData cropIcon(String crop) {
    switch (crop.toLowerCase()) {
      case "rice":
      case "wheat":
      case "barley":
      case "millet":
        return FontAwesomeIcons.wheatAwn;

      case "maize":
        return FontAwesomeIcons.leaf;

      case "banana":
        return FontAwesomeIcons.apple;

      case "apple":
        return FontAwesomeIcons.appleWhole;

      case "mango":
        return FontAwesomeIcons.leaf;

      case "cotton":
        return FontAwesomeIcons.seedling;

      case "sugarcane":
        return FontAwesomeIcons.glassWater;

      case "watermelon":
        return FontAwesomeIcons.water;

      default:
        return FontAwesomeIcons.tractor;
    }
  }

  @override
  void initState() {
    super.initState();

    // Fade animation (already exists)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);


    loadMetadata();
  }

  // --------------------------------------------------




  Future<void> loadMetadata() async {
    final meta = await ApiService.fetchMetadata();
    setState(() {
      categories = List<String>.from(meta["categories"]);
      nutrientLevels = List<String>.from(meta["nutrient_levels"]);
      phLevels = List<String>.from(meta["ph_levels"]);
      soilTypes = List<String>.from(meta["soil_types"]);
      category = categories.first;
      soil = soilTypes.first;
      loading = false;
    });
  }

  Future<void> getRecommendation() async {
    FocusScope.of(context).unfocus();

    if (_tempController.text.isEmpty ||
        _humidityController.text.isEmpty ||
        _rainfallController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all environmental parameters"),
        ),
      );
      return;
    }

    final temp = double.tryParse(_tempController.text);
    final hum = double.tryParse(_humidityController.text);
    final rain = double.tryParse(_rainfallController.text);

    if (temp == null || hum == null || rain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid numeric values"),
        ),
      );
      return;
    }

    setState(() {
      predicting = true;
      recommendations.clear();
    });

    final payload = {
      "category": category,
      "N": n,
      "P": p,
      "K": k,
      "temperature": temp,
      "humidity": hum,
      "ph": ph,
      "rainfall": rain,
      "soil_type": soil,
    };

    final res = await ApiService.recommendCrop(payload);

    setState(() {
      recommendations = res["recommendations"];
      predicting = false;
    });

    _controller.forward(from: 0);
  }


  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget skeletonBox({double height = 20}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget dropdown(
      String label,
      String value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e.toUpperCase()),
          ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // --------------------------------------------------
  // 📊 CONFIDENCE CHART
  // --------------------------------------------------
  Widget confidenceChart(List recs) {
    if (recs.isEmpty) return const SizedBox();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: 100,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) => Text(
                  "${value.toInt()}%",
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= recs.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      recs[i]["crop"]
                          .toString()
                          .substring(0, 3)
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(recs.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: recs[i]["confidence"].toDouble(),
                  width: 18,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      confidenceColor(recs[i]["confidence"].toDouble()).withOpacity(0.6),
                      confidenceColor(recs[i]["confidence"].toDouble()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }


  // --------------------------------------------------
  // ℹ️ LEGEND
  // --------------------------------------------------
  Widget legend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 6),
          Text("Suitable")
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 18),
          SizedBox(width: 6),
          Text("Conditionally Suitable")
        ]),
      ],
    );
  }

  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Crop Recommendation")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            skeletonBox(height: 24),
            skeletonBox(),
            skeletonBox(),
            skeletonBox(),
            skeletonBox(height: 50),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Crop Recommendation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          sectionTitle("Input Parameters"),

          dropdown("Crop Category", category, categories,
                  (v) => setState(() => category = v!)),
          dropdown("Nitrogen (N)", n, nutrientLevels,
                  (v) => setState(() => n = v!)),
          dropdown("Phosphorus (P)", p, nutrientLevels,
                  (v) => setState(() => p = v!)),
          dropdown("Potassium (K)", k, nutrientLevels,
                  (v) => setState(() => k = v!)),
          dropdown("Soil pH", ph, phLevels,
                  (v) => setState(() => ph = v!)),
          dropdown("Soil Type", soil, soilTypes,
                  (v) => setState(() => soil = v!)),
          sectionTitle("Environmental Parameters"),

          TextFormField(
            controller: _tempController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Temperature (°C)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.thermostat),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _humidityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Humidity (%)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.water_drop),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _rainfallController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Rainfall (mm)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.grain),
            ),
          ),


          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: predicting ? null : getRecommendation,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1B5E20)
                      : Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.greenAccent.withOpacity(0.4)
                          : Colors.green.shade900,
                      width: 1.2,
                    ),
                  ),
                ),
                child: predicting
                    ? const SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  "Get Recommendation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),

          ),

          if (recommendations.isNotEmpty) ...[
            sectionTitle("Confidence Comparison"),
            confidenceChart(recommendations),

            sectionTitle("Legend"),
            legend(),

            sectionTitle("Recommended Crops"),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: recommendations.map((r) {
                  final bool suitable = r["soil_status"] == "Suitable";
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: FaIcon(
                          cropIcon(r["crop"]),
                          key: ValueKey(r["crop"]),
                          color: confidenceColor(r["confidence"].toDouble()),
                          size: 28,
                        ),
                      ),

                      onTap: () async {
                        final crop = widget.availableCrops.firstWhere(
                              (c) => c.name.toLowerCase() == r["crop"].toLowerCase(),
                        );

                        final added = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CropRecommendationDetailScreen(
                              recommendation: r,
                              crop: crop,
                              n: n,
                              p: p,
                              k: k,
                              ph: ph,
                              soil: soil,
                              temperature: _tempController.text,
                              humidity: _humidityController.text,
                              rainfall: _rainfallController.text,
                            ),
                          ),
                        );

                        // 🔥 PASS RESULT BACK TO DASHBOARD
                        if (added == true && mounted) {
                          Navigator.pop(context, true);
                        }
                      },



                      title: Text(
                        r["crop"].toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Text(
                              "Confidence: ${r["confidence"]}%",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: confidenceColor(r["confidence"].toDouble()),
                              ),
                            ),
                          ),


                          const SizedBox(height: 6),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: r["confidence"] / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade800,
                              valueColor: AlwaysStoppedAnimation(
                                confidenceColor(r["confidence"].toDouble()),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Soil: ${r["soil_status"]}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      trailing: Icon(
                        suitable ? Icons.check_circle : Icons.info_outline,
                        color: suitable ? Colors.green : Colors.orange,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
