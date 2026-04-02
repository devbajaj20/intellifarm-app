import 'package:flutter/material.dart';
import '../models/user_crop.dart';

class UserCropCard extends StatelessWidget {
  final UserCrop crop;

  const UserCropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final uc = crop;

    final int daysPassed = DateTime.now()
        .difference(uc.sowingDate)
        .inDays
        .clamp(0, uc.crop.totalDuration);

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
                  '${uc.sowingDate.day}/${uc.sowingDate.month}/${uc.sowingDate.year}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS (UI ONLY)
  // ─────────────────────────────────────────────

  Color _stageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'germination':
        return Colors.lightGreenAccent;
      case 'vegetative':
        return Colors.green;
      case 'flowering':
        return Colors.orange;
      case 'harvesting':
        return Colors.brown;
      default:
        return Colors.green;
    }
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
}
