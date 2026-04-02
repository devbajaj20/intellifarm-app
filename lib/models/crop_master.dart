import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_stage.dart';

class CropMaster {
  final String id;
  final String name;
  final String category;
  final int totalDuration;
  final bool isActive;
  final List<CropStage> stages;

  CropMaster({
    required this.id,
    required this.name,
    required this.category,
    required this.totalDuration,
    required this.isActive,
    required this.stages,
  });

  /// 🔥 Factory from Firestore document
  factory CropMaster.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    return CropMaster(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      totalDuration: (data['totalDuration'] ?? 0) as int,
      isActive: (data['isActive'] ?? true) as bool,
      stages: (data['stages'] as List<dynamic>? ?? [])
          .map(
            (e) => CropStage.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList()
        ..sort((a, b) => a.startDay.compareTo(b.startDay)), // safety
    );
  }

  // ─────────────────────────────
  // FARMER-SIDE HELPERS
  // ─────────────────────────────

  /// Get current stage based on days passed
  CropStage? getCurrentStage(int daysPassed) {
    for (final stage in stages) {
      if (daysPassed >= stage.startDay &&
          daysPassed <= stage.endDay) {
        return stage;
      }
    }
    return null; // should never happen if validation rules are followed
  }

  /// Days left for the crop
  int getDaysLeft(int daysPassed) {
    final left = totalDuration - daysPassed;
    return left < 0 ? 0 : left;
  }

  /// Progress (0.0 – 1.0)
  double getProgress(int daysPassed) {
    if (totalDuration <= 0) return 0;
    return (daysPassed / totalDuration).clamp(0.0, 1.0);
  }
}
